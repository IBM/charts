{{/* Probe for Message Bus configuration for Logstash */}}
{{- define "probeLogstashConfig" }}
message_bus.props: |
  {{- if .Values.netcool.backupServer }}
  Server          : 'AGG_V'
  {{ else }}
  Server          : '{{ .Values.netcool.primaryServer }}'
  {{- end -}}
  TransformerFile : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus_logstash_parser.json'
  TransportFile   : '/opt/IBM/tivoli/netcool/omnibus/java/conf/webhookTransport.properties'
  TransportType   : 'Webhook'
  MessageLog      : 'stdout'
  MessageLevel    : '{{ default "warn" .Values.probe.messageLevel }}'

message_bus.rules: |
  # Logstash event elements for kubelet.log:
  # $(@timestamp)
  # $(@version)
  # $(beat.hostname)
  # $(beat.name)
  # $(beat.version)
  # $(container_id)
  # $(container_name)
  # $(host)
  # $(input_type)
  # $(log)
  # $(offset)
  # $(resync_event)
  # $(source)
  # $(stream)
  # $(tags)
  # $(time)
  # $(type)
  #
  if( match( @Manager, "ProbeWatch" ) )
  {
    #
    # This section deals with internal probe events
    #
    switch(@Summary)
    {
      case "Running ...":
        @Severity = 1  # Clear (1 is actually indeterminate, but needed for auto deletion of active)
        @AlertGroup = "probestat"
        @Type = 2      # Clear (Resolution)
      case "Going Down ...":
        @Severity = 5  # Critical
        @AlertGroup = "probestat"
        @Type = 1
      default:
        @Severity = 2  # Warning
        @Type = 1      # Problem
      @AlertGroup = "probestat"
    }
    @AlertKey = @Agent
    @Summary = @Agent + " probe on " + @Node + ": " + @Summary
  }
  else if (exists($liveness))
  {
    # livenessProbe ProbeWatch
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
    # readinessProbe ProbeWatch
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
    #
    # This section deals with Logstash alerts
    #
    log(DEBUG, "<<<<< Entering... Logstash rules >>>>>")
    if (match(@Manager,""))
    {
      @Manager = "Probe for Message Bus on" + hostname()
    }
    @Class = 30505
    @Agent = "Logstash"
    if(exists($(kubernetes.container_id)))
    {
      @AlertKey = $(kubernetes.container_id)
    }
    else
    {
      @AlertKey = $(container_id)
    }
    if(exists($(kubernetes.container_name)))
    {
      @AlertGroup = $(kubernetes.container_name)
    }
    else
    {
      @AlertGroup = $(container_name)
    }
    # Define SiteName
    @SiteName = @AlertGroup
    if(exists($(kubernetes.pod)))
    {
      @Node = $(kubernetes.pod)
    }
    else
    {
      @Node = $(host)
    }
    @NodeAlias = @Node
    # Define severity
    if (regmatch($(log), "[Uu]nhealthy"))
    {
      @Type=1
      @Severity=5
    }
    if (regmatch($(log), ".*[Ww]arn[ing]?.*") || regmatch($(log), ".*WARN[ING]?.*"))
    {
      @Type=1
      @Severity=2
    }
    else if (regmatch($(log), ".*[Ff]ail.*") || regmatch($log,".*[Ee]rror.*"))
    {
      @Type=1
      @Severity=3
    }
    else if (regmatch($(log), ".*[Ss]uccess.*") || regmatch($log,".*[Ss]ucceeded.*"))
    {
      @Type=2
      ## Set severity to 1 instead of 0
      ## This is to ensure generic clear works
      @Severity=1
    }
    else
    {
      #Default
      @Type=0
      @Severity=1
      @ExpireTime = 180
    }
    #Trim multiple backslashes to a single backslash
    $log = regreplace($log,"\\{2,}","\\")
    # Look for logs in stderr stream from kubelet
    if (match($stream,"stderr") && match($container_name,"kubelet"))
    {
      if (nmatch($log,""))
      {
        #Process Liveness Probe unhealthy event
        log(DEBUG,"Parsing Kubelet stderr stream event.")
        if (regmatch($log,".*Liveness probe failed:.*"))
        {
          log(DEBUG,"Parsing a liveness probe failed event.")
          $pod_data = extract($log,"ObjectReference(.*)")
          log(DEBUG,"pod_data=" + $pod_data)
          if (nmatch($pod_data,""))
          {
            [$pod_kind,$pod_namespace,$pod_name,$pod_uid,$pod_apiVersion,$pod_resourceVersion,$pod_fieldPath]
              = scanformat($pod_data,"{Kind:%s, Namespace:%s, Name:%s, UID:%s, APIVersion:%s, ResourceVersion:%s, FieldPath:%s}")
            $pod_kind = extract($pod_kind,'\"(.*)\"')
            $pod_namespace = extract($pod_namespace,'\"(.*)\"')
            $pod_name = extract($pod_name,'\"(.*)\"')
            $pod_uid = extract($pod_uid,'\"(.*)\"')
            $pod_apiVersion = extract($pod_apiVersion,'\"(.*)\"')
            $pod_resourceVersion = extract($pod_resourceVersion,'\"(.*)\"')
            $pod_fieldPath = extract($pod_fieldPath,'\"(.*)\"')
            $pod_deployment = extract($pod_fieldPath,"\{(.*)\}")
          }
          $message = extract($log,"*(Liveness probe failed: .*)\'")
          @Summary = "Liveness Probe failed for " + $pod_name
          @AlertGroup = @AlertGroup + " Liveness Probe"
          if (nmatch($pod_deployment,""))
          {
            @ScopeID = $pod_deployment
          }
          else
          {
            @ScopeID = $pod_name
          }
          if (int(@Type) == 1 && int(@Severity) < 4)
          {
            # Set the severity to Major for this problem
            @Severity = 4
          }
          #Set to expire in 2 mins if no subsequent probe failure event
          @ExpireTime = 120
          log(DEBUG,"pod_kind=" + $pod_kind + ",namespace=" + $pod_namespace
            + ",pod_name=" + $pod_name + ",uid=" + $pod_uid + ",APIVersion=" + $pod_apiVersion
            + ",resourceVersion=" + $pod_resourceVersion + ",fieldPath=" + $pod_fieldPath
            + ",pod_deployment=" + $pod_deployment
            +",message=" + $message)
          @ExtendedAttr = nvp_add(@ExtendedAttr,"log",$log, "pod_data", $pod_data, "pod_name", $pod_name,
            "pod_namespace",$pod_namespace,"pod_kind",$pod_kind,
            "pod_uid", $pod_uid,"pod_apiVersion",$pod_apiVersion,
            "pod_resourceVersion",$pod_resourceVersion,"pod_deployment",$pod_deployment,
            "pod_fieldPath", $pod_fieldPath, "message",$message)
        }
        #Process Pod sync error event
        else if (regmatch($log,".*Error syncing pod.*"))
        {
          log(DEBUG,"Parsing an error syncing pod event.")
          $pod_data = extract($log,"(Error syncing pod .*)")
          log(DEBUG,"pod_data=" + $pod_data)
          if (nmatch($pod_data,""))
          {
            [$pod_uid,$pod_detail]
              = scanformat($pod_data,"Error syncing pod %s (%s),")
            $pod_detail = extract($pod_detail,'\"(.*)\"')
            $pod_namespace = extract($pod_detail,".*_(.*)\(.*\)")
            $pod_name = extract($pod_detail,"(.*)_.*$")
            [$container] = scanformat($pod_data,".*container=%s")
          }
          $message = extract($log,"skipping: (.*)$")
          @Summary = "Error syncing pod " + $pod_name
          log(DEBUG,"pod_detail=" + $pod_detail + ",namespace=" + $pod_namespace
            + ",pod_name=" + $pod_name + ",uid=" + $pod_uid + ",APIVersion=" + $pod_apiVersion
            + ",resourceVersion=" + $pod_resourceVersion + ",fieldPath=" + $pod_fieldPath
            + ",container=" + $container
            +",message=" + $message)
          @ExtendedAttr = nvp_add(@ExtendedAttr,"log",$log, "pod_data", $pod_data, "pod_name", $pod_name,
            "pod_namespace",$pod_namespace,"pod_detail",$pod_detail,"container",$container,
            "message",$message)
        }
      }
    }
    if (match(@Summary,""))
    {
      @Summary = $(log)
    }
    if (length(@Summary) > 254)
    {
      @Summary = substr(@Summary,1,250) + "..."
    }
    #Define ScopeID if unset
    if (match(@ScopeID,""))
    {
      if (regmatch($(kubernetes.container_name), "db2"))
      {
        @ScopeID = "DB2"
      }
      else if (regmatch($(log), "db2"))
      {
        @ScopeID = "DB2"
      }
      else if (regmatch($(log), "nfs-pv-1"))
      {
        @ScopeID = "DB2"
      }
      else if (regmatch($(log), "nfs"))
      {
        @ScopeID = "NFS"
      }
      else if (exists($(kubernetes.namespace)))
      {
        @ScopeID = $(kubernetes.namespace)
      }
      else if (exists($(container_name)))
      {
        @ScopeID = $(container_name)
      }
      else
      {
        @ScopeID = $(beat.name)
      }
    }
    @ExtendedAttr = nvp_add(@ExtendedAttr, "Log", $(log))
    @Identifier = @Node + " " + @AlertKey + " " + @AlertGroup + " " + @Type + " " + @Agent + " " + @Manager
    log(DEBUG, "<<<<< Exiting... Logstash rules >>>>>")
  }
  # Uncomment the following line for extra information
  #@ExtendedAttr = nvp_add($*)
  # Add custom rules below

webhookTransport.properties: |
  httpVersion=1.1
  responseTimeout=60
  idleTimeout=180
  webhookURI=http://localhost:80/probe/webhook/logstash

omni.dat: |
  [{{ .Values.netcool.primaryServer }}]
  {
    Primary: {{ .Values.netcool.primaryHost }} {{ .Values.netcool.primaryPort }}
  }
  {{ if .Values.netcool.backupServer -}}
  [{{ .Values.netcool.backupServer }}]
  {
    Primary: {{ .Values.netcool.backupHost }} {{ .Values.netcool.backupPort }}
  }
  [AGG_V]
  {
    Primary: {{ .Values.netcool.primaryHost }} {{ .Values.netcool.primaryPort }}
    Backup: {{ .Values.netcool.backupHost }} {{ .Values.netcool.backupPort }}
  }
  {{- end -}}
{{- end }}
