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
ibmcom/netcool
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
ibmcom/busybox:1.28.4
{{- end -}}

{{/*
redefine the repository name without the trailing /
*/}}
{{- define "image.docker.repository" -}}
{{ trimSuffix "/" .Values.global.image.repository }}
{{- end -}}
