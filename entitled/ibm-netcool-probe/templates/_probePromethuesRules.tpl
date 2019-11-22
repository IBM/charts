{{/* Probe for Message Bus Rules for Prometheus */}}
{{- define "ibm-netcool-probe.probePrometheusRules" }}

message_bus.rules: |
  # Prometheus alert elements from Kubernetes:
  # $(status)
  # $(startsAt)
  # $(labels.severity)
  # $(labels.release)
  # $(labels.kubernetes_namespace)
  # $(labels.kubernetes_name)
  # $(labels.job)
  # $(labels.instance)
  # $(labels.heritage)
  # $(labels.component)
  # $(labels.chart)
  # $(labels.app)
  # $(labels.alertname)
  # $(generatorURL)
  # $(endsAt)
  # $(annotations.summary)
  # $(annotations.description)
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
    #
    # This section deals with Prometheus alerts
    #
    log(DEBUG, "<<<<< Entering... Prometheus rules >>>>>")
    if (match(@Manager,""))
    {
      @Manager = "Probe for Message Bus on " + hostname()
    }
    @Class = 30505
    @Agent = "Prometheus Alert Manager"
    
    if (match("",$(labels.job)))
    {
      if (match("",$(annotations.type)))
      {
        # Assume alert is from a container rules because it does not have "job" label
        @AlertKey = "Container"
      }
      else
      {
        @AlertKey = $(annotations.type)
      }
    }
    else
    {
      @AlertKey = $(labels.job)
    }
    @AlertGroup = $(labels.alertname)
    @ScopeID = $(labels.release)
    @SiteName = $(labels.job)

    if (match("",$(labels.instance)))
    {
      # Default to "Prometheus Source" when no IP address or host is provided in alert.
      @Node = "Prometheus Source"
    }
    else
    {
      @Node = $(labels.instance)
    }
    
    @NodeAlias = @Node
    switch($(labels.severity))
    {
      case "critical":
        @Type=1
        @Severity=5
      case "major":
        @Type=1
        @Severity=4
      case "minor":
        @Type=1
        @Severity=3
      case "warning":
        @Type=1
        @Severity=2
      default:
        @Type=0
        @Severity=1
    }
    switch($(status))
    {
      case "resolved":
        @Type=2
        ## Set severity to 1 instead of 0
        ## This is to ensure generic clear works
        @Severity=1
      default:
        ## Nothing to do
    }

    if (!match("",$(annotations.DESCRIPTION)))
    {
      @Summary = $(annotations.DESCRIPTION)
    }
    else if (!match("",$(annotations.description)))
    {
      @Summary = $(annotations.description)
    }
    else if (!match("",$(annotations.SUMMARY)))
    {
      @Summary = $(annotations.SUMMARY)
    }
    else if (!match("",$(annotations.summary)))
    {
      @Summary = $(annotations.summary)
    }
    
    @Identifier = @Node + " " + @AlertKey + " " + @AlertGroup + " " + @Type + " " + @Agent + " " + @Manager

    # Append with container and pod info if available
    if (exists($(labels.container)) && !match($(labels.container),"")) {
      @Identifier = @Identifier + " " + $(labels.container)
    }
    if (exists($(labels.pod)) && !match($(labels.container),"")) {
      @Identifier = @Identifier + " " + $(labels.pod)
    }

    log(DEBUG, "<<<<< Exiting... Prometheus rules >>>>>")
  }
  
  @ExtendedAttr = nvp_add($*)
  # Add custom rules below

{{- end }}