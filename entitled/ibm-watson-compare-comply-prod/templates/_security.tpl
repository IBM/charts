{{- define "ibm-watson-compare-comply-prod.securityKeys" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
  runAsUser: 1001
{{- end }} 
{{- end -}}

{{- define "ibm-watson-compare-comply-prod.securityContext" -}}
securityContext:
  runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
  runAsUser: 1001
{{- end }}
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
{{- end -}}