{{/* SNMP Probe Default Rules file */}}
{{- define "probeSnmpRules-floodcontrol" }}
########################################################################
#
#       Licensed Materials - Property of IBM
#       
#       
#       
#       (C) Copyright IBM Corp. 2014,2019. All Rights Reserved
#       
#       US Government Users Restricted Rights - Use, duplication
#       or disclosure restricted by GSA ADP Schedule Contract
#       with IBM Corp.
#       
#       ========================================================
#       Module Information:
#       
#       DESCRIPTION:
#       mttrapd_flood_control.rules
#       This files provides rules for trap statistics analysis and flood control mechanism. 
#
#       Requirement: 
#           - TrapStat property is set to 1.
#
#######################################################################

#######################################################################
# Must do for customized rules file:
# ----------------------------------
#     Copy the arrays declaration to the top of main rules file, 
# then remove the # signs before the arrays.
#
# See the example in mttrapd.rules.
#######################################################################

######################################################################
## Copy DefaultOS definition to the main rules file                 ##
## Note:                                                            ##
##   (1) Calls to registertarget() must be placed at the start of   ##
##       rules.                                                     ##
##   (2) If details($*) is used in the rules, add "alerts.details"  ##
##       in registertarget() after "alerts.status".                 ##
######################################################################
##DefaultOS = registertarget(%Server, "", "alerts.status")

##################### Array Definitions <starts> ######################
#######################################################################
# Keep track of which hosts we've marked as flooded or not
# If the entry for an IP address is set to 0 then host is not being ignored
# If the entry for an IP address is set to >0 then the host is being ignored
#	(and the value is the UTC time at which we started ignoring it)
#
#######################################################################
##array OplTrapFloodHosts

#######################################################################
# A _tmp array which we use to keep the above array clear of re-enabled 
# entries (see below)
#######################################################################
##array OplTrapFloodHosts_tmp

#######################################################################
# Arrays to keep track of the number of dropped traps when the connection 
# was disabled
#######################################################################
##array OplTrapFloodHostsNosDroppedTraps
##array OplTrapFloodHostsNosDroppedTrapsTimestamp

##################### Array Definitions <ends> ########################

## Configuration
#
# Number of traps in the queue at which point we stop processing traps for this IP
$OplMttrapdQueueDropThreshold = 1000
# Interval (in seconds) between checks whether we should start to accept traps from IPs no longer flooding
$OplMttrapdBannedIPCheckInterval = 30
# Trap rate that isn't considered a flood. 3 traps/sec by default. Integer!
$OplMttrapdNonFloodRate = 3
# Report interval (in seconds)
$OplMttrapdReportInterval = 30

$now = getdate

# Only do this for real traps and not ProbeWatch
if( exists( $IPaddress ) ) {
	## Set up some vars
	# 
	# Need the IP address that this was received from
	$tf_ip = $IPaddress

	## check whether we need to start to drop the current host
	#
	# See how many traps there are in the queue for this IP
	$tmp = read_trap_count( $tf_ip )
	if( int($tmp) > int( $OplMttrapdQueueDropThreshold) ) {
		# We have more than our threshold, flag it as being dropped
		log( WARNING, "TRAP_FLOOD: IP=["+$tf_ip+"] has "+$tmp+" entries in the queue. Dropping and discarding." )
		discard
		# Tell the probe to drop entries from this IP address now
		$x = drop_list_add($tf_ip)
		# Mark entry as being dropped in our own array
		OplTrapFloodHosts[$tf_ip]=$now
		# Store the number of dropped traps for this IP and the current timestamp
		OplTrapFloodHostsNosDroppedTraps[$tf_ip]=read_drop_count( $tf_ip )
		OplTrapFloodHostsNosDroppedTrapsTimestamp[$tf_ip]=$now
		
		###################################################
		# Send probewatch to notify the IP is blocked now.
		###################################################
		$tf_manager = "ProbeWatch"
		$tf_node = hostname()
		$tf_alertkey = $tf_ip
		$tf_alertgroup = "Trap IP Status"
		$tf_severity = 5
		$tf_type = 1
		$tf_summary = $tf_ip + " is blocked"
		$tf_agent = @Agent
		$tf_summary = $tf_agent + " probe on " + $tf_node + ": " + $tf_summary
		$tf_identifier = $tf_node + " " + $tf_alertkey + " " + $tf_alertgroup + " " + $tf_type + " " + $tf_agent + " " + $tf_manager
		
		genevent(DefaultOS,
		          @Identifier, $tf_identifier,
		          @Summary, $tf_summary,
		          @Node, $tf_node,
		          @Manager, $tf_manager,
		          @Type, $tf_type,
		          @Severity, $tf_severity,
		          @FirstOccurrence, $now,
		          @LastOccurrence, $now,
		          @AlertGroup, $tf_alertgroup,
		          @AlertKey, $tf_alertkey,
		          @Agent, $tf_agent)
		  
		break	# Stop rules file processing right now
	}
}

# Every $OplMttrapdBannedIPCheckInterval seconds we check how long each IP has been banned for
$tf_lastcheck=OplTrapFloodHosts["tf lastcheck"]
if( match( $tf_lastcheck, "" ) || int($tf_lastcheck) <= ( int($now)-int($OplMttrapdBannedIPCheckInterval) ) ) {
	## Clear _tmp array
	#
	# The _tmp array is used to store just the banned IPs (and the last check placeholder)
	# when we loop through all of the entries to check whether we need to unban any of them
	clear( OplTrapFloodHosts_tmp )
	# Check each host entry in Hosts array
	foreach ( tf_host in OplTrapFloodHosts ) {
		if( nmatch( tf_host, "tf " ) ) {
			# Copy across any placeholder entries
			OplTrapFloodHosts_tmp[tf_host]=OplTrapFloodHosts[tf_host]
		} else {
			$tf_host_bantime=OplTrapFloodHosts[tf_host]

			# Get the number of traps dropped when the ban was stared
			$tf_nosdropped_then=OplTrapFloodHostsNosDroppedTraps[tf_host]
			$tf_nosdropped_then_timestamp=OplTrapFloodHostsNosDroppedTrapsTimestamp[tf_host]

			# Get the number of traps dropped now
			$tf_nosdropped_now=read_drop_count(tf_host)

			# Wait until the number of traps dropped has slowed for this host.
			# Wait for fewer than 5/second before re-enabling
			$tf_tdiff = int($now)-int($tf_nosdropped_then_timestamp)
			if( int( $tf_tdiff ) > 0 ) {
				$tf_nosdropped_since = int($tf_nosdropped_now)-int($tf_nosdropped_then)
				$rate = int( $tf_nosdropped_since ) / int( $tf_tdiff )
				if( int( $rate ) >= int( $OplMttrapdNonFloodRate ) ) {
					# Still sending too many, copy entry over to _tmp array
					log( WARNING, "TRAP_FLOOD: IP=["+tf_host+"] has sent ["+$tf_nosdropped_since+"] traps in the last ["+$tf_tdiff+"] seconds, rate = ["+$rate+"] so remains banned." )
					OplTrapFloodHosts_tmp[tf_host]=OplTrapFloodHosts[tf_host]
				} else {
					# Rate has dropped to under 3 a second, allow this host again
					log( WARNING, "TRAP_FLOOD: IP=["+tf_host+"] has only sent ["+$tf_nosdropped_since+"] traps in the last ["+$tf_tdiff+"] seconds, rate = ["+$rate+"] so is being allowed again." )
					$x = drop_list_remove(tf_host)
					# No need to copy entry to _tmp array
					
					###################################################
					# Send probewatch to notify the IP is unblocked.
					###################################################
					$tf_manager = "ProbeWatch"
					$tf_node = hostname()
					# Note: tf_host is an iterator, not $ sign prefix
					$tf_alertkey = tf_host
					$tf_alertgroup = "Trap IP Status"
					$tf_severity = 1
					$tf_type = 2
					$tf_summary = tf_host + " is unblocked"
					$tf_agent = @Agent
					$tf_summary = $tf_agent + " probe on " + $tf_node + ": " + $tf_summary
					$tf_identifier = $tf_node + " " + $tf_alertkey + " " + $tf_alertgroup + " " + $tf_type + " " + $tf_agent + " " + $tf_manager
					
					genevent(DefaultOS,
					         @Identifier, $tf_identifier,
					         @Summary, $tf_summary,
					         @Node, $tf_node,
					         @Manager, $tf_manager,
					         @Type, $tf_type,
					         @Severity, $tf_severity,
					         @FirstOccurrence, $now,
				           @LastOccurrence, $now,
				           @AlertGroup, $tf_alertgroup,
				           @AlertKey, $tf_alertkey,
				           @Agent, $tf_agent)
				}
			}

			# Update dropped traps array entries for this host
			OplTrapFloodHostsNosDroppedTraps[tf_host]=$tf_nosdropped_now
			OplTrapFloodHostsNosDroppedTrapsTimestamp[tf_host]=$now
		}
	}
	# Update timestamp of last check (do this in _tmp array)
	OplTrapFloodHosts_tmp["tf lastcheck"]=$now

	# Clear array and copy _tmp array across
	clear( OplTrapFloodHosts )
	foreach ( e in OplTrapFloodHosts_tmp ) {
		OplTrapFloodHosts[e]=OplTrapFloodHosts_tmp[e]
	}
	# Finally clear the _tmp array ready for text time
	clear( OplTrapFloodHosts_tmp )
}

## Report code
#
# Produce a report every $OplMttrapdReportInterval seconds
$tf_summary = ""
$tf_lastreport=OplTrapFloodHosts["tf lastreport"]
if( match( $tf_lastreport, "" ) || int($tf_lastreport) <= ( int($now)-int($OplMttrapdReportInterval) ) ) {
	# OK run a report
	$tf_inqueue = get_queue_size()
	log( WARNING, "TRAP_FLOOD_REPORT_START at "+$now+" with "+$tf_inqueue+" traps in the queue." )
	$tf_summary = $tf_summary + "TRAP_FLOOD_REPORT_START at "+$now+" with "+$tf_inqueue+" traps in the queue." + " "
	# Loop through each item that has ever been blocked:-
	foreach ( tf_host in OplTrapFloodHostsNosDroppedTraps ) {
		$tf_drop = read_drop_count(tf_host)
		$tf_inqueue = read_trap_count(tf_host)
		if( exists( OplTrapFloodHosts[tf_host] ) ) {
			# We're currently blocking it
			$tf_host_drop_timestamp=OplTrapFloodHosts[tf_host]
			$tf_since = int($now)-int($tf_host_drop_timestmap)
			log( WARNING, "TRAP_FLOOD_REPORT_HOST: ip=["+tf_host+"] status=[DROP] since "+$tf_since+" seconds. inqueue=["+$tf_inqueue+"] nosdrop=["+$tf_drop+"]" )
			$tf_summary = $tf_summary + "TRAP_FLOOD_REPORT_HOST: ip=["+tf_host+"] status=[DROP] since "+$tf_since+" seconds. inqueue=["+$tf_inqueue+"] nosdrop=["+$tf_drop+"]" + " "
		} else {
			# Not blocked currently, but has been in the past
			log( WARNING, "TRAP_FLOOD_REPORT_HOST: ip=["+tf_host+"] status=[ACCEPT] inqueue=["+$tf_inqueue+"] nosdrop=["+$tf_drop+"]" )
			$tf_summary = $tf_summary + "TRAP_FLOOD_REPORT_HOST: ip=["+tf_host+"] status=[ACCEPT] inqueue=["+$tf_inqueue+"] nosdrop=["+$tf_drop+"]" + " "
		}
	}
	log( WARNING, "TRAP_FLOOD_REPORT_END at "+$now )
	# Update last report time
	OplTrapFloodHosts["tf lastreport"]=$now
	
	$tf_manager = "ProbeWatch"
	$tf_alertgroup = "Trap Flood"
	$tf_alertkey = "Trap Flood"
	$tf_agent = @Agent
	$tf_identifier = "trap_flood_report " + " " + $tf_alertkey + " " + $tf_alertgroup + " " + $tf_agent + " " + $tf_manager

	genevent(DefaultOS,
	         @Identifier, $tf_identifier,
	         @Summary, $tf_summary,
           @Node, hostname(),
           @Manager, $tf_manager,
           @Type, 0,
           @Severity, 1,
           @FirstOccurrence, $now,
           @LastOccurrence, $now,
           @AlertGroup, $tf_alertgroup,
           @AlertKey, $tf_alertkey,
           @Agent, $tf_agent
         )
}
{{- end }}