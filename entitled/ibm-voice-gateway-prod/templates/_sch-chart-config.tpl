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
      productName: {{ .Values.addon.displayName }}
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
{{ $noDotAppVersion := splitList "." .Chart.AppVersion | join ""}}
      productID: {{ printf "%s_%s_%s_%s_%s" "WatsonVoiceGateway" "5737D52" $noDotAppVersion "IL" "0000" | trunc 63 }}
      com.ibm.cloud.metering.selfmeter: "true"
{{- else }}
      productID: {{ printf "%s-%s-%s-%s-%s" "ICP4D" "addon" "IBMWatson" .Release.Name .Values.addon.serviceId | trunc 63 }}
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
