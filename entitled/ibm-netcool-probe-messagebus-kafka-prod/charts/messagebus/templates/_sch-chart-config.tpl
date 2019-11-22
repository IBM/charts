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
    appName: "probe-mb-kfk"
    components: 
      probe:
        name: "mb"
        transport:
          type: "kafka"
        config:
          name: "configmap"
        rules:
          name: "rules"
      rbac:
        roleName: role
        roleBindingName: rolebinding
        serviceAccountName: sa
    metering:
      productName: "IBM Netcool Operations Insight v1.6.0 on IBM Cloud Private"
      productID: "4DBA2B5A269740CAAE5FECDAFE0568AA"
      productVersion: '1.6.0'
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
{{- end -}}
