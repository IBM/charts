{{- /*
Generate service URL

__Usage:__
{{ include "serviceURL" (list .Values.ums "ums")}}

*/}}
{{- define "aae.serviceURL" }}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $compoName := last $params }}
  {{- with $root }}
    {{- if (eq (toString .port) "443" ) }}
      {{- printf "https://%s" .hostname }}
    {{- else }}
      {{- printf "https://%s:%s" .hostname (toString .port) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- /*
Generate service definition

__Usage:__
{{ include "serviceDefinition" (list . (dict "serviceType" "Ingress" "name" "ums-service" "port" "30810" "targetPort" "https" "label" "app: ums")) }}

`label` is used for selector and labels both.

*/}}
{{- define "aae.serviceDefinition" }}
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
      {{if eq .serviceType "NodePort" }}nodePort: {{ toString .port }}{{ end }}
  selector:
{{ .label | indent 4 }}
  {{- end }}
{{- end }}
