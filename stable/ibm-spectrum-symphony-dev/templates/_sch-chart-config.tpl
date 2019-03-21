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
      productVersion: "7.2.1.1"
{{- if .Values.master.entitlementSecretName }}
      productName: "IBM Spectrum Symphony"
      productID: "IBMSpectrumSymphony_5725G86"
{{- else }}
      productName: "IBM Spectrum Symphony CE"
      productID: "IBMSpectrumSymphony_5725G86_CE"
{{- end }}
    labels:
      app: {{ include "sch.names.appName" (list .) }}
      release: {{ .Release.Name }}
      chart: "{{ .Chart.Name }}"
      heritage: "{{ .Release.Service }}"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
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
        runAsUser: 1000
        fsGroup: 1000          
    containerSecurity:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
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
      {{- if .Values.cluster.enableSSHD }}
      - name: START_SSHD
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
