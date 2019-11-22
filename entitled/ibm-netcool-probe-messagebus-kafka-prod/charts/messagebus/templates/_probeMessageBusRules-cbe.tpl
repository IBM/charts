{{/* Message Bus Probe CBE Rules file */}}
{{- define "messagebus.probeMessageBusRules-cbe" }}
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

case "cbe2nvpairs":

	log(DEBUG, "<<<<< Entering.... MESSAGE BUS CBE Rules ............ >>>>>")

	@Manager = %Manager + " is running on " + hostname()
	@Agent = "MESSAGE BUS CBE"
	@Class = 89220

	if(exists ($GlobalInstanceId))
	{
		@EventId = $GlobalInstanceId
	}


	
	if(exists ($SourceComponentId_Location))
	{        
		@Node = $SourceComponentId_Location
	}
	else
	{
		@Node = "Unknown Alarm Location"
	}
	
	
	if(exists ($SourceComponentId_LocationType) && exists ($SourceComponentId_Location))
	{
		@NodeAlias = $SourceComponentId_LocationType + " : " + $SourceComponentId_Location
	}
	else
	{
		@NodeAlias = "Unknown Alarm Location Name"
	}


	if(exists ($ReporterComponentId_LocationType) && exists ($ReporterComponentId_Location))
	{
		@RemoteNodeAlias = $ReporterComponentId_LocationType + " : " + $ReporterComponentId_Location
	}


	if(exists ($SourceComponentId_LocationType))
	{
		$AlertGroup = $SourceComponentId_LocationType
	}

	if(exists ($Situation_CategoryName))
	{
		if(exists ($AlertGroup))
		{
			$AlertGroup = $AlertGroup + "  "  + $Situation_CategoryName
		}
		else
		{
			$AlertGroup = $Situation_CategoryName
		}
	}

	if(!match ($AlertGroup, ""))
	{
		@AlertGroup = $AlertGroup
	}
	else
	{
		@AlertGroup = "AlertGroup is Unknown"	
	}



	if(exists ($SourceComponentId_Application))
	{
		$AlertKey = $SourceComponentId_Application
	}
	if (exists ($SourceComponentId_ComponentIdType))
	{
		if(exists ($AlertKey))
		{
			$AlertKey = $AlertKey + " " + $SourceComponentId_ComponentIdType
		}
		else
		{
			$AlertKey = $SourceComponentId_ComponentIdType
		}
	}
	if (exists ($SourceComponentId_Component))
	{
		if(exists ($AlertKey))
		{
			$AlertKey = $AlertKey + " " + $SourceComponentId_Component
		}
		else
		{
			$AlertKey = $SourceComponentId_Component
		}
	}

	if (exists ($SourceComponentId_SubComponent))
	{
		if(exists ($AlertKey))
		{
			$AlertKey = $AlertKey + " " + $SourceComponentId_SubComponent
		}
		else 
		{
			$AlertKey = $SourceComponentId_SubComponent
		}
	}
	if (exists ($SourceComponentId_InstanceId))
	{
		if(exists ($AlertKey))
		{
			$AlertKey = $AlertKey + " " + $SourceComponentId_InstanceId
		}
		else
		{
			$AlertKey = $SourceComponentId_InstanceId
		}
	}

	if(!match ($AlertKey, ""))
	{
		@AlertKey = $AlertKey
		@LocalPriObj = @AlertKey
	}
	else
	{
		@AlertKey = "AlertKey is Unknown"
		@LocalPriObj = "LocalPriObj is Unknown"	
	}


	if(exists ($ReporterComponentId_Application))
	{
		$RemotePriObj = $ReporterComponentId_Application
	}
	if (exists ($ReporterComponentId_Component))
	{
        	if(exists ($RemotePriObj))
                {
			$RemotePriObj = $RemotePriObj + " " + $ReporterComponentId_Component
		}
		else
		{
			$RemotePriObj = $ReporterComponentId_Component
		}
	}
	if (exists ($ReporterComponentId_SubComponent))
	{
		if(exists ($RemotePriObj))
		{
			$RemotePriObj = $RemotePriObj + " " + $ReporterComponentId_SubComponent
		}
		else
		{
			$RemotePriObj = $ReporterComponentId_SubComponent
		}
	}
	if (exists ($ReporterComponentId_ComponentIdType))
	{
		if(exists ($RemotePriObj))
		{
			$RemotePriObj = $RemotePriObj + " " + $ReporterComponentId_ComponentIdType
		}
		else
		{
			$RemotePriObj = $ReporterComponentId_ComponentIdType
		}
	}
	if (exists ($ReporterComponentId_InstanceId))
	{
		if(exists ($RemotePriObj))
		{
			$RemotePriObj = $RemotePriObj + " " + $ReporterComponentId_InstanceId
		}
		else
		{
			$RemotePriObj = $ReporterComponentId_InstanceId
		}
	}

	if(!match ($RemotePriObj, ""))
	{
		@RemotePriObj = $RemotePriObj
	}
	else
	{
		@RemotePriObj = "RemotePriObj is Unknown"
	}


	if(exists ($Msg))
	{
		@Summary = $Msg
	}
	else
	{
		if(exists ($MsgDataElement_MsgIdType) && exists ($MsgDataElement_MsgId))
		{
			$Summary = "MsgId is: " + $MsgDataElement_MsgIdType + " " + $MsgDataElement_MsgId
		}
		else if(exists ($MsgDataElement_MsgIdType))
		{
			if(exists ($Summary))
			{
				$Summary = $Summary + " MsgIdType is: " + $MsgDataElement_MsgIdType
			}
			else
			{
				$Summary = "MsgIdType is: " + $MsgDataElement_MsgIdType
			}
		}
		else if(exists ($MsgDataElement_MsgId))
		{
			if(exists ($Summary))
			{
				$Summary = $Summary + " MsgId is: " + $MsgDataElement_MsgId
			}
			else
			{
				$Summary = "MsgId is: " + $MsgDataElement_MsgId
			}
		}
		if(exists ($MsgDataElement_MsgCatalogType) && exists ($MsgDataElement_MagCatalogId) && exists ($MsgDataElement_MsgCatalog))
		{
			if(exists ($Summary))
			{
				$Summary = $Summary + " Catalog is " + $MsgDataElement_MsgCatalogType + " " + $MsgDataElement_MagCatalogId + " " + $MsgDataElement_MsgCatalog
			}
			else
			{
				$Summary = "Catalog is " + $MsgDataElement_MsgCatalogType + " " + $MsgDataElement_MagCatalogId + " " + $MsgDataElement_MsgCatalog
			}
		}
		if(exists ($MsgDataElement_MsgLocale))
		{
			if(exists ($Summary))
			{	
				$Summary = $Summary + " MsgLocale is: " + $MsgDataElement_MsgLocale
			}
			else
			{
				$Summary = "MsgLocale is: " + $MsgDataElement_MsgLocale
			}
		}

		if(!match ($Summary, ""))
		{
			@Summary = $Summary
		}
	}


	if(exists ($Severity))
	{
		switch($Severity)
		{
	   		case "0": ### unknown
				@Severity = 2
				@Type = 1
	   		case "10": ### information
				@Severity = 2
				@Type = 13
	   		case "20": ### harmless
				@Severity = 2
				@Type = 1
	   		case "30": ### warning
				@Severity = 2
				@Type = 1
	   		case "40": ### minor
				@Severity = 3
				@Type = 1
	   		case "50": ### critical
				@Severity = 4
				@Type = 1
	   		case "60": ### fatal
				@Severity = 5
				@Type = 1
	   		default:
				@Severity = 2
				@Type = 1
		}
	}
	

	if(exists ($Situation_CategoryName))
	{
		if(match ($Situation_CategoryName, "StartSituation"))
		{
			if(exists ($Situation_SituationQualifier))
			{
				if(match ($Situation_SituationQualifier, "START INITIATED") || match ($Situation_SituationQualifier, "RESTART INITIATED") || match ($Situation_SituationQualifier, "START COMPLETED"))
				{
					if(exists ($Situation_SuccessDisposition))
					{
						if(match ($Situation_SuccessDisposition, "SUCCESSFUL"))
						{
							@Severity = 2
							@Type = 13
							@Summary = @Summary + "  " + $Situation_SituationQualifier + "  " + $Situation_SuccessDisposition
						}
						else if(match ($Situation_SuccessDisposition, "UNSUCCESSFUL"))
						{
							@Severity = 3
							@Type = 1
							@Summary = @Summary + "  " + $Situation_SituationQualifier + "  " + $Situation_SuccessDisposition
						}			
					}	   
				}
			}
		}
		else if(match ($Situation_CategoryName, "StopSituation") || match ($Situation_CategoryName, "RequestSituation"))
		{
			if(exists ($Situation_SituationQualifier))
			{
				if(match ($Situation_SituationQualifier, "STOP INITIATED") || match ($Situation_SituationQualifier, "ABORT INITIATED") || match ($Situation_SituationQualifier, "PAUSE INITIATED") || match ($Situation_SituationQualifier, "PAUSE INITIATED"))
				{
					if(exists ($Situation_SuccessDisposition))
					{
						if(match ($Situation_SuccessDisposition, "SUCCESSFUL"))
						{
							@Severity = 2
							@Type = 13
							@Summary = @Summary + "  " + $Situation_SituationQualifier + "  " + $Situation_SuccessDisposition
						}
						else if(match ($Situation_SuccessDisposition, "UNSUCCESSFUL"))
						{
							@Severity = 3
							@Type = 1
							@Summary = @Summary + "  " + $Situation_SituationQualifier + "  " + $Situation_SuccessDisposition
						}			
					}	   
				}
			}
		}
		else if(match ($Situation_CategoryName, "ConnectionSituation"))
		{
			if(exists ($Situation_SituationQualifier))
			{
				if(match ($Situation_SituationQualifier, "INUSE") || match ($Situation_SituationQualifier, "FREED") || match ($Situation_SituationQualifier, "CLOSED") || match ($Situation_SituationQualifier, "AVAILABLE"))
				{
					if(exists ($Situation_SuccessDisposition))
					{
						if(match ($Situation_SuccessDisposition, "SUCCESSFUL"))
						{
							@Severity = 2
							@Type = 13
							@Summary = @Summary + "  " + $Situation_SituationQualifier + "  " + $Situation_SuccessDisposition
						}
						else if(match ($Situation_SuccessDisposition, "UNSUCCESSFUL"))
						{
							@Severity = 3
							@Type = 1
							@Summary = @Summary + "  " + $Situation_SituationQualifier + "  " + $Situation_SuccessDisposition
						}			
					}	   
				}
			}
		}
		else if(match ($Situation_CategoryName, "ConfigurationSituation"))
		{
			if(exists ($Situation_SuccessDisposition))
			{
				if(match ($Situation_SuccessDisposition, "SUCCESSFUL"))
				{
					@Severity = 2
					@Type = 13
					@Summary = @Summary + "  " + $Situation_SuccessDisposition
				}
				else if(match ($Situation_SuccessDisposition, "UNSUCCESSFUL"))
				{
					@Severity = 3
					@Type = 1
					@Summary = @Summary + "  " + $Situation_SuccessDisposition
				}			
			}	   
		}
		else if(match ($Situation_CategoryName, "AvailableSituation"))
		{
			if(exists ($Situation_SituationQualifier))
			{
				if(match ($Situation_SituationQualifier, "FUNCTION_PROCESS") || match ($Situation_SituationQualifier, "FUNCTION_BLOCK") || match ($Situation_SituationQualifier, "MGMTTASK_PROCESS") || match ($Situation_SituationQualifier, "MGMTTASK_BLOCKED"))
				{
					if(exists ($Situation_AvailabilityDisposition))
					{
						if(match ($Situation_AvailabilityDisposition, "AVAILABLE") || match ($Situation_AvailabilityDisposition, "NOT AVAILABLE"))
						{
							if(exists ($Situation_SuccessDisposition))
							{
								if(match ($Situation_SuccessDisposition, "SUCCESSFUL"))
								{
									@Severity = 2
									@Type = 13
									@Summary = @Summary + "  " + $Situation_SituationQualifier + "  " + $Situation_AvailabilityDisposition + "  " + $Situation_SuccessDisposition
								}
								else if(match ($Situation_SuccessDisposition, "UNSUCCESSFUL"))
								{
									@Severity = 3
									@Type = 1
									@Summary = @Summary + "  " + $Situation_SituationQualifier + "  " + $Situation_AvailabilityDisposition + "  " + $Situation_SuccessDisposition
								}			
							}	   
						}
					}
				}
			}
		}
		else if(match ($Situation_CategoryName, "ReportSituation"))
		{
			if(exists ($Situation_ReportCategory))
			{
				@Summary = $Situation_ReportCategory + " : " + @Summary
			}	   
		}
		else if(match ($Situation_CategoryName, "CreateSituation"))
		{
			if(exists ($Situation_SuccessDisposition))
			{
				if(match ($Situation_SuccessDisposition, "SUCCESSFUL"))
				{
					@Severity = 2
					@Type = 13
					@Summary = @Summary + "  " + $Situation_SuccessDisposition
				}
				else if(match ($Situation_SuccessDisposition, "UNSUCCESSFUL"))
				{
					@Severity = 3
					@Type = 1
					@Summary = @Summary + "  " + $Situation_SuccessDisposition
				}			
			}	   
		}
		else if(match ($Situation_CategoryName, "DestroySituation"))
		{
			if(exists ($Situation_SuccessDisposition))
			{
				if(match ($Situation_SuccessDisposition, "SUCCESSFUL"))
				{
					@Severity = 2
					@Type = 13
					@Summary = @Summary + "  " + $Situation_SuccessDisposition
				}
				else if(match ($Situation_SuccessDisposition, "UNSUCCESSFUL"))
				{
					@Severity = 3
					@Type = 1
					@Summary = @Summary + "  " + $Situation_SuccessDisposition
				}			
			}	   
		}
		else if(match ($Situation_CategoryName, "FeatureSituation"))
		{
			if(exists ($Situation_FeatureDisposition))
			{
				if(match ($Situation_FeatureDisposition, "AVAILABLE"))
				{
					@Severity = 2
					@Type = 13
					@Summary = @Summary + "  " + $Situation_FeatureDisposition
				}
				else if(match ($Situation_FeatureDisposition, "NOT AVAILABLE"))
				{
					@Severity = 3
					@Type = 1
					@Summary = @Summary + "  " + $Situation_FeatureDisposition
				}			
			}	   
		}
		else if(match ($Situation_CategoryName, "DependencySituation"))
		{
			if(exists ($Situation_DependencyDisposition))
			{
				if(match ($Situation_DependencyDisposition, "MET"))
				{
					@Severity = 2
					@Type = 13
					@Summary = @Summary + "  " + $Situation_DependencyDisposition
				}
				else if(match ($Situation_DependencyDisposition, "NOT MET"))
				{
					@Severity = 3
					@Type = 1
					@Summary = @Summary + "  " + $Situation_DependencyDisposition
				}			
			}	   
		}	
		else if(match ($Situation_CategoryName, "OtherSituation"))
		{
			if(exists ($(Situation_OtherSituationElement[0-9][0-9])))
			{
				$OtherSituation = $(Situation_OtherSituationElement[0-9][0-9])
				@Summary = @Summary + "  " + $OtherSituation
			}
		}
	}
	


	if(exists ($Priority))
	{
		switch($Priority)
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


	if (exists ($GlobalInstanceId))
	{
		@Identifier =  @Node +  "  "  + @AlertKey + "  " + @AlertGroup  + "  "  + @Type + "  " + @Agent + "  " + @Manager + "  " + $GlobalInstanceId
	}
	else
	{
		@Identifier =  @Node +  "  "  + @AlertKey + "  " + @AlertGroup  + "  "  + @Type + "  " + @Agent + "  " + @Manager
	}

	details($*)
	
	log(DEBUG, "<<<<< Leaving.... MESSAGE BUS CBE Rules ............ >>>>>")

{{- end }}