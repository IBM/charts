{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "zookeeper.name" -}}
{{- default "zookeeper" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zookeeper.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "zookeeper" .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zookeeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Defines default chart labels
*/}}
{{- define "zookeeper.defaultLabels" }}
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
release: "{{ .Release.Name }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
app.kubernetes.io/component: "{{ .Chart.Name }}"
{{- end }}

{{/*
Defines product metering
*/}}
{{- define "zookeeper.metering" }}
{{- if ( .Values.environmentType ) and eq .Values.environmentType "icp4data"  }}
productID: "ICP4D-998edc72e0f04ec18cc5e2310eabafee-Management"
productName: "IBM Streams for IBM Cloud Pak For Data"
{{- else }}
productID: "d278763f052d4334b2e3fc210a3cc027-Management"
productName: "IBM Streams"
{{- end }}
productVersion: {{.Chart.AppVersion | quote }}
{{- end }}

{{/*
Defines serviceability labels
*/}}
{{- define "zookeeper.serviceability" }}
{{- if ( .Values.environmentType ) and eq .Values.environmentType "icp4data"  }}
{{- if ( .Values.serviceInstanceId )  }}
icpdsupport/zenInstanceID: {{ .Values.serviceInstanceId | quote }}
{{- end }}
icpdsupport/addOnKey: "streams"
{{- end }}
{{- end }}

{/*
Defines container security context values
*/}}
{{- define "zookeeper.containerSecurityContext" }}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: false
runAsNonRoot: true
capabilities:
  drop:
  - ALL
{{- end }}

{/*
Defines pod general security policies
HostPID - Controls whether the pod containers can share the host process ID namespace. Note that when 
paired with ptrace this can be used to escalate privileges outside of the container (ptrace is forbidden by default).
HostIPC - Controls whether the pod containers can share the host IPC namespace.
HostNetwork - Controls whether the pod may use the node network namespace. Doing so gives the pod access to the 
loopback device, services listening on localhost, and could be used to snoop on network activity of other pods on the same node.
*/}}
{{- define "zookeeper.podGeneralSecurityPolicies" }}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end }}

{/*
Defines general pod securityContext values
*/}}
{{- define "zookeeper.podSecurityContext" }}
runAsNonRoot: true
{{- end }}

{/*
Install owner and user uid
*/}}
{{- define "zookeeper.streamsinstall" -}}
{{- printf "%d" 10756 -}}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "zookeeper.serviceAccountName" -}}
{{- if .Values.serviceAccount -}}
{{- printf "%s" .Values.serviceAccount -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "streams" -}}
{{- end -}}
{{- end -}}


{{/* 
Validate required values are specified. 
*/}}
{{- define "zookeeper.checkValues" -}}

  {{- if or (empty .Values.license) (ne .Values.license "accept") -}} 
    {{- fail "You must read and accept the license by setting the following value to 'accept':  license." -}}
  {{- end -}}
{{- end -}}