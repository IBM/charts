{{/* vim: set filetype=mustache: */}}
{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp.
#
# 2019 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{- define "container.security.context" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
    - ALL
    add: ["NET_BIND_SERVICE","NET_RAW"]
{{- end -}}

{{- define "deployment.security.context" -}}
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
hostNetwork: false
hostPID: false
hostIPC: false
serviceAccountName: {{ .Values.global.rbac.serviceAccountName }}
{{- end -}}
