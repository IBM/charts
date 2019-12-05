{{ define "common-prospector" }}
encoding: 'utf-8'
ignore_older: 0
scan_frequency: '10s'
symlinks: true
max_bytes: 10485760
harvester_buffer_size: 16384
fields_under_root: true
fields:
  type: '${FIELDS_TYPE:kube-logs}'
  pod_name: '${MY_POD_NAME}'
  namespace: '${MY_POD_NAMESPACE}'
  node_host_ip: '${MY_NODE_NAME}'
  pod_ip: '${MY_POD_IP}'
tags: '${TAGS:sidecar}'
{{ end }}
