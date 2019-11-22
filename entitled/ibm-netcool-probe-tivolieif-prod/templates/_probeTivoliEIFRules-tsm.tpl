{{/* Tivoli EIF Probe TSM Rules file */}}
{{- define "probeTivoliEIFRules-tsm" }}
#######################################################################
#
# Licensed Materials - Property of IBM
# "Restricted Materials of IBM"
#
# StoragaProductivity
#
# (C) Copyright IBM Corp. 2018, 2019
#
# Netcool/OMNIbus Tivoli EIF Probe Rules for IBM Storage Manager
#
#######################################################################

case "TSM":

    log(DEBUG, "<<<<< Entering... tivoli_eif_tsm.rules >>>>>")

    @Agent = "Tsm-TSM SERVER"
    @Class = "87720"
 
    $OPTION_TypeFieldUsage = "3.6"

                    @Node = hostname()                   
                    @Manager = "tivoli_eif probe on " + hostname()

                    if(exists($msg))
                    {
                       $AlertGrp = extract($msg, "^AN([A-Za-z]+)[0-9][0-9][0-9][0-9][A-Za-z]+")
                       if (match($AlertGrp, "R") OR match($AlertGrp, "r"))
                       {
                           @AlertGroup = "TSM_Server"
                       }   
                       if (match($AlertGrp, "E") OR match($AlertGrp, "e"))
                       {
                           @AlertGroup = "TSM_CLient"
                       }
                       else if (match($AlertGrp, "S") OR match($AlertGrp, "s"))
                       {
                           @AlertGroup = "TSM_CLient"
                       }		       
                    }
                    else if (exists($ClassName))
                    {
                        @AlertGroup = $ClassName
                    }

                    if (exists($source))
                    {
                        $AlertKey = "Source:" + $source
                    }
                    if(exists($sub_source) && exists($AlertKey))          
                    {   
                        $AlertKey = $AlertKey + " " + "Sub Source:" + $sub_source  
                    }
                    else if(exists($sub_source))
                    {                  
                        $AlertKey = "Sub Source:" + $sub_source
                    }
                    if(exists($sub_origin) && exists($AlertKey))          
                    {   
                        $AlertKey = $AlertKey + " " + "Sub Origin:" + $sub_origin  
                    }
                    else if(exists($sub_origin))
                    { 
                        $AlertKey = "Sub Origin:" + $sub_origin
                    }
                    
                    if(!match ($AlertKey, ""))
                    {
                        @AlertKey = $AlertKey
                    }
                    else
                    {
                        @AlertKey = "Unknown Alarm Location"                    
                    }

                    if (exists($msg_index))
                    {
                        @AlertKey = @AlertKey + " Msg Ind:" + $msg_index
                    }

                    if (exists($msg))
                    { 
                        @Summary = $msg
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
                                 @Severity = 2
                                 @Type = 13
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
                if( exists($msg))
                {
                  $sev = extract($msg, "^ANR[0-9][0-9][0-9][0-9]([A-Za-z]+)\s+")
                  switch($sev)
                  {
                            case "I" | "i":
                                @Severity = 2
                                @Type = 13
                            case "W" | "w":
                                @Severity = 2
                                @Type = 1
                            case "E" | "e":
                                @Severity = 3
                                @Type = 1
                            case "S" | "s":
                                @Severity = 3
                                @Type = 1
                            default:
                                @Severity = 2
                                @Type = 1
                 }
               }
                     
                    @Identifier = @Node + " " + @AlertKey + " " + @AlertGroup + " " + @Type + " " + @Agent + " " + @Manager

                    details($*)

    log(DEBUG, "<<<<< Leaving... tivoli_eif_tsm.rules >>>>>")
{{- end }}