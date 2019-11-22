{{/* Tivoli EIF Probe TPC Rules file */}}
{{- define "probeTivoliEIFRules-tpc" }}
#######################################################################
#
# Licensed Materials - Property of IBM
# "Restricted Materials of IBM"
#
# 5725-Q09
#
# (C) Copyright IBM Corp. 2018, 2019
#
# Netcool/OMNIbus Tivoli EIF Probe Rules for IBM Tivoli Storage Productivity Center
#
#######################################################################
#
# This rulesfile has been developed in accordance to the IBM Netcool
# Rules Files Best Practices to perform the following functionality
#
# 1. De-duplicate events
# 2. Generic-Clear to correlate Problems/Resolutions
# 3. Readable alarm summaries
#
#######################################################################
#
# It is requiered that this file has to be used for every Event 
# sent by TPC releases 4.1.1 FP5, other newer 4.1.1. Fixpacks and
# 4.2.1 release and above.
#
#######################################################################
#
#    tivoli_eif_tpc.rules 1.0 
#    2008/11/20 Aveek Kumar Gupta
#
#    tivoli_eif_tpc.rules 1.1 
#    2010/09/30 Kai Boerner and Simona Constantin
#
#######################################################################

case "'IBM Tivoli Storage Productivity Center'" | "IBM Tivoli Storage Productivity Center" :

	log(DEBUG, "<<<<< Entering.... IBM Tivoli Storage Productivity Center Rules File............. >>>>>")

	@Class = 89200
	@Agent = $source
	@Manager = "Probe is running on " + hostname()

	if (exists($origin))
	{
		@Node = $origin
	}
	else
	{
		@Node = "Unknown Alarm Location"
	}

	if (exists($hostname))
	{	
		@NodeAlias = $hostname
	}
	else if (exists($adapter_host))
	{
		@NodeAlias = $adapter_host
	}
	else
	{
		@NodeAlias = "Unknown Alarm Location"
	}

	if( exists($severity))
	{
		switch($severity)
		{
			case "FATAL" | "3": 
			    @Severity = 5
			    @Type = 1
			case "CRITICAL": 
			    @Severity = 4
			    @Type = 1
			case "MINOR": 
			    @Severity = 3
			    @Type = 1
			case "WARNING" | "2": 
			    @Severity = 2
			    @Type = 1
			case "HARMLESS": 
			    @Severity = 1
			    @Type = 2
			case "UNKNOWN" | "0": 
			    @Severity = 2
			    @Type = 1
			case "1":
			    @Severity = 2
			    @Type = 13
			default: 
			    @Severity = 2
			    @Type = 1
		}
	}
	else if( exists($messageID))
	{
		$sev = extract($messageID, "ALR[0-9][0-9][0-9][0-9]([A-Za-z]+)$")
		switch($sev)
		{
			case "I" | "i":
			    @Severity = 1
			    @Type = 2
			case "W" | "w":
			    @Severity = 2
			    @Type = 1
			case "E" | "e":
			    @Severity = 3
			    @Type = 1
			default:
			    @Severity = 2
			    @Type = 1
		}
	}

        if( exists($msg))
	{
		@Summary = $msg
	}

	if( exists($messageID))
	{
	switch($messageID)
	{
		case "ALR4047W":
		    @EventId = "TPC-FABRIC-MISSING"
		    @AlertGroup = "Fabric State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
                    @Severity = 4 
		    details($*)

		case "ALR4048I":
		    @EventId = "TPC-FABRIC-REDISCOVERED"
		    @AlertGroup = "Fabric State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4046I":
		    @EventId = "TPC-FABRIC-DISCOVERED"
		    @AlertGroup = "Fabric State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4049W":
		    @EventId = "TPC-FABRIC-OFFLINE"
		    @AlertGroup = "Fabric State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    @Severity = 3 
	       	    details($*)

		case "ALR4050I":
		    @EventId = "TPC-FABRIC-ONLINE"
		    @AlertGroup = "Fabric State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4066I":
		    @EventId = "TPC-SWITCH-FABRIC-ASSOCIATION-DISCOVERED"
		    @AlertGroup = "Fabric to Switch Association"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4067W":
		    @EventId = "TPC-SWITCH-FABRIC-ASSOCIATION-MISSING"
		    @AlertGroup = "Fabric to Switch Association"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    @Severity = 4
		    details($*)

		case "ALR4068I":
		    @EventId = "TPC-SWITCH-FABRIC-ASSOCIATION-REDISCOVERED"
		    @AlertGroup = "Fabric to Switch Association"
		    @AlertKey =  "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4052W":
		    @EventId = "TPC-FABRIC-ZONE-MISSING"
		    @AlertGroup = "Fabric-Zone State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    @Severity = 4
		    details($*)

		case "ALR4053I":
		    @EventId = "TPC-FABRIC-ZONE-REDISCOVERED"
		    @AlertGroup = "Fabric-Zone State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4051I":
		    @EventId = "TPC-ZONE-FABRIC-DISCOVERED"
		    @AlertGroup = "Fabric-Zone State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4090I":
		    @EventId = "TPC-ZONE-FABRIC-MISSING"
		    @AlertGroup = "Fabric-Zone State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
                    @Severity = 4
		    details($*)

		case "ALR4091I" | "ALR4094I":
		    @EventId = "TPC-ZONE-FABRIC-DISCOVERED"
		    @AlertGroup = "Fabric-Zone State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4055W":
		    @EventId = "TPC-FABRIC-ZONESET-MISSING"
		    @AlertGroup = "Fabric-ZoneSet State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    @Severity = 4
                    details($*)

		case "ALR4056I":
		    @EventId = "TPC-FABRIC-ZONESET-REDISCOVERED"
		    @AlertGroup = "Fabric-ZoneSet State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    details($*)

		case "ALR4054I":
		    @EventId = "TPC-FABRIC-ZONESET-DISCOVERED"
		    @AlertGroup = "Fabric-ZoneSet State"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    details($*)

		case "ALR4095I" | "ALR4092I":
		    @EventId = "TPC-FABRIC-ZONESET-DISCOVERED"
		    @AlertGroup = "Fabric-ZoneSet State"
		    details($*)
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName

		case "ALR4093I" | "ALR4089I":
		    @EventId = "TPC-FABRIC-ZONESET-DEACTIVATED"
		    @AlertGroup = "Fabric-ZoneSet State"
		    details($*)
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName

		case "ALR4078I":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-ALIAS-DISCOVERED"
		    @AlertGroup = "Zone-to-Zone Alias Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    details($*)

		case "ALR4080I":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-ALIAS-REDISCOVERED"
		    @AlertGroup = "Zone-to-Zone Alias Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    details($*)

		case "ALR4079W":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-ALIAS-MISSING"
		    @AlertGroup = "Zone-to-Zone Alias Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    @Severity = 4
		    details($*)

		case "ALR4109I" | "ALR4111I" :
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-ALIAS-ADDED"
		    @AlertGroup = "Zone-to-Zone Alias Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Name: " + $zoneName +   "To Object: " + $toObjectLabel
		    details($*)

		case "ALR4110W":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-ALIAS-REMOVED"
		    @AlertGroup = "Zone-to-Zone Alias Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Name: " + $zoneName +   "To Object: " + $toObjectLabel
		    details($*)

		case "ALR4081I":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-MEMBER-DISCOVERED"
		    @AlertGroup = "Zone-to-Zone Member Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    details($*)

		case "ALR4083I":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-MEMBER-REDISCOVERED"
		    @AlertGroup = "Zone-to-Zone Member Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    details($*)

		case "ALR4082W":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-MEMBER-MISSING"
		    @AlertGroup = "Zone-to-Zone Member Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    @Severity = 4
		    details($*)

		case "ALR4084I":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONESET-DISCOVERED"
		    @AlertGroup = "Zone-to-Zone Set Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4085W":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONESET-MISSING"
		    @AlertGroup = "Zone-to-Zone Set Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    @Severity = 4
		    details($*)

		case "ALR4086I":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONESET-REDISCOVERED"
		    @AlertGroup = "Zone-to-Zone Set Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4099I" | "ALR4500I":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONESET-ADDED"
		    @AlertGroup = "Zone-to-Zone Set Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4107W":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONESET-REMOVED"
		    @AlertGroup = "Zone-to-Zone Set Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName + "  " + "Zone Name: " + "  " + $zoneName
		    details($*)

		case "ALR4096I" | "ALR4098I" :
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-MEMBER-ADDED"
		    @AlertGroup = "Zone-to-Zone Member Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Name: " + $zoneName + " " +  "To Object: " + $toObjectLabel
		    details($*)

		case "ALR4097W":
		    @EventId = "TPC-FABRIC-ZONE-TO-ZONE-MEMBER-REMOVED"
		    @AlertGroup = "Zone-to-Zone Member Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Name: " + $zoneName + " " +  "To Object: " + $toObjectLabel
		    details($*)

		case "ALR4329I":
		    @EventId = "TPC-FABRIC-ZONEMEMBER-TO-ZONE-ALIAS-DISCOVERED"
		    @AlertGroup = "Zone Member-to-Zone Alias Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    details($*)

		case "ALR4331I":
		    @EventId = "TPC-FABRIC-ZONEMEMBER-TO-ZONE-ALIAS-REDISCOVERED"
		    @AlertGroup = "Zone Member-to-Zone Alias Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    details($*)

		case "ALR4330W":
		    @EventId = "TPC-FABRIC-ZONEMEMBER-TO-ZONE-ALIAS-MISSING"
		    @AlertGroup = "Zone Member-to-Zone Alias Association"
		    @AlertKey = "SAN Name: " + $SANName + "  " +  "Zone Set Name: " + $zoneSetName
		    @Severity = 4
       	 	    details($*)

		case "ALR4063I":
		    @EventId = "TPC-PORT-TO-PORT-CONNECTION-DISCOVERED"
		    @AlertGroup = "Port to port Connection-State"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4064W":
		    @EventId = "TPC-PORT-TO-PORT-CONNECTION-MISSING"
		    @AlertGroup = "Port to port Connection-State"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    @Severity = 4
	       	    details($*)

		case "ALR4065I":
		    @EventId = "TPC-PORT-TO-PORT-CONNECTION-REDISCOVERED"
		    @AlertGroup = "Port to port Connection-State"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4087W":
		    @EventId = "TPC-PORT-TO-PORT-CONNECTION-OFFLINE"
		    @AlertGroup = "Port to port Connection-State"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    @Severity = 4
		    details($*)

		case "ALR4088I":
		    @EventId = "TPC-PORT-TO-PORT-CONNECTION-ONLINE"
		    @AlertGroup = "Port to port Connection-State"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4021W":
		    @EventId = "TPC-SWITCH-MISSING"
		    @AlertGroup = "Switch State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    @Severity = 4
		    details($*)

		case "ALR4022I":
		    @EventId = "TPC-SWITCH-REDISCOVERED"
		    @AlertGroup = "Switch State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4020I":
		    @EventId = "TPC-SWITCH-DISCOVERED"
		    @AlertGroup = "Switch State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4015I":
		    @EventId = "TPC-SWITCH-PORT-DISCOVERED"
		    @AlertGroup = "Switch Port State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type 
		    details($*)

		case "ALR4016W":
		    @EventId = "TPC-SWITCH-PORT-MISSING"
		    @AlertGroup = "Switch Port State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 4
		    details($*)

		case "ALR4017W":
		    @EventId = "TPC-SWITCH-PORT-REDISCOVERED"
		    @AlertGroup = "Switch Port State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 1
                    @Type = 2
		    details($*)

		case "ALR4024W":
		    @EventId = "TPC-SWITCH-STATUS-OFFLINE"
		    @AlertGroup = "Switch Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    @Severity = 3
		    details($*)

		case "ALR4025I":
		    @EventId = "TPC-SWITCH-STATUS-ONLINE"
		    @AlertGroup = "Switch Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4023W":
		    @EventId = "TPC-SWITCH-VERSION-CHANGE"
		    @AlertGroup = "Switch Version"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4069I":
		    @EventId = "TPC-SWITCH-TO-SWITCH-PORT-ASSOCIATION-DISCOVERED"
		    @AlertGroup = "Switch-to-Switch-Port Association"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4070W":
		    @EventId = "TPC-SWITCH-TO-SWITCH-PORT-ASSOCIATION-MISSING"
		    @AlertGroup = "Switch-to-Switch-Port Association"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    @Severity = 4
                    details($*)

		case "ALR4071I":
		    @EventId = "TPC-SWITCH-TO-SWITCH-PORT-ASSOCIATION-REDISCOVERED"
		    @AlertGroup = "Switch-to-Switch-Port Association"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4026I":
		    @EventId = "TPC-SWITCH-BLADE-DISCOVERED"
		    @AlertGroup = "Switch Blade State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4027W":
		    @EventId = "TPC-SWITCH-BLADE-MISSING"
		    @AlertGroup = "Switch Blade State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 4
		    details($*)

		case "ALR4028I":
		    @EventId = "TPC-SWITCH-BLADE-REDISCOVERED"
		    @AlertGroup = "Switch Blade State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4029W":
		    @EventId = "TPC-SWITCH-BLADE-OFFLINE"
		    @AlertGroup = "Switch Blade Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 3
		    details($*)

		case "ALR4030I":
		    @EventId = "TPC-SWITCH-BLADE-ONLINE"
		    @AlertGroup = "Switch Blade Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4011W" | "ALR4001W":
		    @EventId = "TPC-ENDPOINT-MISSING"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    @Severity = 4
		    details($*)

		case "ALR4012I":
		    @EventId = "TPC-ENDPOINT-REDISCOVERED"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4002I":
		    @EventId = "TPC-ENDPOINT-REDISCOVERED"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4038W":
		    @EventId = "TPC-ENDPOINT-MISSING"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 4
	       	    details($*)

		case "ALR4039I":
		    @EventId = "TPC-ENDPOINT-REDISCOVERED"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4010I":
		    @EventId = "TPC-ENDPOINT-DISCOVERED"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4000I":
		    @EventId = "TPC-ENDPOINT-DISCOVERED"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4037I":
		    @EventId = "TPC-ENDPOINT-DISCOVERED"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4004I" | "ALR4014I":
		    @EventId = "TPC-ENDPOINT-DEVICE-ONLINE"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4003W" | "ALR4013W":
		    @EventId = "TPC-ENDPOINT-DEVICE-OFFLINE"
		    @AlertGroup = "Endpoint State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 3
		    details($*)

		case "ALR4009I":
		    @EventId    = "TPC-ENDPOINT-NODE-ONLINE"
		    @AlertGroup = "Endpoint State"
		    @AlertKey   = "Name: " + $label + "  " + "Entity: " + $entityType 
		    details($*)

		case "ALR4005I":
		    @EventId    = "TPC-ENDPOINT-NODE-DISCOVERED"
		    @AlertGroup = "Endpoint State"
		    @AlertKey   = "Name: " + $label + "  " + "Entity: " + $entityType 
		    details($*)

		case "ALR4007I":
		    @EventId    = "TPC-ENDPOINT-NODE-REDISCOVERED"
		    @AlertGroup = "Endpoint State"
		    @AlertKey   = "Name: " + $label + "  " + "Entity: " + $entityType 
		    details($*)

		case "ALR4008W":
		    @EventId    = "TPC-ENDPOINT-NODE-OFFLINE"
		    @AlertGroup = "Endpoint State"
		    @AlertKey   = "Name: " + $label + "  " + "Entity: " + $entityType 
		    @Severity = 3
		    details($*)

		case "ALR4006W":
		    @EventId    = "TPC-ENDPOINT-MISSING"
		    @AlertGroup = "Endpoint State"
		    @AlertKey   = "Name: " + $label + "  " + "Entity: " + $entityType 
		    @Severity = 4 
		    details($*)

		case "ALR4019I":
		    @EventId = "TPC-FABRIC-PORT-ONLINE"
		    @AlertGroup = "SAN Port State" 
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type 
		    details($*)

		case "ALR4018W":
		    @EventId = "TPC-FABRIC-PORT-OFFLINE"
		    @AlertGroup = "SAN Port State" 
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type 
		    @Severity = 3
		    details($*)

		case "ALR4017I":
		    @EventId = "TPC-SWITCH-PORT-REDISCOVERED"
		    @AlertGroup = "SAN Port State" 
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type 
		    details($*)

		case "ALR4031I" | "ALR4033I" :
		    @EventId = "TPC-HBA-DISCOVERED"
		    @AlertGroup = "HBA State" 
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type 
		    details($*)

		case "ALR4032W":
		    @EventId = "TPC-HBA-MISSING"
		    @AlertGroup = "HBA State" 
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type 
		    @Severity = 4
		    details($*)

		case "ALR4034W" | "ALR4035W":
		    @EventId = "TPC-HBA-DRIVER-FIRMWARE"
		    @AlertGroup = "HBA State" 
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type 
		    @Severity = 1
                    @Type = 2
		    details($*)

		case "ALR4036W":
		    @EventId = "TPC-HBA-CHANGE-STATUS"
		    @AlertGroup = "HBA State" 
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type  + " " + "Old status: " + $oldStatus + " " + "New status: " + "$newStatus"
		    details($*)

		case "ALR4041I" | "ALR4043I" :
		    @EventId = "TPC-HOST-DISCOVERED"
		    @AlertGroup = "Host State" 
		    @AlertKey = "Name: " + $label + "  " 
		    details($*)

		case "ALR4042W":
		    @EventId = "TPC-HOST-MISSING"
		    @AlertGroup = "Host State" 
		    @AlertKey = "Name: " + $label + "  " 
		    @Severity = 4 
		    details($*)

		case "ALR4044W":
		    @EventId = "TPC-HOST-OFFLINE"
		    @AlertGroup = "Host State" 
		    @AlertKey = "Name: " + $label + "  " 
		    @Severity = 3
		    details($*)

		case "ALR4045I":
		    @EventId = "TPC-HOST-ONLINE"
		    @AlertGroup = "Host State" 
		    @AlertKey = "Name: " + $label + "  " 
		    details($*)

		case "ALR4072I" | "ARL4074I":
		    @EventId = "TPC-HBA-NODE-DISCOVERED"
		    @AlertGroup = "HBA Node State" 
		    @AlertKey = "From Object: " + $fromObjectLabel + "  " + "To Object: " + $toObjectLabel + "  " + "Computer name:" + $toObjectHLDLabel
		    details($*)

		case "ALR4073W":
		    @EventId = "TPC-HBA-NODE-MISSING"
		    @AlertGroup = "HBA Node State" 
		    @AlertKey = "From Object: " + $fromObjectLabel + "  " + "To Object: " + $toObjectLabel + "  " + "Computer name:" + $toObjectHLDLabel
		    @Severity = 4
		    details($*)

		case "ALR4075I":
		    @EventId = "TPC-ENDPOINT-NODE-ASSOCIATION-DISCOVERED"
		    @AlertGroup = "Endpoint to Node Association"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4076W":
		    @EventId = "TPC-ENDPOINT-NODE-ASSOCIATION-MISSING"
		    @AlertGroup = "Endpoint to Node Association"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    @Severity = 4
                    details($*)

		case "ALR4077I":
		    @EventId = "TPC-ENDPOINT-NODE-ASSOCIATION-REDISCOVERED"
		    @AlertGroup = "Endpoint to Node Association"
		    @AlertKey = "From Object: " + $fromObjectLabel+ "  " + "Type: " + $fromObjectType + "  " + "To Object: " + $toObjectLabel + "  " + "Type: " + $toObjectType
		    details($*)

		case "ALR4040W":
		    @EventId = "TPC-ENDPOINT-VERSION-CHANGED"
		    @AlertGroup = "Endpoint Version"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR1114W" | "ALR1114M":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-DISCOVERED"
		    @AlertGroup = "Storage Subsystem State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    @Severity = 1
                    @Type = 2
		    details($*)

		case "ALR0050W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-CACHE-INCREASED"
		    @AlertGroup = "Storage Subsystem Cache Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    @Severity = 1
                    @Type = 2
		    details($*)

		case "ALR0050W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-CACHE-DECREASED"
		    @AlertGroup = "Storage Subsystem Cache Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR1057W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-DISK-DETECTED"
		    @AlertGroup = "Disk State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4323W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-DISK-DISCOVERED"
		    @AlertGroup = "Disk State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 1
                    @Type = 2
		    details($*)

		case "ALR4324W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-DISK-MISSING"
		    @AlertGroup = "Disk State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 4
		    details($*)

		case "ALR0048W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-MISSING"
		    @AlertGroup = "Storage Subsystem State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    @Severity = 4
                    details($*)

		case "ALR4241W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-OFFLINE"
		    @AlertGroup = "Storage Subsystem Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    @Severity = 3
                    details($*)

		case "ALR4242I":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-ONLINE"
		    @AlertGroup = "Storage Subsystem Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4243W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-VERSION-CHANGED"
		    @AlertGroup = "Storage Subsystem Version"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4278W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-PROPERTY-CHANGE"
		    @AlertGroup = "Storage Subsystem Property Change"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Summary = @Summary + "  " + ", The Changed Attribute: " + $attributeName
		    details($*)

		case "ALR4244W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-ALLOCATED-CAPACITY-CHANGE"
		    @AlertGroup = "Storage Subsystem Allocated Capacity"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4245W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-AVAILABLE-CAPACITY-CHANGE"
		    @AlertGroup = "Storage Subsystem Available Capacity"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4246W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-BACKEND-CAPACITY-CHANGE"
		    @AlertGroup = "Storage Subsystem Backend Capacity"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType
		    details($*)

		case "ALR4247W":
		    @EventId = "TPC-BACKEND-CONTROLLER-OFFLINE"
		    @AlertGroup = "Backend Controller Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 3
                    details($*)

		case "ALR4248I":
		    @EventId = "TPC-BACKEND-CONTROLLER-ONLINE"
		    @AlertGroup = "Backend Controller Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4249W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-VOLUME-OFFLINE"
		    @AlertGroup = "Storage Subsystem Volume Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 3
                    details($*)

		case "ALR4250I":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-VOLUME-ONLINE"
		    @AlertGroup = "Storage Subsystem Volume Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4251W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-VOLUME-CAPACITY"
		    @AlertGroup = "Storage Subsystem Volume Capacity Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4252W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-POOL-STATE-CHANGE"
		    @AlertGroup = "Pool Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4253I":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-POOL-DISCOVERED"
		    @AlertGroup = "Pool Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4254W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-POOL-OFFLINE"
		    @AlertGroup = "Pool Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 3
		    details($*)

		case "ALR4255I":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-POOL-ONLINE"
		    @AlertGroup = "Pool Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4256W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-POOL-CAPACITY-CHANGE"
		    @AlertGroup = "Pool Capacity Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4257W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-POOL-AVAILABLE-SPACE-CHANGE"
		    @AlertGroup = "Pool Available Space Status"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4283W" | "ALR4353W" :
		    @EventId = "TPC-STORAGE-SUBSYSTEM-DATAPATH-STATE-CHANGE"
		    @AlertGroup = "Datapath State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4280I" | "ALR4354I":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-DATAPATH-DISCOVERED"
		    @AlertGroup = "Datapath State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR4325W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-NEW-VOLUME-DISCOVERED"
		    @AlertGroup = "Storage Subsystem Volume State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    @Severity = 1
                    @Type = 2
		    details($*)

		case "ALR4326W":
		    @EventId = "TPC-STORAGE-SUBSYSTEM-VOLUME-NOT-FOUND"
		    @AlertGroup = "Storage Subsystem Volume State"
		    @AlertKey = "Name: " + $label + "  " + "Entity: " + $entityType + "  " + "Type: " + $type
		    details($*)

		case "ALR0540W" | "ALR0541W" | "ALR0542W" | "ALR0543W" :
		    @EventId = "TPC-DISK-PORT-RESPONSE-TIME-THRESHOLD"
		    @AlertGroup = "Overall Port Response Time Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0556W" | "ALR0557W" | "ALR0558W" | "ALR0559W" :
		    @EventId = "TPC-DISK-CPU-UTILIZATIOPN-THRESHOLD"
		    @AlertGroup = "CPU Utilization Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0520W" | "ALR0521W" | "ALR0522W" | "ALR0523W" :
		    @EventId = "TPC-DISK-DATA-RATE-THRESHOLD"
		    @AlertGroup = "Data Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0516W" | "ALR0517W" | "ALR0518W" | "ALR0519W" :
		    @EventId = "TPC-DISK-IO-RATE-THRESHOLD"
		    @AlertGroup = "IO Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0528W" | "ALR0529W" | "ALR0530W" | "ALR0531W" :
		    @EventId = "TPC-DISK-CACHE-HOLDING-TIME-THRESHOLD"
		    @AlertGroup = "Cache Holding Time Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0524W" | "ALR0525W" | "ALR0526W" | "ALR0527W" :
		    @EventId = "TPC-DISK-WRITE-CACHE-DELAY-PERCENTAGE-THRESHOLD"
		    @AlertGroup = "Write-Cache Delay Percentage Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0512W" | "ALR0513W" | "ALR0514W" | "ALR0515W" | "ALR0560W" | "ALR0561W" | "ALR0562W" | "ALR0563W" | "ALR0564W" | "ALR0565W" | "ALR0566W" | "ALR0567W" :
		    @EventId = "TPC-DISK-BACKEND-RESPONSE-TIME-THRESHOLD"
		    @AlertGroup = "Backend Response Time Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0568W" | "ALR0569W" | "ALR0570W" | "ALR0571W" | "ALR0572W" | "ALR0573W" | "ALR0574W" | "ALR0575W" :
		    @EventId = "TPC-DISK-BACKEND-READ-WRITE-QUEUE-TIME-THRESHOLD"
		    @AlertGroup = "Backend Read, Write Time Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0576W" | "ALR0577W" | "ALR0578W" | "ALR0579W" | "ALR0580W" | "ALR0581W" | "ALR0582W" | "ALR0583W" | "ALR0584W" | "ALR0585W" | "ALR0586W" | "ALR0587W" | "ALR0588W" | "ALR0589W" | "ALR0590W" | "ALR0591W" :
		    @EventId = "TPC-PORT-TO-LOCALNODE-SEND-RECEIVE-QUEUE-TIME-THRESHOLD"
		    @AlertGroup = "Port to local node Send, Receive, Queue Time Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0592W" | "ALR0593W" | "ALR0594W" | "ALR0595W" :
		    @EventId = "TPC-NON-PREFERRED-NODE-USAGE-THRESHOLD"
		    @AlertGroup = "Non-preferred Node Usage Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0596W" | "ALR0597W" | "ALR0598W" | "ALR0599W" :
		    @EventId = "TPC-PEAK-BACKEND-WRITE-RESPONSE-THRESHOLD"
		    @AlertGroup = "Backend Read, Write Time Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

                case "ALR0600W" | "ALR0601W" | "ALR0602W" | "ALR0603W" | "ALR0604W" | "ALR0605W" | "ALR0606W" | "ALR0607W" :
		    @EventId = "TPC-PORT-UTILIZATION-THRESHOLD"
		    @AlertGroup = "Port Send Utilization Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

                case "ALR0608W" | "ALR0609W" | "ALR0610W" | "ALR0611W" | "ALR0612W" | "ALR0613W" | "ALR0614W" | "ALR0615W" :
		    @EventId = "TPC-PORT-BANDWITH-THRESHOLD"
		    @AlertGroup = "Port Send, Receive Bandwidth Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0532W" | "ALR0533W" | "ALR0534W" | "ALR0535W" :
		    @EventId = "TPC-DISK-PORT-IO-RATE-THRESHOLD"
		    @AlertGroup = "Port I/O Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0508W" | "ALR0509W" | "ALR0510W" | "ALR0511W":
		    @EventId = "TPC-DISK-BACKEND-DATA-RATE-THRESHOLD"
		    @AlertGroup = "Backend Data Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0504W" | "ALR0505W" | "ALR0506W" | "ALR0507W":
		    @EventId = "TPC-DISK-BACKEND-IO-RATE-THRESHOLD"
		    @AlertGroup = "Backend I/O Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

                case "ALR0500W" | "ALR0501W" | "ALR0502W" | "ALR0503W":
		    @EventId = "TPC-DISK-UTILIZATION-PERCENTAGE-THRESHOLD"
		    @AlertGroup = "Disk Utilization Percentage Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0536W" | "ALR0537W" | "ALR0538W" | "ALR0539W" :
		    @EventId = "TPC-SWITCH-PORT-DATA-RATE-THRESHOLD"
		    @AlertGroup = "Port Data Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0548W" | "ALR0549W" | "ALR0550W" | "ALR0551W" :
		    @EventId = "TPC-SWITCH-LINK-FAILURE-RATE-THRESHOLD"
		    @AlertGroup = "Link Failure Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0544W" | "ALR0545W" | "ALR0546W" | "ALR0547W" :
		    @EventId = "TPC-SWITCH-ERROR-FRAME-RATE-THRESHOLD"
		    @AlertGroup = "Error Frame Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0552W" | "ALR0553W" | "ALR0554W" | "ALR0555W" :
		    @EventId = "TPC-SWITCH-PORT-PACKET-RATE-THRESHOLD"
		    @AlertGroup = "Port packet Rate Threshold"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR0071W" | "ALR0076W":
		    @EventId = "TPC-DATA-SERVER-PERFORMANCE-MONITOR-FAILED"
		    @AlertGroup = "Performance Monitor Status"
		    @AlertKey = "Device Name: " + $deviceName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1300W":
		    @EventId = "TPC-COMPUTER-RAM-CHANGED"
		    @AlertGroup = "RAM Status"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1301W":
		    @EventId = "TPC-COMPUTER-VIRTUAL-MEMORY-CHANGED"
		    @AlertGroup = "Virtual Memory Status"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1302W":
		    @EventId = "TPC-DISK-NEW-DISCOVERY"
		    @AlertGroup = "Disk State"
		    @AlertKey = "Storage Sub-System Name: " + $storageSubsystemName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1303W":
		    @EventId = "TPC-DISK-MISSING"
		    @AlertGroup = "Disk State"
		    @AlertKey = "Storage Sub-System Name: " + $storageSubsystemName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1304W":
		    @EventId = "TPC-DISK-DEFECT-DETECTION"
		    @AlertGroup = "Disk Status"
		    @AlertKey = "Storage Sub-System Name: " + $storageSubsystemName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1305W":
		    @EventId = "TPC-DISK-FAILURE"
		    @AlertGroup = "Disk Status"
		    @AlertKey = "Storage Sub-System Name: " + $storageSubsystemName + "  " + "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1306W":
		    @EventId = "TPC-FILESYSTEM-NEW-DISCOVERY"
		    @AlertGroup = "Filesystem State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1307W":
		    @EventId = "TPC-FILESYSTEM-MISSING"
		    @AlertGroup = "Filesystem State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1308W":
		    @EventId = "TPC-FILESYSTEM-MODIFIED"
		    @AlertGroup = "Filesystem Status"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1309W":
		    @EventId = "TPC-FILESYSYTEM-FREESPACE-LOW-THRESHOLD"
		    @AlertGroup = "Filesystem Space Threshold"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1310W":
		    @EventId = "TPC-DIRECTORY-MISSING"
		    @AlertGroup = "Directory State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1311W":
		    @EventId = "TPC-FILESYSTEM-CONSTRAINT-VIOLATION"
		    @AlertGroup = "Filesystem Constraint Status"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1312W":
		    @EventId = "TPC-FILESYSTEM-INODE-LOW-THRESHOLD"
		    @AlertGroup = "Filesystem Inode Threshold"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1313W":
		    @EventId = "TPC-DIRECTORY-OR-USER-STORAGE-QUOTA-EXCEED"
		    @AlertGroup = "Directory or User Storage Quota Threshold"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1314W":
		    @EventId = "TPC-COMPUTER-DISCOVERED"
		    @AlertGroup = "Computer State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1315W":
		    @EventId = "TPC-COMPUTER-OFFLINE"
		    @AlertGroup = "Computer State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1316W":
		    @EventId = "TPC-COMPUTER-FILER-DISCOVERED"
		    @AlertGroup = "Filer State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1317W":
		    @EventId = "TPC-COMPUTER-FILER-MISSING"
		    @AlertGroup = "Filer State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1319W":
		    @EventId = "TPC-COMPUTER-STORAGE-SUBSYSTEM-MISSING"
		    @AlertGroup = "Storage Subsystem State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1318W":
		    @EventId = "TPC-COMPUTER-STORAGE-SUBSYSTEM-DISCOVERED"
		    @AlertGroup = "Storage Subsystem State"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1340W":
		    @EventId = "TPC-FILESYSTEM-AUTOEXTEND"
		    @AlertGroup = "Filesystem Extend Status"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1341W":
		    @EventId = "TPC-FILESYSTEM-AUTOEXTEND-PREVENTED"
		    @AlertGroup = "Filesystem Extend Status"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1342W":
		    @EventId = "TPC-CLUSTER-RESORCE-GROUP-ADDED-NEW"
		    @AlertGroup = "Cluster Resource Group Status"
		    @AlertKey = "CRG Name: " + $crgName + "  " + "Cluster Name: " + $clusterName + "  " + "Current Node Name: " + $currentNodeName
		    details($*)

		case "ALR1343W":
		    @EventId = "TPC-CLUSTER-RESORCE-GROUP-REMOVED"
		    @AlertGroup = "Cluster Resource Group Status"
		    @AlertKey = "CRG Name: " + $crgName + "  " + "Cluster Name: " + $clusterName + "  " + "Current Node Name: " + $currentNodeName
		    details($*)

		case "ALR1344W":
		    @EventId = "TPC-CLUSTER-RESOURCE-GROUP-MOVED"
		    @AlertGroup = "Cluster Resource Group Status"
		    @AlertKey = "CRG Name: " + $crgName + "  " + "Cluster Name: " + $clusterName + "  " + "Current Node Name: " + $currentNodeName
		    details($*)

		case "ALR1345W":
		    @EventId = "TPC-COMPUTER-PERFORMANCE-THRESHOLD-EXCEED"
		    @AlertGroup = "Computer Performance Threshold"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1346W":
		    @EventId = "TPC-COMPUTER-PERFORMANE-MONITOR-FAILED"
		    @AlertGroup = "Computer Performance Monitor Status"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1320W":
		    @EventId = "TPC-DIRECTORY-ARCHIVE-LOG-QUOTA-EXCEED"
		    @AlertGroup = "Archive Log Directory Quota threshold"
		    @AlertKey = "Resource Name: " + $resourceName + "  " + "Resource Type: " + $resourceType
		    details($*)

		case "ALR1321W":
		    @EventId = "TPC-DATABASE-TABLESPACE-ADDED-NEW"
		    @AlertGroup = "Database Tablespace State"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1322W":
		    @EventId = "TPC-DATABASE-TABLESPACE-DROPPED"
		    @AlertGroup = "Database Tablespace State"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1323W":
		    @EventId = "TPC-DATABASE-TABLESPACE-THRESHOLD-LOW"
		    @AlertGroup = "Database Tablespace Freespace Threshold"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1324W":
		    @EventId = "TPC-DATABASE-TABLESPACE-FRAGMENTED"
		    @AlertGroup =  "Database Tablespace Fragment Status"
		    @AlertKey = "Database Name: " + $databaseName + "  " + "Database Type: " + $rdbmsType + "  " + "Segment Name: " + $segmentName + "  " + "Segment Type: " + $segmentType
		    details($*)

		case "ALR1325W":
		    @EventId = "TPC-DATABASE-TABLESPACE-OFFLINE"
		    @AlertGroup = "Database Tablespace Status"
		    @AlertKey = "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1326W":
		    @EventId = "TPC-DATABASE-TABLESPACE-EXTENT-SIZE-THRESHOLD"
		    @AlertGroup = "Tablespace Extent Size Threshold"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1327W":
		    @EventId = "TPC-TABLE-FRAGMENTED"
		    @AlertGroup = "Table Fragment Status"
		    @AlertKey = "Database Name: " + $databaseName + "  " + "Database Type: " + $rdbmsType + "  " + "Segment Name: " + $segmentName + "  " + "Segment Type: " + $segmentType
		    @Summary = @Summary + "  " + "Threshold Value: " + $threshold + "  " + "Current Value: " + $currentValue
		    details($*)

		case "ALR1328W":
		    @EventId = "TPC-TABLE-EXTENT-SIZE-THRESHOLD"
		    @AlertGroup = "Table Extent Size Threshold"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1329W":
		    @EventId = "TPC-TABLE-DROPPED"
		    @AlertGroup = "Table State"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1330W":
		    @EventId = "TPC-TABLE-QUOTA-THRESHOLD-EXCEED"
		    @AlertGroup = "Table Quota Threshold"
		    @AlertKey =  "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName + "  " + "Violater Name: " + $violatorName + "  " + "Violater Type: " + $violatorType
		    @Summary = @Summary + "  " + "Threshold Value: " + $threshold + "  " + "Current Value: " + $currentValue
		    details($*)

		case "ALR1331W":
		    @EventId = "TPC-TABLE-CHAINED-ROW-THRESHOLD"
		    @AlertGroup = "Table Chained Rows Threshold"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    @Summary = @Summary + "  " + "Threshold Value: " + $threshold + "  " + "Current Value: " + $currentValue
		    details($*)

		case "ALR1332W":
		    @EventId = "TPC-TABLE-OVERALLOCATED"
		    @AlertGroup = "Table Over Allocated Status"
		    @AlertKey = "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName + "  " + "Violater Name: " + $violatorName + "  " + "Violater Type: " + $violatorType
		    @Summary = @Summary + "  " + "Threshold Value: " + $threshold + "  " + "Current Value: " + $currentValue
		    details($*)

		case "ALR1333W":
		    @EventId = "TPC-INSTANCE-NEW-DEVICE-DISCOVERED"
		    @AlertGroup = "Instance Device State"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1334W":
		    @EventId = "TPC-INSTANCE-DEVICE-DROPPED"
		    @AlertGroup = "Instance Device State"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    details($*)

		case "ALR1335W":
		    @EventId = "TPC-INSTANCE-DEVICE-FREESPACE-THRESHOLD-LOW"
		    @AlertGroup = "Instance Device Freespace Threshold"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    @Summary = @Summary + "  " + "Threshold Value: " + $threshold + "  " + "Current Value: " + $currentValue
		    details($*)

		case "ALR1336W":
		    @EventId = "TPC-INSTANCE-DEVICE-FREESPACE-THRESHOLD-HIGH"
		    @AlertGroup = "Instance Device Freespace Threshold"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    @Summary = @Summary + "  " + "Threshold Value: " + $threshold + "  " + "Current Value: " + $currentValue
		    details($*)

		case "ALR1337W":
		    @EventId = "TPC-DATABASE-TABLESPACE-LOW-FREESPACE"
		    @AlertGroup = "Database Tablespace Freespace Status"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    @Summary = @Summary + "  " + "Threshold Value: " + $threshold + "  " + "Current Value: " + $currentValue
		    details($*)

		case "ALR1338W":
		    @EventId = "TPC-DATABASE-BACKUP-DURATION-THRESHOLD"
		    @AlertGroup = "Database Backup Duration Threshold"
		    @AlertKey = "Database Vendor Name: " + $rdbmsName + "  " + "Database Type: " + $rdbmsType + "  " + "Database Name: " + $databaseName
		    @Summary = @Summary + "  " + "Threshold Value: " + $threshold + "  " + "Current Value: " + $currentValue
		    details($*)

		case "ALR4104W":
		    @EventId = "TPC-DATABASE-ALARM"
		    @AlertGroup = "Database status"
		    @AlertKey = $msg
		    details($*)

                case "ALR1339W":
		    @EventId = "SCHEDULE_JOB_FAILED"
		    @AlertGroup = "Jobs"
		    @AlertKey = "Schedule name: " + $scheduleName +  " " + "Schedule Type: " + $scheduleType
		    @Summary = @Summary + "  " + "Schedule name: " + $scheduleName +  " " + "Schedule Type: " + $scheduleType + " " + "Schedule run: " + $scheduleRun
		    details($*)

		case "ALR4342T":
		    @EventId = "SSO-TIP-AUTH-CONFIG-NOT-SUPPORTED"
		    @AlertGroup = "Authentication Not Supported"
		    @AlertKey = "New Authentication Method: " + $newAuthMethod
		    details($*)

		case "ALR4343T":
		    @EventId = "SSO-SERVER-AUTH-CONFIG-CHANGE"
		    @AlertGroup = "SSO Authentication Status"
		    @AlertKey = "Current Authentication Method: " + $currentAuthMethod + " " + "New Authentication Method: " + $newAuthMethod + " " + "Device Server Host: " + $deviceServerHost
		    details($*)
			
	        default:
        
                    @AlertKey = $messageID
                    @AlertGroup = $alertName
		    @Summary = "Unknown  Message ID (" + $messageID + ") Received for " + $source + "  " + ", Original Message: " + @Summary
        	    details($*)
	            log(DEBUG, "<<<<<........... Unknown  Message ID (" + $messageID + ") .............>>>>>")

	}
		    @Identifier = @Node +  "  "  + @AlertKey + "  " + @AlertGroup  + "  "  + @Type + "  " + @Agent + "  " + @Manager +  "  " + $messageID
	}
	
	log(DEBUG, "<<<<< Leaving.... IBM TotalStorage Productivity Center Rules File.............  >>>>>")

{{- end }}