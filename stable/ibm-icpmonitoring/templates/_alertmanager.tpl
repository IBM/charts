{{/* Alertmanager Configuration Files */}}
{{- define "alermanagerConfig" }}
alertmanager.yml: |-
  global:
  receivers:
    - name: default-receiver
  route:
    group_wait: 10s
    group_interval: 5m
    receiver: default-receiver
    repeat_interval: 3h
{{- end }}