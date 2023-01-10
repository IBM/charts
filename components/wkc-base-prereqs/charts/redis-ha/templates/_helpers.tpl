{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "redis-ha.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "redis-ha.fullname" -}}
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
Return sysctl image
*/}}
{{- define "redis.sysctl.image" -}}
{{- $registryName :=  default "docker.io" .Values.sysctlImage.registry -}}
{{- $tag := default "latest" .Values.sysctlImage.tag | toString -}}
{{- printf "%s/%s:%s" $registryName .Values.sysctlImage.repository $tag -}}
{{- end -}}

{{- /*
Credit: @technosophos
https://github.com/technosophos/common-chart/
labels.standard prints the standard Helm labels.
The standard labels are frequently used in metadata.
*/ -}}
{{- define "labels.standard" -}}
app: {{ template "redis-ha.name" . }}
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
chart: {{ .Chart.Name | quote }}
redis: "true"
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "redis-ha.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "redis-ha.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create HAProxy master backends list
*/}}
{{- define "masters.list" -}}
{{- $name := include "redis-ha.fullname" . -}}
{{- $namespace := .Release.Namespace -}}
{{- $serviceName := include "redis-ha.fullname" . -}}
{{- $clusterDomain := .Values.clusterDomain -}}
{{- $port := ( required "A valid Redis port entry required!" .Values.redis.port | int ) -}}
{{- $conns := ( required "A valid Redis maxConnections entry required!" .Values.haproxy.redis.maxConnections | int) -}}
{{- $chksec := ( required "A valid Redis checkSeconds entry required!" .Values.haproxy.redis.checkSeconds | int) -}}
{{- range $i, $e := until ( required "A valid Redis replicaCount entry required!" .Values.replicas | int ) }}
      {{ printf "server master-%d %s-server-%d.%s.%s.svc.%s:%d maxconn %d check inter %ds on-marked-down shutdown-sessions init-addr none resolvers k8s_dns" $i $name $i $serviceName $namespace $clusterDomain $port $conns $chksec }}
{{- end -}}
{{- end -}}

{{/*
Create HAProxy master backends list
*/}}
{{- define "masters.ssl.list" -}}
{{- $name := include "redis-ha.fullname" . -}}
{{- $namespace := .Release.Namespace -}}
{{- $serviceName := include "redis-ha.fullname" . -}}
{{- $clusterDomain := .Values.clusterDomain -}}
{{- $cert := "" -}}
{{- $port := ( required "A valid Redis port entry required!" .Values.ssl.tlsPort | int ) -}}
{{- $conns := ( required "A valid Redis maxConnections entry required!" .Values.haproxy.redis.maxConnections | int) -}}
{{- $chksec := ( required "A valid Redis checkSeconds entry required!" .Values.haproxy.redis.checkSeconds | int) -}}
{{- range $i, $e := until ( required "A valid Redis replicaCount entry required!" .Values.replicas | int ) }}
      {{ printf "server master-%d %s-server-%d.%s.%s.svc.%s:%d maxconn %d check check-ssl verify none no-tls-tickets inter %ds on-marked-down shutdown-sessions rise 1 fall 2 init-addr none resolvers k8s_dns" $i $name $i $serviceName $namespace $clusterDomain $port $conns $chksec }}
{{- end -}}
{{- end -}}


{{- define "redis-ha.sentinelPort" -}}
{{- if .Values.ssl.enabled -}}
{{- .Values.ssl.tlsSentinelPort -}} 
{{- else -}}
{{- .Values.sentinel.port -}}
{{- end -}}
{{- end -}}

{{- define "redis-ha.redisPort" -}}
{{- if .Values.ssl.enabled -}}
{{- .Values.ssl.tlsPort -}} 
{{- else -}}
{{- .Values.redis.port -}}
{{- end -}}
{{- end -}}