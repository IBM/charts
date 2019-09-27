{{- include "sch.config.init" (list . "hsts.sch.chart.config.values") -}}

{{ define "hsts.cert" -}}
 {{- if .Values.ingress.tlsSecret -}}
 {{ .Values.ingress.tlsSecret }}
 {{- else if .Values.tls.issuer -}}
 {{ include "sch.names.fullCompName" (list . .sch.chart.components.certificate) | quote }}
 {{- else -}}
 {{ printf "%s-%s" "cert" .sch.chart.secretGen.suffix }}
 {{- end -}}
{{- end }}

{{ define "hsts.secret.accessKey" -}}
  {{ default (printf "%s-%s" "access-key" .sch.chart.secretGen.suffix) .Values.asperanode.accessKeySecret }}
{{- end }}

{{ define "hsts.secret.nodeAdmin" -}}
  {{ default (printf "%s-%s" "node-admin" .sch.chart.secretGen.suffix) .Values.asperanode.nodeAdminSecret }}
{{- end }}

{{ define "hsts.secret.sshdKeys" -}}
  {{ default (printf "%s-%s" "sshd" .sch.chart.secretGen.suffix) .Values.sshdKeysSecret }}
{{- end }}

{{- define "secretGen.secrets.spec.rsa" }}
{{- $params := . -}}
{{- $secret := first $params -}}
{{- $labels := index $params 1 -}}
{{- $overwriteExisting := index $params 2 -}}
ssh-keygen -b 4096 -f /tmp/id_rsa -t rsa -N ''
cat /tmp/id_rsa.pub | awk '{print $2}' | base64 -d | sha1sum | sed 's/\(.*\) .*/\1/' > /tmp/fingerprint

{{ if eq $overwriteExisting true }}
cat <<EOF | kubectl apply -f -
{{- else }}
cat <<EOF | kubectl create -f -
{{- end }}
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: {{ $secret.name }}
  labels:
{{ $labels | indent 4 }}
data:
  {{ $secret.privateKeyName }}: $(cat //tmp/id_rsa | base64 | tr -d '\n')
  {{ $secret.publicKeyName }}: $(cat /tmp/id_rsa.pub | base64 | tr -d '\n')
  {{ $secret.fingerprintName }}: $(cat /tmp/fingerprint | base64 | tr -d '\n')
EOF
{{- end }}
