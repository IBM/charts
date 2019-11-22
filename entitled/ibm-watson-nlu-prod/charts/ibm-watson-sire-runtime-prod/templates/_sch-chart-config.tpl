{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sireRuntime.sch.chart.config.values" -}}
sch:
  chart:
    appName: "sire-runtime"
    labelType: "prefixed"
    components:
      sireRuntime:
        deploymentName: "model-mesh"
      meshDashboard:
        deploymentName: "model-mesh-dashboard"
    metering:
      productName: {{ .Values.product.name }}
      productVersion: {{ .Values.product.version }}
      productID: {{ .Values.product.id }}
    containerSecurityContextRuntime:
      securityContext:
        {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 10000
        {{- end }}
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
    containerSecurityContextMesh:
      securityContext:
        {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 2000
        {{- end }}
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
    specSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
        {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        fsGroup: 10000
        {{- end }}
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
{{- end -}}
