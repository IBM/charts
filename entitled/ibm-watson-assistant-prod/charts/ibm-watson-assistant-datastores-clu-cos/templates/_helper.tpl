{{ define "clu.labels" }}
labels:
{{- /*
  service:   "{ { $kingdom.bluemix_service_name } }"
  component: "dialog"
  slot:      "{ { $kingdom.slot_name } }"
  
  app:       "{ { $k8s_names.icp.app } }"
  chart:     "{ { $kingdom.icp.chart } }" 
  heritage:  "{ { $kingdom.icp.heritage } }"
  release:   "{ { $kingdom.icp.release } }"
*/}}
  app:       "watson-assistant"
  chart:     "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
  heritage:  {{ .Release.Service | quote }}
  release:   {{ .Release.Name    | quote }}
{{ end }}


{{- define "assistant.minio.fullname" -}}
  {{ .Release.Name }}-clu-minio-svc.{{ .Release.Namespace }}.svc.{{ tpl .Values.global.clusterDomain . }}
{{- end -}}
