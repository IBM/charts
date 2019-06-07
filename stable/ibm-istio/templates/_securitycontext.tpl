{{- define "container.security.context" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
    add:
    - SETPCAP
    - AUDIT_WRITE
    - CHOWN
    - NET_RAW
    - DAC_OVERRIDE
    - FOWNER
    - FSETID
    - KILL
    - SETUID
    - SETGID
    - NET_BIND_SERVICE
    - SYS_CHROOT
    - SETFCAP
{{- end }}

{{- define "pod.security.context" }}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: false
  runAsUser: 0
{{- end }}

{{- define "helm.test.container.security.context" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
{{- end }}
