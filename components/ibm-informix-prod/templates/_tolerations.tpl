{{- define "tolerations.ifx" }}
tolerations:
  - key: "Tainted4Informix"
    operator: "Exists"
    # operator: "Equal"
    # value: "IfxSccGroup"
    effect: "NoSchedule"
{{- end }}
