{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "probe.sch.chart.config.values" -}}
sch:
  chart:
    labelType: "prefixed"
    appName: "ibm-netcool-probe-syslogd"
    components: 
      probe:
        name: "syslogd"
    metering:
      productName: "IBM Tivoli Netcool/OMNIbus Syslogd Probe"
      productID: " DF6839B3B0E54A2693FD0C561EB7D4C8"
      productVersion: "5.0.3"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
          - {{ .Values.arch }}
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
{{- end -}}

