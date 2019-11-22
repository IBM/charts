{{/* Tivoli EIF Probe IBM Systems Director Rules file */}}
{{- define "probeTivoliEIFRules-isd" }}
#######################################################################
#
# Licensed Materials - Property of IBM
# "Restricted Materials of IBM"
#
# 5725-Q09
#
# (C) Copyright IBM Corp. 2018, 2019
#
# Netcool/OMNIbus Tivoli EIF Probe Rules for IBM System Director
#
#######################################################################
#
# File: IBM_Systems_Director_Events.rules 
#
# Description: This file contains event rule and data mappings to support the processing of 
#              IBM Systems Director events.
#
#######################################################################
#
# 1.0 - Initial Release. (Last Update Date: 09/05/2013)
#
#        Initial release in Probe Extensions Package
#
#        Compatible with:
#
#          -  Netcool/Omnibus 3.x and 7
#          -  Netcool Rules File Standards (MUSE-STD-RF-03, Jan 2006)
#
#
#######################################################################

### Sample IBM System Director event:

# ClassName: IBMPSG_PowerSupplyEvent
# ProbableCause:     '5'
# adapter_host:      '10.129.243.146'
# managed_oject_type:        'Power Supply'
# SystemCreationClassName:   'CIM_AlertIndication'
# EventTime: '20111019115838.059285-240'
# adapter_host_name: 'esmdvm6w3.svr.bankone.net'
# msg:       'This is a Test Event sent from LightWeightIndicationGeneratorTool. The Indication Class is IBMPSG_PowerSupplyEvent'
# event_type:        'Managed Resource.Managed System Resource.Logical Resource.Logical Device.Power Supply (OperationalCondition: Failed)'
# source_app:        'IBM_DIRECTOR'
# hostname:  'esmdvm6.svr.bankone.net'
# source_moid:       '8648'
# Trending:  '1'
# source:    'Director_Server'
# category:  'Alert'
# http_port: '8421'
# severity:  'CRITICAL'
# https_port:        '8422'
# ProviderName:      'Director|Agent|IndicationGeneratorProvider'
# EventID:   '\\esmdvm6.svr.bankone.net'
# date:      'Oct 19, 2011 11:58:15 EDT'
# source_app_version:        '6.2.1.2'
# EventSeqNo:        1

 # ClassName: IBMPSG_PowerSupplyEvent
 # ProbableCause:     '5'
 # adapter_host:      '10.129.243.146'
 # managed_oject_type:        'Power Supply'
 # SystemCreationClassName:   'CIM_AlertIndication'
 # EventTime: '20111019124018.352979-240'
 # adapter_host_name: 'esmdvm6w3.svr.bankone.net'
 # msg:       'This is a Test Event sent from LightWeightIndicationGeneratorTool. The Indication Class is IBMPSG_PowerSupplyEvent'
 # event_type:        'Managed Resource.Managed System Resource.Logical Resource.Logical Device.Power Supply (OperationalCondition: Failed)'
 # source_app:        'IBM_DIRECTOR'
 # hostname:  'esmdvm6.svr.bankone.net'
 # source_moid:       '8648'
 # Trending:  '1'
 # source:    'Director_Server'
 # category:  'Resolution'
 # http_port: '8421'
 # severity:  'HARMLESS'
 # https_port:        '8422'
 # ProviderName:      'Director|Agent|IndicationGeneratorProvider'
 # EventID:   '\\esmdvm6.svr.bankone.net'
 # date:      'Oct 19, 2011 12:39:55 EDT'
 # source_app_version:        '6.2.1.2'
 # EventSeqNo:        1
 # Processing alert

#   @AlertGroup = $ClassName
#   @AlertKey = $event_type

# 0: Clear. The Clear severity level indicates the
# clearing of one or more previously reported alarms.
# The alarms have either been cleared manually by a
# network operator, or automatically by a process
# which has determined the fault condition no longer
# exists. Automatic processes, for example the
# GenericClear Automation process, typically clear all
# alarms for a managed object (the AlertKey) that
# have the same Alarm Type and/or probable cause
# (the Alert Group).


# If the incoming event has a $source_app token 
# and the value of the token is "IBM_DIRECTOR", it is an ISD event.
log(DEBUG, "<<<<< Entering.... IBM_Systems_Director_Events.rules ..................... >>>>>")

if (exists($source_app) AND match($source_app,"IBM_DIRECTOR") )
{


    foreach ( e in $* )
    {
    if(regmatch($e, "^'.*'$"))
    {
        $e = extract($e, "^'(.*)'$")
        log(DEBUG,"Removing quotes from Director attribute: " + $e)
    }
    }




    log(DEBUG, "++++ Processing IBM Systems Director events.")
    if ( exists($system_name))
    {
    @Node = $system_name
    } else if (exists($hostname)) {
    @Node = $hostname
    }else {
    @Node = $adapter_host
    } 
    if (exists($sender_name)) {
    @Agent = $source_app+":"+$sender_name
    } else {
    @Agent = $source_app
    }
    
    @Manager = "IBM Systems Director on "+$adapter_host
    
    #@AlertGroup = $source_app  #RKR CHANGED
    @AlertGroup = $ClassName
    @AlertKey = $event_type
    @Summary = $msg
    @Location = $adapter_host
    @Director_MOID = $source_moid
    @URL ="https://"+$adapter_host_name+":"+$https_port+"/ibm/console"

    if (exists($severity)) {
            @Type = 1

        if ( match($severity,"FATAL" )) {
                  @Severity = 5
        } else if (match($severity, "CRITICAL")) {
              @Severity = 4
            } else if ( match($severity,"MINOR")) {
            @Severity = 3
        } else if ( match($severity,"WARNING")) {
            @Severity = 2
        } else if ( match($severity,"INFORMATIONAL") OR  match($severity,"HARMLESS") OR match($severity,"UNKNOWN")) {
            @Severity = 1
        }
        if (exists($category) AND match(upper($category),"RESOLUTION") ) {
            @Severity = 1
            @Type = 2
        }
            update(@Severity)
    } 
    #@Identifier =  @AlertGroup +":"+ @AlertKey +":"+ @Agent +":"+ @Node+":"+@Summary +":"+ @Severity 
    ##@Identifier =  @AlertGroup +":"+ @AlertKey +":"+ @Agent +":"+ @Node+":"+ @Severity +":"+ @Severity + ":" +@Type

    @Identifier=@Node+" "+@AlertKey+" "+@AlertGroup+" "+@Type+" "+@Agent+" "+@Manager
}
log(DEBUG, "<<<<< Leaving.... IBM_Systems_Director_Events.rules  ..................... >>>>>")

{{- end }}