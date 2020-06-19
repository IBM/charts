{{- define "dg.metadataLabels" -}}
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "helm"
app.kubernetes.io/name: {{ template "dg.fullname" . }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end }}
