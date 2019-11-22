{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "gw.cem.sch.chart.config.values" -}}
sch:
  names:
    statefulSetName:
      releaseNameTruncLength: 25
  chart:
    labelType: prefixed
    appName: "gateway-cem"
    components:
        # Common component name for components
      common:
        name: "common"
        roleName: role
        roleBindingName: rolebinding
        serviceAccountName: sa
      gatecem:
        # the component name
        name: "cemgate"
        gatewayName: G_CEM
        gatewayPort: 4300
        gatewayHttpPort: 4080
        configmap:
          config:
            name: "config"
      gatecemtest:
        imageName: "netcool-integration-util"
        version: "2.0.0-amd64"

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

