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
      stt:
        name: "stt"
    metering:
      productName: {{ .Values.global.stt.productName }}
      productID: {{ .Values.global.stt.productId }}
      productVersion: {{ .Values.global.stt.productVersion }}
      productMetric: VIRTUAL_PROCESSOR_CORE

      cloudpakName: IBM Cloud Pak for Data
      cloudpakId: eb9998dcc5d24e3eb5b6fb488f750fe2
      cloudpakVersion: 3.0.0

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
{{- end }}
    securityContextContainer:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
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
      tts:
        name: "tts"
    metering:
      productName: {{ .Values.global.tts.productName }}
      productID: {{ .Values.global.tts.productId }}
      productVersion: {{ .Values.global.tts.productVersion }}
      productMetric: VIRTUAL_PROCESSOR_CORE

      cloudpakName: IBM Cloud Pak for Data
      cloudpakId: eb9998dcc5d24e3eb5b6fb488f750fe2
      cloudpakVersion: 3.0.0

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
{{- end }}
    securityContextContainer:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
        privileged: false
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
