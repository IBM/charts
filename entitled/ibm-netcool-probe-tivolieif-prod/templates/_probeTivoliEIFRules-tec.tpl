{{/* Tivoli EIF Probe TEC Rules file */}}
{{- define "probeTivoliEIFRules-tec" }}
#######################################################################
#
# Licensed Materials - Property of IBM
# "Restricted Materials of IBM"
#
# 5725-Q09
#
# (C) Copyright IBM Corp. 2018, 2019
#
# Netcool/OMNIbus Tivoli EIF Probe Rules for IBM Tivoli Enterprise Console
#
#######################################################################
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

			
if(exists($hostname))
{
    @Identifier = $hostname
}

if(exists($source))
{
    @AlertKey = $source
    @Identifier = @Identifier + ":" + $source
}

if(exists($sub_source))
{
    @AlertKey = @AlertKey + ":" + $sub_source
    @Identifier = @Identifier + ":" + $sub_source
}

if(exists($sub_origin))
{
    @AlertKey = @AlertKey + ":" + $sub_origin 
    @Identifier = @Identifier + ":" + $sub_origin
}


if(exists($origin))
{
    @Node = $origin
    @NodeAlias = $origin
}

@Identifier = @Identifier + ":" + $ClassName	


if(exists ($server_path))
{
    $num_servers = split($server_path, servers, ",")
    $num_detail = split(servers[$num_servers], server_detail, "'")
    $num_info = split(server_detail[int($num_detail)-1], server_info, " ")
    @TECServerHandle=server_info[2]
    @TECDateReception = server_info[3]
    @TECEventHandle=server_info[4]
}

@Summary = $msg
@TECHostname = $hostname
@TECFQHostname = $fqhostname
@TECDate = $date
@TECRepeatCount = $repeat_count
@LastOccurrence = getdate
@FirstOccurrence = getdate
@TECStatus = $status


#
# Handle TEC event status
#

switch ($status)
{
    CASE "CLOSED":
        @Type = 2
        @Severity = 0
    CASE "30":
        @Type = 2
        @Severity = 0
    CASE "ACK":
	@Acknowledged = 1
    CASE "20":
	@Acknowledged = 1
    default:
}


{{- end }}