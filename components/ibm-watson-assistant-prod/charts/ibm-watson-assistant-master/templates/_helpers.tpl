{{/* Docker registry from where to pull images */}}
{{- define "master.docker_registry" -}}
  {{- if tpl ( .Values.slad.dockerRegistry | toString ) . -}}
    {{-  tpl ( .Values.slad.dockerRegistry | toString ) . -}}
  {{- else -}}
    {{- ( tpl ( .Values.image.repository | toString ) . ) | splitList "/" |  first -}}
  {{- end -}}
{{- end -}}

{{/* The pull secret to use */}}
{{- define "master.docker_registry_pull_secret" -}}
  {{- if tpl ( .Values.slad.dockerRegistryPullSecret | toString ) . -}}
    {{- tpl ( .Values.slad.dockerRegistryPullSecret | toString ) . -}}
  {{- else -}}
    sa-{{ .Release.Namespace }}
  {{- end -}}
{{- end -}}

{{/* The docker registry namespace where the (training) images were uploaded */}}
{{- define "master.docker_registry_namespace" -}}
  {{- if tpl ( .Values.slad.dockerRegistryNamespace | toString ) . -}}
    {{-  tpl ( .Values.slad.dockerRegistryNamespace | toString ) . -}}
  {{- else -}}
     {{- ( tpl ( .Values.image.repository | toString ) . ) | splitList "/" | rest | join "/" | trimSuffix "/" -}}
  {{- end -}}
{{- end -}}
