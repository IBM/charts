{{- define "health.test" -}}
{{- $params := . }}
{{- $global := (index $params 0) -}}
{{- $serviceName := (index $params 1) -}}
{{- $urlPath := (index $params 2) -}}
{{- $labels := (index $params 3) -}}
apiVersion: v1
kind: Pod
metadata:
  name: {{ $serviceName }}-healthcheck-test
  labels:
{{ $labels | indent 4 }}
    testPod: "true"
  annotations:
    "helm.sh/hook": test-success
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
    image: "{{ $global.Values.global.dockerRegistryPrefix }}/{{ $global.Values.global.images.utils.image }}:{{ $global.Values.global.images.utils.tag }}"
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
    command: ["sh", "-c", "curl http://{{ $serviceName }}:80/{{ $urlPath }}"]
  - name: {{ $global.Release.Name }}-https
    image: "{{ $global.Values.global.dockerRegistryPrefix }}/{{ $global.Values.global.images.utils.image }}:{{ $global.Values.global.images.utils.tag }}"
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
        memory: "512Mi"
        cpu: "1000m"
    command: ["sh", "-c", "curl -k https://{{ $serviceName }}:443/{{ $urlPath }}"]
  restartPolicy: Never
  affinity:
{{- include "ibm-watson-speech-prod.affinity" $global | indent 4 }}
{{- end -}}
