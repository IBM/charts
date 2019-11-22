{{- define "conductor.serviceUrl" -}}
{{ range $i := until (int $.Values.app.numReplicas) }}
{{- printf "https://conductor-%d.conductor:8761/eureka/," $i }}
{{- end -}}
{{- end -}}


{{- define "alm.getImageRepo" -}}
{{- printf "%s" .Values.global.image.repository }}
{{- end -}}

{{- define "alm.podSecurityContext" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
{{- end -}}

{{- define "alm.containerSecurityContext" -}}
privileged: false
readOnlyRootFilesystem: true
allowPrivilegeEscalation: false
runAsNonRoot: true
runAsUser: 1000
capabilities:
  drop:
  - ALL
{{- end -}}

{{- define "alm.getResources" -}}
{{- if index .Values.resources .Values.global.environmentSize -}}
{{- $resources := index .Values.resources .Values.global.environmentSize -}}
{{ toYaml $resources -}}
{{- end -}}
{{- end -}}
