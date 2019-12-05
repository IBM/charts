{{- define "podSecurityContext" }}
  runAsNonRoot: {{ .Values.global.pod.ibmuser.securityContext.runAsNonRoot }}
  {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
  fsGroup: {{ .Values.global.pod.ibmuser.securityContext.fsGroup }}
  runAsUser: {{ .Values.global.pod.ibmuser.securityContext.runAsUser }}
  {{- end }}
  supplementalGroups:
  {{ toYaml .Values.global.pod.ibmuser.securityContext.supplementalGroups }}
{{- end }}