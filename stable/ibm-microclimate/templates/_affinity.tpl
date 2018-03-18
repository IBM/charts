{{/*Copyright IBM Corporation 2017. All Rights Reserved.*/}}
{{- define "nodeaffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
        {{- range $key, $val := .Values.arch }}
          {{- if gt ($val | trunc 1 | int) 0 }}
          - {{ $key }}
          {{- end }}
        {{- end }}
{{- end }}
