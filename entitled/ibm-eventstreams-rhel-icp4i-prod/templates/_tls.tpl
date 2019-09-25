{{- define "tls.sch.chart.config.values" }}
  sch:
    config:
      tlsInternal:
       {{- if eq .Values.global.security.tlsInternal "enabled" }}
       enabled: "enabled"
       httpProtocol: "https"
       {{- else }}
       enabled: "disabled"
       httpProtocol: "http"
       {{- end }}
{{- end }}
