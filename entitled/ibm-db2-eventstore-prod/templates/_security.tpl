
{{- define "eventstore.security" }}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end }}

{{- define "eventstore.securityContext" }}
securityContext:
  capabilities:
    drop:
    - ALL
    add:
    - MKNOD
    - CHOWN
    #TODO: Figure out which of the following are necessary
    - FOWNER
    - FSETID
    - SETGID
    - SETUID
    - DAC_OVERRIDE
{{- end }}

{{- define "eventstore.securityContextEngine" }}
securityContext:
  capabilities:
    drop:
    - ALL
    add:
    - MKNOD
    - CHOWN
    - SYS_RESOURCE
    - IPC_OWNER
    - SYS_NICE
    #TODO: Figure out which of the following are necessary
    - DAC_OVERRIDE
    - FOWNER
    - FSETID
    - SETGID
    - SETUID
    - KILL
    - NET_RAW
    - AUDIT_WRITE
    - SETPCAP
    - NET_BIND_SERVICE
    - SYS_CHROOT
    - SETFCAP
  allowPrivilegeEscalation: true
  privileged: false
{{- end }}

{{- define "eventstore.securityContextEngine.InitDb2" }}
securityContext:
  privileged: true
  allowPrivilegeEscalation: true
  capabilities:
    add:
    - "SYS_RESOURCE"
    - "IPC_OWNER"
    - "SYS_NICE"
    drop:
    - "ALL"
{{- end }}
