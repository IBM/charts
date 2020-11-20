{{- define "voice-gateway.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Chart.Name }}"
    components:
      sip:
        name: "sip"
      orchestrator:
        name: "orchestrator"
    metering:
      productName: {{ .Values.addon.productName }}
      productID: {{ .Values.addon.productID }}
      productMetric: 'THOUSAND_MONTHLY_MINUTES'
      productChargedContainers: 'All'
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      com.ibm.cloud.metering.selfmeter: "true"
{{- end }}
      productVersion: "{{ .Chart.AppVersion }}"
    labelType: new
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
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
