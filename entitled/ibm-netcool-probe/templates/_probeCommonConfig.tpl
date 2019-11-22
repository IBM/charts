{{- /* Common utility functions for probe configuration template. */ -}}

{{- /* 
Probe for Message Bus Common configuration for Webhook.
This function takes an argument (integration) which is used
in the webhook URI.
*/ -}}
{{- define "ibm-netcool-probe.probeCommonConfigWebhook" -}}
{{- $params := . -}}
{{- $integration := first $params -}}
webhookTransport.properties: |
  httpVersion=1.1
  responseTimeout=60
  idleTimeout=180
  webhookURI=http://localhost:4080/probe/webhook/{{ $integration }}
{{- end }}

{{- /*
Probe for Message Bus Common configuration for Object Server.
This function constructs the omni.dat file.
*/ -}}
{{- define "ibm-netcool-probe.probeCommonConfigObjserv" -}}
{{- $netcoolsslenabled := include "ibm-netcool-probe.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolauthenabled := include "ibm-netcool-probe.netcoolConnectionAuthEnabled" ( . ) -}}
omni.dat: |
  [{{ .Values.netcool.primaryServer }}]
  {
    Primary: {{ .Values.netcool.primaryHost }}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.primaryPort }}
  }
  {{ if .Values.netcool.backupServer -}}
  [{{ .Values.netcool.backupServer }}]
  {
    Primary: {{ .Values.netcool.backupHost }}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.backupPort }}
  }
  [AGG_V]
  {
    Primary: {{ .Values.netcool.primaryHost }}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.primaryPort }}
    Backup: {{ .Values.netcool.backupHost }}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.backupPort }}
  }
  {{- end -}}
{{- end }}
