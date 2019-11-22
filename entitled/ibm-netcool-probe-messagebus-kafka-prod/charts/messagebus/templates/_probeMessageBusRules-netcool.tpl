{{/* Message Bus Probe Netcool Rules file */}}
{{- define "messagebus.probeMessageBusRules-netcool" }}
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

case "netcool2nvpairs":

    log(DEBUG, "<<<<< Entering... message_bus_netcool.rules >>>>>")

    @Manager = %Manager
    @Class = 89210
    @Identifier = $Identifier
    @Node = $Node
    @NodeAlias = $NodeAlias
    @Agent = $Agent
    @AlertGroup = $AlertGroup
    @AlertKey = $AlertKey
    @Severity = $Severity
    @Summary = $Summary
    @StateChange = $StateChange
    @FirstOccurrence = $FirstOccurrence
    @LastOccurrence = $LastOccurrence
    @InternalLast = $InternalLast
    @Poll = $Poll
    @Type = $Type
    @Tally = $Tally
    @Class = $Class
    @Grade = $Grade
    @Location = $Location
    @OwnerUID = $OwnerUID
    @OwnerGID = $OwnerGID
    @Acknowledged = $Acknowledged
    @Flash = $Flash
    @EventId = $EventId
    @ExpireTime = $ExpireTime
    @ProcessReq = $ProcessReq
    @SuppressEscl = $SuppressEscl
    @Customer = $Customer
    @Service = $Service
    @PhysicalSlot = $PhysicalSlot
    @PhysicalPort = $PhysicalPort
    @PhysicalCard = $PhysicalCard
    @TaskList = $TaskList
    @NmosSerial = $NmosSerial
    @NmosObjInst = $NmosObjInst
    @NmosCauseType = $NmosCauseType
    @LocalNodeAlias = $LocalNodeAlias
    @LocalPriObj = $LocalPriObj
    @LocalSecObj = $LocalSecObj
    @LocalRootObj = $LocalRootObj
    @RemoteNodeAlias = $RemoteNodeAlias
    @RemotePriObj = $RemotePriObj
    @RemoteSecObj = $RemoteSecObj
    @RemoteRootObj = $RemoteRootObj
    @X733EventType = $X733EventType
    @X733ProbableCause = $X733ProbableCause
    @X733SpecificProb = $X733SpecificProb
    @X733CorrNotif = $X733CorrNotif
    @URL = $URL
#    @ExtendedAttr = $ExtendedAttr
    @ServerName = $ServerName
    @ServerSerial = $ServerSerial

    log(DEBUG, "<<<<< Leaving... message_bus_netcool.rules >>>>>")
{{- end }}