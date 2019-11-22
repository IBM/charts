{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "compare-and-comply"
    components:
      metrics:
        name: "metrics"
      frontend:
        name: "frontend"
      test:
        name: "cnc-test"
    metering:
      productName: "IBM Watson Compare and Comply for ICP for Data"
      productID: "ICP4D-addon-6fa32f78f6144322a237d2312fe08d12-compare-and-comply"
      productVersion: "1.1.6"
    labelType: "prefixed"
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
    securityContextSpec:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
    securityContextContainer:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
        privileged: false
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
