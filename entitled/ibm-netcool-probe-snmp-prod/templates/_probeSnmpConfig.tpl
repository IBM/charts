{{/* SNMP Probe for configuration */}}
{{- define "probeSnmpConfig" }}
mttrapd.props: |
  {{- if .Values.netcool.backupServer }}
  Server          : 'AGG_V'
  {{ else }}
  Server          : '{{ .Values.netcool.primaryServer }}'
  {{- end }}
  MessageLog      : 'stdout'
  MessageLevel    : '{{ default "warn" .Values.probe.messageLevel }}'
  {{- if eq (.Values.probe.rulesFile | upper) "NCKL"  }}
  RulesFile       : '$NC_RULES_HOME/snmptrap.rules'
  MIBFile         : ""
  {{- else }}
  RulesFile       : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/mttrapd.rules'
  {{- end }}
  Protocol        : 'ANY'
  Port            : 4162
  TrapStat        : 1
  
  ## Enable HTTP API
  NHttpd.EnableHTTP : TRUE
  NHttpd.ListeningPort : 8080

  # SNMPv3
  snmpv3ONLY : {{if .Values.probe.snmpv3.snmpv3Only }}1{{else}}0{{end}}
  ConfPath : '$NCHOME/omnibus/etc/'
  PersistentDir : '$NCHOME/omnibus/var/'
  SnmpConfigChangeDetectionInterval : {{ .Values.probe.snmpv3.snmpConfigChangeDetectionInterval }}
  ReuseEngineBoots : {{if .Values.probe.snmpv3.reuseEngineBoots }}1{{else}}0{{end}}
  UsmUserBase : {{.Values.probe.snmpv3.usmUserBase }}
  snmpv3MinSecurityLevel : {{ .Values.probe.snmpv3.snmpv3MinSecurityLevel }}
  


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