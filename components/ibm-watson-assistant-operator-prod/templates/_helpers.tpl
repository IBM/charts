{{/*
  Generate name of the service account to use.
*/}}
{{- define "assistant-operator.serviceAccount.name" -}}
  {{- if tpl ( .Values.serviceAccount.name | toString ) . -}}
    {{- tpl  ( .Values.serviceAccount.name | toString ) . -}}
  {{- else -}}
    {{- include "sch.names.fullName" (list .) -}}
  {{- end -}}
{{- end -}}

{{/*
  Generate name of the config map with detailed defaults for Watson Assistant instances
*/}}
{{- define "assistant-operator.waDefaultConfig.name" -}}
  {{- if tpl ( .Values.waDefaultConfig.name | toString ) . -}}
    {{- tpl  ( .Values.waDefaultConfig.name | toString ) . -}}
  {{- else -}}
    {{- include "sch.names.fullName" (list .) -}}-app-config
  {{- end -}}
{{- end -}}

{{/*
   A helper templates to support templated boolean values.
   Takes a value (and converts it into Boolean equivalet string value).
     If the value is of type Boolean, then if false renders to empty string, otherwise renders to non-empty string.
     If the value is of type String, then takes (and renders the string) and if the value is true (case sensitive) or renders to (true) then renders to non-empty string, otherwise renders to empty string.
     
  Usage: For keys like `auth.enabled` "true/false" add possiblity to have also non-boolean value "{{ .Values.global.mongodb.auth.enables }}"
  
  Usage in templates:
    Instead of direct value test `{{ if .Values.auth.enabled }}` one has to use {{ if include "ibm-mongodb.boolConvertor" (list .Values.auth.enabled . ) }}
*/}}
{{- define "assistant-operator.boolConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VAULT renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Adds support for templated affinity
  i.e., .Values.affinity: "{ { include "umbrella-chart.affinity" . } }"
*/}}
{{- define "assistant-operator.affinity" -}}
  {{- $root    := . }}

  {{- if $root.Values.affinity -}}
    {{/* To be backward compatible, we are looking for .Values.affinity before defaulting to sch chart labels */}}
    {{- if kindIs "string" $root.Values.affinity -}}
      {{- tpl $root.Values.affinity $root -}}
    {{- else -}}
      {{- tpl ( $root.Values.affinity | toYaml ) $root -}}
    {{- end -}}
  {{- else -}}
    {{- include "sch.affinity.nodeAffinity" (list $root $root.sch.chart.nodeAffinity) }}
  {{- end -}}
{{- end -}}

{{- define "assistant-operator.antiAffinity" -}}
  {{- if .Values.antiAffinity.policy -}}
    {{/* Accept a string or a template as the mode */}}
    {{- $antiAffinityPolicy := (tpl .Values.antiAffinity.policy .) -}}
    {{- if eq $antiAffinityPolicy "hard" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: {{ tpl (.Values.antiAffinity.topologyKey | toString ) . }}
    labelSelector:
      matchLabels:
{{ include "sch.metadata.labels.standard" (list . ) | indent 8 }}
    {{- else if eq $antiAffinityPolicy "soft" }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    podAffinityTerm:
      topologyKey: {{ tpl .Values.antiAffinity.topologyKey . }}
      labelSelector:
        matchLabels:
{{ include "sch.metadata.labels.standard" (list . ) | indent 10 }}
    {{- end }}
  {{- end -}}
{{- end -}}

{{/*****************************************************************************
   * License
   **************************************************************************/}}

{{/*
Display license
*/}}
{{- define "assistant-operator.license" -}}
  {{- $msg := "Please read the licenses provided in the LICENSES subdirectory of this chart and set license=true to accept the license and install the product." -}}
  {{- $border := printf "\n%s\n" (repeat (len $msg ) "=") -}}
  {{- printf "\n\n%s%s%s" $border $msg $border -}}
{{- end -}}