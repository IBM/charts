{{- define "ibm-app-navigator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-app-navigator.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-app-navigator.container.security" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
{{- end -}}

{{- define "ibm-app-navigator.pod.security" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  fsGroup:
{{- end -}}

{{- define "ibm-app-navigator.utils.isICP" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
{{- if contains "icp" $root.Capabilities.KubeVersion.GitVersion -}}
{{- $_ := set $root.Values "isICP" true -}}
{{- end -}}
{{- end -}}