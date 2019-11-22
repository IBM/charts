{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rabbitmq.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "rabbitmq.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Defines a JSON file containing definitions of all broker objects (queues, exchanges, bindings, 
users, virtual hosts, permissions and parameters) to load by the management plugin.
*/}}
{{- define "ibmRabbitmq.definitions" -}}
{
  "users": [
    {
      "name": {{ .Values.auth.managementUsername | quote }},
      "password": "'$management_password_raw'",
      "tags": "management"
    },
    {
      "name": {{ .Values.auth.rabbitmqUsername | quote }},
      "password": "'$rabbitmq_password_raw'",
      "tags": "administrator"
    }{{- if .Values.definitions.users -}},
{{ .Values.definitions.users | indent 4 }}
{{- end }}
  ],
  "vhosts": [
    {
      "name": {{ .Values.rabbitmqVhost | quote }}
    }{{- if .Values.definitions.vhosts -}},
{{ .Values.definitions.vhosts | indent 4 }}
{{- end }}
  ],
  "permissions": [
    {
      "user": {{ .Values.auth.rabbitmqUsername | quote }},
      "vhost": {{ .Values.rabbitmqVhost | quote }},
      "configure": ".*",
      "read": ".*",
      "write": ".*"
    }{{- if .Values.definitions.permissions -}},
{{ .Values.definitions.permissions | indent 4 }}
{{- end }}
  ],
  "parameters": [
{{ .Values.definitions.parameters| indent 4 }}
  ],
  "policies": [
{{ .Values.definitions.policies | indent 4 }}
  ],
  "queues": [
{{ .Values.definitions.queues | indent 4 }}
  ],
  "exchanges": [
{{ .Values.definitions.exchanges | indent 4 }}
  ],
  "bindings": [
{{ .Values.definitions.bindings| indent 4 }}
  ]
}

{{- end -}}