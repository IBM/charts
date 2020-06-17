{{/*
Pod related security context settings
*/}}

{{- define "common.RestrictedContainerSecurityContext" -}}
runAsNonRoot: true
{{- if (not .Values.global.deployOnCP4D) }}
runAsUser: {{ .Values.global.runAsUser}}
{{- end }}
privileged: false
readOnlyRootFilesystem:  false
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
{{- end -}}

{{- define "common.PodHostConfig" -}}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end -}}

{{- define "common.PodSecurityContextConfig" -}}
{{- if .Values.fsGroupConfig }}
{{ toYaml .Values.fsGroupConfig }}
{{- else }}
{{ toYaml .Values.global.fsGroupConfig }}
{{- end }}
{{- end -}}

{{- define "common.AnyuidContainerSecurityContext" -}}
runAsNonRoot: true
privileged: false
readOnlyRootFilesystem:  false
allowPrivilegeEscalation: false
{{- end -}}

{{- define "common.PrivilegedContainerSecurityContext" -}}
runAsNonRoot: false
privileged: true
readOnlyRootFilesystem:  false
allowPrivilegeEscalation: true
{{- end -}}

{{- define "common.RootedContainerSecurityContext" -}}
runAsNonRoot: false
runAsUser: 0
privileged: true
readOnlyRootFilesystem:  false
allowPrivilegeEscalation: true
{{- end -}}

{{- define "common.RootUserContainerSecurityContext" -}}
runAsNonRoot: false
runAsUser: 0
privileged: false
readOnlyRootFilesystem:  true
allowPrivilegeEscalation: false
{{- end -}}

{{- define "common.RootChownerContainerSecurityContext" -}}
runAsNonRoot: false
runAsUser: 0
privileged: false
readOnlyRootFilesystem:  false
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
  add:
  - CHOWN
{{- end -}}

{{- define "common.RootFownerContainerSecurityContext" -}}
runAsNonRoot: false
runAsUser: 0
privileged: false
readOnlyRootFilesystem:  false
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
  add:
  - FOWNER
{{- end -}}
