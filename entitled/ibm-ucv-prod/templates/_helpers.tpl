{{/* vim: set filetype=mustache: */}}

{{- define "root.url.appHome" -}}
  {{- if .Values.ingress.enable -}}
    {{- $ingressPath := .Values.ingress.path | trimSuffix "/" -}}
    {{- printf "%s://%s%s" .Values.url.protocol .Values.url.domain $ingressPath -}}
  {{- else -}}
    {{- printf "%s://%s:%g" .Values.url.protocol .Values.url.domain .Values.url.port -}}
  {{- end -}}
{{- end -}}

{{- define "root.url.reportingUi" -}}
  {{- $servicePath := "reports" -}}
  {{- if .Values.ingress.enable -}}
    {{- $ingressPath := .Values.ingress.path | trimSuffix "/" -}}
    {{- printf "%s://%s%s/%s" .Values.url.protocol .Values.url.domain $ingressPath $servicePath -}}
  {{- else -}}
    {{- printf "%s://%s:%g/%s" .Values.url.protocol .Values.url.domain .Values.url.port $servicePath -}}
  {{- end -}}
{{- end -}}

{{- define "root.url.cr" -}}
  {{- $servicePath := "deploymentPlans" -}}
  {{- if .Values.ingress.enable -}}
    {{- $ingressPath := .Values.ingress.path | trimSuffix "/" -}}
    {{- printf "%s://%s%s/%s" .Values.url.protocol .Values.url.domain $ingressPath $servicePath -}}
  {{- else -}}
    {{- printf "%s://%s:%g/%s" .Values.url.protocol .Values.url.domain .Values.url.port $servicePath -}}
  {{- end -}}
{{- end -}}

{{- define "root.url.securityAuth" -}}
  {{- $servicePath := "security-api/auth" -}}
  {{- if .Values.ingress.enable -}}
    {{- $ingressPath := .Values.ingress.path | trimSuffix "/" -}}
    {{- printf "%s://%s%s/%s" .Values.url.protocol .Values.url.domain $ingressPath $servicePath -}}
  {{- else -}}
    {{- printf "%s://%s:%g/%s" .Values.url.protocol .Values.url.domain .Values.url.port $servicePath -}}
  {{- end -}}
{{- end -}}

{{- define "root.url.securityApiHost" -}}
  {{- $servicePath := "security-api" -}}
  {{- if .Values.ingress.enable -}}
    {{- $ingressPath := .Values.ingress.path | trimSuffix "/" -}}
    {{- printf "%s://%s%s/%s" .Values.url.protocol .Values.url.domain $ingressPath $servicePath -}}
  {{- else -}}
    {{- printf "%s://%s:%g/%s" .Values.url.protocol .Values.url.domain .Values.url.port $servicePath -}}
  {{- end -}}
{{- end -}}

{{- define "root.url.mapApi" -}}
  {{- $servicePath := "multi-app-pipeline-api" -}}
  {{- if .Values.ingress.enable -}}
    {{- $ingressPath := .Values.ingress.path | trimSuffix "/" -}}
    {{- printf "%s://%s%s/%s" .Values.url.protocol .Values.url.domain $ingressPath $servicePath -}}
  {{- else -}}
    {{- printf "%s://%s:%g/%s" .Values.url.protocol .Values.url.domain .Values.url.port $servicePath -}}
  {{- end -}}
{{- end -}}

{{- define "root.url.releaseEventsApi" -}}
  {{- $servicePath := "release-events-api" -}}
  {{- if .Values.ingress.enable -}}
    {{- $ingressPath := .Values.ingress.path | trimSuffix "/" -}}
    {{- printf "%s://%s%s/%s" .Values.url.protocol .Values.url.domain $ingressPath $servicePath -}}
  {{- else -}}
    {{- printf "%s://%s:%g/%s" .Values.url.protocol .Values.url.domain .Values.url.port $servicePath -}}
  {{- end -}}
{{- end -}}

{{- define "root.url.reportingConsumer" -}}
  {{- $servicePath := "reporting-consumer" -}}
  {{- if .Values.ingress.enable -}}
    {{- $ingressPath := .Values.ingress.path | trimSuffix "/" -}}
    {{- printf "%s://%s%s/%s" .Values.url.protocol .Values.url.domain $ingressPath $servicePath -}}
  {{- else -}}
    {{- printf "%s://%s:%g/%s" .Values.url.protocol .Values.url.domain .Values.url.port $servicePath -}}
  {{- end -}}
{{- end -}}

{{- define "ucv.nodeAffinity" -}}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
        - amd64
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    preference:
      matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
        - amd64
{{- end -}}

{{- define "ucv.resources" -}}
limits:
  memory: {{ (index .Values.resources.limits.memory .ucvService) | default .Values.resources.limits.memory.default }}
  cpu: {{ (index .Values.resources.limits.cpu .ucvService) | default .Values.resources.limits.cpu.default }}
requests:
  memory: {{ (index .Values.resources.requests.memory .ucvService) | default .Values.resources.requests.memory.default }}
  cpu: {{ (index .Values.resources.requests.cpu .ucvService) | default .Values.resources.requests.cpu.default }}
{{- end -}}

{{- define "ucv.productAnnotations" -}}
productName: 'UrbanCode Velocity'
productID: '49333afbd55b467987bfff5305891dd2'
productVersion: '{{ .Chart.Version }}'
{{- end -}}

{{- define "ucv.securityContext" -}}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: false
runAsNonRoot: true
runAsUser: 1000162043
capabilities:
  drop:
  - ALL
{{- end -}}

{{- define "ucv.imagePullSecrets" -}}
- name: {{.Values.secrets.imagePull}}
- name: "sa-{{ .Release.Namespace }}"
{{- end -}}

{{- define "ucv.labels" -}}
app: velocity
app.kubernetes.io/name: velocity
chart: '{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}'
helm.sh/chart: '{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}'
release: '{{ .Release.Name }}'
app.kubernetes.io/instance: {{ .Release.Name }}
heritage: '{{ .Release.Service }}'
app.kubernetes.io/managed-by: '{{ .Release.Service }}'
{{- end -}}

{{- define "ucv.specTemplateLabels" -}}
app: velocity
app.kubernetes.io/name: velocity
chart: '{{ .Chart.Name }}'
helm.sh/chart: '{{ .Chart.Name }}'
release: '{{ .Release.Name }}'
app.kubernetes.io/instance: {{ .Release.Name }}
heritage: '{{ .Release.Service }}'
app.kubernetes.io/managed-by: '{{ .Release.Service }}'
service: {{ .ucvService }}
{{- end -}}

{{- define "ucv.selector" -}}
app: velocity
release: {{ .Release.Name }}
service: {{ .ucvService }}
{{- end -}}

{{- define "ucv.livenessProbe" -}}
httpGet:
  path: /alive
  port: {{ .ucvLivenessPort }}
initialDelaySeconds: 300
timeoutSeconds: 10
periodSeconds: 10
failureThreshold: 3
{{- end -}}

{{- define "ucv.readinessProbe" -}}
httpGet:
  path: /ready
  port: {{ .ucvReadinessPort }}
initialDelaySeconds: 15
timeoutSeconds: 5
periodSeconds: 5
failureThreshold: 5
{{- end -}}

{{- define "ucv.mongoUrl" -}}
{{- if .Values.mongo }}
value: {{ .Values.mongo.url }}
{{- else }}
valueFrom:
  secretKeyRef:
    name: {{ .Values.secrets.database }}
    key: password
{{- end }}
{{- end -}}