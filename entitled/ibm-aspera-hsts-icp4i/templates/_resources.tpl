{{ define "hsts.resources.static.tiny" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.01'
  limits:
    memory: 100Mi
    cpu: '.1'
{{- end }}

{{ define "hsts.resources.static.small" -}}
resources:
  requests:
    memory: 100Mi
    cpu: '.1'
  limits:
    memory: 200Mi
    cpu: '.1'
{{- end }}

# resource sizing for ascp transfer pods, defaults to "medium"

{{ define "hsts.resources.static.ascp" -}}
  {{- $size := .Values.global.resources.all -}}
  {{- if ne .Values.global.resources.ascp "" -}}
    {{- $size := .Values.global.resources.ascp -}}
  {{- end }}
  {{- if eq $size "tiny" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.005'
  limits:
    memory: 700Mi
    cpu: '.1'
  {{- else if eq $size "medium" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.02'
  limits:
    memory: 700Mi
    cpu: '1.0'
  {{- else if eq $size "large" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.04'
  limits:
    memory: 700Mi
    cpu: '2.0'
  {{- else if eq $size "xlarge" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.08'
  limits:
    memory: 700Mi
    cpu: '4.0'
  {{- else }}
resources:
  requests:
    memory: 50Mi
    cpu: '.01'
  limits:
    memory: 700Mi
    cpu: '.5'
  {{- end }}
{{- end }}

# resource sizing for asperanode pods, defaults to "medium"

{{ define "hsts.resources.static.asperanode" -}}
  {{- $size := .Values.global.resources.all -}}
  {{- if ne .Values.global.resources.asperanode "" -}}
    {{- $size := .Values.global.resources.asperanode -}}
  {{- end }}
  {{- if eq $size "tiny" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.005'
  limits:
    memory: 700Mi
    cpu: '.1'
  {{- else if eq $size "medium" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.02'
  limits:
    memory: 700Mi
    cpu: '1.0'
  {{- else if eq $size "large" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.04'
  limits:
    memory: 700Mi
    cpu: '2.0'
  {{- else if eq $size "xlarge" -}}
resources:
  requests:
    memory: 50Mi
    cpu: '.08'
  limits:
    memory: 700Mi
    cpu: '4.0'
  {{- else }}
resources:
  requests:
    memory: 50Mi
    cpu: '.01'
  limits:
    memory: 700Mi
    cpu: '.5'
  {{- end }}
{{- end }}
