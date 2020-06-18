
{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.zeno.config.values" -}}
sch:
  chart:
    appName: {{ .Values.global.product.schName }}
    labelType: prefixed
    components:
      addon: {{ .Values.global.addon.name | quote }}
      eventGrouping: "event-grouping"
      alertLocalization: "alert-localization"
      chatopsSlackIntegrator: {{ .Values.global.chatopsSlackIntegrator.name | quote }}
      chatopsOrchestrator: "chatops-orchestrator"
      logAnomalyDetector: "log-anomaly-detector"
      modelTrainConsole: "model-train-console"
      persistence: "persistence"
      similarIncidents: "similar-incidents-service"
      topology: "topology"
      qualityEvaluation: "qes"
      controller: {{ .Values.global.controller.name | quote }}
    config:
      tls: "tls"
      kafka: "kafka"
      elasticsearch: "elasticsearch"
      componentUrls: "component-urls"
      globalConfigMap: "global-config"
      zenoEngineConfigMap: "zeno-engine-config"
      modelTrainConsole: "model-train-console-config"
    tests:
      coreTests: "core-tests"
      mockServer: "mock-server"
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
