{{/* Tivoli EIF Probe ITM Predictive Rules file */}}
{{- define "probeTivoliEIFRules-predictive" }}
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

log(DEBUG, "<<<<< Entering.... ITM Predictive Events Rules File ............. >>>>>")

# ------------------------------------------------------------------
# NOTE: ITM situation processing must have already been included 
# before this include file.
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# First handle situations from ITPA. In this case then the 
# situation_origin should be the hostname of the Agent followed
# by ":PA". If $direction exists as well then it is a predictive event; 
# otherwise it might be an ITPA error such as "Connection to DB2 failed".
# ------------------------------------------------------------------
if ( exists( $situation_origin ) )
{
	if( regmatch($situation_origin, ":PA$") and exists( $direction ) )
	{
		log( DEBUG, "Processing a Performance Analyzer situation event" )

		# ITPA (ITM Performance Analyzer) sets the fields direction, 
		# time_to_warning_threshold, time_to_critical_threshold and 
		# confidence.

		@Class = 89300
		@TrendDirection = $direction

		if (exists($sub_origin) )
		{
			# sub_origin comes from the data used by ITPA to do its
			# predictions on, so we can extract the hostname of
			# where the original data came from.
			if( regmatch( $sub_origin, ":.*:") )
			{
				@Node = extract($sub_origin, ":(.*):")
			}
			else
			{
				log( ERROR, "sub_origin malformed: " + $sub_origin )
			}
		}

		if (exists( $time_to_warning_threshold ) )
		{
			@PredictionTime = getdate + (int($time_to_warning_threshold) * 24 * 3600)
		}  
		
		if (exists( $time_to_critical_threshold ) )
		{
			@PredictionTime = getdate + (int($time_to_critical_threshold) * 24 * 3600)
		} 

		# If it is an event rate prediction then we will have nconode set
		# which should indicate the probe machine that may have a problem.
                if (exists($nconode) )
		{
			@Node = $nconode

			if( match($situation_status, "Y"))
			{
				if( match($integration_type, "N"))
				{
					# Situation has fired for the first time.
					log( DEBUG, "Predicted event rate has fired for node " + $nconode)
					@Summary = "Predicted event rate on " + $nconode + " will hit threshold within 7 days" 		
				}
				else if ( match($integration_type, "U"))
				{
					# Situation has fired again.
					log( DEBUG, "Predicted event rate has fired again for node " + $nconode)
					@Summary = "Predicted event rate on " + $nconode + " will hit threshold within 7 days"
 				}
			}
			# Leave the stop and reset options to be dealt with by the generic ITM situation handling 
		}

		# Add everything to ExtendedAttr. This will produce a lengthy column.
		@ExtendedAttr = nvp_add($*)
		@ExtendedAttr = nvp_remove(@ExtendedAttr,
                "direction", 
                "time_to_warning_threshold",
                "time_to_critical_threshold",
                "situation_origin",
                "source")
	}
}

# ------------------------------------------------------------------
# The following rules handle the low event rate and high event rate situations.
# Ignore any situations which do not have $nconode set since this indicates the
# original events contributing to the eventcount did not contain an @Node value
# ------------------------------------------------------------------
if( regmatch($situation_origin, ".*:NO") and regmatch($situation_name, ".*_Event_Rate_Baseline"))
{
	if(exists($nconode) and !match(ltrim(rtrim($nconode)), ""))
	{
	        log( DEBUG, "Processing an event rate baseline situation event" )
	
	        if( match($situation_name, "Low_Event_Rate_Baseline"))
	        {                   
	                $event_type = "Low"
	        }
	        else if( match($situation_name, "High_Event_Rate_Baseline"))
	        {                   
	                $event_type = "High"
	        }
                else
	        {
	                log( ERROR, "Unexpected situation name " + $situation_name)
	        }
	        
	        @Node = $nconode
	        @NodeAlias = $nconode
	        @Class = 89400
	        @AlertGroup = "Event Rate Baseline Violation"
	        
	        if( match($situation_status, "Y"))
	        {
	                if( match($integration_type, "N"))
	                {
	                        # Situation has fired for the first time.
	                        log( DEBUG, "Baseline situation has fired for node " + $nconode)
	                        @Summary = $event_type + " event rate baseline situation has fired for node " + $nconode + ", the event count is " + $eventcount
	                        @Severity = 4
	                }
	                else if ( match($integration_type, "U"))
	                {
	                        # Situation has fired again.
	                        log( DEBUG, "Baseline situation has fired again for node " + $nconode)
	                        @Summary = $event_type + " event rate baseline situation is continuing for node " + $nconode + ", the event count is " + $eventcount
	                        @Severity = 4
	                }
	        }
	        else if( match($situation_status, "N") && match($integration_type, "U"))
	        {
	                # Situation has reset
	                log( DEBUG, "Baseline situation has reset")
	                @Summary = $event_type + " event rate baseline situation has reset"
	                
	                if ( nmatch( $situation_displayitem, "" ) )
	                {
	                        @Summary = @Summary + " for node " + $situation_displayitem
	                }
	                
	                @Severity = 2
	        }
	}
}

log(DEBUG, "<<<<< Leaving.... predictive_event.rules  ..................... >>>>>")



{{- end }}