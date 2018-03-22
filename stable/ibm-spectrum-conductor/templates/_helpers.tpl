{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 48 -}}
{{- end -}}

{{/*
Create fully qualified names.
We truncate at 48 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "master-fullname" -}}
{{- $name := default .Chart.Name .Values.master.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 48 -}}
{{/*- printf "%s" $name | trunc 48 - */}}
{{- end -}}

{{- define "conductorVersion" -}}
{{- printf "2.2.1" -}}
{{- end -}}

{{- define "dliVersion" -}}
{{- printf "1.1.0" -}}
{{- end -}}

{{- define "getmaxslots" -}}
{{- if .Values.sig.maxCpu|hasSuffix "m" }}
{{- $maxcpu := default 6 .Values.sig.maxCpu|trimSuffix "m"|int -}}
{{- $maxslot := div $maxcpu 1000 -}}
{{- printf "%d" $maxslot -}}
{{- else }}
{{- $maxslot := default 6 .Values.sig.maxCpu|int -}}
{{- printf "%d" $maxslot -}}
{{- end }}
{{- end -}}

{{- define "etcdService" -}}
{{- printf "cwsetcd" -}}
{{- end -}}

{{- define "etcdServiceNamespace" -}}
{{- printf "default" -}}
{{- end -}}

{{- define "etcdServicePort" -}}
{{- printf "2379" -}}
{{- end -}}

{{- define "etcdHostDir" -}}
{{- printf "http://cwsetcd.default:2379/v2/keys/cwsnodemap" -}}
{{- end -}}

{{- define "cwsImage" -}}
{{- if .Values.dli.enabled }}
{{- default "ibmcom/spectrum-dli:1.1.0" .Values.master.imageName -}}
{{- else }}
{{- default "ibmcom/spectrum-conductor:2.2.1" .Values.master.imageName -}}
{{- end }}
{{- end -}}

{{- define "cwsImageWithoutRegistryTag" -}}
{{- printf "default/conductor-spark" -}}
{{- end -}}

{{- define "cwsProxyService" -}}
{{- printf "cwsproxy" -}}
{{- end -}}

{{- define "cwsProxyImage" -}}
{{- printf "ibmcom/spectrum-conductor:proxy" -}}
{{- end -}}

{{- define "cwsImagePullSecret" -}}
{{- if eq .Values.master.imageName "ibmcom/spectrum-conductor:2.2.1" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" "https://index.docker.io/v1/" (printf "spectrumuser:spectrumuser" | b64enc) | b64enc -}}
{{- else -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.master.registry (printf "%s:%s" .Values.master.registryUser .Values.master.registryPasswd | b64enc) | b64enc -}}
{{- end -}}
{{- end -}}

{{- define "sigImagePullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.sig.registry (printf "%s:%s" .Values.sig.registryUser .Values.sig.registryPasswd | b64enc) | b64enc -}}
{{- end -}}

{{- define "helmHost" -}}
{{- printf "tiller-deploy.kube-system:44134" -}}
{{- end -}}

{{- define "kubectlImage" -}}
{{- $imagetag := .Capabilities.KubeVersion.GitVersion | trunc 6 -}}
{{- if eq .Capabilities.KubeVersion.Platform "linux/amd64" -}}
{{- printf "\"ibmcom/kubernetes:%s\"" $imagetag -}}
{{- else if eq .Capabilities.KubeVersion.Platform "linux/ppc64le" -}}
{{- printf "\"ibmcom/kubernetes-ppc64le:%s\"" $imagetag -}}
{{- end -}}
{{- end -}}

{{- define "helmImage" -}}
{{- $imagetag := "v2.6.0" -}}
{{- if eq .Capabilities.KubeVersion.Platform "linux/amd64" -}}
{{- printf "\"ibmcom/helm:%s\"" $imagetag -}}
{{- else if eq .Capabilities.KubeVersion.Platform "linux/ppc64le" -}}
{{- printf "\"ibmcom/helm-ppc64le:%s\"" $imagetag -}}
{{- end -}}
{{- end -}}

{{- define "dnsmasqImage" -}}
{{- if eq .Capabilities.KubeVersion.Platform "linux/amd64" -}}
{{- printf "\"ibmcom/k8s-dns-dnsmasq-nanny:1.14.4\"" -}}
{{- else if eq .Capabilities.KubeVersion.Platform "linux/ppc64le" -}}
{{- printf "\"ibmcom/k8s-dns-dnsmasq-nanny-ppc64le:1.14.4\"" -}}
{{- end -}}
{{- end -}}

{{- define "etcdImage" -}}
{{- if eq .Capabilities.KubeVersion.Platform "linux/amd64" -}}
{{- printf "ibmcom/etcd:v3.1.5" -}}
{{- else if eq .Capabilities.KubeVersion.Platform "linux/ppc64le" -}}
{{- printf "ibmcom/etcd-ppc64le:v3.1.5" -}}
{{- end -}}
{{- end -}}

{{- define "guiPort" -}}
{{- .Values.cluster.basePort -}}
{{- end -}}

{{- define "ascdPort" -}}
{{- add .Values.cluster.basePort 1 -}}
{{- end -}}

{{- define "egoRestPort" -}}
{{- add .Values.cluster.basePort 2 -}}
{{- end -}}

{{- define "proxyHttpsPort" -}}
{{- add .Values.cluster.basePort 3 -}}
{{- end -}}

{{- define "dliMonitorPort" -}}
{{- add .Values.cluster.basePort 4 -}}
{{- end -}}

{{- define "dliOptimizerPort" -}}
{{- add .Values.cluster.basePort 5 -}}
{{- end -}}

{{- define "dlRestPort" -}}
{{- add .Values.cluster.basePort 6 -}}
{{- end -}}
