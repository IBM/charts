{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.stt.config.values" -}}
sch:
  chart:
    appName: "speech-to-text"
    components:
      stt_customization:
        name: "stt-customization"
      stt_async:
        name: "stt-async"
      rabbitmq:
        name: "rabbitmq"
        headless: "rabbitmq-ibm-rabbitmq-headless-svc"
        service: "rabbitmq-ibm-rabbitmq-svc"
      postgres:
        name: "postgres"
        proxyService: "postgres-proxy-service"
      minio:
        name: "minio"
        headless: "minio-ibm-minio-headless-svc"
        service: "minio-ibm-minio-svc"
        sseMasterKeySecret: "minio-sse-masterKeySecret"
      stt:
        name: "stt"
    metering:
      cloudpakName: {{ .Values.global.cloudpakName }}
      cloudpakId: {{ .Values.global.cloudpakId }}

      productName: {{ .Values.global.stt.productName }}
      productID: {{ .Values.global.stt.productId }}
      productVersion: {{ .Values.global.stt.productVersion }}
      productMetric: {{ .Values.global.stt.productMetric }}
      productCloudpakRatio: {{ .Values.global.productCloudpakRatio }}
      productChargedContainers: {{ .Values.global.productChargedContainers }}

      licenseType: "International Program License Agreement (IPLA)"
      uniqueKey: "00000"
    labelType: prefixed
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
#only apply runAsGroup label if Kubernetes version is >=1.14
{{- if semverCompare ">=1.14" .Capabilities.KubeVersion.GitVersion }}
        runAsGroup: 10000
{{- end }}
{{- end }}
    securityContextContainer:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
#only apply runAsGroup label if Kubernetes version is >=1.14
{{- if semverCompare ">=1.14" .Capabilities.KubeVersion.GitVersion }}
        runAsGroup: 10000
{{- end }}
{{- end }}
        privileged: false
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}

{{- define "sch.chart.tts.config.values" -}}
sch:
  chart:
    appName: "text-to-speech"
    components:
      tts_customization:
        name: "tts-customization"
      tts:
        name: "tts"
      postgres:
        name: "postgres"
        proxyService: "postgres-proxy-service"


    metering:
      cloudpakName: IBM Watson API Kit for IBM Cloud Pak for Data
      cloudpakId: df0b9c8451114e2d86d27ecb96afb37a
      cloudpakInstanceId: {{ .Values.global.cloudpakInstanceId }}

      productName: {{ .Values.global.tts.productName }}
      productID: {{ .Values.global.tts.productId }}
      productVersion: {{ .Values.global.tts.productVersion }}
      productMetric: {{ .Values.global.tts.productMetric }}
      productCloudpakRatio: "1:1"
      productChargedContainers: "All"

      licenseType: "International Program License Agreement (IPLA)"
      uniqueKey: "00000"
    labelType: prefixed
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
{{- if semverCompare ">=1.14" .Capabilities.KubeVersion.GitVersion }}
        runAsGroup: 10000
{{- end }}
{{- end }}
    securityContextContainer:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
#only apply runAsGroup label if Kubernetes version is >=1.14
{{- if semverCompare ">=1.14" .Capabilities.KubeVersion.GitVersion }}
        runAsGroup: 10000
{{- end }}
{{- end }}
        privileged: false
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
