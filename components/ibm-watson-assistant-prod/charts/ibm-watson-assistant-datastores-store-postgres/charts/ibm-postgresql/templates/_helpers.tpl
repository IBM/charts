{{/* vim: set filetype=mustache: */}}

{{- define "stolon.clusterName" -}}
{{- $genName := printf "%s-%s" .Release.Name .Chart.Name -}}
{{- $name := default $genName (tpl .Values.clusterName . ) -}}
{{- printf $name -}}
{{- end -}}

{{/* Create the name of the service account to use */}}
{{- define "stolon.serviceAccountName" -}}
  {{- if tpl .Values.serviceAccount.name . -}}
    {{- tpl .Values.serviceAccount.name . -}}
  {{- else -}}
    {{- include "sch.names.fullName" (list .) -}}
  {{- end -}}
{{- end -}}

{{/*
   A helper template to support templated boolean values.
   Takes a value (and converts it into Boolean equivalent string value).
     If the value is of type Boolean, then false value renders to empty string, otherwise renders to non-empty string.
     If the value is of type String, then takes (and renders the string) and if the value is true (case sensitive) or renders to (true) then renders to non-empty string, otherwise renders to empty string.

  Usage: For keys like `tls.enabled` "true/false" add possiblity to have also non-boolean value "{{ .Values.global.postgres.tls.enables }}"

  Usage in templates:
    Instead of direct value test `{{ if .Values.tls.enabled }}` one has to use {{ if include "ibm-postgresql.boolConvertor" (list .Values.tls.enabled . ) }}
*/}}
{{- define "ibm-postgresql.boolConvertor" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}                            Type is Boolean  VALUE is TRUE           ==>  Generating a non-empty string{{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}Type is String   VALUE renders to "true" ==>  Generating a non-empty string{{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  A helper template to compute affinity for sts/deployments.
  Usage in templates:
  To generate affinities based on overriden values in `sentinel.affinity` use  `{{- include "ibm-postgresql.affinity" (list . .Values.sentinel.affinity) | indent 8 }}`
*/}}
{{- define "ibm-postgresql.affinity" -}}
  {{- $params   := . -}}
  {{- $root     := first $params -}}
  {{- $affinity := index $params 1 -}}
  {{- $affinityObjectDetails := index $params 2 -}}
  {{- $_     := set $root "affinityDetails" $affinityObjectDetails -}}

  {{- if $affinity -}}
    {{- if kindIs "string" $affinity -}}
      {{- tpl  $affinity $root -}}
    {{- else -}}
      {{- tpl ( $affinity | toYaml ) $root -}}
    {{- end -}}
  {{- else -}}
    {{- /* Affinity override is not specified using default sch arch based affinities */ -}}
    {{- include "sch.affinity.nodeAffinity" (list $root $root.sch.chart.nodeAffinity) -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-postgresql.antiAffinity" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $component := index $params 1 -}}

  {{- if $root.Values.antiAffinity.policy -}}
    {{/* Accept a string or a template as the mode */}}
    {{- $antiAffinityPolicy := (tpl $root.Values.antiAffinity.policy $root) -}}
    {{- if eq $antiAffinityPolicy "hard" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: {{ tpl $root.Values.antiAffinity.topologyKey $root }}
      labelSelector:
        matchLabels:
{{ include "sch.metadata.labels.standard" (list $root) | indent 10 }}
          component: {{ $component | quote }}
    {{- else if eq $antiAffinityPolicy "soft" }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      podAffinityTerm:
        topologyKey: {{ tpl $root.Values.antiAffinity.topologyKey $root }}
        labelSelector:
          matchLabels:
{{ include "sch.metadata.labels.standard" (list $root) | indent 12 }}
            component: {{ $component | quote }}
    {{- end }}
  {{- end -}}
{{- end -}}

{{- define "ibm-postgresql.licenseValidate" -}}
  {{ $license := .Values.global.license }}
  {{- if $license -}}
    true
  {{- end -}}
{{- end -}}
