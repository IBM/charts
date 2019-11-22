{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.

*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "etcd.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-etcd"
    labelType: new
    metering:
    {{- if .Values.metering }}
      {{- if kindIs "string" .Values.metering }}
{{ tpl .Values.metering . | indent 6 }}
      {{- else }}
{{ tpl ( .Values.metering | toYaml ) . | indent 6 }}
      {{- end }}
    {{- else }}
      productName: "{{ .Release.Name }}"
      productID: "{{ .Release.Name }}_{{ .Values.image.tag }}_free_00000"
      productVersion: "{{ .Values.image.tag }}"
    {{- end }}
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
    securityContext1:
      securityContext:
        runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1000
        fsGroup: 1000
    {{- end }}
        supplementalGroups:
        - 1000
    securityContext2:
      securityContext:
        runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1000
    {{- end }}
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}