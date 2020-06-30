{{/* Storage - https://kubernetes.io/docs/concepts/storage/persistent-volumes/ */}}

{{/***/}}
{{/* Pod Level Storage https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#persistentvolumeclaim-v1-core */}}
{{/* Supersede Volumes definition */}}
{{/***/}}
{{- define "db2u.pod.storage.volumeClaimTemplates" }}
{{- if and (.Values.storage.enableVolumeClaimTemplates) (.Values.storage.useDynamicProvisioning) }}
volumeClaimTemplates:
  {{- if and (.Values.storage.storageLocation.dataStorage.enabled) (.Values.storage.storageLocation.dataStorage.enablePodLevelClaim) }}
  - metadata:
      name: {{ .Values.storage.storageLocation.dataStorage.volumeName }}
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: {{ .Values.storage.storageLocation.dataStorage.pvc.claim.size | quote }}
      storageClassName: {{ default nil .Values.storage.storageLocation.dataStorage.pvc.claim.storageClassName | quote }}
  {{- end }}
  {{- if and (.Values.storage.storageLocation.backupStorage.enabled) (.Values.storage.storageLocation.backupStorage.enablePodLevelClaim) }}
  - metadata:
      name: {{ .Values.storage.storageLocation.backupStorage.volumeName }}
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: {{ .Values.storage.storageLocation.backupStorage.pvc.claim.size | quote }}
      storageClassName: {{ default nil .Values.storage.storageLocation.backupStorage.pvc.claim.storageClassName | quote }}
  {{- end }}
  {{- if and (.Values.storage.storageLocation.growthStorage.enabled) (.Values.storage.storageLocation.growthStorage.enablePodLevelClaim) }}
  - metadata:
      name: {{ .Values.storage.storageLocation.growthStorage.volumeName }}
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: {{ .Values.storage.storageLocation.growthStorage.pvc.claim.size | quote }}
      storageClassName: {{ default nil .Values.storage.storageLocation.growthStorage.pvc.claim.storageClassName | quote }}
  {{- end }}
  {{- if .Values.storage.storageLocation.tieredStorage.enabled }}
  {{- range $tier := .Values.storage.storageLocation.tieredStorage.tiers -}}
  {{ $tierSettings := (index $.Values.storage.storageLocation.tieredStorage $tier) }}
  {{- if and ($tierSettings.enabled) ($tierSettings.enablePodLevelClaim) }}
  - metadata:
      name: {{ $tierSettings.volumeName }}
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: {{ $tierSettings.pvc.claim.size | quote }}
      storageClassName: {{ default nil $tierSettings.pvc.claim.storageClassName | quote }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
