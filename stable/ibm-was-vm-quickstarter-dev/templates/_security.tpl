
{{- define "wasaas.security.pod.host" }}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end }}

{{- define "wasaas.security.container.init" }}
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

{{- define "wasaas.security.container.nonroot" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1001
  capabilities:
    drop:
    - ALL
    add:
    - CHOWN
    - DAC_OVERRIDE
    - FOWNER
    - KILL
    - SETGID
    - SETUID
{{- end }}

{{- define "wasaas.security.container.root" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    drop:
    - ALL
    add:
    - CHOWN
    - DAC_OVERRIDE
    - FOWNER
    - KILL
    - SETGID
    - SETUID
{{- end }}
