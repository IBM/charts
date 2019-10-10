{{/* vim: set filetype=mustache: */}}
{{/*
InitContainer for elasticsearch
*/}}
{{- define "elasticsearch.initContainers" -}}
initContainers:
- name: sysctl
  image: {{ .Values.elasticsearch.init.image.repository }}:{{ .Values.elasticsearch.init.image.tag }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ["/bin/sh", "-c", "sysctl -w vm.max_map_count=262144 && sed -i '/^vm.max_map_count /d' /etc/sysctl.conf && echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf && sysctl -w vm.swappiness=1 && sed -i '/^vm.swappiness /d' /etc/sysctl.conf && echo 'vm.swappiness=1' >> /etc/sysctl.conf"]
  securityContext:
    privileged: true
{{- if .Values.elasticsearch.data.storage.persistent }}
- name: initcontainer
  image: {{ .Values.elasticsearch.init.image.repository }}:{{ .Values.elasticsearch.init.image.tag }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ["/bin/sh", "-c", "mkdir -p /usr/share/elasticsearch/data/nodes && chown -R 1000:1000 /usr/share/elasticsearch/data; chmod ug+x /usr/share/elasticsearch/data /usr/share/elasticsearch/data/nodes"]
  securityContext:
    privileged: true
  volumeMounts:
  - name: data
    mountPath: /usr/share/elasticsearch/data
{{- end }}
{{ end }}

{{- define "elasticsearch.initContainers.client" -}}
initContainers:
- name: sysctl
  image: {{ .Values.elasticsearch.init.image.repository }}:{{ .Values.elasticsearch.init.image.tag }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ["/bin/sh", "-c", "sysctl -w vm.max_map_count=262144 && sed -i '/^vm.max_map_count /d' /etc/sysctl.conf && echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf && sysctl -w vm.swappiness=1 && sed -i '/^vm.swappiness /d' /etc/sysctl.conf && echo 'vm.swappiness=1' >> /etc/sysctl.conf"]
  securityContext:
    privileged: true
{{ end }}
