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
{{ include "bastudio.trustVolumes" (list .Values.global.caSecretName .Values.ums.tlsTrustList )}}

*/}}
{{- define "bastudio.trustVolumes" }}
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

