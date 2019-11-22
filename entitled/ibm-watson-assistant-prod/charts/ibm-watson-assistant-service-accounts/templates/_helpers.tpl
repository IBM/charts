{{- define "assistant.serviceAccount.imagePullSecrets" -}}
imagePullSecrets:
  - name: sa-{{ .Release.Namespace }}
  {{- if tpl .Values.global.image.pullSecret . }}
  - name: {{ tpl .Values.global.image.pullSecret . }}
  {{- end }}
  {{- if tpl .Values.global.image.pullSecret2 . }}
  - name: {{ tpl .Values.global.image.pullSecret2 . }}
  {{- end }}
{{- end -}}

{{ define "serviceAccounts.labels" }}  
labels:
  # Dammed GOLANG comments why why needs to be in { { -     - } }
{{- /*
  service:   "{ { $kingdom.bluemix_service_name } }"
  component: "dialog"
  slot:      "{ { $kingdom.slot_name } }"
 
  
  app:       "{ { $k8s_names.icp.app } }"
  chart:     "{ { $kingdom.icp.chart } }" 
  heritage:  "{ { $kingdom.icp.heritage } }"
  release:   "{ { $kingdom.icp.release } }"
*/ -}}
  # Just a comment to make helm happy, remove with the commend above
  app:       "watson-assistant"
  chart:     "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
  heritage:  {{ .Release.Service | quote }}
  release:   {{ .Release.Name    | quote }}
{{ end }}
