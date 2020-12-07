{{- define "user-home-pvc" }}
- name: user-home-mount
  persistentVolumeClaim:
    claimName: "user-home-pvc"
{{- end }}
{{- define "rt-user-home-pvc" }}
          "claimName": "user-home-pvc"
{{- end }}
