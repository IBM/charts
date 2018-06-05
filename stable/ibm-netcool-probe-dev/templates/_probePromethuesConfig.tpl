{{/* Probe for Message Bus configuration for Prometheus */}}
{{- define "probePrometheusConfig" }}
message_bus.props: |
  {{- if .Values.netcool.backupServer }}
  Server          : 'AGG_V'
  {{ else }}
  Server          : '{{ .Values.netcool.primaryServer }}'
  {{- end -}}
  TransformerFile : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus_prometheus_parser.json'
  TransportFile	  : '/opt/IBM/tivoli/netcool/omnibus/java/conf/webhookTransport.properties'
  TransportType   : 'Webhook'
  MessageLog      : 'stdout'
  MessageLevel    : '{{ default "warn" .Values.probe.messageLevel }}'

webhookTransport.properties: |
  httpVersion=1.1
  responseTimeout=60
  idleTimeout=180
  webhookURI=http://localhost:80/probe/webhook/prometheus

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