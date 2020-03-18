{{- define "ibm-security-foundations-dev-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "ibm-security-foundations-dev-chart.fullname" -}}
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


{{- define "ibm-security-foundations-dev-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Display license
*/}}
{{- define "ibm-security-foundations-dev-chart.license" -}}
{{- $licenseName := .Values.global.licenseFileName -}}
{{- $license := .Files.Get $licenseName -}}
{{- $msg := "Please read the above license and set global.license=accept to install the product." -}}
{{- $border := printf "\n%s\n" (repeat (len $msg ) "=") -}}
{{- printf "\n%s\n\n\n%s%s%s" $license $border $msg $border -}}
{{- end -}}