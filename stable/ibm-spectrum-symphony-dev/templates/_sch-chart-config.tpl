{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.

*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-spectrum-symphony.sch.chart.config.values" -}}
sch:
  chart:
    image:
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      tty: true
    metering:
      productVersion: "7.3"
{{- if .Values.master.entitlementSecretName }}
      productName: "IBM Spectrum Symphony"
      productID: "28826cfd6dcd4beebca2cb2d9ef0ffe4"
      productMetric: ”VIRTUAL_PROCESSOR_CORE”
      productChargedContainers: ”All”
{{- else }}
      productName: "IBM Spectrum Symphony Community Edition"
      productID: "762afa9e64da4fec89452dd822e63370"
      productMetric: ”VIRTUAL_PROCESSOR_CORE”
      productChargedContainers: ””
{{- end }}
    labels:
      app: {{ include "sch.names.appName" (list .) }}
      release: {{ .Release.Name }}
      chart: "{{ .Chart.Name }}"
      heritage: "{{ .Release.Service }}"
      app.kubernetes.io/instance: {{ .Release.Name }}
      app.kubernetes.io/managed-by: {{ .Release.Service }}
      app.kubernetes.io/name: {{ .Chart.Name }}
      helm.sh/chart: {{ .Chart.Name }}
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
        - amd64
        - ppc64le
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
    specSecurity:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }} 
        runAsUser: 1000
{{- end }}
    containerSecurity:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }} 
      runAsUser: 1000
{{- end }}
      capabilities:
        drop:
          - ALL
    env:
      - name: LICENSE
        value: "accept"
      {{- if .Values.cluster.logsOnShared }}
      - name: LOGS_ON_SHARED
        value: "Y"
      {{- end }}
      {{- if .Values.cluster.enableSharedSubdir }}
      - name: SHARED_TOP_SUBDIR
        value: "{{ include "sch.names.fullName" (list .) }}"
      {{- end }}
      - name: CLUSTER_NAME
{{- if .Values.cluster.clusterName }}
        value: "{{ .Values.cluster.clusterName }}"
{{- else }}
        value: "{{ include "sch.names.fullName" (list .) }}"
{{- end }}

{{- end -}}

{{- define "ibm-spectrum-symphony.serviceAccountName" -}}
{{- if (.Values.serviceAccountName) -}}
{{- .Values.serviceAccountName -}}
{{- else -}}
{{ include "sch.names.fullName" (list .) }}-serviceaccount
{{- end -}}
{{- end -}}

