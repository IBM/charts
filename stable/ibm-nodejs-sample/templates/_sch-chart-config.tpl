{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "nodejsSample.sch.chart.config.values" -}}
sch:
  chart:
    appName: "nodejsSample"
    components:
      nodejsSample:
        name: "nodejs"
    metering:
      productName: "Node.js Sample Application"
      productID: "Node.js_Sample_Application_2.0.0_perpetual_00000"
      productVersion: "2.0.0"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
        - ppc64le
        - s390x
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
{{- end -}}
