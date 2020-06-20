{{- define "discovery.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}"
    components:
      apiTest:
        name: "api-post-install-test"
      cnm:
        name: cnm
        apiServer:
          name: cnm-api
        test:
          name: cnm-api-test
      cp4d:
        nginx:
          name: ibm-nginx-svc
      dataDeletionAgent:
        name: "training-data-deletion-agent"
      dfs:
        name: "dfs-induction"
      dfsSecret:
        name: "dfs-secret"
      gateway:
        name: "discovery-gateway-svc"
      haywire:
        name: "haywire"
      haywireTest:
        name: "haywire-test"
      mm:
        name: "dfs-modelmesh"
      mmRuntime:
        name: "mm-runtime"
      mmServer:
        name: "mm-server"
      projectDataPrepAgent:
        name: "project-data-prep-agent"
      postOffice:
        name: "post-office"
      rankerCleanerAgent:
        name: "ranker-cleaner-agent"
      rankerCleanerAgentTest:
        name: "ranker-cleaner-agent-test"
      rankerMaster:
        name: "ranker-master"
      rankerMasterTest:
        name: "ranker-master-test"
      rankerMonitorAgent:
        name: "ranker-monitor-agent"
      rankerMonitorAgentTest:
        name: "ranker-monitor-agent-test"
      rankerRest:
        name: "ranker-rest"
      rankerRestTest:
        name: "rest-test"
      rankerSecret:
        name: "ranker-secret"
      sdu:
        name: "sdu-api"
      sduApiTest:
        name: "sdu-api-test"
      serveRanker:
        name: "serve-ranker"
      serveRankerTest:
        name: "serve-ranker-test"
      tooling:
        name: "discovery-tooling"
      toolingTest:
        name: tooling-test
      trainingAgents:
        name: "training-agents"
      trainingAgentsTest:
        name: "training-agents-test"
      trainingCrud:
        name: "training-data-crud"
      trainingCrudInitContainer:
        name: "training-crud-init-container"
      trainingCrudTest:
        name: "training-data-crud-test"
      trainingJobTemplate:
        name: "training-job-template-config"
      trainingRest:
        name: "training-rest"
      trainingRestTest:
        name: "training-rest-test"
      wexCore:
        name: wex-core
        ck:
          credential:
            secret:
              name: wex-core-ck-secret
          genJob:
            name: wex-core-ck-gen
          delJob:
            name: wex-core-ck-del
        converter:
          name: converter
        crawler:
          name: crawler
        gateway:
          name: gateway
          init:
            name: gateway-init
          nginx:
            port: 60443
          port: 10443
        ingestionApi:
          name: ingestion-api
          port: 9463
        ingestion:
          pvc:
            name: ingestion-userdata
        inlet:
          name: inlet
        management:
          name: management
          port: 9443
        minerapp:
          name: minerapp
          port: 9483
          adminapp:
            port: 9473
        orchestrator:
          name: orchestrator
          port: 9544
        outlet:
          name: outlet
        rapi:
          name: rapi
          port: 9453
        statelessApi:
          secret:
            name: statelss-api-etcd-conn
          credGen:
            name: stateless-api-cred-gen
          proxy:
            name: stateless-api-rest-proxy
            port: 8394
          runtime:
            name: stateless-api-model-runtime
            port: 8033
        test:
          name: wex-core-test
        wksml:
          name: wksml
          port: 5194
    labelType: prefixed
    metering:
    {{- if .Values.global.contentIntelligence.enabled }}
      productName: {{ .Values.global.contentIntelligence.metering.productName }}
      productID: {{ .Values.global.contentIntelligence.metering.productID }}
    {{- else }}
      productName: {{ .Values.global.metering.productName }}
      productID: {{ .Values.global.metering.productID }}
    {{- end }}
      productVersion: {{ .Values.global.metering.productVersion }}
      productMetric: {{ .Values.global.metering.productMetric }}
      productChargedContainers: {{ .Values.global.metering.productChargedContainers }}
      cloudpakName: {{ .Values.global.metering.cloudpakName }}
      cloudpakId: {{ .Values.global.metering.cloudpakId }}
      cloudpakVersion: {{ .Values.global.metering.cloudpakVersion }}
    restrictedPodSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
{{- if .Values.global.private }}
        runAsNonRoot: true
{{- end }}
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1000
{{- end }}
{{- if .Values.global.activityTracker.enabled }}
        fsGroup: 0
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
    watsonUserSecurityContext:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
        privileged: false
        readOnlyRootFilesystem: false
      {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1002
      {{- end }}
    watsonUserPodSecurityContext:
      securityContext:
        runAsNonRoot: true
      {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1002
      {{- end }}
    wexUserSpecSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
{{- if .Values.global.private }}
        runAsNonRoot: true
{{- end }}
        runAsUser: 60001
{{- if .Values.global.activityTracker.enabled }}
        fsGroup: 0
{{- end }}
    wexUserPodSecurityContext:
      securityContext:
        runAsNonRoot: true
        runAsUser: 60001
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
    wexUserSecurityContext:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
        privileged: false
        readOnlyRootFilesystem: false
        runAsUser: 60001
  names:
    statefulSetName:
      maxLength: 55
      releaseNameTruncLength: 36
      appNameTruncLength: 13
      compNameTruncLength: 12
{{- end }}
