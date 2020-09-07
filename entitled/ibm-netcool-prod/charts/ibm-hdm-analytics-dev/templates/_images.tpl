{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2020 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{/*
Use either image tag or digest
*/}}
{{- define "eventanalytics.image.suffix" -}}
{{- $root := (index . 0) -}}
{{- $image := (index . 1) -}}
{{- if or (eq (toString $root.Values.global.image.useTag) "true") (eq (toString $image.digest) "") -}}
{{- printf ":%s" $image.tag -}}
{{- else -}}
{{- printf "@%s" $image.digest -}}
{{- end -}}
{{- end -}}