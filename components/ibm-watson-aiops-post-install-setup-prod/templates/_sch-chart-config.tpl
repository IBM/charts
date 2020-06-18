
{{/* Configuration for SCH charts.  */}}
{{- define "sch.chart.zeno.config.values" -}}
sch:
  chart:
    components:
      controller: {{ .Values.global.controller.name | quote }}
    appName: {{ .Values.global.product.schName }}
    labelType: prefixed
    podSecurityContext:
      securityContext:
        runAsNonRoot: true
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
    specSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
    podSecurityContext:
      securityContext:
        runAsNonRoot: true
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
{{- end -}}
