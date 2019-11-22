{{/* Syslogd Probe Default Rules file */}}
{{- define "ibm-netcool-probe-syslogd-prod.probeSyslogdRules-main" }}
########################################################################
#
#       Licensed Materials - Property of IBM
#       
#       
#       
#       (C) Copyright IBM Corp. 2003, 2019. All Rights Reserved
#       
#       US Government Users Restricted Rights - Use, duplication
#       or disclosure restricted by GSA ADP Schedule Contract
#       with IBM Corp.
#       
#######################################################################
if( match( @Manager, "ProbeWatch" ) )
{
        switch(@Summary)
        {
        case "Running ...":
                @Severity = 1
                @AlertGroup = "probestat"
                @Type = 2
        case "Going Down ...":
                @Severity = 5
                @AlertGroup = "probestat"
                @Type = 1
        default:
                @Severity = 1
        }
        @AlertKey = @Agent
        @Summary = @Agent + " probe on " + @Node + ": " + @Summary
}
else
{
	@Class = 200

	if (exists($Token4))
	{
		@Identifier = "@" + $Token4 + " -> " + $Details
	}
	@Manager = %Manager
	@Summary = $Details
	@Node = $Token4
	@Severity = 1
	@Agent = $Token5


#
# This is the 'normal' catch for a syslog message, the following matches are
# used because its not possible to recognise where a message has come from
# without looking for more information in the alarm
#

	if(regmatch($Token5, "ASCEND.*"))
	{
		$agent = "Ascend"
	}
	else if(regmatch($Token5, "asxd:"))
	{
		$agent = "asxd"
	}
	else if(regmatch($Token5, "named.*"))
	{
		$agent = "named"
	}
	else if(regmatch($Token5, "^([a-zA-Z/\.]+)[^a-zA-Z].*"))
	{
		$agent = extract($Token5, "^([a-zA-Z/\.]+)[^a-zA-Z].*")
	}
	else if(nmatch($Details, "Action Request System"))
	{
		$agent = "ARS"
	}
	else if(regmatch($Token5, "[0-9]+:") AND regmatch($Token6, ".*-.*-.*:"))
	{
		$agent = "Cisco"
		@AlertKey = extract($Token5, "(.*):")
	}
	else if(regmatch($Token5, "--"))
	{
		$agent = "MARK"
		@Summary = "Syslog Marker"
	}
	else if(regmatch($Token6, "^%"))
	{
		$agent = "CiscoIP"
	}
	else if(regmatch($Token9, "^%"))
	{
		$agent = "Cisco"
	}
	else
	{
		$agent = $Token5
	}

#
# Here we temporarily set @Agent, for the above cases
#
	@Agent = $agent

#
# Once we know where an alarm has come from, we can set up the variables
# accordingly
#

	switch($agent)
	{
		case "unix":
			@Agent = "SVR4 kernel"
			if (nmatch($Details, "NFS"))
			{
				@AlertGroup = "NFS"
				if(regmatch($Details, ".*file system full"))
				{
					$host = extract($Details, ".* on host ([a-zA-Z0-9]+) .*")
					@AlertKey = $host
					@Summary = "file system full on " + $host
					@Severity = 5
					@Type = 1
				}
				else if(regmatch($Details, "NFS write error on host.*"))
				{
					$host = extract($Details, "NFS write error on host ([a-zA-Z0-9]+): .*")
					@AlertKey = $host
					@Severity = 4
					@Type = 1
				}
				else if(regmatch($Details, "NFS server [a-zA-Z0-9]+ [oO][kK]"))
				{
					$host = extract($Details, "NFS server ([a-zA-Z0-9]+) [oO][kK]")
					@AlertKey = $host
					@Severity = 1
					@Type = 2
				}
				else if(regmatch($Details, ".*not responding.*"))
				{
					@AlertKey = extract($Details, "NFS server ([^ ]+) not responding.*")
					@Type = 1
					@Severity = 4
				}
			
			}
			else if(regmatch($Details, "NOTICE:.*file system full"))
			{
				@AlertKey = extract($Details, "[A-Z]+: [^ ]+ (/[^ ]+)[|:] file system full")
				@Severity = 5
			}
			else if (nmatch($Details, "mem"))
			{
				# Sun specific
				$mem = extract($Details, "^mem = ([0-9]+K).*")
				@Summary = @Node + " has " + $mem + " of memory"
				@AlertKey = "mem " + $mem
				@Severity = 2
			}
			else if (nmatch($Details, "Ethernet address"))
			{
				#$mac = extract($Details, "Ethernet address = ([0-9][a-f]{1,2}:[0-9][a-f]{1,2}:[0-9][a-f]{1,2}:[0-9][a-f]{1,2}:[0-9][a-f]{1,2}:[0-9][a-f]{1,2})")
				#@AlertKey = $mac
				@AlertKey = $Token9
				@Summary = @Node + ": MAC Address " + $Token9
				@Severity = 2
			}
			else if( nmatch($Details, "dump on /"))
			{
				$device = extract($Details, "dump on ([^ ]+).*")
				$size = extract($Details, "dump on /[^ ]+ size ([0-9]+)K")
				@Summary = @Node + " has " + $size + "K of swap"
				@AlertKey = $size
				@Severity = 2
			}
			else if (regmatch($Details, ".*[cC]opyright \(c\) [0-9]+-[0-9]+ Sun Microsystems Inc\..*")) {
				discard
			}
			else if (regmatch($Details, ".*SunOS Release [0-9].[0-9].[0-9].*")) {
				discard
			} else {
				@Severity = 1
				@Summary = $Details
			}

		case "vmunix":
			@Agent = "BSD kernel"
			@Grade = 1
			if (nmatch($Details, "NFS"))
			{
				@AlertGroup = "NFS"
				if(regmatch($Details, ".*file system full"))
				{
					$host = extract($Details, ".* on host ([a-zA-Z0-9]+) .*")
					@Summary = "file system full on " + $host
					@Severity = 5
					@Type = 1
				}
				else if(nmatch($Details, "NFS write error"))
				{
					@Severity = 3
					@AlertKey = extract($Details, "NFS write error [0-9]+ on host ([^ ]+) .*")
					@Type = 1
					@Identifier = $AlertGroup + $Agent + $Token4 + "NFS write error"
					@Summary = "NFS write error on " + @AlertKey
				}
				else if(regmatch($Details, ".*not responding.*"))
				{
					@AlertKey = extract($Details, "NFS server ([^ ]+) not responding.*")
					@Type = 1
					@Severity = 5
				}
				else if(regmatch($Details, "NFS server.*ok"))
				{
					@AlertKey = extract($Details, "NFS server ([^ ]+) ok")
					@Type = 2
				}
			}
			else if (nmatch($Details, "mem"))
			{
				# Sun specific
				$mem = extract($Details, "^mem = ([0-9]+K).*")
				@Summary = @Node + " has " + $mem + " of memory"
				@AlertKey = "mem " + $mem
				@Severity = 2
			}
			else if (regmatch($Details, "Physical: ([0-9]+) Kbytes.*"))
			{
				# HP specific
				$mem = extract($Details, "Physical: ([0-9]+) Kbytes.*")
				@Summary = @Node + " has " + $mem + "K of Memory"
				@AlertKey = "mem " + $mem
				@Severity = 2
			}
			else if (nmatch($Details, "Ethernet address"))
			{
				#$mac = extract($Details, "Ethernet address = ([0-9][a-f]{1,2}:[0-9][a-f]{1,2}:[0-9][a-f]{1,2}:[0-9][a-f]{1,2}:[0-9][a-f]{1,2}:[0-9][a-f]{1,2})")
				#@AlertKey = $mac
				@AlertKey = $Token9
				@Summary = @Node + ": MAC Address " + $Token9
				@Severity = 2
			}
			else if (regmatch($Details, ".*[cC]opyright \(c\) [0-9]+-[0-9]+ Sun Microsystems Inc\..*")) {
				discard
			}
			else if (regmatch($Details, ".*SunOS Release [0-9].[0-9].[0-9].*")) {
				discard
			}
			else
			{
				@Summary = $Details
				@Severity = 1
			}
			
		case "sendmail":
			@Agent = "MTA"
			if(nmatch($Details, "alias database rebuilt by"))
			{
				@Severity = 2
			}
			if(nmatch($Details, "alias database out of date"))
			{
				@Severity = 1
			}
			else if(regmatch($Details, ".*Permission denied"))
			{
				@Severity = 4
			}
			else if(regmatch($Details, ".*SYSERR\([a-zA-Z0-9]+\): .*")) {
				@AlertKey = extract($Details, ".*SYSERR\(([a-zA-Z0-9]+)\): .*")
				@Summary = extract($Details, ".*SYSERR\([a-zA-Z0-9]+\): (.*)")
				@Severity = 3
			}
			else if(regmatch($Details, ".*MX list for .* points back to .*"))
			{
				@Summary = extract($Details, "[A-Z0-9]+: (.*)")
				@Identifier = "@" + $Token4 + " -> " + @Summary
			}
			else
			{
				@Summary = $Details
				@Severity = 1
			}

		case "popper":
			@Agent = $agent
			if(regmatch($Details, "^connect from.*"))
			{
				@Severity = 1
				@AlertKey = extract($Details, "^connect from (.*)")
			}
			else if(regmatch($Details, "^refused connect from.*"))
			{
				@Severity = 4
				@AlertKey = extract($Details, "^refused connect from (.*)")
			}

		case "in.comsat":
			@Agent = "biff"
			if(regmatch($Details, "^connect from.*"))
			{
				@Severity = 1
				@AlertKey = extract($Details, "^connect from (.*)")
			}
			else if(regmatch($Details, "^refused connect from.*"))
			{
				@Severity = 4
				@AlertKey = extract($Details, "^refused connect from (.*)")
			}
		case "procmail":
			@Agent = $agent

		case "named":
			@Agent = "DNS"
			if (regmatch($Details, ".* Masters .* unreachable"))
			{
				$whichz = extract($Details, ".* for ([a-z]+) .*")
				$zone = extract($Details, ".*zone ([a-z\.]+) .*")
				@AlertKey = $whichz + $zone
				@Severity = 2
			}
			else if (regmatch($Details, ".*Err.*"))
			{
				@Severity = 5
				if(exists($Token15))
				{
					@AlertKey = $Token15
				}
			}
			else if (regmatch($Details, ".*unexpected.*"))
			{
				@Severity = 3
				if(exists($Token10))
				{
					@AlertKey = $Token10
				}
			}
			else if (regmatch($Details, ".*bad referral.*"))
			{
				@Severity = 4
				if(exists($Token8))
				{
					@AlertKey = $Token8
				}
			}
			else if (regmatch($Details, "^dangling.*") || regmatch($Details, "^Malformed.*") || regmatch($Details, "^unapproved.*"))
			{
				@Severity = 4
				if(exists($Token9))
				{
					@AlertKey = $Token9
				}
			}
				
		case "syslogd":
			@Agent = $agent
			if(regmatch($Details, "Bad terminal owner.*"))
			{
				@AlertKey = extract($Details, "Bad terminal owner.*owns /dev/([a-zA-Z0-9]+) but utmp says.*")
				@Severity = 1
			}
			else if(nmatch($Details, "going down on signal"))
			{
				@Severity = 4
				@Type = 1
			}

		case "syslog":
			if(match($Details, "Syslogd has been restarted")){
				@Severity = 2
				@Type = 2
			}

		case "reboot":
			@Severity = 5
			@Type = 1
			@AlertKey = extract($Details, ".*by ([a-z]+)$")

		case "automount":
			@Agent = $agent
			if(regmatch($Details, "host.*not responding"))
			{
				@AlertKey = extract($Details, "host ([^ ]+) not responding")
				@Severity = 4
				@Type = 1
			}

		case "automountd":
			if(regmatch($Details, "^server ([^ ]+) not responding")){
				@Severity = 4
				@Type = 1
				@AlertKey = extract($Details, "server ([^ ]+) not responding")
			}

		case "su":
			@Agent = $agent
			@AlertGroup = "security"
			if(regmatch($Details, "^.*su.*succeeded.*"))
			{
				$to = extract ($Details, "[a-z]+ ([a-zA-Z0-9]+) .*")
				$from = extract ($Details, ".*succeeded for ([a-zA-Z0-9]+) on.*")
				@AlertKey = $from + "->" +$to
				@Severity = 4
			}
			else if (regmatch($Details, "^.*su.*failed.*"))
			{
				$to = extract ($Details, "[a-z]+ ([a-zA-Z0-9]+) .*")
				$from = extract ($Details, ".*failed for ([a-zA-Z0-9]+).*")
				@AlertKey = $from + "->" +$to
				@Severity = 5
			}

		case "login":
			@Agent = $agent
			@AlertGroup = "security"
			if (nmatch($Details, "ROOT LOGIN REFUSED"))
			{
				$from = extract($Details, ".* FROM ([a-zA-Z0-9]+).*")
				@AlertKey = $from
				@Severity = 5
			}
			else if(regmatch($Details, "REPEATED LOGIN FAILURES ON .* FROM .*"))
			{
				@Severity = 4
				@AlertKey = extract($Details, "REPEATED LOGIN FAILURES ON [^ ]+ FROM (.*)")
			}
			else if(regmatch($Details, "REPEATED LOGIN FAILURES ON [^ ]+ [^ ]+"))
			{
				@Severity = 4
				@AlertKey = extract($Details, "REPEATED LOGIN FAILURES ON ([^ ]+) .*")
			}
			else
			{
				@Severity = 3
			}
		case "nnrpd":
			@Agent = "news"
		case "innd":
			@Agent = "news"
			if(regmatch($Details,".*No such file or directory.*"))
			{
				@Severity = 1
			}
		case "rnews":
			@Agent = "news"
			if(regmatch($Details, ".*Connection refused"))
			{
				@Severity = 2
			}
		case "getty":
			@Agent = "BSD getty"
			@AlertKey = extract($Details, "^(/dev/[a-zA-Z0-9]+): .*")
		case "inetd":
			@Agent = "inetd"
			if (regmatch($Details, ".* identity .*"))
			{
				$remotehost = extract($Details, "identity server at (.*)")
				@AlertKey = "ident " + $remotehost
				@Severity = 2
			}
			else if(nmatch($Details, "unknown RPC service"))
			{
				@AlertKey = extract($Details, "unknown RPC service: ([0-9]+).*")
			}
			else if(nmatch($Details, "USERID:"))
			{
				@AlertKey = extract($Details, ".*UNIX : (.*)")
			}
			else if(nmatch($Details, "START: pop3"))
			{
				@Agent = "pop3"
				@NodeAlias = extract($Details, ".*from=([^ ]+).*")
				@AlertKey = extract($Details, ".*pid=([0-9]+) .*")
				@Type = 1
#
# we treat pop3 Start as a generic down, so that we can correlate
# the pop3 session close in the next rule
#
			}
			else if(nmatch($Details, "EXIT: pop3"))
			{
				@Agent = "pop3"
				@AlertKey = extract($Details, ".*pid=([0-9]+) duration.*")
				@Type = 2
			}
			else if(nmatch($Details, "START: comsat")){
				@Agent = "comsat"
			}
			else if(nmatch($Details, "EXIT: comsat")){
				@Agent = "comsat"
			}
				
		case "ftpd":
			@Agent = "ftpd"
			if (regmatch($Details, ".*repeated login failures.*"))
			{
				$from = extract($Details, "^.*repeated login failures from (.*)$")
				@AlertKey = $from
				@AlertGroup = "security"
				@Summary = "ftp: repeated login failures from " + $from
				@Severity = 5
			}
			else if (regmatch($Details, ".*[l|L]ogin incorrect.*"))
			{
				@AlertGroup = "security"
				@Summary = "ftp: login failure"
				@Severity = 4
			}
			else if (regmatch($Details, "^FTP LOGIN REFUSED.* not in /etc/passwd.*"))
			{
				$from = extract ($Details, "^FTP LOGIN REFUSED .* FROM (.*) \[.*")
				@AlertKey = $from
				@AlertGroup = "security"
				$as = extract($Details, ".*] (.*)$")
				@Summary = "FTP refused from user " + $as + ", from " + $from
				@Severity = 5
			}
			else if(nmatch($Details, "FTP LOGIN FROM"))
			{
				$from = extract($Details, "FTP LOGIN FROM ([^ ]+) .*")
				@AlertKey = $from
				@AlertGroup = "security"
				#$as = extract($Details, ".*, ([a-zA-Z0-9]+)")
				$as = extract($Details, ".* ([a-z]+)")
				@Summary = "ftp: login from " + $from + ", as " + $as
				@Severity = 2
			} else {
				@Severity = 2
			}

		case "nettl":
			@Agent = $agent
			if(nmatch($Details, "starting"))
			{
				@Summary = "network tracing and logging starting"
			}

		case "automount":
			@Agent = $agent
			if(regmatch($Details, "[a-zA-Z0-9]+:/.*: server not responding.*"))
			{
				@AlertKey = extract($Details, "^([^ ]+) .*")
			}

		case "ARS":
			if(regmatch($Details, ".*server does not have a license for production use.*"))
			{
				@Summary = "Your AR system does not have a permanent license key"
			}

		case "Cisco":
			@Agent = "Cisco"
			@Summary = extract($Details, "%(.*)")
			if (regmatch(@Summary, ".*LINEPROTO.*down.*"))
			{
				@Severity = 4
				@Type = 1
				@AlertKey = extract($Details, ".*Interface ([^ ]+).*")
			}
			else if (regmatch(@Summary, ".*LINK.*down.*"))
			{
				@Severity = 4
				@Type = 1
				@AlertKey = extract($Details, ".*Interface ([^ ]+).*")
			}
			else if (regmatch(@Summary, ".*LINEPROTO.*up"))
			{
				@Severity = 1
				@Type = 2
				@AlertKey = extract($Details, ".*Interface ([^ ]+).*")
			}
			else if (regmatch(@Summary, ".*LANE.*up.*"))
			{
				@Severity = 1
				@Type = 2
				@AlertKey = extract($Details, ".* ([a-z0-9_]+): [A-Z]+.*")
			}
			else if (regmatch(@Summary, ".*LANE.*down.*"))
			{
				@Severity = 4
				@Type = 1
				@AlertKey = extract($Details, ".* ([a-z0-9_]+): [A-Z]+.*")
			}
			else if (regmatch(@Summary, ".*LINK.*up"))
			{
				@Severity = 1
				@Type = 2
				@AlertKey = extract($Details, ".*Interface ([^ ]+).*")
			}
			else if (regmatch(@Summary, ".*CONFIG.*"))
			{
				@Severity = 1
				@AlertKey = extract($Details, ".*\(([0-9\.]+)")
			}
			else if (regmatch(@Summary, ".*COLL.*"))
			{
				@Severity = 1
				if(exists($Token11))
				{
					@AlertKey = $Token10 + $Token11
				}
			}
			else if(regmatch(@Summary, ".*DLCICHANGE.*"))
			{
				@Severity = 1
				@AlertKey = extract($Details, ".*Interface ([^ ]+).*")
			}
			else if(regmatch(@Summary, "^ALIGN.*"))
			{
				@Severity = 1
				@AlertKey = extract($Details, ".*made at ([0-9A-Fx]+).*")
			}
			else if(regmatch(@Summary, ".*SYS.*"))
			{
				@Severity = 2
				@AlertKey = extract($Details, ".*([0-9\.]+)\)$")
			}
			
			@Identifier = "@" + $Token4 + " -> " + @AlertKey + @Summary

		case "CiscoIP":
			@Agent = "Cisco"
			@Summary = extract($Details, "(%.*)")
			if (regmatch(@Summary, ".*LINEPROTO.*down.*"))
			{
				@Severity = 4
				@Type = 1
				if(exists($Token11))
				{
					@AlertKey = $Token11
				}
			}
			else if (regmatch(@Summary, ".*LANE.*down.*"))
			{
				@Severity = 4
				@Type = 1
				if(exists($Token9))
				{
					@AlertKey = $Token9
				}
			}
			else if (regmatch(@Summary, ".*LINK.*down.*"))
			{
				@Severity = 4
				@Type = 1
				if(exists($Token8))
				{
					@AlertKey = $Token8
				}
			}
			else if (regmatch(@Summary, ".*LINEPROTO.*up"))
			{
				@Severity = 1
				@Type = 2
				if(exists($Token11))
				{
					@AlertKey = $Token11
				}
			}
			else if (regmatch(@Summary, ".*LANE.*up.*"))
			{
				@Severity = 1
				@Type = 2
				if(exists($Token9))
				{
					@AlertKey = $Token9
				}
			}
			else if (regmatch(@Summary, ".*LINK.*up"))
			{
				@Severity = 1
				@Type = 2
				if(exists($Token8))
				{
					@AlertKey = $Token8
				}
			}
			else if (regmatch(@Summary, ".*CONFIG.*"))
			{
				@Severity = 1
				if(exists($Token15))
				{
					@AlertKey = $Token15
				}
			}
			else if (regmatch(@Summary, ".*COUNTER.*"))
			{
				@Severity = 1
				if(exists($Token11))
				{
					@AlertKey = $Token11
				}
			}
			else if (regmatch(@Summary, ".*COLL.*"))
			{
				@Severity = 1
				if(exists($Token8))
				{
					@AlertKey = $Token7 + $Token8
				}
			}

		case "Ascend":
			@Agent = $agent
			@Summary = extract($Details, "(.*)")

			if (regmatch(@Summary, ".*LAN.*down.*"))
			{
				@Severity = 5
				@Type = 1
				@NodeAlias = extract(@Summary, ".* session down (.*)")
			}
			else if (regmatch(@Summary, ".*LAN.*up.*"))
			{
				@Severity = 1
				@Type = 2
				@NodeAlias = extract(@Summary, ".* session up (.*)")
			}
			else if (regmatch(@Summary, ".*Call Terminated.*"))
			{
				@Severity = 2
			}
			else if (regmatch(@Summary, ".*Call Connected.*"))
			{
				@NodeAlias = extract(@Summary, ".* Call Connected (.*)")
			}
			else if (regmatch(@Summary, ".*Incoming Call.*"))
			{
				@NodeAlias = extract(@Summary, ".* Incoming Call (.*)")
			}

			#
			# Now that the alarm has been identified, extract 
			# slot, call, port, line for use in the AlertKey
			#

			if(match($Token6, "slot"))
			{
				@AlertKey = $Token7 + " " + $Token9
				if(match($Token10, "line"))
				{
					@AlertKey = @AlertKey + " " + $Token11
				}
			}
			else if(match($Token6, "call"))
			{
				@AlertKey = $Token7
				if(match($Token9, "slot"))
				{
					@AlertKey = @AlertKey + " " + $Token10 + " " + $Token12
				}
			}

		case "asxd":
			@Agent = $agent
			@Summary = extract($Details, "(.*)")

			switch($Token6)
			{
				case "debug:":
					@Severity = 1
				case "INFO:":
					@Severity = 2
				case "NOTICE:":
					@Severity = 3
				case "WARNING:":
					@Severity = 4
				default:
					@Severity = 4
			}
			
			if (regmatch(@Summary, ".*NOTICE.*SONET.*asserted.*"))
			{
				@Severity = 5
				if(exists($Token7))
				{
					@AlertKey = $Token7
				}
			}
			else if (regmatch(@Summary, ".*NOTICE.*DS3.*asserted.*"))
			{
				@Severity = 5
				if(exists($Token7))
				{
					@AlertKey = $Token7
				}
			}
			else if (regmatch(@Summary, ".*WARNING.*err.*"))
			{
				@Severity = 3
				if(exists($Token8))
				{
					@AlertKey = $Token8
				}
			}
			else if (regmatch(@Summary, ".*NOTICE.*SONET.*cleared.*"))
			{
				@Severity = 1
				if(exists($Token7))
				{
					@AlertKey = $Token7
				}
			}
			else if (regmatch(@Summary, ".*NOTICE.*DS3.*cleared.*"))
			{
				@Severity = 1
				if(exists($Token7))
				{
					@AlertKey = $Token7
				}
			}
			else if (regmatch(@Summary, ".*TRANSITION data_transfer_ready.*"))
			{
				@Severity = 5
				if(exists($Token7))
				{
					@AlertKey = $Token7
				}
			}
			else if (regmatch(@Summary, ".*TRANSITION.*to data_transfer_ready.*"))
			{
				@Severity = 1
				if(exists($Token7))
				{
					@AlertKey = $Token7
				}
			}
			else if (regmatch(@Summary, ".*INFO.*"))
			{
				@Severity = 1
				if(exists($Token7))
				{
					@AlertKey = $Token7
				}
			}

		case "NameD":
			@Agent = $agent
			@Summary = extract($Details, "(.*)")

			if (regmatch(@Summary, ".*Err.*"))
			{
				if(exists($Token15))
				{
					@AlertKey = $Token15
				}
			}
			else if (regmatch(@Summary, ".*unexpected.*"))
			{
				@Severity = 3
				if(exists($Token10))
				{
					@AlertKey = $Token10
				}
			}
			else if (regmatch(@Summary, ".*bad referral.*"))
			{
				@Severity = 4
				if(exists($Token8))
				{
					@AlertKey = $Token8
				}
			}
			else if (regmatch(@Summary, "^dangling.*") || regmatch(@Summary, "^Malformed.*") || regmatch(@Summary, "^unapproved.*"))
			{
				@Severity = 4
				if(exists($Token9))
				{
					@AlertKey = $Token9
				}
			}

		case "lpd":
			if(nmatch($Details, "unknown printer"))
			{
				@AlertKey = extract($Details, "unknown printer (.*)")
			}
		
		case "printer":
			if(nmatch($Details, "paper out"))
			{
				@Severity = 4
				@Type = 1
			}
			else if(regmatch($Details, ".*intervention required"))
			{
				@Severity = 4
				@Type = 1
			}
			else if(nmatch($Details, "error cleared"))
			{
				@Severity = 1
				@Type = 2
			}
			else if(nmatch($Details, "paper out"))
			{
				@Severity = 4
				@Type = 1
			}
			else if(nmatch($Details, "paper jam"))
			{
				@Severity = 4
				@Type = 1
			}
			else if(nmatch($Details, "cover/door open"))
			{
				@Severity = 3
				@Type = 1
			}
			else if(nmatch($Details, "offline"))
			{
				@Severity = 4
				@Type = 1
			}
			
		case "xntpd":
			if(nmatch($Details, "synchronized to"))
			{
				@Severity = 1
				@AlertKey = extract($Details, "synchronized to ([0-9\.]+) .*")
			}

		case "MARK":
			@Severity = 2
			@Summary = "syslogd alive on " + @Node
		
		case "SKY":
			@AlertGroup = "nco_pad"
			if(match($Token8, "ALERT_MSG")){
				@Severity = 5
				@Type = 2
			} else if(match($Token8, "RESTORE_MSG")){
				@Severity = 1
				@Type = 1
			}
			if(regmatch($details, ".* [^ ]+$")){
				@AlertKey = extract($Details, ".* ([^ ]+)$")
			}

		case "sshd":
			@Severity = 1
			if(nmatch($Details, "fatal:")){
				@Severity = 4
			}
			if(regmatch($Details, ".*Connection from ([0-9\.]+) .*")){
				@AlertKey = extract($Details, ".*Connection from ([0-9\.]+) .*")
			}

		case "in.telnetd":
			@Severity = 1
			if(regmatch($Details, "connect from .*")){
				@AlertKey = extract($Details, "connect from (.*)")
			}

		case "ypbind":
			if(regmatch($Details, "NIS server not responding for domain .*"))
			{
				@AlertGroup = "NIS"
				@AlertKey = extract($Details, "NIS server not responding for domain ([^ ]+) .*")
				@Severity = 4
				@Type = 1
			}
			else if(regmatch($Details, "NIS server for domain .* [oO][kK]"))
			{
				@AlertGroup = "NIS"
				@AlertKey = extract($Details, "NIS server for domain ([^ ]+) [oO][kK]")
				@Type = 2
				@Severity = 1
}
		case "yppasswdd":
			@Severity = 5
			@AlertGroup = "security"

		default:
			if(nmatch($Details, "message repeated"))
			{
				discard
			} else if(regmatch($Details, "[0-9]+ [0-9]+:[0-9]+:[0-9]+")) {
				discard
			} else {
#
# Uncomment the next line to get more debug information for any unmatched events
#
#				details($*)
#
			}
	}

	@FirstOccurrence = $Time
	@LastOccurrence = $Time

    @ExtendedAttr = nvp_add($*)
    # Add custom rules below
}
log( DEBUG, "---- Exitting syslogd.rules ----" )
{{- end }}