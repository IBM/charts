{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
If the total memory is 10Gi, we will allocate 2Gi for the service, 8Gi for the Java heap.
For 20Gi, we will allocate 4Gi for the service , 16Gi for the heap.
*/}}

{{- define "serviceMemory" -}}
{{- if (eq (.Values.workersize | trunc 6) "2Cores") -}}
{{- printf "%s" "6G" -}}
{{- else if (eq (.Values.workersize | trunc 6) "4Cores") -}}
{{- printf "%s" "12G" -}}
{{- else -}}
{{- printf "%s" "16G" -}}
{{- end -}}
{{- end -}}

{{- define "totalMemory" -}}
{{- if (eq (.Values.workersize | trunc 6) "2Cores") -}}
{{- printf "%s" "10Gi" -}}
{{- else if (eq (.Values.workersize | trunc 6) "4Cores") -}}
{{- printf "%s" "16Gi" -}}
{{- else -}}
{{- printf "%s" "20Gi" -}}
{{- end -}}
{{- end -}}

{{- define "totalCpu" -}}
{{- if (eq (.Values.workersize | trunc 6) "2Cores") -}}
{{- printf "%s" "2000m" -}}
{{- else if (eq (.Values.workersize | trunc 6) "4Cores") -}}
{{- printf "%s" "4000m" -}}
{{- else -}}
{{- printf "%s" "8000m" -}}
{{- end -}}
{{- end -}}

{{- define "totalworkers" -}}
{{- if (eq (.Values.workersize | trunc 12) "2Cores 10G 1") -}}
{{- printf "%s" "1" -}}
{{- else if (eq (.Values.workersize | trunc 12) "2Cores 10G 2") -}}
{{- printf "%s" "2" -}}
{{- else if (eq (.Values.workersize | trunc 12) "4Cores 16G 1") -}}
{{- printf "%s" "1" -}}
{{- else if (eq (.Values.workersize | trunc 12) "4Cores 16G 2") -}}
{{- printf "%s" "2" -}}
{{- else if (eq (.Values.workersize | trunc 12) "8Cores 20G 1") -}}
{{- printf "%s" "1" -}}
{{- else -}}
{{- printf "%s" "2" -}}
{{- end -}}
{{- end -}}

{{- define "maxActiveNumFiles" -}}
{{- if (eq (.Values.workersize | trunc 6) "2Cores") -}}
{{- printf "%s" "4" -}}
{{- else if (eq (.Values.workersize | trunc 6) "4Cores") -}}
{{- printf "%s" "8" -}}
{{- else -}}
{{- printf "%s" "16" -}}
{{- end -}}
{{- end -}}

{{- define "maxInputProcessingSize" -}}
{{- if (eq (.Values.workersize | trunc 6) "2Cores") -}}
{{- printf "%s" "2000000" -}}
{{- else if (eq (.Values.workersize | trunc 6) "4Cores") -}}
{{- printf "%s" "4000000" -}}
{{- else -}}
{{- printf "%s" "8000000" -}}
{{- end -}}
{{- end -}}

{{/*
Return arch based on kube platform
*/}}
{{- define "arch" -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
{{- end -}}


{{- define "frontend-name" -}}
  {{- printf "%s-compare-and-comply-frontend" .Release.Name }}
{{- end -}}


{{- define "icp-pull-secrets" -}}
  {{- printf "%s" (default (printf "sa-%s" .Release.Namespace) .Values.global.imagePullSecretName) -}}
{{- end -}}
