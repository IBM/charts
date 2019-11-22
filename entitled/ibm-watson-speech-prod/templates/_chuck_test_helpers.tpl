{{- define "chuck.test" -}}
{{- $params := . }}
{{- $global := (index $params 0) -}}
{{- $group_name := (index $params 1) -}}
{{- $serviceName := (index $params 2) -}}
{{- $group := (index $global.Values.groups $group_name) -}}
apiVersion: v1
kind: Pod
metadata:
  name: {{ $serviceName }}-healthcheck-test
  labels:
{{ include "sch.metadata.labels.standard" (list $global $serviceName) | indent 4 }}
  annotations:
    "helm.sh/hook": test-success
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  hostNetwork: false
  hostPID: false
  hostIPC: false
  securityContext:
    runAsNonRoot: true
    {{- if not ($global.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
    runAsUser: 1001
    {{- end }}
  containers:
  - name: {{ $global.Release.Name }}-http
    image: "{{ $global.Values.global.image.repository }}/{{ $global.Values.global.images.utils.image }}:{{ $global.Values.global.images.utils.tag }}"
    securityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "1024Mi"
        cpu: "1000m"
    command: ["sh", "-c", "curl http://{{ $serviceName }}:1080/v1/miniHealthCheck"]
  - name: {{ $global.Release.Name }}-https
    image: "{{ $global.Values.global.image.repository }}/{{ $global.Values.global.images.utils.image }}:{{ $global.Values.global.images.utils.tag }}"
    securityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "1024Mi"
        cpu: "1000m"
    command: ["sh", "-c", "curl -k https://{{ $serviceName }}:1443/v1/miniHealthCheck"]
  restartPolicy: Never
  affinity:
{{- include "ibm-watson-speech-prod.watson-speech-nodeaffinity" $global.Values.arch | indent 4 }}
{{- end -}}
