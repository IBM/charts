{{/* Probe for Message Bus configuration for Prometheus */}}
{{- define "ibm-netcool-probe.probePrometheusConfig" }}
{{- $netcoolsslenabled := include "ibm-netcool-probe.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolauthenabled := include "ibm-netcool-probe.netcoolConnectionAuthEnabled" ( . ) -}}
message_bus.props: |
  {{- if .Values.netcool.backupServer }}
  Server          : 'AGG_V'
  {{- else }}
  Server          : '{{ .Values.netcool.primaryServer }}'
  {{- end }}
  TransformerFile : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus_prometheus_parser.json'
  TransportFile	  : '/opt/IBM/tivoli/netcool/omnibus/java/conf/webhookTransport.properties'
  TransportType   : 'Webhook'
  MessageLog      : 'stdout'
  MessageLevel    : '{{ default "warn" .Values.probe.messageLevel }}'
  HeartbeatInterval : 60
  {{- if or (eq $netcoolsslenabled "true") (eq $netcoolauthenabled "true") }}
  # Secure connection to Object Server
  {{- if (eq $netcoolsslenabled "true") }}
  # SSL connection enabled
  {{- if .Values.probe.sslServerCommonName }}
  SSLServerCommonName: '{{ .Values.probe.sslServerCommonName }}'
  {{- end }}
  {{- end }}
  ConfigCryptoAlg: 'AES_FIPS'
  {{- if (eq $netcoolauthenabled "true") }}
  # Authentication enabled. AuthUserName and AuthPassword properties are 
  # intentionally not shown in this Config Map and will be set by the probe during 
  # initialization. 
  # AuthUserName: '<AuthUserName from {{ .Values.netcool.secretName }} secret>'
  # AuthPassword: '<AuthPassword from {{ .Values.netcool.secretName }} secret>'
  ConfigKeyFile: '/opt/IBM/tivoli/netcool/etc/security/keys/encryption.keyfile'
  {{- end }}
  {{- end }}


{{ include "ibm-netcool-probe.probeCommonConfigWebhook" ( list "prometheus") }}

{{ include "ibm-netcool-probe.probeCommonConfigObjserv" ( . ) -}}
{{- end }}
