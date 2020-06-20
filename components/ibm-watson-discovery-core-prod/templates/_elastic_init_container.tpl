{{- define "discovery.elasticInitContainer" -}}
{{- $elasticCredentialSecretName := include "discovery.mantle.elastic.secret" . -}}
- name: elastic-init-container
  image: "{{ .Values.global.dockerRegistryPrefix }}/{{ .Values.initContainers.elastic.image.name }}:{{ .Values.initContainers.elastic.image.tag }}"
{{ include "sch.security.securityContext" (list . .sch.chart.restrictedSecurityContext) | indent 2 }}
  resources:
    requests:
      memory: {{ .Values.initContainers.elastic.resources.requests.memory | quote }}
      cpu: {{ .Values.initContainers.elastic.resources.requests.cpu | quote }}
    limits:
      memory: {{ .Values.initContainers.elastic.resources.limits.memory | quote }}
      cpu: {{ .Values.initContainers.elastic.resources.limits.cpu | quote }}
  env:
  - name: ELASTIC_USER
    valueFrom:
      secretKeyRef:
        name: {{ $elasticCredentialSecretName }}
        key: username
  - name: ELASTIC_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ $elasticCredentialSecretName }}
        key: password
  - name: ELASTIC_URL
    valueFrom:
      configMapKeyRef:
        name: {{ include "discovery.mantle.elastic.configmap" . }}
        key: endpoint
  command:
  - "/bin/bash"
  - -c
  - |
    while true;
    do
      echo "Waiting for elasticsearch startup"
      curl -l -k -u ${ELASTIC_USER}:${ELASTIC_PASSWORD} ${ELASTIC_URL}/_cluster/health | grep '"status":"yellow"\|"status":"green"'
      if [ $? -eq 0 ]
      then
        echo "Elasticsearch has started up"
        break
      fi
      sleep 1s
    done
{{- end -}}