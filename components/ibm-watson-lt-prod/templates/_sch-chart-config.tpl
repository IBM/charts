{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-watson-lt.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}"
    labelType: "prefixed"
    components:
      api:
        name: "api"
      lid:
        name: "lid"
      segmenter:
        name: "segmenter"
      docTrans:
        name: "documents"
    metering:
      productName: {{ .Values.product.name }}
      productVersion: {{ .Values.product.version }}
      productID: {{ .Values.product.id }}
      productMetric: VIRTUAL_PROCESSOR_CORE
      productChargedContainers: All
      cloudpakName: IBM Cloud Pak for Data
      cloudpakId: eb9998dcc5d24e3eb5b6fb488f750fe2
      cloudpakVersion: 3.0.0
    mnlpPodSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        fsGroup: 10000
        runAsUser: 10000
{{- end }}

    dropAllContainerSecurityContext:
      securityContext:
        privileged: false
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: false
        capabilities:
          drop:
          - ALL
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
{{- end -}}
