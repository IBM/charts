{{/* Storage - https://kubernetes.io/docs/concepts/storage/persistent-volumes/ */}}

{{/***/}}
{{/* Container Level Storage https://kubernetes.io/docs/concepts/storage/volumes */}}
{{/* https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaimvolumesource-v1-core */}}
{{/***/}}
{{- define "db2u.container.storage.dataStorage" }}
{{- if not .Values.storage.storageLocation.dataStorage.enablePodLevelClaim }}
- name: {{ .Values.storage.storageLocation.dataStorage.volumeName }}
  {{- if eq .Values.storage.storageLocation.dataStorage.volumeType "hostPath" }}
  hostPath:
    path: {{ .Values.storage.storageLocation.dataStorage.hostPath.path }}
    type: {{ .Values.storage.storageLocation.dataStorage.hostPath.type }}
  {{- else }}
  persistentVolumeClaim:
    {{- if .Values.storage.storageLocation.dataStorage.pvc.existingClaim.name }}
    claimName: {{ .Values.storage.storageLocation.dataStorage.pvc.existingClaim.name }}
    {{- else }}
    claimName: {{ template "fullname" . }}-db2u-data-storage
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
