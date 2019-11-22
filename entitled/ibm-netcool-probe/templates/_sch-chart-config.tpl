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
    appName: "ibm-netcool-probe"
    components:
        # Common component name for components
      common:
        name: "common"
        roleName: role
        roleBindingName: rolebinding
        serviceAccountName: sa
      prometheus:
        # the component name
        name: "prometheusprobe"
        configmap:
          config:
            name: "prometheusprobe-config"
          rules:
            name: "prometheusprobe-rules"

      logstash:
        # the component name
        name: "logstashprobe"
        configmap:
          config:
            name: "logstashprobe-config"
          rules:
            name: "logstashprobe-rules"
      
      cem:
        # the component name
        name: "cemprobe"
        configmap:
          config:
            name: "cemprobe-config"
          rules:
            name: "cemprobe-rules"

    metering:
      productName: "IBM Netcool Operations Insight v1.6.0.1 on IBM Cloud Private"
      productID: "4DBA2B5A269740CAAE5FECDAFE0568AA"
      productVersion: '1.6.0.1'
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

