
{{- define "eventstore.security" }}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end }}

{{- define "eventstore.podSecurityContext" }}
securityContext:
  {{- if ( .user  ) }}
  runAsUser: {{ .user }}
  {{- end }}
  runAsGroup: 0
  fsGroup: 0
  runAsNonRoot: true
{{- end }}

{{- define "eventstore.securityContext" }}
securityContext:
  seLinuxOptions:
    type: spc_t
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
  allowPrivilegeEscalation: true
  privileged: false
  readOnlyRootFilesystem: false
{{- end }}

{{- define "eventstore.securityContextEngine" }}
securityContext:
  seLinuxOptions:
    type: spc_t
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
  readOnlyRootFilesystem: false
{{- end }}

{{- define "eventstore.securityContextEngine.InitDb2" }}
securityContext:
  seLinuxOptions:
    type: spc_t
  capabilities:
    add:
    - "SYS_RESOURCE"
    - "IPC_OWNER"
    - "SYS_NICE"
    drop:
    - "ALL"
  allowPrivilegeEscalation: true
  privileged: true
  readOnlyRootFilesystem: false
{{- end }}
