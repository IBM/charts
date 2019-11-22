{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "core.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "core.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "core.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Update the image details in the deployment yaml, if it is Non ICp env then first
Block will work as it was and if it is ICp then the else block where we will replace
the AFFAS details with the registry details that is populated by ICp in values.yaml
*/}}
{{- define "core.readConfig" -}}
    {{- $top := first . -}}
    {{- $name := index . 1 -}}
    {{- range $line := $top.Files.Lines "config/image_manifest.json" }}{{if contains ($name|quote) $line}}{{$line|replace ($name|quote) "" | replace ": " "" | replace "," "" | replace "\\\"" "" | replace "    " "" | trim }}{{ end }}{{ end }}
{{- end -}}

{{- define "coreicp.readConfig" -}}
    {{- $top := first . -}}
    {{- $name := (index . 1) -}}
    {{- $registry := (index . 2) -}}
    {{- range $line := $top.Files.Lines "config/image_manifest.json" }}{{if contains ($name|quote) $line}}{{$line|replace ($name|quote) "" | replace ": " "" | replace "," "" | replace "\\\"" "" | replace "    " "" | replace "ibmcb-docker-local.artifactory.swg-devops.com/" $registry | trim }}{{ end }}{{ end }}
{{- end -}}


{{- define "core.labels" -}}
app: "{{ template "core.fullname" . }}"
chart: "{{ .Chart.Name }}"
release: {{ .Release.Name | quote }}
heritage: "{{ .Release.Service }}"
{{- end -}}

{{- define "core.test-labels" -}}
app: "{{ template "core.fullname" . }}"
chart: "{{ .Chart.Name }}-test"
release: {{ .Release.Name | quote }}
heritage: "{{ .Release.Service }}"
{{- end -}}

{{/*
ICP requires metering annotations to meter the usage
hence these annotations are added
*/}}
{{- define "core.icpMetering" -}}
productName: {{ template "productName" . | quote}}
productID: {{ template "productID" . | quote}}
productVersion: {{ .Chart.Version }}
{{- end -}}

{{/*
This allows the user to run as root(0) user,
regardless of k8s cluster settings
*/}}
{{- define "core.securityContext" -}}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end -}}

{{/*
Security context settings container level
*/}}
{{- define "core.container.securityContext" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1104
  capabilities:
    drop:
    - ALL
{{- end -}}

{{/*
Use imagePullSecrets to pull images from registry
*/}}
{{- define "core.imagePullSecrets" -}}
imagePullSecrets:
  - name: myregistrykey
{{- end -}}

{{- define "productName" -}}
"IBM Cloud Management Platform"
{{- end -}}

{{- define "productID" -}}
"IBMCloudManagementPlatform_5737E67_3200_EE_000"
{{- end -}}

{{/*
Detects if running on an ICP cluster, and Set ignoreIcpCheck to skip
*/}}
{{- define "isIcp" -}}
{{- if not (.Values.ignoreIcpCheck) -}}
{{- if or ( contains "icp" $.Capabilities.KubeVersion.GitVersion ) ( $.Capabilities.APIVersions.Has "security.openshift.io/v1" ) -}}
{{- $_ := set $.Values "isIcp" true -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
If not an ICP environment use nginx.ingress, while if ICP use ingress
*/}}
{{- define "nginx.ingress" -}}
nginx.ingress.kubernetes.io/rewrite-target: /
nginx.ingress.kubernetes.io/ssl-passthrough: "true"
nginx.ingress.kubernetes.io/proxy-body-size: 0m
nginx.ingress.kubernetes.io/proxy-read-timeout: "1200"
nginx.ingress.kubernetes.io/proxy-send-timeout: "1200"
ingress.kubernetes.io/rewrite-target: /
ingress.kubernetes.io/ssl-passthrough: "true"
ingress.kubernetes.io/proxy-body-size: 0m
ingress.kubernetes.io/proxy-read-timeout: "1200"
ingress.kubernetes.io/proxy-send-timeout: "1200"
{{- end -}}


{{- define "deployClassConfig" -}}
{{- $top := first . -}}
{{- $name := (index . 1) -}}
{{- $flavour := (index $top.Values.deploymentClass) -}}
{{- $filen := printf "config/resources/%s-config.json" $flavour -}}
{{- $limitscpu := printf "%s_limits_cpu" $name -}}
{{- $limitsmem := printf "%s_limits_mem" $name -}}
{{- $requestscpu := printf "%s_requests_cpu" $name -}}
{{- $requestsmem := printf "%s_requests_mem" $name -}}
limits:
  memory:  {{ range $line := $top.Files.Lines $filen }}{{if contains ($limitsmem) $line}}{{ $line | replace ($limitsmem|quote) "" | replace ":" ""  | replace "," "" | trim }}{{ end }}{{ end }}
  cpu:  {{ range $line := $top.Files.Lines $filen }}{{if contains ($limitscpu) $line}}{{ $line | replace ($limitscpu|quote) "" | replace ":" ""  | replace "," "" | trim }}{{ end }}{{ end }}
requests:
  cpu:  {{ range $line := $top.Files.Lines $filen }}{{if contains ($requestscpu|quote) $line}}{{ $line | replace ($requestscpu|quote) "" | replace ":" ""  | replace "," "" | trim }}{{ end }}{{ end }}
  memory: {{ if eq ($top.Values.enableDevSettings|quote|lower) "\"true\"" }}{{"0"|quote}}{{ else }}{{ range $line := $top.Files.Lines $filen }}{{if contains ($requestsmem|quote) $line}}{{ $line | replace ($requestsmem|quote) "" | replace ":" ""  | replace "," "" | trim }}{{ end }}{{ end }}{{ end }}
{{- end -}}
