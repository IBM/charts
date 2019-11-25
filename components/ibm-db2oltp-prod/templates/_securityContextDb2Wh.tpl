{{- define "sqllib.containers.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    add:
    #Default capabilities, re-add some back
    - "FOWNER"
    # Glusterfs support
    - "SETGID"
    - "SETUID"
    - "CHOWN"
    - "DAC_OVERRIDE"
    drop:
    - "ALL"
{{- end }}

{{- define "init-db2.containers.securityContext" }}
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


{{- define "db2u.containers.securityContext" }}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: true
  runAsNonRoot: false
  runAsUser: 0
  hostIPC: true
  procMount: Default
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


