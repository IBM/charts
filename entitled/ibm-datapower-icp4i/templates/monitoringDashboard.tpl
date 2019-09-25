{{- if and (.Capabilities.APIVersions.Has "monitoringcontroller.cloud.ibm.com/v1") .Values.dashboard.enabled }}
apiVersion: monitoringcontroller.cloud.ibm.com/v1
kind: MonitoringDashboard
metadata:
  name: {{ template "ibm-datapower-icp4i.fullname" . }}-monitoring-dashboard
  labels:
    helm.sh/chart: {{ .Chart.Name}}-{{ .Chart.Version | replace "+" "_" }}
    app.kubernetes.io/name: {{ template "ibm-datapower-icp4i.fullname" . }}
    release: "{{ .Release.Name }}"
    app.kubernetes.io/instance: "{{ .Release.Name }}"
    app.kubernetes.io/managed-by: "{{ .Release.Service }}"
spec:
  enabled: true
  data: |-
{{ .Files.Get "ibm_cloud_pak/pak_extensions/dashboards/datapower-grafana.json" | indent 4 }}
{{- end }}
