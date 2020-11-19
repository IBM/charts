{{- /*
  Helper function for generating image names
*/ -}}
{{- define "aios.image" -}}
    {{- $params := . -}}
    {{- /* root context required for accessing other sch files */ -}}
    {{- $root := first $params -}}
    {{- /* The image we are going to edit */ -}}
    {{- $imageName := (include "sch.utils.getItem" (list $params 1 "")) -}}
    {{- /* The image tag shared across editions */ -}}
    {{- $imageTag := (include "sch.utils.getItem" (list $params 2 "")) -}}
    {{- $imageRepo := $root.Values.global.image.repository -}}
    {{- $cpdImageRepo := $root.Values.global.dockerRegistryPrefix -}}
    {{- $arch := $root.Values.global.arch -}}
    {{- if $cpdImageRepo -}}
      {{- if eq "amd64" $arch }}
         {{- printf "%s/%s:%s" $cpdImageRepo $imageName $imageTag }}
      {{- else -}}
         {{- printf "%s/%s:%s-%s" $cpdImageRepo $imageName $imageTag $arch }}
      {{- end -}}
    {{- else -}}
      {{- if eq "amd64" $arch }}
        {{- printf "%s/%s:%s" $imageRepo $imageName $imageTag }}
      {{- else -}}
        {{- printf "%s/%s:%s-%s" $imageRepo $imageName $imageTag $arch }}
      {{- end -}}
    {{- end -}}
{{- end -}}

{{- define "aios.serviceAccountName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $serviceAccount := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- if $root.Values.global.dockerRegistryPrefix -}}
    {{ print "cpd-viewer-sa" }}
  {{- else -}}
    {{ template "sch.names.fullCompName" (list $root $serviceAccount) }}
  {{- end -}}
{{- end -}}

{{- define "aios.fqdn" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $serviceName:= (index $params 1) -}}
  {{- printf "%s-%s.%s.svc.%s" (include "fullname" $root) $serviceName $root.Release.Namespace $root.Values.clusterDomain }}
{{- end -}}

{{- /*
  Helper function for generating FQDN names - host name in certs cannot be longer than 64 characters
*/ -}}
{{- define "aios.fqdn2" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $serviceName:= (index $params 1) -}}
  {{- $name1 := printf "%s-%s.%s.svc.%s" (include "fullname" $root) $serviceName $root.Release.Namespace $root.Values.clusterDomain -}}
  {{- $name2 := printf "%s-%s.%s" (include "fullname" $root) $serviceName $root.Release.Namespace -}}
  {{- $name3 := printf "%s-%s" (include "fullname" $root) $serviceName -}}
  {{- $len1 := len $name1 -}}
  {{- $len2 := len $name2 -}}
  {{- if gt $len1 63 -}}
      {{- if gt $len2 63 -}}
          {{- $name3 }}
      {{- else -}}
          {{- $name2 }}
      {{- end -}}
  {{- else -}}
     {{- $name1 }}
  {{- end -}}
{{- end -}}

{{- define "aios.serviceAccountNameEditor" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $serviceAccount := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- if $root.Values.global.dockerRegistryPrefix -}}
    {{ printf "cpd-editor-sa" }}
  {{- else -}}
    {{ template "sch.names.fullCompName" (list $root $serviceAccount) }}
  {{- end -}}
{{- end -}}

{{- /*
  This service account was originally used for sudo access in changing file permission;
  default to viewer account as file permission change is no longer needed.
*/ -}}
{{- define "aios.serviceAccountNameAdmin" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $serviceAccount := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- if $root.Values.global.dockerRegistryPrefix -}}
    {{ printf "cpd-viewer-sa" }}
  {{- else -}}
    {{ template "sch.names.fullCompName" (list $root $serviceAccount) }}
  {{- end -}}
{{- end -}}

{{- define "aios.storageClassName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- if $root.Values.global.dockerRegistryPrefix -}}
    {{ $root.Values.global.storageClassName | default "" | quote }}
  {{- else -}}
    {{ $root.Values.global.persistence.storageClassName | default "" | quote }}
  {{- end -}}
{{- end -}}

{{- define "aios.cp4d.namespace" }}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- if $root.Values.global.dockerRegistryPrefix -}}
    {{- if $root.Values.cpd.namespace -}}
      {{- printf "%s"  $root.Values.cpd.namespace -}}
    {{- else -}}
      {{- printf "%s" $root.Release.Namespace -}}
    {{- end -}}
  {{- else -}}
    {{- printf "%s" $root.Values.icp4DataNamespace -}}
  {{- end -}}
{{- end -}}

{{- define "aios.nonroot.uid" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- if $root.Values.global.nonRootUID -}}
    {{- $root.Values.global.nonRootUID -}}
  {{- else -}}
    {{ print "1000321421" }}
  {{- end -}}
{{- end -}}

{{- /*
  UID for zensys - required for cpd-admin-sa which uses cpd-zensys-scc
*/ -}}
{{- define "aios.nonroot.uid2" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- if $root.Values.global.nonRootUID -}}
    {{- $root.Values.global.nonRootUID -}}
  {{- else -}}
    {{ print "1000321000" }}
  {{- end -}}
{{- end -}}

{{- /*
  Helper function fsGroupGid
*/ -}}
{{- define "aios.fsGroupGid" -}}
  {{- $params := . -}}
  {{- /* root context required for accessing other sch files */ -}}
  {{- $root := first $params -}}
  {{- if $root.Values.global.fsGroupGid -}}
fsGroup: {{ $root.Values.global.fsGroupGid }}
  {{- end -}}
{{- end -}}

{{- /*
  Helper function node affinity
*/ -}}
{{- define "aios.nodeAffinity" }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: beta.kubernetes.io/arch
              operator: In
              values:
                - {{ $.Values.global.arch }}
{{- end }}

{{- define "aios.labels" }}
  app.kubernetes.io/name: {{ include "sch.names.appName" ( list .) | quote}}
  helm.sh/chart: {{ .Chart.Name | quote }}
  app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
  app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{- define "aios.pod.labels" }}
  icpdsupport/addOnId: "aios"
  icpdsupport/app: {{ include "sch.names.appName" ( list .) | quote}}
  app.kubernetes.io/name: {{ include "sch.names.appName" ( list .) | quote}}
  helm.sh/chart: {{ .Chart.Name | quote }}
  app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
  app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{- define "aios.metering.base" }}
  productName: {{ $.Values.global.displayName }}
  productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
  productVersion: "3.5.0"
  productMetric: "VIRTUAL_PROCESSOR_CORE"
  cloudpakName: "IBM Cloud Pak for Data"
  cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
  productCloudpakRatio: "1:1"
  cloudpakInstanceId: {{ $.Values.global.cloudpakInstanceId }}
{{- end -}}

{{- define "aios.metering.nocharge" }}
{{- include "aios.metering.base" . }}
  productChargedContainers: ""
{{- end -}}

{{- define "aios.metering" }}
{{- include "aios.metering.base" . }}
  productChargedContainers: "ALL"
{{- end -}}

{{- define "aios.testpod.annotations" }}
  helm.sh/hook: "test-success"
{{- include "aios.metering.nocharge" . }}
{{- end -}}

{{- define "aios.getEncryptionSecretName" }}
    {{- $params := . -}}
    {{- $root := first $params -}}
    {{- $releaseName := $root.Release.Name -}}
    {{- if $root.Values.encryption.secretName -}}
        {{- print $root.Values.encryption.secretName -}}
    {{- else -}}
        {{- printf "%s-encryption-secret" $releaseName -}}
    {{- end -}}
{{- end -}}

{{- define "aios.getEncryptionSecretKeyName" }}
    {{- if .Values.encryption.secretKey -}}
        {{- print .Values.encryption.secretKey -}}
    {{- else -}}
        {{- print "encryptionKey" -}}
    {{- end -}}
{{- end -}}

{{- define "aios.common.liveness.options" }}
  initialDelaySeconds: 60
  timeoutSeconds: 6
  periodSeconds: 30
  failureThreshold: 6
{{- end }}

{{- define "aios.common.readiness.options" }}
  initialDelaySeconds: 75
  timeoutSeconds: 5
  periodSeconds: 30
  failureThreshold: 5
{{- end }}

{{- define "aios.cpdbr.annotations" }}
  hook.deactivate.cpd.ibm.com/command: '[]'
  hook.activate.cpd.ibm.com/command: '[]'
{{- end -}}
