{{/* Syslogd Probe for configuration */}}
{{- define "ibm-netcool-probe-syslogd-prod.probeSyslogdConfig" }}
syslogd.props: |
{{- if .Values.netcool.backupServer }}
  Server          : 'AGG_V'
  {{ else }}
  Server          : '{{ .Values.netcool.primaryServer }}'
  {{- end }}
  MessageLog      : 'stdout'
  MessageLevel    : '{{ default "warn" .Values.probe.messageLevel }}'
  {{- if eq .Values.probe.rulesFile "NCKL"  }}
  RulesFile       : '$NC_RULES_HOME/syslog.rules'
  {{- else }}
  RulesFile       : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/syslogd.rules'
  {{- end }}
  UDPPort               : 4514
  ReadRulesFileTimeout  : {{ .Values.probe.readRulesFileTimeout }}
  WhiteSpaces           : '{{ .Values.probe.whiteSpaces }}'
  BreakCharacters       : '{{ .Values.probe.breakCharacters }}'
  OffsetOne             : {{ .Values.probe.offsetOne }}
  OffsetTwo             : {{ .Values.probe.offsetTwo }}
  OffSetZero            : {{ .Values.probe.offsetZero }}
  QuoteCharacters       : '{{ .Values.probe.quoteCharacters}}'
  TimeFormat            : '{{ .Values.probe.timeFormat }}'

  # Disabling Hostname Resolution to avoid errors when resolving hostnames from within a container
  NoNameResolution      : 1

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
