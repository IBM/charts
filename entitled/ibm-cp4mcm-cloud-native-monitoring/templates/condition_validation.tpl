{{- $licenseCheck := dict "accepted" "false" -}}
{{- if (hasKey .Values.global "license") -}}
  {{- if eq .Values.global.license "accept" -}}
    {{ $_ := set $licenseCheck "accepted" "true" }}
  {{- end -}}
{{- end -}}

{{- /* License accepted check */ -}}
{{- if ne $licenseCheck.accepted "true" -}}
  {{- fail "The product license must be accepted to install the chart. Use global.license=accept to accept the product license." -}}
{{- end -}}
