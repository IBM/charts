{{- define "addon-sample.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "addon-sample.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
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
{{- define "addon-sample.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the database type
*/}}
{{- define "databasetype" -}}
{{- printf "database-%s" .Values.dbType -}}
{{- end -}}

{{- define "tolerations" }}
tolerations:
- key: "icp4data"
  operator: "Equal"
  value: "{{ template "databasetype" . }}"
  effect: "NoSchedule"
{{- end }}

{{- define "nodeaffinity" }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- include "nodeAffinityRequiredDuringScheduling" . }}
{{- end }}

{{- define "nodeAffinityRequiredDuringScheduling" }}
    #If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    #then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    #If you specify multiple matchExpressions associated with nodeSelectorTerms,
    #then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    #valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
      nodeSelectorTerms:
      - matchExpressions:
        - key: beta.kubernetes.io/arch
          operator: In
          values:
            - {{ template "kubeplatform" . }}
{{- end }}

{{/*
Expand the name of the chart.fdfd
*/}}
{{- define "svc-api.name" -}}
{{- default .Values.SVCAPI.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "svc-api.fullname" -}}
{{- default .Values.SVCAPI.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.fdfdf
*/}}
{{- define "svc-api.chart" -}}
{{- printf "%s-%s" .Values.SVCAPI.name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

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
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default unique name per database.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
We need a unique name for the deployment and service because of various versions.
*/}}
{{- define "uniquename" -}}
{{- printf "%s" .Release.Name | trunc 63 | replace "." "" -}}
{{- end -}}

{{/*
Check if tag contains specific platform suffix and if not set based on kube platform
*/}}
{{- define "platform" -}}
{{- if not .Values.arch }}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "x86_64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- end -}}
{{- else -}}
  {{- if (eq "amd64" .Values.arch) }}
     {{- printf "%s" "x86_64" }}
  {{- else -}}
     {{- printf "%s" .Values.arch }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Check if tag contains specific platform suffix and if not set based on kube platform
*/}}
{{- define "kubeplatform" -}}
{{- if not .Values.arch }}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- end -}}
{{- else -}}
    {{- printf "%s" .Values.arch }}
{{- end -}}
{{- end -}}

