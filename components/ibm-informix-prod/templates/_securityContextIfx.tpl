
{{- define "securityContext.containers.init-ifx" }}
securityContext:
  privileged: true
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: true
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    add:
    - "SYS_RESOURCE"
    - "IPC_OWNER"
    - "SYS_NICE"
    drop:
    - "ALL"
{{- end }}

{{- define "securityContext.containers.init-cont" }}
securityContext:
  privileged: false 
  runAsNonRoot: false
  runAsUser: 0
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: true
  capabilities:
    add:
    - "SYS_RESOURCE"
    - "IPC_OWNER"
    - "SYS_NICE"
    drop:
    - "ALL"
{{- end }}


{{- define "securityContext.containers.ifx" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: true
  runAsNonRoot: true
  runAsUser: 200
  capabilities:
    add:
    - "SYS_RESOURCE"
    - "IPC_OWNER"
    - "SYS_NICE"
    #Default capabilities, re-add them as it will be drop
    - "CHOWN"
    - "DAC_OVERRIDE"
    - "FSETID"
    - "FOWNER"
    - "SETGID"
    - "SETUID"
    - "SETFCAP"
    - "SETPCAP"
    - "NET_BIND_SERVICE"
    - "SYS_CHROOT"
    - "KILL"
    - "AUDIT_WRITE"
    drop:
    - "ALL"
{{- end }}