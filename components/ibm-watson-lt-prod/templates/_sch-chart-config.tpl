{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-watson-lt.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}"
    labelType: "prefixed"
    components:
      api:
        name: "api"
      lid:
        name: "lid"
      segmenter:
        name: "segmenter"
      docTrans:
        name: "documents"
      postgres:
        name: "postgres"
        authSecret: "postgres-auth-secret"
        proxyService: "postgres-proxy-service"
      minio:
        name: "minio"
        authSecret: "minio-auth-secret"
        headless: "minio-ibm-minio-headless-svc"
        service: "minio-ibm-minio-svc"
        sseMasterKeySecret: "minio-sse-masterKeySecret"
    metering:
      productName: {{ .Values.product.name }}
      productVersion: {{ .Values.product.version }}
      productID: {{ .Values.product.id }}
      productMetric: VIRTUAL_PROCESSOR_CORE
      productChargedContainers: All
      productCloudpakRatio: "1:1"
      cloudpakName: "IBM Watson API Kit for IBM Cloud Pak for Data"
      cloudpakId: {{ .Values.product.id }}
      cloudpakVersion: 3.0.0
    mnlpPodSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true

{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        fsGroup: 10000
        runAsUser: 10000
#only apply runAsGroup label if Kubernetes version is >=1.14
{{- if semverCompare ">=1.14" .Capabilities.KubeVersion.GitVersion }}
        runAsGroup: 10000
{{- end }}
{{- end }}

    dropAllContainerSecurityContext:
      securityContext:
        privileged: false
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: false
        capabilities:
          drop:
          - ALL
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
{{- end -}}
