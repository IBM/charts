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
    {{- if $cpdImageRepo -}}
      {{ printf "%s/%s:%s" $cpdImageRepo $imageName $imageTag }}
    {{- else -}}
      {{ printf "%s/%s:%s" $imageRepo $imageName $imageTag }}
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

{{- define "aios.serviceAccountNameAdmin" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $serviceAccount := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- if $root.Values.global.dockerRegistryPrefix -}}
    {{ printf "cpd-admin-sa" }}
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
                - amd64
{{- end }}

{{- define "aios.metering" }}
  productName: "IBM Watson OpenScale"
  productID: "5737_H76"
  productVersion: "2.5.0.0"
  productMetric: "VIRTUAL_PROCESSOR_CORE"
  productChargedContainers: "All"
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
  timeoutSeconds: 5
  periodSeconds: 30
  failureThreshold: 5
{{- end }}

{{- define "aios.common.readiness.options" }}
  initialDelaySeconds: 75
  timeoutSeconds: 5
  periodSeconds: 30
  failureThreshold: 5
{{- end }}
