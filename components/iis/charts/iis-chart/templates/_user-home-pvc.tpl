{{- define "user-home-pvc" }}
- name: user-home-mount
  persistentVolumeClaim:
    claimName: "user-home-pvc"
    readOnly: true
{{- end }}
