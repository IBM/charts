{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "bigsql.chart_name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "bigsql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "bigsql.app_name" -}}
{{- printf "%s" "db2-bigsql" -}}
{{- end -}}

{{- define "bigsql.subdomain" -}}
{{- printf "%s" "bigsql" -}}
{{- end -}}

{{- define "bigsql.service_account_name" -}}
{{- printf "%s" "bigsql" -}}
{{- end -}}

{{- define "bigsql.product_name" -}}
{{- printf "%s" "BigSQL" -}}
{{- end -}}

{{- define "bigsql.product_id" -}}
{{- printf "%s" "eb9998dcc5d24e3eb5b6fb488f750fe2" -}}
{{- end -}}

{{- define "bigsql.product_version" -}}
{{- printf "%s" "7.1.1" -}}
{{- end -}}

{{- define "bigsql.product_metric" -}}
{{- printf "%s" "VIRTUAL_PROCESSOR_CORE" -}}
{{- end -}}

{{- define "bigsql.product_charged_containers" -}}
{{- printf "%s" "All" -}}
{{- end -}}

{{- define "bigsql.product_cloudpak_ratio" -}} 
{{- printf "1:1" -}}
{{- end -}}

{{- define "bigsql.cloudpak_name" -}}
{{- printf "%s" "IBM Cloud Pak for Data" -}}
{{- end -}}

{{- define "bigsql.cloudpak_id" -}}
{{- printf "%s" "eb9998dcc5d24e3eb5b6fb488f750fe2" -}}
{{- end -}}

{{- define "bigsql.cloudpak_version" -}}
{{- printf "%s" "3.5.0" -}}
{{- end -}}

{{/*
Create the secrets key.
Secrets may be created with a unique suffix per instance.
It will be passed as secretsInstanceKey in values.yaml
*/}}
{{- define "bigsql.instance.secret.key" -}}
{{- if .Values.secretsInstanceKey -}}
{{- printf "%s" .Values.secretsInstanceKey | lower -}}
{{- end -}}
{{- end -}}

{{/*
Create the secrets suffix.
Secrets may be created with a unique suffix per instance.
It will be passed as secretsInstanceKey in values.yaml
*/}}
{{- define "bigsql.instance.secret.suffix" -}}
{{- if .Values.secretsInstanceKey -}}
{{- printf "-%s" .Values.secretsInstanceKey | lower -}}
{{- end -}}
{{- end -}}

{{/*
   * Define the hostIPC value 
   */}}
{{- define "bigsql.hostIPC" -}}
{{- if .Values.resources.setHostIPCTrue -}}
{{- printf "%t" .Values.resources.setHostIPCTrue -}}
{{- else -}}
{{- printf "false" -}}
{{- end -}}
{{- end -}}
