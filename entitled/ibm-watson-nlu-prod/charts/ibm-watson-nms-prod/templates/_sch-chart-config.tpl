{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "nms.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-watson-nms-prod"
    components:
      nms:
        name: "models-server"
      mma:
        name: "model-management-api"
    containerSecurityContext:
      securityContext:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        runAsNonRoot: true
        {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 2000
        {{- end }}
        capabilities:
          drop:
          - ALL
    testContainerSecurityContext:
      securityContext:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 99
{{- end }}
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
        runAsUser: 2000
        {{- end }}
    testSpecSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 99
    {{- end }}
    labelType: "prefixed"
{{- end -}}
