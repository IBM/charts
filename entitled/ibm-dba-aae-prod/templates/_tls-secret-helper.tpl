{{- /*
Generate service URL

__Usage:__
{{ include "trustVolumes" (list .Values.global.caSecretName .Values.ums.tlsTrustList )}}

*/}}
{{- define "aae.trustVolumes" }}
{{- $params := . }}
{{- $cacert := first $params }}
{{- $trusted := last $params -}}
- name: trust-tls-volume
{{- if (or $cacert $trusted) }}
  projected:
    defaultMode: 0777
    sources:
    {{- if $cacert }}
    - secret:
        name: {{ $cacert }}
        items:
        - key: tls.crt
          path: ca.crt
    {{- end }}
    {{- range $index, $val := $trusted }}
    - secret:
        name: {{ $val }}
        items:
        - key: tls.crt
          path: tls-{{ toString $index }}.crt
    {{- end }}
{{- else }}
  emptyDir: {}
{{- end }}
{{- end }}

