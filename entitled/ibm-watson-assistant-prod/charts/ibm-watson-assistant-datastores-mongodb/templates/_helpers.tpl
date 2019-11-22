
{{- define "assistant.mongo.ibm-mongodb.affinitiesMongodb.nodeAffinity" -}}
  {{- include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
{{- end -}}


{{- define "assistant.mongo.ibm-mongodb.affinitiesMongodb.podAntiAffinity" -}}
  {{- if or (eq .Values.global.podAntiAffinity "Enable") (and (eq .Values.global.deploymentType "Production") (ne .Values.global.podAntiAffinity "Disable")) }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
    {{- $labels := include "sch.metadata.labels.standard" (list . .sch.chart.components.server) | fromYaml }}
    {{- range $name, $value := $labels }}
      - key: {{ $name | quote }}
        operator: In
        values:
        - {{ $value | quote }}
    {{- end }}
    topologyKey: "kubernetes.io/hostname"
  {{- end -}}
{{- end -}}


