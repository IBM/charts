{{- define "securityContext.nonroot" }}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
{{- end  }}

{{- define "securityContext.containers.nonroot" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 500
  capabilities:
    drop:
    - ALL
{{- end }}

{{- define "securityContext.root" }}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: false 
{{- end  }}

{{- define "securityContext.containers.root" }}
securityContext:
  privileged: false 
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false 
  runAsNonRoot: false 
  runAsUser: 0
  capabilities:
    drop:
    - ALL
{{- end }}

