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
      productName: "IBM Watson Speech To Text"
      productID: "ICP4D-addon-344c12fda5fd4b94918c3ab349ebc5c8-speech-to-text"
      productVersion: "1.0.0"
      licenseType: "International Program License Agreement (IPLA)"
      uniqueKey: "00000"
    labelType: prefixed
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
      productName: "IBM Watson Text To Speech"
      productID: "ICP4D-addon-5ed60094aaaf41809bedf65c9b38cdcc-text-to-speech"
      productVersion: "1.0.0"
      licenseType: "International Program License Agreement (IPLA)"
      uniqueKey: "00000"
    labelType: prefixed
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
