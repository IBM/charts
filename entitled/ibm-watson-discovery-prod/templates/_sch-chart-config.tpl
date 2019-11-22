{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "discovery.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}"
    components:
      addon:
        name: "addon"
      gateway:
        name: "gateway"
      tooling:
        name: "tooling"
      trainingRest:
        name: "training-rest"
      trainingCrud:
        name: "training-data-crud"
      rankerRest:
        name: "rest"
      sharedPrivilegedRole:
        name: "shared-privileged-role"
      sharedPrivilegedRoleBinding:
        name: "shared-privileged-role-binding"
      sharedRole:
        name: "shared-role"
      sharedRoleBinding:
        name: "shared-role-binding"
      sdu:
        name: "sdu-api"

    metering:
      productName: "{{ .Values.global.metering.productName }}"
      productID: "{{ .Values.global.metering.productID }}"
      productVersion: "{{ .Values.global.metering.productVersion }}"
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
