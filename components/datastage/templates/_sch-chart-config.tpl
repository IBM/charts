  {{- define "sch.chart.config.values" -}}
sch:
  names:
    fullCompName:
      maxLength: 92
      releaseNameTruncLength: 36
      appNameTruncLength: 17
      compNameTruncLength: 39

  chart:
    appName: "ibm-ds"
{{- end -}}