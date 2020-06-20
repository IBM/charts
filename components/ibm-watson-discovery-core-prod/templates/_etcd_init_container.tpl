{{- define "discovery.etcdInitContainer" -}}
{{- $etcdCredentialSecretName := include "discovery.crust.etcd.secret" . -}}
- name: etcd-init-container
  image: {{ .Values.global.dockerRegistryPrefix }}/
    {{- .Values.initContainers.etcd.image.name }}:
    {{- .Values.initContainers.etcd.image.tag }}
{{ include "sch.security.securityContext" (list . .sch.chart.restrictedSecurityContext) | indent 2 }}
  resources:
    requests:
      memory: {{ .Values.initContainers.etcd.resources.requests.memory | quote }}
      cpu: {{ .Values.initContainers.etcd.resources.requests.cpu | quote }}
    limits:
      memory: {{ .Values.initContainers.etcd.resources.limits.memory | quote }}
      cpu: {{ .Values.initContainers.etcd.resources.limits.cpu | quote }}
  env:
  - name: ETCD_USERNAME
    valueFrom:
      secretKeyRef:
        name: {{ $etcdCredentialSecretName }}
        key: username
  - name: ETCD_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ $etcdCredentialSecretName }}
        key: password
  - name: ETCD_ENDPOINTS
    valueFrom:
      configMapKeyRef:
        name: {{ include "discovery.crust.etcd.configmap" . }}
        key: endpoint
  - name: ETCDCTL_API
    value: "3"
  command:
  - "/bin/sh"
  - -ec
  - |
    # Checks if etcd is running
    if [ ${DEBUG} ] ; then
     set -x
    fi
    while true ; do
      echo "etcdctl endpoint health"
      etcdctl \
        --insecure-skip-tls-verify=true \
        --insecure-transport=false \
        --endpoints="${ETCD_ENDPOINTS}" \
        --user $ETCD_USERNAME:$ETCD_PASSWORD endpoint health && break
      echo "  command failed. Waiting 5 sec before next retry"
      sleep 5
    done
{{- end -}}
