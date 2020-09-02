{{- define "discovery.mantle.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}"
    components:
      hdp:
        name: hdp
        networkPolicy:
          name: hdp-network-policy
      postgresConfigJob:
        name: "dlaas-postgres-config"
      glimpse:
        builder:
          name: "glimpse-builder"
        query:
          name: "glimpse-query"
      cnm:
        name: cnm
        apiServer:
          name: cnm-api
        test:
          name: cnm-api-test
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

