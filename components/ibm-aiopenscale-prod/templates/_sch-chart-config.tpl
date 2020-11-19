{{- define "sch.chart.config.values" -}}
sch:
  securityContext:
    nonRootUser: 1000131421
  names:
    fullCompName:
      maxLength: 92
      releaseNameTruncLength: 36
      appNameTruncLength: 17
      compNameTruncLength: 39

  chart:
    appName: "ibm-aios"
{{- end -}}
