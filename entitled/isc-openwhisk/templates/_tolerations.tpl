{{/* Core toleration */}}
{{- define "openwhisk.toleration.core" -}}
- key: "openwhisk-role"
  operator: "Equal"
  value: {{ .Values.toleration.coreValue }}
  effect: "NoSchedule"
{{- end -}}

 {{/* Edge toleration */}}
{{- define "openwhisk.toleration.edge" -}}
- key: "openwhisk-role"
  operator: "Equal"
  value: {{ .Values.toleration.edgeValue }}
  effect: "NoSchedule"
{{- end -}}

 {{/* Invoker toleration */}}
{{- define "openwhisk.toleration.invoker" -}}
- key: "openwhisk-role"
  operator: "Equal"
  value: {{ .Values.toleration.invokerValue }}
  effect: "NoSchedule"
{{- end -}}
