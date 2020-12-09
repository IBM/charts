{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibmWatsonAssistantOperator.sch.chart.config.values" -}}
sch:
  chart:
    labelType: new
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
    metering:
  {{- if .Values.metering }}
    {{- if kindIs "string" .Values.metering }}
{{ tpl .Values.metering              . | indent 6 }}
    {{- else }}
{{ tpl ( .Values.metering | toYaml ) . | indent 6 }}
    {{- end }}
  {{- else }}
      productID: "2eb0774c8a3841f09b7b75c9fb1fbdd7"
      productName: "IBM Watson Assistant for IBM Cloud Pak for Data"
      productVersion: "{{ .Chart.AppVersion }}"
      cloudpakName: "IBM Cloud Pak for Data"
      cloudpakId: "2eb0774c8a3841f09b7b75c9fb1fbdd7"
      cloudpakInstanceId: "8d68a333-1cff-4b43-8061-4b6e489aeca2" # ????
      productChargedContainers: "All"
      productMetric:            "VIRTUAL_PROCESSOR_CORE"
  {{- end }}
    podSecurityContext:
      runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      fsGroup: {{ .Values.securityContext.fsGroup }}
      runAsUser: {{ .Values.securityContext.runAsUser }}
      runAsGroup: {{ .Values.securityContext.runAsGroup }}
    {{- end }} 
    containerSecurityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
{{- end -}}
