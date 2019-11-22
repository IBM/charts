###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2019. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################
{{- /*
Generate service URL

__Usage:__
{{ include "bastudio.serviceURL" (list .Values.ums "ums")}}

*/}}
{{- define "bastudio.serviceURL" }}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $compoName := last $params }}
  {{- with $root }}
    {{- if (eq .serviceType "Ingress") }}
      {{- printf "https://%s" .hostname }}
    {{- else if (eq .serviceType "NodePort") }}
      {{- printf "https://%s:%s" .hostname (toString .port) }}
    {{- else if (eq (toString .port) "443" ) }}
      {{- printf "https://%s-service" $compoName }}
    {{- else }}
      {{- printf "https://%s-service:%s" $compoName (toString .port) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- /*
Generate service definition

__Usage:__
{{ include "serviceDefinition" (list . (dict"serviceType" "Ingress" "name" "ums-service" "port" "30810" "targetPort" "https" "label" "app: ums")) }}

`label` is used for selector and labels both.

*/}}
{{- define "bastudio.serviceDefinition" }}
{{- $params := . }}
{{- $root := first $params }}
{{- $dictValues := last $params }}
  {{- with $dictValues }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  labels:
{{ .label | indent 4 }}
spec:
  type: {{if or (eq .serviceType "Ingress") (eq .serviceType "ClusterIP") }}ClusterIP{{ else }}NodePort{{ end }}
  ports:
    - name: https
      protocol: TCP
      port: 443
      targetPort: {{toString .targetPort}}
      {{if eq .serviceType "NodePort" }}nodePort: {{ .port }}{{ end }}
  selector:
{{ .label | indent 4 }}
  {{-  if eq .serviceType "NodePort" }}
  sessionAffinity: ClientIP
  {{- end }}
  {{- end }}
{{- end }}
