{{- define "tests.resources" }}
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "1"
    memory: "1Gi"
{{- end }}

{{- define "tests.labels" }}
app: {{ include "informix-ibm.fullname" . }}-test 
chart: "{{ .Chart.Name }}"
heritage: "{{ .Release.Service }}"
release: "{{ .Release.Name }}"
app.kubernetes.io/instance: {{ include "informix-ibm.fullname" . }}
app.kubernetes.io/managed-by: helm 
app.kubernetes.io/name: deployment 
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end }}