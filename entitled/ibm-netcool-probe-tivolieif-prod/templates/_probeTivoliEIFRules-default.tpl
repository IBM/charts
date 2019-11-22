{{/* Tivoli EIF Probe Default Rules file */}}
{{- define "probeTivoliEIFRules-default" }}
# ----------------------------------------------------------------
# 
#       Licensed Materials - Property of IBM
#
#       5725-Q09
#
#       (C) Copyright IBM Corp. 2018, 2019. All Rights Reserved
#
#       US Government Users Restricted Rights - Use, duplication
#       or disclosure restricted by GSA ADP Schedule Contract
#       with IBM Corp.
#
# ------------------------------------------------------------------
#######################################################################
#	This rulesfile has been developed in accordance to the IBM Netcool 
#	Rules Files Best Practices to perform the following functionality
#
#	1. De-duplicate events
#	2. Generic-Clear  to correlate Problems/Resolutions
#	3. Readable alarm summaries
#######################################################################
# Available elements:
#	$ClassName - Class name of the TEC event
#	$EventSeqNo - Event sequence number of this event
#	All other elements are dynamically created, based on the name/value
#	pairs in the event.
#######################################################################

# Uncomment the following include line and part 2 below to use the ITM 
# virtualization integration files found in .../extensions/itmvirtualization/ :

# include "tivoli_eif_virtualization_pt1.rules"

# Uncomment the following include line to use the TBSM z/OS Identity Rules
# provided with TBSM. The TBSM extension files can be fund in a folder named
# "tbsm_extensions" located in the base directory of the TBSM installation media

# include "tivoli_eif_zos_tbsm.rules"

# Uncomment the following include line to use the z/OS Event Pump rules
# provided with the z/OS Event Pump

# include "tivoli_eif_zos_lookup.rules"

# Uncomment the following include line to use the z/OS Event Pump Rules. This is
# an array used to gather event stats for zOS.
#
# array azos_events;




array servers;
array server_info;
array server_detail;

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
	switch($source)
	{
		case "dummy case statement": ### This will prevent syntax errors in case no includes are added below.
			
			# Uncomment the following include line when using the TotalStorage Productivity 
            # Center integration:

            # Uncomment the following include line when getting the rules from Probe Extensions package
            # Uncomment the following include line when using the TPC integration:
			{{ if .Values.probe.rulesFile.tpc }}
			include "../../../../ProbeExtensions/eif/IBM_TPC/tivoli_eif_tpc.rules"
			{{ else }}
			# include "$NC_PROBE_EXT/eif/IBM_TPC/tivoli_eif_tpc.rules"
			{{- end }}


            # Uncomment the following include line when getting the rules from Probe Extensions package
			# Uncomment the following include line when using the TSM integration:
			{{ if .Values.probe.rulesFile.tsm }}
			include "../../../../ProbeExtensions/eif/IBM_TSM/tivoli_eif_tsm.rules"
			{{ else }}
			# include "$NC_PROBE_EXT/eif/IBM_TSM/tivoli_eif_tsm.rules"
			{{- end }}


			# Uncomment the following include line when using the TADDM integration
			# rules file found in .../extensions/taddm/ :

			{{ if .Values.probe.rulesFile.taddm }}
			include "../../extensions/taddm/tivoli_eif_taddm.rules"
			{{ else }}
			# include "tivoli_eif_taddm.rules"
			{{- end }}

		#case "Director_Server"
            # Uncomment the following include line when getting the rules from Probe Extensions package
            # include "$NC_PROBE_EXT/eif/IBM_ISD/IBM_Systems_Director_Events.rules"
            
		default: ### We handle input from ITM here.
			# ------------------------------------------------------------------
			# Extract all of the fields we might require from the ITM situation.  
			# The ObjectServer will still work if extra quotes are left around
			# the incoming fields but many of the products that OMNIbus integrates 
			# with will fail so remove them. 
			# ------------------------------------------------------------------
			
			foreach ( e in $* )
			{
				if(regmatch($e, "^'.*'$"))
				{
					$e = extract($e, "^'(.*)'$")
					log(DEBUG,"Removing quotes from attribute: " + $e)
				}
			}

			# Default values for some key ObjectServer fields
			# These may be overridden by the include rules files below
       			@Manager = "tivoli_eif probe on " + hostname()
			if( exists( $ClassName ) ) 
			{
				@AlertGroup = $ClassName
			} 
			@Class = 6601
			if( exists( $source ) ) 
			{
				@Agent = $source
			} 			
			@Type = 1 
			@Grade = 1
			if( exists( $severity ) )
			{
    				switch ( $severity )
    				{
 					case "FATAL":
 				        	@Severity = 5
 					case "60":
 				         	@Severity = 5
					case "CRITICAL":
            					@Severity = 5
					case "50":
						@Severity = 5
					case "MINOR":
						@Severity = 3
					case "40":
						@Severity = 3
					case "WARNING":
						@Severity = 2
					case "30":
						@Severity = 2
					default:
						@Severity = 1
				}
			}

			# Uncomment the following include line when receiving events from TEC. 
			# Please note if the itm_event.rules file in used it may also populate TEC fields.
			# include "$NC_PROBE_EXT/eif/IBM_TEC/tivoli_eif_tec.rules"

			# This is the generic ITM situation handling. This may get modified if
			# later include files are used. Must be included if the predictive or
			# virtualization include lines are used.

 			# include "itm_event.rules"

                        # This is the ITM vmware agent situation handling to set BSM_Identity for
                        # use with TBSM. The itm_event.rules file must also be uncommented when
                        # this file is used. 

 			# include "kvm_tbsm.rules"

                        # Uncomment the following include line to use the ITM predictive analytics 
			# integration files found in .../extensions/itmpredictive/ :

			# include "predictive_event.rules"

			# Uncomment the following include line and part 1 above to use the ITM 
			# virtualization integration files found in .../extensions/itmvirtualization/ :

			# include "tivoli_eif_virtualization_pt2.rules"

                        # Uncomment the following include line to use the BSM Identity rules for ITCAM for SOA
                        # provided with TBSM in %OMNHOME%\probes\win23\tbsm_extensions on Windows 
                        # and in $OMNHOME/probes/tbsm_extensions for non-windows

                        # include "kd4_tbsm.rules"

                        # This is the ITCAM Agent for WebSphere MQ situation handling to set BSM_Identity for
                       	#  use with TBSM. The itm_event.rules file must also be uncommented when
                       	#  this file is used. 

                       	# include "kmq_tbsm.rules"

                        # This is the ITCAM for Microsoft Applications - Active Directory Agent situation handling to set BSM_Identity for
                        # use with TBSM. The itm_event.rules file must also be uncommented when
                        # this file is used. 

                        # include "k3z_tbsm.rules"


                        # This is the ITCAM for Microsoft Applications - Exchange Server Agent situation handling to set BSM_Identity for
                        # use with TBSM. The itm_event.rules file must also be uncommented when
                        # this file is used. 

                        # include "kex_tbsm.rules"


                        # This is the ITCAM for Microsoft Applications - Hyper-V Agent situation handling to set BSM_Identity for
                        # use with TBSM. The itm_event.rules file must also be uncommented when
                        # this file is used. 

                        # include "khv_tbsm.rules"


                        # This is the ITCAM for Microsoft Applications - SQL Server Agent situation handling to set BSM_Identity for
                        # use with TBSM. The itm_event.rules file must also be uncommented when
                        # this file is used. 

                        # include "koq_tbsm.rules"


                        # This is the ITCAM for Microsoft Applications - Cluser Server Agent situation handling to set BSM_Identity for
                        # use with TBSM. The itm_event.rules file must also be uncommented when
                        # this file is used. 

                        # include "kq5_tbsm.rules"


                        # This is the ITCAM for Microsoft Applications - IIS Server Agent situation handling to set BSM_Identity for
                        # use with TBSM. The itm_event.rules file must also be uncommented when
                        # this file is used. 

                        # include "kq7_tbsm.rules"


                        # This is the ITCAM for Microsoft Applications - HIS Agent situation handling to set BSM_Identity for
                        # use with TBSM. The itm_event.rules file must also be uncommented when
                        # this file is used. 

                        # include "kqh_tbsm.rules"


                       	# Uncomment the following include line to use the z/OS Event Pump rules
                        # provided with the z/OS Event Pump

                        # include "zos_event.rules"
                        
                        # Uncomment the following include line to use the z/OS Event Pump user defined rules
                        # provided with the z/OS Event Pump
                        
                        # include "zos_event_user_defined.rules"
        
                        # Uncomment the following include line to use the TBSM Identify rules for the
                        # z/OS Event Pump provided with TBSM in %OMNHOME%\probes\win23\tbsm_extensions on Windows 
                        # and in $OMNHOME/probes/tbsm_extensions for non-windows
                        
                        # include "zos_identity.rules"
                        

	}
}
{{- end }}