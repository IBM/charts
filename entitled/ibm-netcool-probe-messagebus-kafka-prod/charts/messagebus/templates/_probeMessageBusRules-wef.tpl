{{/* Message Bus Probe WEF Rules file */}}
{{- define "messagebus.probeMessageBusRules-wef" }}
########################################################################
#
#	   Licensed Materials - Property of IBM
#	   
#	   
#	   
#	   (C) Copyright IBM Corp. 2015,2019. All Rights Reserved
#	   
#	   US Government Users Restricted Rights - Use, duplication
#	   or disclosure restricted by GSA ADP Schedule Contract
#	   with IBM Corp.
#
#
#######################################################################

case "wef2nvpairs":

	log(DEBUG, "<<<<< Entering.... MESSAGE BUS WEF Rules ............ >>>>>")

	@Manager = %Manager + " is running on " + hostname()
	@Agent = "MESSAGE BUS WEF"
	@Class = 89230

	if(exists ($EventId))
	{
		@EventId = $EventId
	}

	
	if(exists ($SourceComponent_ComponentAddress))
	{        
		@Node = $SourceComponent_ComponentAddress
	}
	else
	{
		@Node = "Unknown Alarm Location"
	}

	
	if(exists ($SourceComponent_ResourceId))
	{
		@NodeAlias = $SourceComponent_ResourceId
	}
	else
	{
		@NodeAlias = "Unknown Alarm Location Name"
	}


	if(exists ($ReporterComponent_ComponentAddress))
	{
		@RemoteNodeAlias = $ReporterComponent_ComponentAddress
	}


	if (exists ($Situation_SituationCategory)) 
	{
		@AlertGroup = $Situation_SituationCategory
	}


	if(exists ($SourceComponent_ResourceId))
	{
		@AlertKey = "Source Componenet ID: " + $SourceComponent_ResourceId
	}

	if (exists ($ReporterComponent_ResourceId))
	{
		@RemotePriObj = "Reporter Componenet ID: " + $ReporterComponent_ResourceId
	}


	if(exists ($Situation_Message))
	{
		@Summary = $Situation_Message
	}
	else if(exists ($Situation_SubstitutableMsg))
	{
		@Summary = $Situation_SubstitutableMsg + " " + $Situation_SubstitutableMsg_MsgIdType + " " + $Situation_SubstitutableMsg_MsgId + " " + $MsgCatalogInformation_MsgCatalog + " " + $MsgCatalogInformation_MsgCatalogType
	}
	

	if(exists ($Situation_Severity))
	{
		switch($Situation_Severity)
		{
	   		case "0": ### unknown
				@Severity = 2
				@Type = 1
	   		case "1": ### information
				@Severity = 2
				@Type = 13
	   		case "2": ### warning
				@Severity = 2
				@Type = 1
	   		case "3": ### minor
				@Severity = 3
				@Type = 1
	   		case "4": ### major
				@Severity = 4
				@Type = 1
	   		case "5" | "6": ### critical or fatal
				@Severity = 5
				@Type = 1
	   		default:
				@Severity = 2
				@Type = 1
		}
	}


	if(exists ($Situation_SituationCategory))
	{
		@Summary = @Summary + "  " + $Situation_SituationCategory
	}

	if(exists ($Situation_SuccessDisposition))
	{
		if(match ($Situation_SuccessDisposition, "Successful"))
		{
			@Severity = 2
			@Type = 13
			@Summary = @Summary + "  " + $Situation_SuccessDisposition
		}
		else if(match ($Situation_SuccessDisposition, "Unsuccessful"))
		{
			@Severity = 3
			@Type = 1
			@Summary = @Summary + "  " + $Situation_SuccessDisposition
		}
	}
			


	if(exists ($Situation_Priority))
	{
		switch($Situation_Priority)
		{
			case "10": ### low
				if(int(@Severity) < 3)
				{
					@Severity = 3
				}
			case "50": ### medium
	        		if(int(@Severity) < 4)
				{
					@Severity = 4
				}
			case "70": ### high	
				if(int(@Severity) < 5)
				{
					@Severity = 5
				}
			default:
		}
	}


	@Identifier =  @Node +  "  "  + @AlertKey + "  " + @AlertGroup  + "  "  + @Type + "  " + @Agent + "  " + @Manager

	details($*)
	
	log(DEBUG, "<<<<< Leaving.... MESSAGE BUS WEF Rules ............ >>>>>")

{{- end }}