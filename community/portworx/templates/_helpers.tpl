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

{{- define "px.metering.annotations" -}}
productName: "PX-Enterprise"
productID: com.portworx.enterprise
productVersion: {{ quote .Values.imageVersion }}
{{- end -}}

{{- define "px.kubernetesVersion" -}}
{{$version := .Capabilities.KubeVersion.GitVersion | regexFind "^v\\d+\\.\\d+\\.\\d+"}}{{$version}}
{{- end -}}

{{- define "px.getETCDPreInstallHookImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/px-etcd-preinstall-hook:v1.5" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/portworx/px-etcd-preinstall-hook:v1.5" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "portworx/px-etcd-preinstall-hook:v1.5" }}
{{- end -}}
{{- end -}}

{{- define "px.getK8KubectlImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/k8s-kubectl" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/portworx/k8s-kubectl" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "lachlanevenson/k8s-kubectl" }}
{{- end -}}
{{- end -}}

{{- define "px.getPauseImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/pause:3.1" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/portworx/pause:3.1" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "k8s.gcr.io/pause:3.1" }}
{{- end -}}
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

{{- define "px.getGrafanaImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/grafana" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/grafana/grafana" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "grafana/grafana" }}
{{- end -}}
{{- end -}}

{{- define "px.getPrometheusOperatorImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/prometheus-operator" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/prometheus-operator/prometheus-operator" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "quay.io/prometheus-operator/prometheus-operator" }}
{{- end -}}
{{- end -}}

{{- define "px.getPrometheusImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/prometheus" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/prometheus/prometheus" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "quay.io/prometheus/prometheus" }}
{{- end -}}
{{- end -}}

{{- define "px.getPrometheusConfigReloaderImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/prometheus-config-reloader" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/prometheus-operator/prometheus-config-reloader" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "quay.io/prometheus-operator/prometheus-config-reloader" }}
{{- end -}}
{{- end -}}

{{- define "px.getAlertmanagerImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/alertmanager" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/prometheus/alertmanager" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "quay.io/prometheus/alertmanager" }}
{{- end -}}
{{- end -}}

{{- define "px.getAutopilotImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/autopilot" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/portworx/autopilot" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "portworx/autopilot" }}
{{- end -}}
{{- end -}}


{{- define "px.getk8sImages" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/k8s.gcr.io" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "k8s.gcr.io" }}
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

{{- define "px.getCSIprovisioner" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/quay.io/openstorage" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "quay.io/openstorage" }}
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

{{/*
Populate the ports based on deployemnt environment
*/}}
{{- define "px.pxAPIPort" -}}
{{- if ( eq true .Values.changePortRange) -}}
    {{- printf "17001" -}}
{{- else -}}
    {{- printf "9001" -}}
{{- end -}}
{{- end -}}

{{- define "px.pxHealthPort" -}}
{{- if ( eq true .Values.changePortRange) -}}
    {{- printf "17015" -}}
{{- else -}}
    {{- printf "9015" -}}
{{- end -}}
{{- end -}}

{{- define "px.pxKVDBPort" -}}
{{- if ( eq true .Values.changePortRange) -}}
    {{- printf "17019" -}}
{{- else -}}
    {{- printf "9019" -}}
{{- end -}}
{{- end -}}

{{- define "px.pxSDKPort" -}}
{{- if ( eq true .Values.changePortRange) -}}
    {{- printf "17017" -}}
{{- else -}}
    {{- printf "9020" -}}
{{- end -}}
{{- end -}}

{{- define "px.pxGatewayPort" -}}
{{- if ( eq true .Values.changePortRange) -}}
    {{- printf "17021" -}}
{{- else -}}
    {{- printf "9021" -}}
{{- end -}}
{{- end -}}