{{- /*
  Helper function node affinity
*/ -}}
{{- define "wkcbase.nodeAffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: beta.kubernetes.io/arch
              operator: In
              values:
              - {{ .Values.archx86_64 }}
              - {{ .Values.archppc64le }}
{{- end }}

