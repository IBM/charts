{{- define "customNodeaffinity" -}}
{{- $params := . }}
{{- $root := first $params }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
          - key: beta.kubernetes.io/arch
            operator: In
            values:
              - {{ $root.Values.global.arch }}
{{- end }}
