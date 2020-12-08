{{- define "discovery.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}"
    components:
      operator:
        name: "operator"
      appConfig:
        name: "app-config"
    labelType: prefixed
    metering:
      productName: {{ .Values.global.metering.productName }}
      productID: {{ .Values.global.metering.productID }}
      productVersion: {{ .Values.global.metering.productVersion }}
      productMetric: {{ .Values.global.metering.productMetric }}
      productChargedContainers: {{ .Values.global.metering.productChargedContainers }}
      productCloudpakRatio: {{ .Values.global.metering.productCloudpakRatio }}
      cloudpakName: {{ .Values.global.metering.cloudpakName }}
      cloudpakId: {{ .Values.global.metering.cloudpakId }}
      cloudpakInstanceId: {{ .Values.global.cloudpakInstanceId }}
    restrictedPodSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1001
{{- end }}
    restrictedSecurityContext:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
        privileged: false
        readOnlyRootFilesystem: false
      {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1001
      {{- end }}
{{- end }}
