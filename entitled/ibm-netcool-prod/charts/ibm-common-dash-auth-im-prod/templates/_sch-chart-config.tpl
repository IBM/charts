{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "common-dash-auth-im-repo.sch.chart.config.values" -}}
sch:
  chart:
    appName: "common-dash-auth-im-repo"
    metering:
      productName: "IBM Netcool Operations Insight v1.6.0 on IBM Cloud private"
      productID: "4DBA2B5A269740CAAE5FECDAFE0568AA"
      productVersion: "1.6.0.2"
      productChargedContainers: "All"
    nginx:
      ingress:
        kubernetes.io/ingress.class: nginx
        ingress.kubernetes.io/secure-backends: "true"
        ingress.kubernetes.io/backend-protocol: "HTTPS"
    components:
      dashauth:
        name: "common-dash-auth-im-repo"
        servicePort: "8443"

    defaultSecurityContext:
      securityContext:
        runAsNonRoot: false
        runAsUser: 1000
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL

    labelType: "prefixed"
{{- end -}}


{{- /*
##############################
## common helper to get the root data based on parsing the template name
##############################
*/ -}}
{{- define "root.data" -}}
{{- $chartList := (splitList "/charts/" .Template.Name) -}}
{{- $rootChartName := (index (splitList "/" (index $chartList 0)) 0) -}}
{{- $rootDataTemplate := printf "%s.%s" $rootChartName "data" -}}
{{- include $rootDataTemplate . -}}
{{- end -}}
