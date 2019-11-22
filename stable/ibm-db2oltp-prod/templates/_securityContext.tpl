{{- define "root.containers.securityContext" }}
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

{{- define "root.containers.ldap.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    add:
    - CHOWN
    - NET_BIND_SERVICE
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    - KILL
    drop:
    - ALL
{{- end }}

{{- define "root.containers.etcd.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    add:
    - NET_RAW
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

{{- define "nonroot.containers.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  capabilities:
    drop:
    - ALL
{{- end }}