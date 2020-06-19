{{- define "root.containers.securityContext" }}
securityContext:
  privileged: true
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    drop:
    - ALL
{{- end }}

{{- define "root.securityContext" }}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: false
  runAsUser: 0
{{- end  }}

{{- define "nonroot.securityContext" }}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
{{- end  }}
