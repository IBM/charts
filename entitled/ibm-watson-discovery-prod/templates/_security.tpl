{{- define "ibm-watson-discovery-prod.securityKeys" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  runAsUser: 60001
{{- end -}}

{{- define "ibm-watson-discovery-prod.securityContext" -}}
securityContext:
  runAsNonRoot: true
  runAsUser: 60001
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
{{- end -}}