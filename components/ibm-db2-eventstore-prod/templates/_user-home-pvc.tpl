{{- define "eventstore.user-home-pvc" }}
- name: user-home-mount
  persistentVolumeClaim:
  {{- if .Values.dsx.userHomePVC.persistence.existingClaimName }}
    claimName: {{ .Values.dsx.userHomePVC.persistence.existingClaimName }}
  {{- else }}
    claimName: "user-home-pvc"
  {{- end }}
{{- end }}
{{- define "eventstore.rt-user-home-pvc" }}
          {{- if .Values.dsx.userHomePVC.persistence.existingClaimName }}
          "claimName": {{ .Values.dsx.userHomePVC.persistence.existingClaimName | quote }}
          {{- else }}
          "claimName": "user-home-pvc"
          {{- end }}
{{- end }}
