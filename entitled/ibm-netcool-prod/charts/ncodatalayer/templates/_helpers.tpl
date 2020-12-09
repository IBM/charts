{{/*
********************************************************** {COPYRIGHT-TOP} ****
* Licensed Materials - Property of IBM
*
* "Restricted Materials of IBM"
*
* © Copyright IBM Corp. 2019  All Rights Reserved.
*
* US Government Users Restricted Rights - Use, duplication, or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
********************************************************* {COPYRIGHT-END} ****
*/}}

{{- define "ncodatalayer.initcontainers.depwait" -}}
- name: waitforagg
  image: {{ include "ncodatalayer.image.repository" . }}/{{ .Values.ncodatalayer.image.name }}{{ include "ncodatalayer.image.suffix" (list . .Values.ncodatalayer.image) }}
  volumeMounts:
  - name: ca
    mountPath: /ca
    readOnly: true
{{ include "container.security.context" . | indent 2 }}  
  command:
  - /bin/sh
  - -c
  - '/app/entrypoint.sh npm run ping'
  env:
{{ include "common.application" . | indent 2 }}
{{ include "common.license" . | indent 2 }}
{{ include "common.omnibus" . | indent 2 }}
{{ include "common.kafka" . | indent 2 }}
{{ include "common.defaults" . | indent 2 }}
{{- if eq .Values.global.resource.requests.enable true }}
  resources:
{{ include "ncodatalayer.comp.size.data" (list . "ncoprimary" "resources") | indent 4 }}
{{- end }}
{{- end -}}

{{- define "ncodatalayer.initcontainers.osschemaupgrade" -}}
- name: osschemaupgrade
  image: {{ include "ncodatalayer.image.repository" . }}/{{ .Values.ncodatalayer.image.name }}{{ include "ncodatalayer.image.suffix" (list . .Values.ncodatalayer.image) }}
  volumeMounts:
  - name: ca
    mountPath: /ca
    readOnly: true
{{ include "container.security.context" . | indent 2 }}  
  command:
  - /bin/sh
  - -c
  - '/app/entrypoint.sh npm run upgradedb'
  env:
{{ include "common.application" . | indent 2 }}
{{ include "common.license" . | indent 2 }}
{{ include "common.omnibus" . | indent 2 }}
{{ include "common.kafka" . | indent 2 }}
{{ include "common.defaults" . | indent 2 }}
{{- if eq .Values.global.resource.requests.enable true }}
  resources:
{{ include "ncodatalayer.comp.size.data" (list . "ncoprimary" "resources") | indent 4 }}
{{- end }}
{{- end -}}

{{- define "ncodatalayer.initcontainers.depwait.kafka" -}}
- name: waitforkafka
  image: {{ include "ncodatalayer.image.repository" . }}/{{ .Values.ncodatalayer.image.name }}{{ include "ncodatalayer.image.suffix" (list . .Values.ncodatalayer.image) }}
{{ include "container.security.context" . | indent 2 }}  
  command:
  - /bin/sh
  - -c
  - 'i=1; until getent hosts {{ include "ncodatalayer.kafka.host" . }}; do echo waiting for kafka $i; i=$((i+1)); sleep 2; done;'
  env:
{{ include "common.application" . | indent 2 }}
{{ include "common.license" . | indent 2 }}
{{- if eq .Values.global.resource.requests.enable true }}
  resources:
{{ include "ncodatalayer.comp.size.data" (list . "ncoprimary" "resources") | indent 4 }}
{{- end }}
{{- end -}}

{{- /*
Default URLs based on release name
*/ -}}
{{- define "ncodatalayer.geturl" -}}
  {{- $root := index . 0 -}}
  {{- $userDefinedUrl := index . 1 -}}
  {{- $userDefinedRelease := index . 2 -}}
  {{- $urlTemplate := index . 3 -}}

  {{- if $userDefinedUrl -}}
    {{- $userDefinedUrl -}}
  {{- else if $userDefinedRelease -}}
    {{- printf $urlTemplate $userDefinedRelease -}}
  {{ else }}
    {{- printf $urlTemplate $root.Release.Name -}}
  {{- end -}}
{{- end -}}

{{- define "ncodatalayer.os.contactpoints" -}}
  {{- if eq .Values.global.hybrid.disabled true }}
    {{- $integrations := .Values.global.integrations -}}

    {{- $primaryOsUrlTemplate := "%s-objserv-agg-primary" -}}
    {{- $backupOsUrlTemplate := "%s-objserv-agg-backup" -}}

    {{- $primaryObjectServerHost := include "ncodatalayer.geturl" (list . $integrations.objectServer.primaryHostname $integrations.objectServer.releaseName $primaryOsUrlTemplate) -}}
    {{- $primaryObjectServerPort := int $integrations.objectServer.primaryPort -}}

    {{- $backupObjectServerHost := include "ncodatalayer.geturl" (list . $integrations.objectServer.backupHostname $integrations.objectServer.releaseName $backupOsUrlTemplate) -}}
    {{- $backupObjectServerPort := int $integrations.objectServer.backupPort -}}

    {{- printf "'{\"primary\":{\"hostname\":\"%s\",\"port\":%d},\"backup\":{\"hostname\":\"%s\",\"port\":%d}}'" $primaryObjectServerHost $primaryObjectServerPort $backupObjectServerHost $backupObjectServerPort -}}
  {{- else }}
    {{- $primaryObjectServerPort := int .Values.global.hybrid.objectserver.primary.port -}}
    {{- $backupObjectServerPort := int .Values.global.hybrid.objectserver.backup.port -}}
    {{- printf "'{\"primary\":{\"hostname\":\"%s\",\"port\":%d},\"backup\":{\"hostname\":\"%s\",\"port\":%d}}'" .Values.global.hybrid.objectserver.primary.hostname  $primaryObjectServerPort .Values.global.hybrid.objectserver.backup.hostname $backupObjectServerPort -}}
  {{- end }}
{{- end -}}

{{- define "ncodatalayer.os.username" -}}
  {{- if eq .Values.global.hybrid.disabled true }}
    {{- printf "%s" .Values.global.integrations.objectServer.username -}}
  {{- else }}
    {{- printf "%s" .Values.global.hybrid.objectserver.username -}}
  {{- end }}
{{- end -}}

{{- define "ncodatalayer.os.secret" -}}
  {{- if eq .Values.global.hybrid.disabled true }}
    {{- $integrations := .Values.global.integrations -}}
    {{- $objectServerSecretNameTemplate := "%s-omni-secret" -}}

    {{- include "ncodatalayer.geturl" (list . $integrations.objectServer.secretName $integrations.objectServer.releaseName $objectServerSecretNameTemplate) -}}
 {{- else }}
   {{- $objectServerSecretNameTemplate := "%s-omni-secret" -}}
   {{ printf .Values.global.omnisecretname .Release.Name }}
 {{- end }}
{{- end -}}

{{- define "ncodatalayer.kafka.host" -}}
  {{- $integrations := .Values.global.integrations -}}
  {{- $kafkaUrlTemplate := "%s-kafka" -}}

  {{- include "ncodatalayer.geturl" (list . $integrations.kafka.hostname $integrations.kafka.releaseName $kafkaUrlTemplate) -}}
{{- end -}}

{{- define "ncodatalayer.kafka.port" -}}
  {{- $integrations := .Values.global.integrations -}}

  {{- $integrations.kafka.port -}}
{{- end -}}

{{- define "ncodatalayer.kafka.adminPort" -}}
  {{- $integrations := .Values.global.integrations -}}

  {{- $integrations.kafka.adminPort -}}
{{- end -}}

{{- define "ncodatalayer.kafka.secretName" -}}
  {{- $integrations := .Values.global.integrations -}}
  {{- $kafkaSecretNameTemplate := "%s-kafka-client-secret" -}}

  {{- include "ncodatalayer.geturl" (list . $integrations.kafka.secretName $integrations.kafka.releaseName $kafkaSecretNameTemplate) -}}
{{- end -}}

{{- define "ncodatalayer.kafka.adminSecretName" -}}
  {{- $integrations := .Values.global.integrations -}}
  {{- $kafkaAdminSecretNameTemplate := "%s-kafka-admin-secret" -}}

  {{- include "ncodatalayer.geturl" (list . $integrations.kafka.adminSecretName $integrations.kafka.releaseName $kafkaAdminSecretNameTemplate) -}}
{{- end -}}

{{/*
Redefine the repository name without the trailing /
*/}}
{{- define "ncodatalayer.image.repository" -}}
{{ trimSuffix "/" .Values.global.image.repository }}
{{- end -}}

{{/*
Use either image tag or digest
*/}}
{{- define "ncodatalayer.image.suffix" -}}
{{- $root := (index . 0) -}}
{{- $image := (index . 1) -}}
{{- if or (eq (toString $root.Values.global.image.useTag) "true") (eq (toString $image.digest) "") -}}
{{- printf ":%s" $image.tag -}}
{{- else -}}
{{- printf "@%s" $image.digest -}}
{{- end -}}
{{- end -}}
