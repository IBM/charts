{{- define "discovery.dfs.secretInitContainer" -}}
{{- $jobNameSuffix:= "dfs-secret-gen-job" -}}
{{- $dfsSecretGenJobName:= include "sch.names.fullCompName" (list . $jobNameSuffix ) -}}
- name: dfs-secret-init-container-job-status
  image: "{{ .Values.global.dockerRegistryPrefix }}/{{ .Values.dfs.secretGen.image.name }}:{{ .Values.dfs.secretGen.image.tag }}"
{{ include "sch.security.securityContext" (list . .sch.chart.restrictedSecurityContext) | indent 2 }}
  resources:
    requests:
      memory: {{ .Values.dfs.secretGen.resources.requests.memory | quote }}
      cpu: {{ .Values.dfs.secretGen.resources.requests.cpu | quote }}
    limits:
      memory: {{ .Values.dfs.secretGen.resources.limits.memory | quote }}
      cpu: {{ .Values.dfs.secretGen.resources.limits.cpu | quote }}
  env:
  - name: NAMESPACE
    value: {{ .Release.Namespace }}
  - name: JOB_NAMES
    value: {{ printf "%s" $dfsSecretGenJobName | quote }}
{{- end -}}
