
{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.flink.config.values" -}}
sch:
  chart:
    appName: "ibm-flink"
    labelType: prefixed
    components:
      jobManager: "job-manager"
      taskManager: "task-manager"
    metering:
      productName: "{{ .Values.global.product.name }}"
      productID: "{{ .Values.global.product.id }}"
      productVersion: "{{ .Values.global.product.version }}"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "All"
      productCloudpakRatio: ""
      cloudpakName: "IBM Cloud Pak for Data"
      cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
      cloudpakVersion: "3.0.1"
    podSecurityContext:
      securityContext:
        runAsNonRoot: true
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
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
{{- end -}}
