{{/* Storage - https://kubernetes.io/docs/concepts/storage/persistent-volumes/ */}}

{{/***/}}
{{/* Container Level Storage https://kubernetes.io/docs/concepts/storage/volumes */}}
{{/* https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaimvolumesource-v1-core */}}
{{/***/}}
{{- define "db2u.container.storage.metaStorage" }}
- name: {{ .Values.storage.storageLocation.metaStorage.volumeName }}
  {{- if eq .Values.storage.storageLocation.metaStorage.volumeType "hostPath" }}
  hostPath:
    path: {{ .Values.storage.storageLocation.metaStorage.hostPath.path }}
    type: {{ .Values.storage.storageLocation.metaStorage.hostPath.type }}
  {{- else }}
  persistentVolumeClaim:
    {{- if .Values.storage.storageLocation.metaStorage.pvc.existingClaim.name }}
    claimName: {{ .Values.storage.storageLocation.metaStorage.pvc.existingClaim.name }}
    {{- else }}
    claimName: {{ template "fullname" . }}-db2u-meta-storage
    {{- end }}
  {{- end }}
{{- end }}
