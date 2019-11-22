{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "wks.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-watson-ks"
    components:
      frontend:
        name: "frontend"
      broker:
        name: "servicebroker"
      dispatcher:
        name: "dispatcher"
      test:
        name: "test"
      init:
        name: "init"
      globalconfig:
        name: "globalconfig"
      credsGen:
        name: "cred-gen"
      credsCleanUp:
        name: "cred-clean-up"
    metering:
{{ tpl ( .Values.global.umbrellaChartMetering | toYaml ) . | indent 6 }}
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
    securityContext1:
      securityContext:
        runAsNonRoot: true
  {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1001
        runAsGroup: 1001
  {{- end }}
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
    credsPodSecurityContext:
      runAsNonRoot: true
  {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      runAsUser: 523
  {{- end }}
{{- end -}}
