{{/* Storage - https://kubernetes.io/docs/concepts/storage/persistent-volumes/ */}}

{{/***/}}
{{/* Container Level Storage https://kubernetes.io/docs/concepts/storage/volumes */}}
{{/* https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaimvolumesource-v1-core */}}
{{/***/}}
{{- define "db2u.container.storage.backupStorage" }}
{{- if not .Values.storage.storageLocation.backupStorage.enablePodLevelClaim }}
- name: {{ .Values.storage.storageLocation.backupStorage.volumeName }}
  {{- if eq .Values.storage.storageLocation.backupStorage.volumeType "hostPath" }}
  hostPath:
    path: {{ .Values.storage.storageLocation.backupStorage.hostPath.path }}
    type: {{ .Values.storage.storageLocation.backupStorage.hostPath.type }}
  {{- else }}
  persistentVolumeClaim:
    {{- if .Values.storage.storageLocation.backupStorage.pvc.existingClaim.name }}
    claimName: {{ .Values.storage.storageLocation.backupStorage.pvc.existingClaim.name }}
    {{- else }}
    claimName: {{ template "fullname" . }}-db2u-backup-storage
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
