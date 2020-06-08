{{- /*
ibm-edge.sch.chart.config.values
*/ -}}
{{- define "ibm-edge.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-edge-application-manager"
    components:
      agbot: agbot
      css: css
      exchange: exchange
      ui: ui
      overview: overview
      podOverview: pod-overview
      authGen: auth-gen
      authCleanup: auth-cleanup
      configGen: config-gen
      auth: auth
      config: config
      remoteDBs: remote-dbs
      serviceVerification: service-verification
      maxLength: 63
      releaseNameTruncLength: 42
      appNameTruncLength: 20
    labelType: prefixed
    metering:
      productID: c886b0f9a18a46f2a38d5fc8d274592a
      productName: "IBM Edge Application Manager"
      productVersion: "4.1.0"
      productMetric: "RESOURCE_VALUE_UNIT"
      productChargedContainers: ""
{{- end -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.config.values" -}}
sch:
  names:
    statefulSetName:
      maxLength: 63
      releaseNameTruncLength: 35
      appNameTruncLength: 14
      compNameTruncLength: 15
  chart:
    postgresPodSecurityContext:
      runAsNonRoot: true
      fsGroup: 2001
    mongoPodSecurityContext:
      runAsNonRoot: true
      fsGroup: 2001
{{- end -}}
