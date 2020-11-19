{{/*
Process zenServiceInstanceId
*/}}
{{- define "planning-analytics.serviceid" -}}
{{ $instanceid := default 9700000000079 .Values.zenServiceInstanceId }}
{{ printf "icpdsupport/serviceInstanceId: '%s'" ($instanceid | int64 | toString) }}
{{- end -}}