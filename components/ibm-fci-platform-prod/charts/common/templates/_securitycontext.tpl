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
runAsNonRoot: false
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


