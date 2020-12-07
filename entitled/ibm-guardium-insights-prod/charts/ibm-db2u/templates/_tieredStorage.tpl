{{/* Storage - https://kubernetes.io/docs/concepts/storage/persistent-volumes/ */}}

{{/***/}}
{{/* Container Level Storage https://kubernetes.io/docs/concepts/storage/volumes */}}
{{/* https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaimvolumesource-v1-core */}}
{{/***/}}
{{- define "db2u.container.storage.tieredStorage" }}
{{- range $tier := .Values.storage.storageLocation.tieredStorage.tiers -}}
  {{ $tierSettings := (index $.Values.storage.storageLocation.tieredStorage $tier) }}
  {{- if and (not $tierSettings.enablePodLevelClaim) ($tierSettings.enabled) }}
- name: {{ $tierSettings.volumeName }}
    {{- if eq $tierSettings.volumeType "hostPath" }}
  hostPath:
    path: {{ $tierSettings.hostPath.path }}
    type: {{ $tierSettings.hostPath.type }}
    {{- else }}
  persistentVolumeClaim:
      {{- if $tierSettings.pvc.existingClaim.name }}
    claimName: {{ $tierSettings.pvc.existingClaim.name }}
      {{- else }}
    claimName: {{ template "fullname" $ }}-db2u-tiered-{{ $tier }}-storage
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
