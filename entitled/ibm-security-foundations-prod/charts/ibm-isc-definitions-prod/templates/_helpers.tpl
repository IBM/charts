{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ibm-isc-definitions.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
