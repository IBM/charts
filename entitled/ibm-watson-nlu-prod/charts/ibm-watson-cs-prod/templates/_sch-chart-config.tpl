{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "cs.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-watson-cs"
    components:
      cs:
        name: "common-service"
    containerSecurityContext:
      securityContext:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        runAsNonRoot: true
        {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        # All NLU containers that run as non-root use the user & group 2000
        runAsUser: 2000
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
    labelType: "prefixed"
  configmap:
    commonServiceConfigConfigMap:
      name: "common-service-config-configmap"
{{- end -}}
