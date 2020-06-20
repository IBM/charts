{{- define "discovery.crust.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}"
    components:
      minioSecretJob:
        name: "minio-job"
    labelType: "prefixed"
    metering:
      productName: {{ .Values.global.metering.productName }}
      productID: {{ .Values.global.metering.productID }}
      productVersion: {{ .Values.global.metering.productVersion }}
      productMetric: {{ .Values.global.metering.productMetric }}
      productChargedContainers: {{ .Values.global.metering.productChargedContainers }}
      cloudpakName: {{ .Values.global.metering.cloudpakName }}
      cloudpakId: {{ .Values.global.metering.cloudpakId }}
      cloudpakVersion: {{ .Values.global.metering.cloudpakVersion }}
    restrictedPodSecurityContext:
      securityContext:
        runAsNonRoot: true
      {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1000
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
        runAsUser: 1000
      {{- end }}
{{- end -}}

