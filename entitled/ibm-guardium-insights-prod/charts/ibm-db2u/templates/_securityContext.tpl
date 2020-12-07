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

{{- define "nonroot.containers.ldap.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 55
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

{{- define "nonroot.containers.rest.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: true
  runAsNonRoot: true
  runAsUser: 205
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

{{- define "nonroot.containers.etcd.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1001
  capabilities:
    drop:
    - ALL
{{- end }}

{{- define "root.containers.client.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    add:
    - SETGID
    - SETUID
    - CHOWN
    - FOWNER
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
  {{- if and (not .Values.setKernelParams) (eq .Values.subType "smp") }}
    {{- include "db2u.sysctls" . }}
  {{- end }}
  runAsNonRoot: true
{{- end  }}

{{- define "nonroot.containers.securityContext" }}
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
