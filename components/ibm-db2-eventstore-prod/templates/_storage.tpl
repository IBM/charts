{{- define "eventstore.container.storage.dataStorage" }}
- name: data-storage
  persistentVolumeClaim:
    {{- if .Values.storage.storageLocation.dataStorage.pvc.existingClaim.name }}
    claimName: {{ .Values.storage.storageLocation.dataStorage.pvc.existingClaim.name }}
    {{- else }}
    claimName: {{ .Values.servicename }}-data-pvc
    {{- end }}
{{- end }}

{{- define "eventstore.container.storage.systemStorage" }}
- name: system-storage
  persistentVolumeClaim:
    {{- if .Values.storage.storageLocation.metaStorage.pvc.existingClaim.name }}
    claimName: {{ .Values.storage.storageLocation.metaStorage.pvc.existingClaim.name }}
    {{- else }}
    claimName: {{ .Values.servicename }}-system-pvc
    {{- end }}
{{- end }}
