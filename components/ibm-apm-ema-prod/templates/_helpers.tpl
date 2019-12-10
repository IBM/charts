{{/* vim: set filetype=mustache: */}}

{{/*
Helper functions which can be used for used for .Values.arch in PPA Charts
Check if tag contains specific platform suffix and if not set based on kube platform
uncomment this section for PPA charts, can be removed in github.com charts

{{- define "content-repo-template.platform" -}}
{{- if not .Values.arch }}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "x86_64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "ppc64le" }}
  {{- end -}}
{{- else -}}
  {{- if eq .Values.arch "amd64" }}
    {{- printf "-%s" "x86_64" }}
  {{- else -}}
    {{- printf "-%s" .Values.arch }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "content-repo-template.arch" -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- end -}}
{{- end -}}

*/}}

{{- define "ema.securitycontext.couchdb.pod" }}
hostPID: false
hostIPC: false
hostNetwork: false
securityContext:
  runAsNonRoot: true
  runAsUser: 5984
  fsGroup: 5984
{{- end -}}

{{- define "ema.securitycontext.couchdb.container" }}
securityContext:
  capabilities:
    drop:
    - ALL
    add: []
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 5984
  privileged: false
{{- end -}}

{{- define "ema.securitycontext.pod" }}
hostPID: false
hostIPC: false
hostNetwork: false
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

{{- end -}}

{{- define "ema.securitycontext.container" }}
securityContext:
  capabilities:
    drop:
    - ALL
    add: []
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 1001
  privileged: false
{{- end -}}

{{- define "landingPage.service.url" -}}
http://{{ include "sch.names.fullCompName" (list . .sch.chart.components.landingPage.name) }}:3000/
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ema.couchdb.name" -}}
couchdb
{{- end -}}

{{- define "ema.couchdb.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name (include "ema.couchdb.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ema.license.name" -}}
LICENSES/LICENSE-ema
{{- end -}}

{{- define "ema.license" -}}
  {{- $licenseName := (include "ema.license.name" .) -}}
  {{- $license := .Files.Get $licenseName -}}
  {{- $msg := "Please read the above license and set global.license=accept to install the product." -}}
  {{- $border := printf "\n%s\n" (repeat (len $msg ) "=") -}}
  {{- printf "\n%s\n\n\n%s%s%s" $license $border $msg $border -}}
{{- end -}}
