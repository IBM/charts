{{- define "discovery.haywireInitContainer" -}}
{{- if .Values.global.private -}}
{{- $haywireCompName := .sch.chart.components.haywire.name -}}
{{- $initContainerCompName := .sch.chart.components.trainingCrudInitContainer.name -}}
{{- $namespace := .Release.Namespace -}}
- name: {{ $initContainerCompName }}
  image: "{{ .Values.global.dockerRegistryPrefix }}/{{- .Values.wire.test.image.name }}:{{- .Values.wire.test.image.tag }}"
{{ include "sch.security.securityContext" (list . .sch.chart.restrictedSecurityContext) | indent 2 }}
  resources:
    requests:
      memory: {{ .Values.wire.test.resources.requests.memory | quote }}
      cpu: {{ .Values.wire.test.resources.requests.cpu | quote }}
    limits:
      memory: {{ .Values.wire.test.resources.limits.memory | quote }}
      cpu: {{ .Values.wire.test.resources.limits.cpu | quote }}
  command:
  - /bin/sh
  - -c
  - >-
    while :; do for p in `kubectl -n {{ $namespace }} get po -l app.kubernetes.io/component={{ $haywireCompName }},release={{ .Release.Name }} -o name`;
    do echo "Testing $p"; kubectl -n {{ $namespace }} exec ${p:4} -c {{ $haywireCompName }} -- sh -c './aceso -method health -service_port 50051 -ca_certificate ca.crt -skip_hostname_verification';
    if [[ $? == 0 ]]; then exit 0; fi; done; sleep 10; done
{{- end -}}
{{- end -}}