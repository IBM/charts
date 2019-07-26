{{- define "px.appName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "px.labels" -}}
app.kubernetes.io/managed-by: {{.Release.Service | quote }}
app.kubernetes.io/instance: {{.Release.Name | quote }}
app.kubernetes.io/name: {{ template "px.appName" . }}
helm.sh/chart: "{{.Chart.Name}}-{{.Chart.Version}}"
{{- end -}}

{{- define "px.kubernetesVersion" -}}
{{$version := .Capabilities.KubeVersion.GitVersion | regexFind "^v\\d+\\.\\d+\\.\\d+"}}{{$version}}
{{- end -}}


{{- define "px.getImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/oci-monitor" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/portworx/oci-monitor" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "portworx/oci-monitor" }}
{{- end -}}
{{- end -}}

{{- define "px.getStorkImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/stork" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/openstorage/stork" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "openstorage/stork" }}
{{- end -}}
{{- end -}}

{{- define "px.getk8sImages" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/gcr.io/google_containers" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "gcr.io/google_containers" }}
{{- end -}}
{{- end -}}

{{- define "px.getcsiImages" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/quay.io/k8scsi" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "quay.io/k8scsi" }}
{{- end -}}
{{- end -}}

{{- define "px.getLighthouseImages" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/portworx/" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "portworx" }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for hooks
*/}}
{{- define "px.hookServiceAccount" -}}
{{- if .Values.serviceAccount.hook.create -}}
    {{- printf "%s-hook" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.hook.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the cluster role to use for hooks
*/}}
{{- define "px.hookClusterRole" -}}
{{- if .Values.serviceAccount.hook.create -}}
    {{- printf "%s-hook" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.hook.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the cluster role binding to use for hooks
*/}}
{{- define "px.hookClusterRoleBinding" -}}
{{- if .Values.serviceAccount.hook.create -}}
    {{- printf "%s-hook" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.hook.name }}
{{- end -}}
{{- end -}}
