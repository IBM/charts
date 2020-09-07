{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}
{{/* vim: set filetype=mustache: */}}

{{/*
Define a common prefix to the image name
*/}}
{{- define "image.family" -}}
netcool
{{- end -}}

{{/*
Define a common edition to the image name
*/}}
{{- define "image.edition" -}}
ee
{{- end -}}

{{/*
Define a common busybox image name
*/}}
{{- define "image.busybox" -}}
busybox:1.28.4
{{- end -}}

{{/*
redefine the repository name without the trailing /
*/}}
{{- define "image.docker.repository" -}}
{{ trimSuffix "/" .Values.global.image.repository }}
{{- end -}}

{{/*
Use either image tag or digest
*/}}
{{- define "image.suffix" -}}
{{- $root := (index . 0) -}}
{{- $image := (index . 1) -}}
{{- if or (eq (toString $root.Values.global.image.useTag) "true") (eq (toString $image.digest) "") -}}
{{- printf ":%s" $image.tag -}}
{{- else -}}
{{- printf "@%s" $image.digest -}}
{{- end -}}
{{- end -}}

{{/*
Configuration share image - Use either image tag or digest
*/}}
{{- define "config.share.image.suffix" -}}
{{- if or (eq (toString .Values.global.image.useTag) "true") (eq (toString .Values.global.image.sharedDigest) "") -}}
{{- printf ":%s" .Values.global.image.sharedTag -}}
{{- else -}}
{{- printf "@%s" .Values.global.image.sharedDigest -}}
{{- end -}}
{{- end -}}