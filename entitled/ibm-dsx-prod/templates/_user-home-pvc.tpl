{{- define "user-home-pvc" }}
- name: user-home-mount
  persistentVolumeClaim:
  {{- if .Values.global.userHomePVC.persistence.existingClaimName }}
    claimName: {{ .Values.global.userHomePVC.persistence.existingClaimName }}
  {{- else }}
    claimName: "user-home-pvc"
  {{- end }}
{{- end }}
{{- define "rt-user-home-pvc" }}
          {{- if .Values.global.userHomePVC.persistence.existingClaimName }}
          "claimName": {{ .Values.global.userHomePVC.persistence.existingClaimName | quote }}
          {{- else }}
          "claimName": "user-home-pvc"
          {{- end }}
{{- end }}