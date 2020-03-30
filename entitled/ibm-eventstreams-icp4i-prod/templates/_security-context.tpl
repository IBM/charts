{{- define "securitycontext.sch.chart.config.values" -}}
sch:
  chart:
    securitycontexts:
      pod:
        runAsNonRoot: true
        runAsUser: 65534
      containerReadOnlyFilesystem:
        privileged: false
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        runAsNonRoot: true
        runAsUser: 65534
        capabilities:
          drop:
          - ALL
      containerWritableFilesystem:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        runAsNonRoot: true
        runAsUser: 65534
        capabilities:
          drop:
          - ALL
{{- end -}}
