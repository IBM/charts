{{/* To difine helper functions */}}
{{- include "sch.config.init" (list . "discovery.sch.chart.config.values") -}}

{{- define "ibmWatsonDiscovery.icpPullSecrets" -}}
{{- printf "%s" (default (printf "sa-%s" .Release.Namespace) .Values.global.imagePullSecretName) -}}
{{- end -}}

{{- define "ibmWatsonDiscovery.privilegedServiceAccountName" -}}
{{- if .Values.global.privilegedServiceAccount.name -}}
{{ .Values.global.privilegedServiceAccount.name }}
{{- else -}}
{{ include "sch.names.fullCompName" (list . "shared-privileged-svc-acc" ) }}
{{- end -}}
{{- end -}}

{{- define "ibmWatsonDiscovery.serviceAccountName" -}}
{{- if .Values.global.serviceAccount.name -}}
{{ .Values.global.serviceAccount.name }}
{{- else -}}
{{ include "sch.names.fullCompName" (list . "shared-svc-acc" ) }}
{{- end -}}
{{- end -}}

{{- define "ibmWatsonDiscovery.tlsSecretName" -}}
{{- $appName:= .Values.global.appName -}}
{{- printf "%s-%s-tls-secret" .Release.Name $appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibmWcnAddon.replicas" -}}
  {{- if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{/*
Display license
*/}}
{{- define "ibmWatsonDiscovery.license" -}}
{{- $licenseName := .Values.global.licenseFileName -}}
{{- $license := .Files.Get $licenseName -}}
{{- $msg := "Please read the above license and set global.license=accept to install the product." -}}
{{- $border := printf "\n%s\n" (repeat (len $msg ) "=") -}}
{{- printf "\n%s\n\n\n%s%s%s" $license $border $msg $border -}}
{{- end -}}
