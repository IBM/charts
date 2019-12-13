{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-wml-accelerator-prod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 48 -}}
{{- end -}}

{{/*
Create fully qualified names.
We truncate at 48 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibm-wml-accelerator-prod.master-fullname" -}}
{{- $name := default .Chart.Name .Values.master.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 48 -}}
{{/*- printf "%s" $name | trunc 48 - */}}
{{- end -}}

{{- define "global.icpVersion" -}}
    {{- if and (eq (.Capabilities.KubeVersion.Major|int) 1) (lt (.Capabilities.KubeVersion.Minor|int) 11) -}}
        {{- printf "2.x" -}}
    {{- else -}}
        {{- printf "3.1+" -}}
    {{- end -}}
{{- end -}}

{{- define "global.conductorVersion" -}}
{{- printf "2.3.0" -}}
{{- end -}}

{{- define "global.dliVersion" -}}
{{- printf "1.2.0" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.getserviceslots" -}}
{{- printf "8" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.getmaxslots" -}}
{{- if .Values.sig.cpu|hasSuffix "m" }}
{{- $maxcpu := default 6 .Values.sig.cpu|trimSuffix "m"|int -}}
{{- $maxslot := div $maxcpu 1000 -}}
{{- printf "%d" $maxslot -}}
{{- else }}
{{- $maxslot := default 6 .Values.sig.cpu|int -}}
{{- printf "%d" $maxslot -}}
{{- end }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdServicePort" -}}
{{- printf "2379" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdEndpoint" -}}
https://{{ include "ibm-wml-accelerator-prod.master-fullname" . }}-etcd:{{ include "ibm-wml-accelerator-prod.etcdServicePort" . }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdInstanceCreation" -}}
{{- printf "http://cwsetcd.default:2379/v2/keys/cwsinstancecreated" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdInstanceDeletion" -}}
{{- printf "http://cwsetcd.default:2379/v2/keys/cwsinstancedeleted" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdClientCertPath" -}}
{{- printf "/var/shareDir/cwsetcd/certs/etcd-client.crt" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdClientKeyPath" -}}
{{- printf "/var/shareDir/cwsetcd/private/etcd-client.key" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdCacert" -}}
{{- printf "/var/shareDir/cwsetcd/certs/ca.crt" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdUID" -}}
101
{{- end }}

{{/* The default image is different for Conductor and DLI */}}
{{- define "ibm-wml-accelerator-prod.Image" -}}
{{- .Values.global.dockerRegistryPrefix -}}/{{- .Values.master.repository -}}:{{- .Values.master.tag -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.CondaImage" -}}
{{- .Values.global.dockerRegistryPrefix -}}/{{- .Values.conda.repository -}}:{{- .Values.conda.tag -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.UtilsImage" -}}
{{- .Values.global.dockerRegistryPrefix -}}/{{- .Values.utils.repository -}}:{{- .Values.utils.tag -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.cwsImageWithoutRegistryTag" -}}
{{- printf "default/conductor-spark" -}}
{{- end -}}


{{- define "ibm-wml-accelerator-prod.imageNamespace" -}}
{{- printf "default" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.kubectlImage" -}}
{{.Values.global.dockerRegistryPrefix}}/{{.Values.hyperkube.repository}}:{{.Values.hyperkube.tag}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.kubectlProxyCmd" -}}
- /bin/hyperkube
- kubectl
- proxy
{{- end -}}

{{- define "ibm-wml-accelerator-prod.kubectlCopyCmd" -}}
- /bin/cp
- /bin/hyperkube
{{- end -}}

{{- define "ibm-wml-accelerator-prod.kubectlProbeCmd" -}}
- ls
- /bin/hyperkube
{{- end -}}

{{- define "ibm-wml-accelerator-prod.securedHelm" -}}
{{- printf .Values.helm.tlsenabled -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.helmHome" -}}
{{- printf "/var/tmp/helm" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.helmFlag" -}}
    {{- if eq (include "ibm-wml-accelerator-prod.securedHelm" .) "true" -}}
        {{- printf "--tls" -}}
    {{- else -}}
        {{- printf "" -}}
    {{- end -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.helmImage" -}}
{{- if eq (.Capabilities.KubeVersion.GitVersion | trunc 7) "v1.10.0" -}}
{{- printf "ibmcom/icp-helm-api:1.0.0" -}}
{{- else -}}
{{- $imagetag := "v2.6.0" -}}
{{- if eq (.Values.arch.amd64 | trunc 1) "3" -}}
{{- $imagetag := "2.12.2" -}}
{{- printf "\"alpine/helm:%s\"" $imagetag -}}
{{- else if eq (.Values.arch.ppc64le | trunc 1) "3" -}}
{{- printf "\"ibmcom/helm-ppc64le:%s\"" $imagetag -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.etcdImage" -}}
{{- .Values.global.dockerRegistryPrefix -}}/{{.Values.etcd.repository}}:{{.Values.etcd.tag}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.ingressImage" -}}
{{- printf "nginx:mainline" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.ContainerUID" -}}
15585
{{- end -}}

{{- define "ibm-wml-accelerator-prod.UtilsCapBinPath" -}}
/opt/wmla/cap_bin
{{- end -}}

{{/*
Define memory request for common component for different platforms.
The same container on power required more memory than x.
*/}}
{{- define "ibm-wml-accelerator-prod.memoryReq" -}}
{{- if eq (.Values.arch.ppc64le | trunc 1) "3" -}}
{{- printf "512Mi" -}}
{{- else -}}
{{- printf "256Mi" -}}
{{- end -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.proxyHttpsPort" -}}
{{- .Values.cluster.basePort -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.logstashPort" -}}
{{- printf "5043" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.ascdPort" -}}
{{- printf "8643" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.egoRestPort" -}}
{{- printf "8543" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.guiPort" -}}
{{- printf "8443" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.dliMonitorPort" -}}
{{- printf "5000" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.dliOptimizerPort" -}}
{{- printf "5001" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.dlRestPort" -}}
{{- printf "9243" -}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.usePortworx" -}}
{{- if contains "portworx" .Values.iks.fileStorageClassType -}}
{{- printf "yes" -}}
{{- else -}}
{{- printf "no" -}}
{{- end -}}
{{- end -}}


{{ define "ibm-wml-accelerator-prod.releaseSharedLabels" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
release: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}
app.kubernetes.io/version: {{ .Chart.Version }}
{{- end -}}

{{ define "ibm-wml-accelerator-prod.appSharedLabels" }}
{{- include "ibm-wml-accelerator-prod.releaseSharedLabels" . }}
app.kubernetes.io/name: {{ template "ibm-wml-accelerator-prod.master-fullname" . }}
appVersion: {{ .Chart.AppVersion }}
{{- end -}}

{{/* The selector is immutable, and so
cannot include version numbers - so the labels
for selectors should be a subset of the app labels */}}
{{ define "ibm-wml-accelerator-prod.appSharedLabelsSelector" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
release: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}
app.kubernetes.io/name: {{ template "ibm-wml-accelerator-prod.master-fullname" . }}
{{- end -}}

{{ define "ibm-wml-accelerator-prod.appMasterLabels" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabels" . }}
wmla-role: app-master
{{- end -}}

{{ define "ibm-wml-accelerator-prod.appMasterLabelSelector" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabelsSelector" . }}
wmla-role: app-master
{{- end -}}

{{ define "ibm-wml-accelerator-prod.appMasterIngressLabels" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabels" . }}
wmla-role: app-master-ingress
{{- end -}}

{{ define "ibm-wml-accelerator-prod.appMasterIngressLabelsSelector" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabelsSelector" . }}
wmla-role: app-master-ingress
{{- end -}}

{{ define "ibm-wml-accelerator-prod.sigLivyLabels" }}
{{- include "ibm-wml-accelerator-prod.releaseSharedLabels" . }}
app.kubernetes.io/name: @SIGNAME-livy
{{- end -}}

{{ define "ibm-wml-accelerator-prod.sigLabels" }}
{{- include "ibm-wml-accelerator-prod.releaseSharedLabels" . }}
app.kubernetes.io/name: @SIGNAME
{{- end -}}

{{ define "ibm-wml-accelerator-prod.etcdLabels" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabels" . }}
wmla-role: etcd
{{- end -}}

{{ define "ibm-wml-accelerator-prod.etcdLabelsSelector" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabelsSelector" . }}
wmla-role: etcd
{{- end -}}

{{ define "ibm-wml-accelerator-prod.condaLabels" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabels" . }}
wmla-role: conda
{{- end -}}

{{ define "ibm-wml-accelerator-prod.condaLabelsSelector" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabelsSelector" . }}
wmla-role: conda
{{- end -}}

{{ define "ibm-wml-accelerator-prod.singletonsSharedLabels" }}
wmla-chart: {{ .Chart.Name }}
wmla-version: {{ .Chart.Version }}
wmla-appVersion: {{ .Chart.AppVersion }}
wmla-singleton-deployer: {{ .Release.Name }}
{{- end -}}

{{ define "ibm-wml-accelerator-prod.releaseAnnotations" }}
productName: "IBM Watson Machine Learning Accelerator"
productVersion: "2.1.0"
productID: "ICP4D-addon-5737-F22"
{{- end -}}

{{- define "ibm-wml-accelerator-prod.singletonsBaseChartName" -}}
wmla-base-singleton
{{- end -}}

{{- define "ibm-wml-accelerator-prod.singletonsBaseReleaseName" -}}
{{ include "ibm-wml-accelerator-prod.singletonsBaseChartName" . }}-{{ .Chart.AppVersion }}
{{- end -}}

{{ define "ibm-wml-accelerator-prod.singletonsBaseLabels" }}
helm.sh/chart: {{ include "ibm-wml-accelerator-prod.singletonsBaseChartName" . }}
release: {{ include "ibm-wml-accelerator-prod.singletonsBaseReleaseName" . }}
app.kubernetes.io/instance: {{ include "ibm-wml-accelerator-prod.singletonsBaseReleaseName" . }}
{{- include "ibm-wml-accelerator-prod.singletonsSharedLabels" . }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.singletonsClusterRole" -}}
{{ include "ibm-wml-accelerator-prod.singletonsBaseChartName" . }}-cr-{{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.singletonsClusterRoleBinding" -}}
{{ include "ibm-wml-accelerator-prod.singletonsBaseChartName" . }}-crb-{{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.singletonsRole" -}}
{{ include "ibm-wml-accelerator-prod.singletonsBaseChartName" . }}-r-{{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.singletonsRoleBinding" -}}
{{ include "ibm-wml-accelerator-prod.singletonsBaseChartName" . }}-rb-{{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.singletonsPodSecurityPolicy" -}}
{{ include "ibm-wml-accelerator-prod.singletonsBaseChartName" . }}-psp-{{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.singletonsServiceAccount" -}}
{{ include "ibm-wml-accelerator-prod.singletonsBaseChartName" . }}-sa-{{ .Chart.AppVersion | replace "." "-"}}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.condaChartName" -}}
wmla-conda-singleton
{{- end -}}

{{- define "ibm-wml-accelerator-prod.condaReleaseName" -}}
{{ include "ibm-wml-accelerator-prod.condaChartName" . }}-{{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.condaConfigMapName" -}}
wmla-conda-env-yamls-{{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.condaInitEnvSetupJobName" -}}
wmla-conda-env-configmap-setup-{{ .Chart.AppVersion }}
{{- end -}}

{{ define "ibm-wml-accelerator-prod.condaSharedLabels" }}
helm.sh/chart: {{ include "ibm-wml-accelerator-prod.condaChartName" . }}
release: {{ include "ibm-wml-accelerator-prod.condaReleaseName" . }}
app.kubernetes.io/instance: {{ include "ibm-wml-accelerator-prod.condaReleaseName" . }}
{{- include "ibm-wml-accelerator-prod.singletonsSharedLabels" . }}
{{- end -}}

{{ define "ibm-wml-accelerator-prod.condaDaemonLabels" }}
{{- include "ibm-wml-accelerator-prod.condaSharedLabels" . }}
wmla-role: conda-daemon
{{- end -}}

{{ define "ibm-wml-accelerator-prod.condaPrebuiltEnvLabels" }}
{{- include "ibm-wml-accelerator-prod.condaSharedLabels" . }}
wmla-role: conda-prebuilt-env-configmap
{{- end -}}

{{ define "ibm-wml-accelerator-prod.condaCleanupLabels" }}
{{- include "ibm-wml-accelerator-prod.condaSharedLabels" . }}
wmla-role: conda-cleanup
{{- end -}}

{{- define "ibm-wml-accelerator-prod.condaEnvNodeLabelPrefix" -}}
wmla-conda-{{ .Chart.AppVersion }}-
{{- end -}}

{{- define "ibm-wml-accelerator-prod.condaReleaseHostPath" -}}
{{ .Values.singletons.condaParentHostPath }}/wmla-conda-{{ .Chart.AppVersion }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.maxMapChartName" -}}
wmla-max-map-singleton
{{- end -}}

{{- define "ibm-wml-accelerator-prod.maxMapReleaseName" -}}
{{ include "ibm-wml-accelerator-prod.maxMapChartName" . }}-{{ .Chart.AppVersion }}
{{- end -}}

{{ define "ibm-wml-accelerator-prod.maxMapLabels" }}
helm.sh/chart: {{ include "ibm-wml-accelerator-prod.maxMapChartName" . }}
release: {{ include "ibm-wml-accelerator-prod.maxMapReleaseName" . }}
{{- include "ibm-wml-accelerator-prod.singletonsSharedLabels" . }}
wmla-role: max-map-daemon
{{- end -}}

{{ define "ibm-wml-accelerator-prod.testSharedLabels" }}
{{- include "ibm-wml-accelerator-prod.appSharedLabels" . }}
wmla-role: wmla-test
{{- end -}}

{{ define "ibm-wml-accelerator-prod.tolerations" }}
{{ if .Values.dli.tolerationKey }}
tolerations:
  - key: {{ .Values.dli.tolerationKey | quote }}
{{- if .Values.dli.tolerationValue }}
    operator: "Equal"
    value: {{ .Values.dli.tolerationValue | quote }}
{{- else }}
    operator: "Exists"
{{- end }}
    effect: {{ .Values.dli.tolerationEffect | quote }}
{{- end }}
{{- end -}}

{{- define "ibm-wml-accelerator-prod.hpacReleaseName" -}}
wmla-hpac
{{- end -}}

{{- define "ibm-wml-accelerator-prod.hpacServiceAccount" -}}
default
{{- end -}}
