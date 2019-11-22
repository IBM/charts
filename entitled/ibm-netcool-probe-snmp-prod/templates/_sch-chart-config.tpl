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
    labelType: prefixed
    appName: "ibm-netcool-probe-snmp"
    components: 
      probe:
        name: "snmp"
    metering:
      productName: "IBM Tivoli Netcool/OMNIbus SNMP Probe"
      productID: "B04FEFB0F41747999A98EFA2DBF44238"
      productVersion: "20.2.0"
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
