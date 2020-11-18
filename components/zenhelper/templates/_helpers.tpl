{{/* vim: set filetype=mustache: */}}

{{/*
Create the default zen base chart annotations
*/}}
{{- define "zenhelper.annotations" }}
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakVersion: "3.0.1"
productChargedContainers: "All"
productMetric: "VIRTUAL_PROCESSOR_CORE"
productName: "IBM Common Core Services for IBM Cloud Pak for Data"
productID: "ICP4D-Common-Core-Services-3-0-1"
productVersion: "3.0.1"
{{- end }}


{{- define "zenhelper.labels" }}
  {{- $params := . }}
  {{- $top := first $params }}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) }}
app: {{ include "sch.names.appName" (list $top)  | quote }}
chart: {{ $top.Chart.Name | quote }}
heritage: {{ $top.Release.Service | quote }}
release: {{ $top.Release.Name | quote }}
  {{- if $compName }}
component: {{ $compName | quote }}
  {{- end }}
  {{- if (gt (len $params) 2) }}
    {{- $moreLabels := (index $params 2) }}
    {{- range $k, $v := $moreLabels }}
{{ $k }}: {{ $v | quote }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "zenhelper.podAntiAffinity" }}
  {{- $params := . }}
  {{- $top := first $params }}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: component
          operator: In
          values:
          - {{$compName}}
      topologyKey: kubernetes.io/hostname
{{- end }}

{{- define "zenhelper.nodeArchAffinity" }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
          - {{ .Values.global.architecture }}
{{- end }}
{{- define "zenhelper.user-home-pvc" }}
- name: user-home-mount
  persistentVolumeClaim:
  {{- if .Values.global.userHomePVC.persistence.existingClaimName }}
    claimName: {{ .Values.global.userHomePVC.persistence.existingClaimName }}
  {{- else }}
    claimName: "user-home-pvc"
  {{- end }}
{{- end }}
