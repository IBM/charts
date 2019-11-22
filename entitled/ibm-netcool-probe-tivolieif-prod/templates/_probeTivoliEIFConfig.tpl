{{/* Tivoli EIF Probe for configuration */}}
{{- define "probeTivoliEIFConfig" }}
tivoli_eif.props: |
  ## Generic properties
  MessageLevel    : '{{ default "warn" .Values.probe.messageLevel }}'
  MessageLog      : 'stdout'
  RulesFile       : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/tivoli_eif.rules'
  {{- if .Values.netcool.backupServer }}
  Server          : 'AGG_V'
  {{ else }}
  Server          : '{{ .Values.netcool.primaryServer }}'
  {{- end }}

  ## Specific properties
  HandleMalformedAlarms		: 'true'
  EIFReadRetryInterval		: 120
  PortNumber              : 9998
  
  ## Enable HTTP API
  NHttpd.EnableHTTP : TRUE
  NHttpd.ListeningPort : 8080

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
  {{- end }}
{{- end }}