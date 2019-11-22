{{/*Copyright IBM Corporation 2018. All Rights Reserved.*/}}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Maximum release name restriction.
The maximum DNS names in Kubernetes is 63. We will allow 40 characters for the release; and leave us 23 characters for unique identifiers
*/}}
{{- define "build.maximumReleaseName" -}}
{{- printf "%d" 40 -}}
{{- end -}}

{{/*
Defines product metering
*/}}
{{- define "build.metering" }}
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
Defines serviceability label
*/}}
{{- define "build.serviceability" }}
{{- if ( .Values.environmentType ) and eq .Values.environmentType "icp4data"  }}
{{- if ( .Values.serviceInstanceId )  }}
icpdsupport/zenInstanceID: {{ .Values.serviceInstanceId | quote }}
{{- end }}
icpdsupport/addOnKey: "streams"
{{- end }}
{{- end }}

{{/*
Defines default chart labels
*/}}
{{- define "build.defaultLabels" }}
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
release: "{{ .Release.Name }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
app.kubernetes.io/component: "{{ .Chart.Name }}"
streams-build: "{{ .Release.Name }}"
{{- end }}

{/*
Defines container security context values
*/}}
{{- define "build.containerSecurityContext" }}
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
{{- define "build.podGeneralSecurityPolicies" }}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end }}

{/*
Defines pod securityContext values for streamsinstall
*/}}
{{- define "build.streamsinstallPodSecurityContext" }}
runAsNonRoot: true
runAsUser: {{ template "build.streamsinstall" . }}
runAsGroup: {{ template "build.streamsinstall" . }}
{{- end }}

{/*
Defines pod securityContext values for streamsapp
*/}}
{{- define "build.streamsappPodSecurityContext" }}
runAsNonRoot: true
runAsUser: {{ template "build.streamsapp" . }}
runAsGroup: {{ template "build.streamsapp" . }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "build.serviceAccountName" -}}
{{- if .Values.build.serviceAccount -}}
{{- printf "%s" .Values.build.serviceAccount -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "build" -}}
{{- end -}}
{{- end -}}
{{/*

{{/*
Sets the build state mount path for state data
*/}}
{{- define "build.stateMountPath" -}}
{{- printf "/opt/ibm/streams-state" -}}
{{- end -}}

{{/*
Sets the build config mount path for state data
*/}}
{{- define "build.configMountPath" -}}
{{- printf "/opt/ibm/streams-build" -}}
{{- end -}}

{{/*
Sets the streams security mount path for the security pod
*/}}
{{- define "build.securityMountPath" -}}
{{- printf "/opt/ibm/streams-security" -}}
{{- end -}}

{{/*
Sets the default security mount path
*/}}
{{- define "build.defaultSecurityMountPath" -}}
{{- printf "/opt/ibm/streams-default-security" -}}
{{- end -}}

{{/*
Sets the external volume mount path
*/}}
{{- define "build.externalMountPath" -}}
{{- printf "/opt/ibm/streams-ext" -}}
{{- end -}}

{{/*
Sets the user external lib volume mount path
*/}}
{{- define "build.userExternalMountPath" -}}
{{- printf "/opt/ibm/streams-user-ext" -}}
{{- end -}}

{{/*
Install owner and user uid
*/}}
{{- define "build.streamsinstall" -}}
{{- printf "%d" 1000320900 -}}
{{- end -}}

{{/*
Application user uid
*/}}
{{- define "build.streamsapp" -}}
{{- printf "%d" 1000320901 -}}
{{- end -}}

{{/*
Streams installation directory
*/}}
{{- define "build.installdir" -}}
{{- if not  ( empty .Values.install ) -}}
  {{- printf .Values.install | quote -}}
{{- else -}}
  {{- printf "/opt/ibm/streams" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Build security secret
*/}}
{{- define "build.securitySecret" -}}
{{- if .Values.build.securitySecret }}
  {{- printf .Values.build.securitySecret -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "build-default-security" -}}
{{- end -}}
{{- end -}}

{{/*
Basic env variables for our worker pods
*/}}
{{- define "build.basicEnv" }}
- name: LANG
  value: en_US.UTF-8
- name: STREAMS_INSTALL
  value: {{ include "build.installdir" . }}
- name: STREAMS_RELEASE
  value: "{{ .Release.Name }}"
- name: STREAMS_STATE
  value: {{ template "build.stateMountPath" . }}
- name: STREAMS_LIFECYCLE_PORT
  value: {{.Values.lifeCyclePort | default 8888 | quote}}
{{- end -}}

{{/*
build/builder security related env vars
*/}}
{{- define "build.securityEnv" }}
- name: STREAMS_SSL_OPTION
  value: {{ .Values.build.sslOption | default "TLSv1.2" }}
- name: STREAMS_KEYSTORE
  value: {{ template "build.securityMountPath" . }}/streams.jks
- name: STREAMS_KEYSTORE_PW
  valueFrom:
    secretKeyRef:
      name: {{ template "build.securitySecret" . }}
      key: keystorepw
- name: STREAMS_KEYSTORE_ALIAS
  valueFrom:
    secretKeyRef:
      name: {{ template "build.securitySecret" . }}
      key: keystorealias
- name: STREAMS_TRUSTSTORE
  value: {{ template "build.securityMountPath" . }}/streams.jts
- name: STREAMS_TRUSTSTORE_PW
  valueFrom:
    secretKeyRef:
      name: {{ template "build.securitySecret" . }}
      key: truststorepw
{{- end -}}

{{/*
sso security related env vars
*/}}
{{- define "build.ssoSecurityEnv" }}
{{- if .Values.environmentType }}
- name: STREAMS_ENVIRONMENT_TYPE
  value: {{ .Values.environmentType }}
- name: STREAMS_SEC_JWT_PUBLIC_KEY_ENDPOINT
  value: "https://ibm-nginx-svc.{{ .Values.environmentNamespace }}/auth/jwtpublic"
- name: STREAMS_SEC_ICP4D_AUTH_ENDPOINT
  value: "https://ibm-nginx-svc.{{ .Values.environmentNamespace }}/v1/preauth/validateAuth"
- name: STREAMS_SEC_ICP4D_SERVICE_AUTH_ENDPOINT
  value: "https://ibm-nginx-svc.{{ .Values.environmentNamespace }}/zen-data/v2/serviceInstance/token"
{{- else }}
- name: STREAMS_SECURITY_URL
  value: {{ .Values.security.ssoUrl }}
- name: STREAMS_SECURITY_REALM
  value: {{ .Values.security.ssoRealm }}
{{- end }}
{{- end -}}

{{/*
Build persistent volume claim
*/}}
{{- define "build.persistentVolumeClaimName" -}}
{{- if .Values.build.persistentVolumeClaim -}}
  {{- printf .Values.build.persistentVolumeClaim | quote -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "build-pvc" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Builder persistent volume claim
*/}}
{{- define "builder.persistentVolumeClaimName" -}}
{{- if .Values.builder.persistentVolumeClaim -}}
  {{- printf .Values.builder.persistentVolumeClaim | quote -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "builder-pvc" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Builder stream-ext-pvc volume claim
*/}}
{{- define "builder.streamsExtPvcClaimName" -}}
{{- if .Values.builder.streamsExtPvc -}}
  {{- printf .Values.builder.streamsExtPvc | quote -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "streams-ext-pvc" | quote -}}
{{- end -}}
{{- end -}}

{{/* 
Validate required values are specified. 
*/}}
{{- define "build.checkValues" -}}

  {{- if or (empty .Values.license) (ne .Values.license "accept") -}} 
    {{- fail "You must read and accept the license by setting the following value to 'accept':  license." -}}
  {{- end -}}
  
  {{- $maxlen := int (include "build.maximumReleaseName" .) -}}  
  {{- $len := int ( len .Release.Name ) -}}
  {{- if ( gt $len $maxlen ) -}} 
    {{- fail (printf "The length of the release name must be less than or equal to %d characters." $maxlen) -}}
  {{- end -}}
  
  {{- $poolmin := int (.Values.build.poolSizeMinimum) -}} 
  {{- $poolmax := int (.Values.build.poolSizeMaximum) -}}
  {{- if ( lt $poolmin 1 ) -}} 
    {{- fail (printf "The build.poolSizeMinimum must be >= 1") -}}
  {{- end -}}
  {{- if ( gt $poolmin $poolmax ) -}} 
    {{- fail (printf "The build.poolSizeMinimum(%d) must be >= build.poolSizeMaximum(%d)." $poolmin $poolmax) -}}
  {{- end -}}
  
  {{- if (empty .Values.image.build) -}}
    {{- fail "You must specify a build image repository in the following value: image.build." -}}
  {{- end -}}
       
  {{- if (empty .Values.image.buildTag) -}}
    {{- fail "You must specify a build image tag in following value: image.buildTag." -}}
  {{- end -}}
  
  {{- if (empty .Values.image.builder) -}}
    {{- fail "You must specify a builder image repository in the following value: image.builder." -}}
  {{- end -}}
       
  {{- if (empty .Values.image.builderTag) -}}
    {{- fail "You must specify a builder image tag in following value: image.builderTag." -}}
  {{- end -}}
  
  {{- if and (empty .Values.build.persistentVolumeClaim) (empty .Values.build.persistentStorageClassName) -}} 
    {{- fail "You must specify build.persistentVolumeClaim or build.persistentStorageClassName." -}}
  {{- end -}}
  
  {{- if and (not (empty .Values.builder.persistentVolumeClaim )) (not (empty .Values.build.persistentVolumeClaim )) -}} 
    {{- if (eq .Values.build.persistentVolumeClaim .Values.builder.persistentVolumeClaim) -}} 
      {{- fail "You may not specify the same value for build.persistentVolumeClaim and builder.persistentVolumeClaim." -}}
    {{- end -}}
  {{- end -}}
  
  {{- if empty .Values.environmentType }}
    {{- if empty .Values.security.ssoUrl }}
      {{- fail "You must specify a url in the following value: security.ssoUrl." -}}
    {{- end -}}
    
    {{- if empty .Values.security.ssoRealm }}
      {{- fail "You must specify a value in the following value: security.ssoRealm." -}}
    {{- end -}}       
  {{- end -}}
  
  {{- if (empty .Values.build.serviceType) -}}
    {{- fail "You must specify a service type in the following value: build.serviceType." -}}
  {{- else -}}
    {{- if and (and (ne .Values.build.serviceType "NodePort") (ne .Values.build.serviceType "ClusterIP")) (ne .Values.build.serviceType "LoadBalancer") -}}
      {{- fail "You must specify a valid service type in the following value: build.serviceType." -}}
    {{- end -}}
  {{- end -}}
  
  {{- include "build.validateMemory" (list .Values.build.memory   .Values.build.memoryLimit    "build.memory" 0) }}
  {{- include "build.validateMemory" (list .Values.builder.memory .Values.builder.memoryLimit  "builder.memory" 1) }}
  {{- include "build.validateCpu"    (list .Values.build.cpu      .Values.build.cpuLimit       "build.cpu" 0) }}
  {{- include "build.validateCpu"    (list .Values.builder.cpu    .Values.builder.cpuLimit     "builder.cpu" 0) }}
  
{{- end -}}

{{/* 
Validate memory request/limit. 
*/}}
{{- define "build.validateMemory" -}}
  {{- $request := (index . 0) -}}
  {{- $limit := (index . 1) -}}
  {{- $type := (index . 2) -}}
  {{- $min := int (index . 3) -}}
  {{- $minVal := int (mul $min 1000000000) -}}
  {{- $r := int64 (include "build.getMemoryBytes" (list $request)) -}}
  {{- $l := int64 (include "build.getMemoryBytes" (list $limit)) -}}

  {{- if (gt $min 0) -}}
     {{- if (lt $r $minVal) -}}
        {{- fail (printf "%s must be at least %dG" $type $min) -}}
     {{- end -}}
  {{- end -}}
  
  {{- if (gt $r $l) -}}
     {{- fail (printf "%s must be less than or equal to %sLimit" $type $type) -}}
  {{- end -}}
{{- end -}}

{{/* 
Translate memory value into bytes. 
*/}}
{{- define "build.getMemoryBytes" -}}
  {{- $mem := toString (index . 0) -}}

  {{- if (regexMatch "[0-9]*[.][0-9]*" $mem) -}}
    {{- $num := regexFind "[0-9]*[.][0-9]*" $mem -}}
    {{- $unit := substr (len $num) (len $mem) $mem -}}
    {{- $num2 := regexFind "[0-9]*" $num -}}
    {{- $dot := add1 (len $num2) -}}
    {{- $frac := substr (int $dot) (int (add1 $dot)) $num -}} 

    {{- if (eq $unit "G") -}}
       {{- add (mul $num2 1000000000) (mul 100000000 $frac) -}}
    {{- else if (eq $unit "Gi") -}}
       {{- add (mul $num2 1073741824) (mul (div 1073741824 10) $frac) -}}
    {{- else if (eq $unit "K") -}}
       {{- add (mul $num2 1000) (mul 100 $frac) -}}
    {{- else if (eq $unit "Ki") -}}
       {{- add (mul $num2 1024) (mul (div 1024 10) $frac) -}}
    {{- else if (eq $unit "M") -}}
       {{- add (mul $num2 1000000) (mul 100000 $frac) -}}
    {{- else if (eq $unit "Mi") -}}
       {{- add (mul $num2 1048576) (mul (div 1048576 10) $frac) -}}
    {{- else if (eq $unit "T") -}}
       {{- add (mul $num2 1000000000000) (mul 100000000000 $frac) -}}
    {{- else if (eq $unit "Ti") -}}
       {{- add (mul $num2 1099511627776) (mul (div 1099511627776 10) $frac) -}}
    {{- else if (eq $unit "P") -}}
       {{- add (mul $num2 1000000000000000) (mul 100000000000000 $frac) -}}
    {{- else if (eq $unit "Pi") -}}
       {{- add (mul $num2 1125899906842624) (mul (div 1125899906842624 10) $frac) -}}
    {{- else if (eq $unit "E") -}}
       {{- add (mul $num2 1000000000000000000) (mul 100000000000000000 $frac) -}}
    {{- else if (eq $unit "Ei") -}}
       {{- add (mul $num2 1152921504606846976) (mul (div 1152921504606846976 10) $frac) -}}
    {{- end -}}
   
  {{- else -}}
    {{- $num := regexFind "[0-9]*" $mem -}}
    {{- $unit := substr (len $num) (len $mem) $mem -}}

    {{- if (eq $unit "G") -}}
       {{- (mul $num 1000000000) -}}
    {{- else if (eq $unit "Gi") -}}
       {{- (mul $num 1073741824) -}}
    {{- else if (eq $unit "K") -}}
      {{- (mul $num 1000) -}}
    {{- else if (eq $unit "Ki") -}}
      {{- (mul $num 1024) -}}
    {{- else if (eq $unit "M") -}}
       {{- (mul $num 1000000) -}}
    {{- else if (eq $unit "Mi") -}}
       {{- (mul $num 1048576) -}}
    {{- else if (eq $unit "T") -}}
       {{- (mul $num 1000000000000) -}}
    {{- else if (eq $unit "Ti") -}}
       {{- (mul $num 1099511627776) -}}
    {{- else if (eq $unit "P") -}}
       {{- (mul $num 1000000000000000) -}}
    {{- else if (eq $unit "Pi") -}}
       {{- (mul $num 1125899906842624) -}}
    {{- else if (eq $unit "E") -}}
       {{- (mul $num 1000000000000000000) -}}
    {{- else if (eq $unit "Ei") -}}
       {{- (mul $num 1152921504606846976) -}}
    {{- else -}}
       {{- $num -}}
    {{- end -}}
  {{- end -}}

{{- end -}}

{{/* 
Validate cpu request/limit. 
*/}}
{{- define "build.validateCpu" -}}
  {{- $request := (index . 0) -}}
  {{- $limit := (index . 1) -}}
  {{- $type := (index . 2) -}}
  {{- $min := int (index . 3) -}}
  {{- $minVal := int (mul $min 1000) -}}
  {{- $r := splitList " " (include "build.getCpu" (list $request)) -}}
  {{- $l := splitList " " (include "build.getCpu" (list $limit)) -}}
  {{- $rn := int (index $r 0) -}}
  {{- $rf := int (index $r 1) -}}
  {{- $ln := int (index $l 0) -}}
  {{- $lf := int (index $l 1) -}}

  {{- if (gt $min 0) -}}
     {{- if (lt $rn $minVal) -}}
        {{- fail (printf "%s must be at least %d" $type $min) -}}
     {{- end -}}
  {{- end -}}
  
  {{- if (gt $rn $ln) -}}
     {{- fail (printf "%s must be less then or equal to %sLimit" $type $type) -}}
  {{- else if (eq $rn $ln) -}}
     {{- if (gt $rf $lf) -}}
        {{- fail (printf "%s must be less than or equal to %sLimit" $type $type) -}}
     {{- end -}}
  {{- end -}}
{{- end -}}

{{/* 
Translate cpu value to number/fraction
*/}}
{{- define "build.getCpu" -}}
  {{- $cpu := toString (index . 0) -}}
  {{- if (regexMatch "[0-9]*m" $cpu) -}}
     {{- $num := regexFind "[0-9]*" $cpu -}}
     {{- cat $num 0 -}}
  {{- else -}}
     {{- if (regexMatch "[0-9]*[.][0-9]*" $cpu) -}}
       {{- $num := regexFind "[0-9]*" $cpu -}}
       {{- $dot := add1 (len $num) -}}
       {{- $frac := substr (int $dot) (len $cpu) $cpu -}}
       {{- cat (mul $num 1000) $frac -}}       
     {{- else -}}
       {{- cat (mul $cpu 1000) 0 -}}
     {{- end -}}
  {{- end -}}
{{- end -}}
