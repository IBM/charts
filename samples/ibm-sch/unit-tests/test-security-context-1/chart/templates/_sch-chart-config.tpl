{{- define "test-01.sch.chart.config.values" -}}
sch:
  chart:
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
    components:
      common:
        name: "test01-common"
    labelType: prefixed
    securityContext1:
      securityContext:
        runAsNonRoot: false
        runAsUser: 0
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
          add:
          - CHOWN
          - AUDIT_WRITE
          - DAC_OVERRIDE
          - FOWNER
          - SETGID
          - SETUID
          - NET_BIND_SERVICE
          - SYS_CHROOT
{{- end -}}
