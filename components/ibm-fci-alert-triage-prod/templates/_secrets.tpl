{{- define "fci.password.generator" -}}
  $(< /dev/urandom tr -dc "A-Za-z0-9" | head "-c10"| base64 | tr -d '\n')
{{- end -}}

{{- define "fci.sch.chart.config.values" -}}
sch:
  chart:
    secretGen:
      suffix: secrets
      overwriteExisting: false
      serviceAccountName: fci-secrets-gen
      secrets:
      - name: fcai-ibm-fcai-prod
        create: true
        type: generic
        values:
        - name: fcai-tls-notebook-password
          generator: "fci.password.generator"
{{- end -}}
