{{/* Message Bus Probe Kafka Rules file */}}
{{- define "ibm-netcool-probe-messagebus-kafka-prod.probeMessageBusKafkaRules-kafka" }}
########################################################################
#
#       Licensed Materials - Property of IBM
#       
#       
#
#       (C) Copyright IBM Corp. 2018,2019. All Rights Reserved
#       
#       US Government Users Restricted Rights - Use, duplication
#       or disclosure restricted by GSA ADP Schedule Contract
#       with IBM Corp.
#
#
#######################################################################
#
#  This is a template rules files which maps the attribute to Object
#  Server fields. Please update this rules files to parse your payload.
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
    case "Start resynchronization" | "Finish resynchronization":
            @Severity = 2
            @AlertGroup = "probestat"
            @Type = 13
    case "Connection to source lost":
            @Severity = 5
            @AlertGroup = "probestat"
            @Type = 1   
    default:
            @Severity = 1
    }
    @AlertKey = @Agent
    @Summary = @Agent + " probe on " + @Node + ": " + @Summary
}
else if (exists($liveness))
{
  # livenessProbe Probe Watch
  @Manager = "ProbeWatch"
  @AlertGroup = "livenessProbe"
  @Agent = "message_bus"
  @AlertKey = @Agent
  @Node = hostname()
  @Summary = @Agent + " probe on " + @Node + ": " + "liveness " + $liveness
  @Identifier = @Agent + "@" + @Node + ":" + @AlertGroup
  @Type = 13  # Information
  @ExpireTime = 60
}
else if (exists($readiness))
{
  # readinessProbe Probe Watch
  @Manager = "ProbeWatch"
  @AlertGroup = "readinessProbe"
  @Agent = "message_bus"
  @AlertKey = @Agent
  @Node = hostname()
  @Summary = @Agent + " probe on " + @Node + ": " + "readiness " + $readiness
  @Identifier = @Agent + "@" + @Node + ":" + @AlertGroup
  @Type = 13  # Information
  @ExpireTime = 60
}
else
{
    @Manager = %Manager + " probe"
    @Node = $Node
    @NodeAlias = %Host + ":" + %Port
    @Class = 30505
    
    if (exists($TransformerName))
    {
        switch($TransformerName)
        {
            case "dummy case statement": ### This will prevent syntax errors in case no includes are added below.   

            #include "message_bus_netcool.rules"
            #include "message_bus_cbe.rules"
            #include "message_bus_wbe.rules"
            #include "message_bus_wef.rules"
        
            default:
                log(DEBUG, "<<<<< Rules are not supported for this format >>>>")
           
            @Summary = "Rules are not supported for this format - " + $TransformerName
        }
    }
    else
    {
        log(DEBUG, "<<<<< Entering... message_bus_netcool_kafka.rules >>>>>")

        @Manager = %Manager
        if (exists($Class) && !match($Class,""))
        {
            @Class = $Class
        }
        else
        {
            @Class = 89210
        }
        @Node = $Node
        @NodeAlias = $NodeAlias
        @Agent = $Agent
        @AlertGroup = $AlertGroup
        @AlertKey = $AlertKey
        @Severity = $Severity
        @Summary = $Summary
        @Poll = $Poll
        @Type = $Type
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
        @ExtendedAttr = $ExtendedAttr
        @ServerName = $ServerName
        @ServerSerial = $ServerSerial

        # Uncomment the following fields to override.
        #@StateChange = $StateChange
        #@FirstOccurrence = $FirstOccurrence
        #@LastOccurrence = $LastOccurrence
        #@InternalLast = $InternalLast
        #@Tally = $Tally

        if (exists($Identifier) && !match($Identifier,""))
        {
            @Identifier = $Identifier
        }
        else
        {
            @Identifier = @Node + " " + @AlertKey + " " + @AlertGroup + " " + @Type + " " + @Agent + " " + @Manager
        }

        log(DEBUG, "<<<<< Leaving... message_bus_netcool_kafka.rules >>>>>")
    }
        
}
{{- end }}
