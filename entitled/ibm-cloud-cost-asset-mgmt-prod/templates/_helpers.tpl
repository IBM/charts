{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cam.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cam.fullname" -}}
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
{{- define "cam.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "cam.readConfig" -}}
    {{- $top := first . -}}
    {{- $name := index . 1 -}}
    {{- range $line := $top.Files.Lines "config/image_manifest.json" }}{{if contains ($name|quote) $line}}{{$line|replace ($name|quote) "" | replace ": " "" | replace "," "" | replace "\\\"" "" | replace "    " "" | trim }}{{ end }}{{ end }}
{{- end -}}
{{- define "camicp.readConfig" -}}
    {{- $top := first . -}}
    {{- $name := (index . 1) -}}
    {{- $registry := (index . 2) -}}
    {{- range $line := $top.Files.Lines "config/image_manifest.json" }}{{if contains ($name|quote) $line}}{{$line|replace ($name|quote) "" | replace ": " "" | replace "," "" | replace "\\\"" "" | replace "    " "" | replace "ibmcb-docker-local.artifactory.swg-devops.com/" $registry | trim }}{{ end }}{{ end }}
{{- end -}}
{{- define "cam.labels" -}}
app: "{{ template "cam.fullname" . }}"
chart: "{{ .Chart.Name }}"
release: {{ .Release.Name | quote }}
heritage: "{{ .Release.Service }}"
{{- end -}}
{{- define "cam.test-labels" -}}
app: "{{ template "cam.fullname" . }}"
chart: "{{ .Chart.Name }}-test"
release: {{ .Release.Name | quote }}
heritage: "{{ .Release.Service }}"
{{- end -}}
{{- define "cam.icpMetering" -}}
productName: {{ template "productName" . | quote}}
productID: {{ template "productID" . | quote}}
productVersion: {{ .Chart.AppVersion }}
{{- end -}}
{{- define "productName" -}}
"IBM Cloud Cost and Asset Management"
{{- end -}}
{{- define "productID" -}}
"IBMCloudCostAssetManagement_5737E67_3200_EE_000"
{{- end -}}
{{- define "cam.securityContext" -}}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end -}}
{{- define "cam.container.securityContext" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    drop:
      - ALL
{{- end -}}
{{- define "cam.container.securityContext.NonRoot" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1100
  capabilities:
    drop:
      - ALL
{{- end -}}
{{/*
Setting init container securityContext
*/}}
{{- define "cam.container.securityContext.InitContainer" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    add: ["CHOWN"]
    drop:
    - ALL
{{- end -}}
{{/*
Use imagePullSecrets to pull images
*/}}
{{- define "ibm-cloud-brokerage-cam.imagePullSecrets" -}}
imagePullSecrets:
  - name: myregistrykey
{{- end -}}
{{/*

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


{{- define "deployClassSingleConfig" -}}
{{- $top := first . -}}
{{- $name := (index . 1) -}}
{{- $flavour := (index . 2) -}}
{{- $filen := printf "config/resources/%s-config.json" $flavour -}}
{{- range $line := $top.Files.Lines $filen }}{{if contains ($name|quote) $line}}{{ $line | replace ($name|quote) "" | replace ":" ""  | replace "," "" | trim }}{{ end }}{{ end }}
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
