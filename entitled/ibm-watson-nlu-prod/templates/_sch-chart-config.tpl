{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "nlu.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-watson-nlu"
    components:
      nluserver:
        name: "nluserver"
      orchestrator:
        name: "orchestrator"
      keywords:
        name: "keywords"
      certgen:
        name: "certgen"
      mma:
        name: "model-management-api"
      nms:
        name: "models-server"
      commonService:
        name: "common-service"
    metering:
      productName: {{ .Values.product.name }}
      productID: {{ .Values.product.id }}
      productVersion: {{ .Values.product.version }}
    labelType: prefixed
    specSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        fsGroup: 1999
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
    credsSpecSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 523
{{- end }}
    containerSecurityContext:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
        privileged: false
        readOnlyRootFilesystem: false
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 2000
{{- end }}
    testContainerSecurityContext:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
        privileged: false
        readOnlyRootFilesystem: false
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 99
{{- end }}
    credsContainerSecurityContext:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
        privileged: false
        readOnlyRootFilesystem: false
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 523
{{- end }}
    labelType: "prefixed"
  configmap:
    featureServerOverridesConfigMap:
      name: "feature-server-overrides-configmap"
    nluServerPlugConfigMap:
      name: "nlu-server-plug-configmap"
    orchestratorWorkflowsConfigMap:
      name: "orchestrator-workflows-configmap"
    dvtConfigMap:
      name: "dvt-configmap"
{{- end -}}
