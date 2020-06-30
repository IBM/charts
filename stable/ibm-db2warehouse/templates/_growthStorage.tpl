{{/* Storage - https://kubernetes.io/docs/concepts/storage/persistent-volumes/ */}}

{{/***/}}
{{/* Container Level Storage https://kubernetes.io/docs/concepts/storage/volumes */}}
{{/* https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaimvolumesource-v1-core */}}
{{/***/}}
{{- define "db2u.container.storage.growthStorage" }}
{{- if not .Values.storage.storageLocation.growthStorage.enablePodLevelClaim }}
- name: {{ .Values.storage.storageLocation.growthStorage.volumeName }}
  {{- if eq .Values.storage.storageLocation.growthStorage.volumeType "hostPath" }}
  hostPath:
    path: {{ .Values.storage.storageLocation.growthStorage.hostPath.path }}
    type: {{ .Values.storage.storageLocation.growthStorage.hostPath.type }}
  {{- else }}
  persistentVolumeClaim:
    {{- if .Values.storage.storageLocation.growthStorage.pvc.existingClaim.name }}
    claimName: {{ .Values.storage.storageLocation.growthStorage.pvc.existingClaim.name }}
    {{- else }}
    claimName: {{ template "fullname" . }}-db2u-growth-storage
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
