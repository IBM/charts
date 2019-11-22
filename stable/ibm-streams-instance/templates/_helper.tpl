# begin_generated_IBM_copyright_prolog                             
#                                                                  
# This is an automatically generated copyright prolog.             
# After initializing,  DO NOT MODIFY OR MOVE                       
# **************************************************************** 
# Licensed Materials - Property of IBM                             
# 5724-Y95                                                         
# (C) Copyright IBM Corp.  2018, 2019    All Rights Reserved.      
# US Government Users Restricted Rights - Use, duplication or      
# disclosure restricted by GSA ADP Schedule Contract with          
# IBM Corp.                                                        
#                                                                  
# end_generated_IBM_copyright_prolog  

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "streams.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Defines product metering
*/}}
{{- define "streams.metering" }}
{{- if ( .Values.environmentType ) and eq .Values.environmentType "icp4data"  }}
productID: "ICP4D-998edc72e0f04ec18cc5e2310eabafee-Management"
productName: "IBM Streams for IBM Cloud Pak For Data"
{{- else }}
productID: "d278763f052d4334b2e3fc210a3cc027-Management"
productName: "IBM Streams"
{{- end }}
productVersion: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Defines serviceability label
*/}}
{{- define "streams.serviceability" }}
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
{{- define "streams.defaultLabels" }}
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
release: "{{ .Release.Name }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
app.kubernetes.io/component: "{{ .Chart.Name }}"
streams-instance: "{{ .Release.Name }}"
{{- end }}

{/*
Defines container security context values
*/}}
{{- define "streams.containerSecurityContext" }}
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
{{- define "streams.podGeneralSecurityPolicies" }}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end }}

{/*
Defines pod securityContext values for streamsinstall
*/}}
{{- define "streams.streamsinstallPodSecurityContext" }}
runAsNonRoot: true
runAsUser: {{ template "streams.streamsinstall" . }}
runAsGroup: {{ template "streams.streamsinstall" . }} 
{{- end }}

{/*
Defines pod securityContext values for streamsapp
*/}}
{{- define "streams.streamsappPodSecurityContext" }}
runAsNonRoot: true
runAsUser: {{ template "streams.streamsapp" . }}
runAsGroup: {{ template "streams.streamsapp" . }} 
{{- end }}

{/*
Defines pod securityContext values for streamsops
*/}}
{{- define "streams.streamsopsPodSecurityContext" }}
runAsNonRoot: true
runAsUser: {{ template "streams.streamsops" . }}
runAsGroup: {{ template "streams.streamsops" . }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "streams.instanceServiceAccountName" -}}
{{- if .Values.instance.serviceAccount -}}
{{- printf "%s" .Values.instance.serviceAccount -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "streams" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for application resources.
*/}}
{{- define "streams.appServiceAccountName" -}}
{{- if .Values.app.serviceAccount -}}
{{- printf "%s" .Values.app.serviceAccount -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "streams-app" -}}
{{- end -}}
{{- end -}}
{{/*

{{/*
Sets the mkinstance mount path
*/}}
{{- define "streams.mkinstanceMountPath" -}}
{{- printf "/opt/ibm/streams-config" -}}
{{- end -}}

{{/*
Sets the instance state mount path for state data
*/}}
{{- define "streams.stateMountPath" -}}
{{- printf "/opt/ibm/streams-state" -}}
{{- end -}}

{{/*
Sets the mount path for kube config
*/}}
{{- define "streams.kubeMountPath" -}}
{{- printf "/opt/ibm/streams-kube" -}}
{{- end -}}

{{/*
Sets the mount path for application templates
*/}}
{{- define "streams.appTplMountPath" -}}
{{- printf "/opt/ibm/streams-app" -}}
{{- end -}}

{{/*
Sets the mount path for user application templates
*/}}
{{- define "streams.userAppTplMountPath" -}}
{{- printf "/opt/ibm/streams-user-app" -}}
{{- end -}}

{{/*
Sets the streams security mount path for the security pod
*/}}
{{- define "streams.securityMountPath" -}}
{{- printf "/opt/ibm/streams-security" -}}
{{- end -}}

{{/*
Sets the user security mount path for the security pod
*/}}
{{- define "streams.userSecurityMountPath" -}}
{{- printf "/opt/ibm/streams-user-security" -}}
{{- end -}}

{{/*
Sets the default security mount path
*/}}
{{- define "streams.defaultSecurityMountPath" -}}
{{- printf "/opt/ibm/streams-default-security" -}}
{{- end -}}

{{/*
Sets the streams sws security mount path
*/}}
{{- define "streams.swsSecurityMountPath" -}}
{{- printf "/opt/ibm/streams-security/sws" -}}
{{- end -}}

{{/*
Sets the streams jmx security mount path
*/}}
{{- define "streams.jmxSecurityMountPath" -}}
{{- printf "/opt/ibm/streams-security/jmx" -}}
{{- end -}}

{{/*
Sets the external volume mount path
*/}}
{{- define "streams.externalMountPath" -}}
{{- printf "/opt/ibm/streams-ext" -}}
{{- end -}}

{{/*
Sets the user external lib volume mount path
*/}}
{{- define "streams.userExternalMountPath" -}}
{{- printf "/opt/ibm/streams-user-ext" -}}
{{- end -}}

{{/*
Install owner and user uid
*/}}
{{- define "streams.streamsinstall" -}}
{{- printf "%d" 1000320900 -}}
{{- end -}}

{{/*
Application user uid
*/}}
{{- define "streams.streamsapp" -}}
{{- printf "%d" 1000320901 -}}
{{- end -}}

{{/*
Streams operations user uid
*/}}
{{- define "streams.streamsops" -}}
{{- printf "%d" 1000320902 -}}
{{- end -}}

{{/*
Streams security secret
*/}}
{{- define "streams.controllerSecuritySecret" -}}
{{- if .Values.controller.securitySecret }}
  {{- printf .Values.controller.securitySecret -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "default-security" -}}
{{- end -}}
{{- end -}}

{{/*
Streams sws security secret
*/}}
{{- define "streams.swsSecuritySecret" -}}
{{- if .Values.sws.securitySecret }}
  {{- printf .Values.sws.securitySecret -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "default-security" -}}
{{- end -}}
{{- end -}}

{{/*
Streams jmx security secret
*/}}
{{- define "streams.jmxSecuritySecret" -}}
{{- if .Values.jmx.securitySecret }}
  {{- printf .Values.jmx.securitySecret -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "default-security" -}}
{{- end -}}
{{- end -}}

{{/*
Streams installation directory
*/}}
{{- define "streams.installdir" -}}
{{- if not  ( empty .Values.install ) -}}
  {{- printf .Values.install | quote -}}
{{- else -}}
  {{- printf "/opt/ibm/streams" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Maximum release name restriction.
The maximum DNS names in Kubernetes is 63. We will allow 40 characters for the release; and leave us 23 characters for unique identifiers
*/}}
{{- define "streams.maximumReleaseName" -}}
{{- printf "%d" 40 -}}
{{- end -}}

{{/*
Basic env variables for our worker pods
*/}}
{{- define "streams.basicEnv" }}
- name: LANG
  value: en_US.UTF-8
- name: STREAMS_INSTALL
  value: {{ include "streams.installdir" . }}
- name: STREAMS_RELEASE
  value: "{{ .Release.Name }}"
- name: STREAMS_INSTANCE_ID
  value: "{{ .Release.Name }}"
- name: STREAMS_STATE
  value: {{ template "streams.stateMountPath" . }}
- name: STREAMS_KUBE_CONFIG
  value: {{ template "streams.kubeMountPath" . }}
{{- if .Values.environmentType }}
- name: STREAMS_ENVIRONMENT_TYPE
  value: {{ .Values.environmentType }}
{{- end }}
{{- end -}}
 
{{/*
Controller security related env vars
*/}}
{{- define "streams.controllerSecurityEnv" }}
- name: STREAMS_LIFECYCLE_PORT
  value: {{ .Values.controller.kubePort | default 8888 | quote }}
- name: STREAMS_SSL_OPTION
  value: {{ .Values.instance.sslOption | default "TLSv1.2" }}
- name: STREAMS_KEYSTORE
  value: {{ template "streams.securityMountPath" . }}/streams.jks
- name: STREAMS_KEYSTORE_PW
  valueFrom:
    secretKeyRef:
      name: {{ template "streams.controllerSecuritySecret" . }}
      key: keystorepw
- name: STREAMS_KEYSTORE_ALIAS
  valueFrom:
    secretKeyRef:
      name: {{ template "streams.controllerSecuritySecret" . }}
      key: keystorealias
- name: STREAMS_TRUSTSTORE
  value: {{ template "streams.securityMountPath" . }}/streams.jts
- name: STREAMS_TRUSTSTORE_PW
  valueFrom:
    secretKeyRef:
      name: {{ template "streams.controllerSecuritySecret" . }}
      key: truststorepw
{{- end -}}

{{/*
sso security related env vars
*/}}
{{- define "streams.ssoSecurityEnv" }}
{{- if and (empty .Values.environmentType) (eq (toString .Values.security.ssoEnabled) "true") }}
- name: STREAMS_SECURITY_URL
  value: {{ .Values.security.ssoUrl }}
- name: STREAMS_SECURITY_REALM
  value: {{ .Values.security.ssoRealm }}
{{- end }}
{{- end -}}

{{/*
sws security related env vars
*/}}
{{- define "streams.swsSecurityEnv" }}
- name: STREAMS_SWS_KEYSTORE
  value: {{ template "streams.swsSecurityMountPath" . }}/streams.jks
- name: STREAMS_SWS_KEYSTORE_PW
  valueFrom:
    secretKeyRef:
      name: {{ template "streams.swsSecuritySecret" . }}
      key: keystorepw
- name: STREAMS_SWS_KEYSTORE_ALIAS
  valueFrom:
    secretKeyRef:
      name: {{ template "streams.swsSecuritySecret" . }}
      key: keystorealias
- name: STREAMS_SWS_TRUSTSTORE
  value: {{ template "streams.swsSecurityMountPath" . }}/streams.jts
- name: STREAMS_SWS_TRUSTSTORE_PW
  valueFrom:
    secretKeyRef:
      name: {{ template "streams.swsSecuritySecret" . }}
      key: truststorepw
{{- if .Values.environmentType }}
- name: STREAMS_SEC_JWT_PUBLIC_KEY_ENDPOINT
  value: "https://ibm-nginx-svc.{{ .Values.environmentNamespace }}/auth/jwtpublic"
- name: STREAMS_SEC_ICP4D_AUTH_ENDPOINT
  value: "https://ibm-nginx-svc.{{ .Values.environmentNamespace }}/v1/preauth/validateAuth"
- name: STREAMS_SEC_ICP4D_SERVICE_AUTH_ENDPOINT
  value: "https://ibm-nginx-svc.{{ .Values.environmentNamespace }}/zen-data/v2/serviceInstance/token"
{{- end }}
{{- end -}}

{{/*
jmx security related env vars
*/}}
{{- define "streams.jmxSecurityEnv" }}
- name: STREAMS_JMX_KEYSTORE
  value: {{ template "streams.jmxSecurityMountPath" . }}/streams.jks
- name: STREAMS_JMX_KEYSTORE_PW
  valueFrom:
    secretKeyRef:
      name: {{ template "streams.jmxSecuritySecret" . }}
      key: keystorepw
{{- end -}}

{{/*
Instance persistent volume claim
*/}}
{{- define "instance.persistentVolumeClaimName" -}}
{{- if .Values.instance.persistentVolumeClaim -}}
  {{- printf .Values.instance.persistentVolumeClaim | quote -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "instance-pvc" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Basic volume definitions for our worker pods
*/}}
{{- define "streams.basicVolumes" }}
- name: state-volume
  persistentVolumeClaim:
    claimName: {{ template "instance.persistentVolumeClaimName" . }}        
- name: kube-config
  configMap:
    name: "{{ .Release.Name }}-kube-config"
- name: security-secret
  secret:
    secretName: {{ template "streams.controllerSecuritySecret" . }}
    items:
      - key: streams.jks
        path: streams.jks
      - key: streams.jts
        path: streams.jts
{{- end -}}

{{/*
Basic volume mounts for our worker pods
*/}}
{{- define "streams.basicVolumeMounts" }}
- name: state-volume
  mountPath: {{ template "streams.stateMountPath" . }}
- name: kube-config
  mountPath: {{ template "streams.kubeMountPath" . }}
- name: security-secret
  mountPath: {{ template "streams.securityMountPath" . }}
{{- end -}}

{{/*
sws volume definitions
*/}}
{{- define "streams.swsVolumes" }}
- name: sws-security-secret
  secret:
    secretName: {{ template "streams.swsSecuritySecret" . }}
    items:
      - key: streams.jks
        path: streams.jks
      - key: streams.jts
        path: streams.jts
{{- end -}}

{{/*
sws volume mounts
*/}}
{{- define "streams.swsVolumeMounts" }}
- name: sws-security-secret
  mountPath: {{ template "streams.swsSecurityMountPath" . }}
{{- end -}}

{{/*
jmx volume definitions
*/}}
{{- define "streams.jmxVolumes" }}
- name: jmx-security-secret
  secret:
    secretName: {{ template "streams.jmxSecuritySecret" . }}
    items:
      - key: streams.jks
        path: streams.jks
      - key: streams.jts
        path: streams.jts
{{- end -}}

{{/*
jmx volume mounts
*/}}
{{- define "streams.jmxVolumeMounts" }}
- name: jmx-security-secret
  mountPath: {{ template "streams.jmxSecurityMountPath" . }}
{{- end -}}

{{/*
Ops volume definitions for our worker pods
*/}}
{{- define "streams.opsVolumes" }}
- name: kube-config
  configMap:
    name: "{{ .Release.Name }}-kube-config"       
- name: security-secret
  secret:
    secretName: {{ template "streams.controllerSecuritySecret" . }}
    items:
      - key: streams.jks
        path: streams.jks
      - key: streams.jts
        path: streams.jts
{{- end -}}

{{/*
Ops volume mounts for our worker pods
*/}}
{{- define "streams.opsVolumeMounts" }}
- name: kube-config
  mountPath: {{ template "streams.kubeMountPath" . }}
- name: security-secret
  mountPath: {{ template "streams.securityMountPath" . }}
{{- end -}}

{{/*
Kubernetes liveness/readiness/lifecycle
*/}}
{{- define "streams.lifecycle" }}
livenessProbe:
  httpGet:
    path: liveness
    port: {{ .Values.controller.kubePort | default 8888 }}
  initialDelaySeconds: {{ .Values.controller.startTimeout | default 60 }}
  periodSeconds: {{ .Values.controller.livenessInterval | default 60 }}
  timeoutSeconds: {{ .Values.controller.livenessTimeout | default 15 }}
  successThreshold: {{ .Values.controller.livenessSuccess | default 1 }}
  failureThreshold: {{ .Values.controller.livenessFailure | default 2 }}
  
readinessProbe:
  httpGet:
    path: readiness
    port: {{.Values.lifeCyclePort | default 8888}}
  initialDelaySeconds: {{.Values.readinessDelay | default 0 }}
  periodSeconds: {{ .Values.readinessPeriod | default 15 }}
  timeoutSeconds: {{ .Values.readinessTimeout | default 10 }}
  successThreshold: {{ .Values.readinessSuccess | default 1 }}
  failureThreshold: {{ .Values.readinessFailure | default 8 }}
                  
lifecycle:
  preStop:
    httpGet:
      path: prestop
      port: {{ .Values.controller.kubePort | default 8888 }}
{{- end -}}

{{/* 
Validate required values are specified. 
*/}}
{{- define "streams.checkValues" -}}

  {{- if or (empty .Values.license) (ne .Values.license "accept") -}} 
    {{- fail "You must read and accept the license by setting the following value to 'accept':  license." -}}
  {{- end -}}

  {{- $maxlen := int (include "streams.maximumReleaseName" .) -}}  
  {{- $len := int ( len .Release.Name ) -}}
  {{- if ( gt $len $maxlen ) -}} 
    {{- fail (printf "The length of the release name must be less than or equal to %d characters." $maxlen) -}}
  {{- end -}}
    
  {{- if (empty .Values.image.application) -}}
    {{- fail "You must specify an application image repository in the following value: image.application." -}}
  {{- end -}}
       
  {{- if (empty .Values.image.applicationTag) -}}
    {{- fail "You must specify an application image tag in following value: image.applicationTag." -}}
  {{- end -}}
  
  {{- if and (empty .Values.instance.persistentVolumeClaim) (empty .Values.instance.persistentStorageClassName) -}} 
    {{- fail "You must specify instance.persistentVolumeClaim or instance.persistentStorageClassName." -}}
  {{- end -}}

  {{- if or (and (empty .Values.security.ldapEnabled) (not (eq (toString .Values.security.ldapEnabled) "false"))) (eq (toString .Values.security.ldapEnabled) "true") -}}
      {{- if and (empty .Values.security.administratorUser) (empty .Values.security.administratorGroup) -}}
	    {{- fail "You must identify an administrator for the instance by specifying one of the following values: security.administratorUser or security.administratorGroup." -}}
	  {{- end -}}
	        
	  {{- if (empty .Values.security.ldapGroupMembersAttribute) -}}
	    {{- fail "You must specify name of the element in the group record that contains the list of members in the group in the following value: security.ldapGroupMembersAttribute." -}}
	  {{- end -}}
	          
	  {{- if (empty .Values.security.ldapGroupObjectClass) -}}
	    {{- fail "You must specify the group object class that is used to search for group names in LDAP in the following value: security.ldapGroupObjectClass." -}}
	  {{- end -}}
	           
	 {{- if (empty .Values.security.ldapGroupSearchBaseDistinguishedName) -}}
	    {{- fail "You must specify the base distinguished name (DN) that is used to search for groups in LDAP in the following value: security.ldapGroupSearchBaseDistinguishedName." -}}
	  {{- end -}}
	          
	  {{- if (empty .Values.security.ldapServerUrl) -}}
	    {{- fail "You must specify the URL to the LDAP Server in the following value: security.ldapServerUrl." -}}
	  {{- end -}}
	          
	  {{- if (empty .Values.security.ldapUserAttributeInGroup) -}}
	    {{- fail "You must specify the name of the user record element that is stored in the group record in the following value: security.ldapUserAttributeInGroup." -}}
	  {{- end -}}
	          
	  {{- if (empty .Values.security.ldapUserDistinguishedNamePattern) -}}
	    {{- fail "You must specify the pattern that is used to create a distinguished name (DN) for a user during login in the following value: security.ldapUserDistinguishedNamePattern." -}}
	  {{- end -}}
  {{- end -}}
  
  {{- if (eq (toString .Values.security.ssoEnabled) "true") -}}
      {{- if (empty .Values.security.ssoUrl) -}}
        {{- fail "You must specify the URL to the IBM Streams single sign-on server in the following value: security.ssoUrl." -}}
      {{- end -}}
      
      {{- if (empty .Values.security.ssoRealm) -}}
        {{- fail "You must specify the IBM Streams single sign-on security realm in the following value: security.ssoRealm." -}}
      {{- end -}}
  {{- end -}}
    
  {{- if and (not (empty .Values.mkinstance.volumes)) (empty .Values.mkinstance.volumeMounts) -}}
    {{- fail "The mkinstance.volumeMounts value is required when you specify mkinstance.volumes." -}}
  {{- end -}}
  
  {{- if and (empty .Values.mkinstance.volumes) (not (empty .Values.mkinstance.volumeMounts)) -}}
    {{- fail "The mkinstance.volumes value is required when you specify mkinstance.volumeMounts." -}}
  {{- end -}}
  
  {{- if (empty .Values.sws.serviceType) -}}
    {{- fail "You must specify a service type in the following value: sws.serviceType." -}}
  {{- else -}}
    {{- if and (and (ne .Values.sws.serviceType "NodePort") (ne .Values.sws.serviceType "ClusterIP")) (ne .Values.sws.serviceType "LoadBalancer") -}}
      {{- fail "You must specify a valid service type in the following value: sws.serviceType." -}}
    {{- end -}}
  {{- end -}}
  
  {{- if (empty .Values.jmx.serviceType) -}}
    {{- fail "You must specify a service type in the following value: jmx.serviceType." -}}
  {{- else -}}
    {{- if and (and (ne .Values.jmx.serviceType "NodePort") (ne .Values.jmx.serviceType "ClusterIP")) (ne .Values.jmx.serviceType "LoadBalancer") -}}
      {{- fail "You must specify a valid service type in the following value: jmx.serviceType." -}}
    {{- end -}}
  {{- end -}}
  
  {{- include "streams.validateMemory" (list .Values.resources.applicationMemory .Values.resources.applicationMemoryLimit "application" 0) }}
  {{- include "streams.validateMemory" (list .Values.resources.managementMemory  .Values.resources.managementMemoryLimit  "management" 1) }}
  {{- include "streams.validateMemory" (list .Values.resources.securityMemory    .Values.resources.securityMemoryLimit    "security" 1) }}
  {{- include "streams.validateMemory" (list .Values.resources.consoleMemory     .Values.resources.consoleMemoryLimit     "console" 1) }}
  {{- include "streams.validateMemory" (list .Values.resources.repositoryMemory  .Values.resources.repositoryMemoryLimit  "repository" 1) }}
  {{- include "streams.validateCpu"    (list .Values.resources.applicationCpu    .Values.resources.applicationCpuLimit    "application" 0) }}
  {{- include "streams.validateCpu"    (list .Values.resources.managementCpu     .Values.resources.managementCpuLimit     "management" 1) }}
  {{- include "streams.validateCpu"    (list .Values.resources.securityCpu       .Values.resources.securityCpuLimit       "security" 1) }}
  {{- include "streams.validateCpu"    (list .Values.resources.consoleCpu        .Values.resources.consoleCpuLimit        "console" 1) }}
  {{- include "streams.validateCpu"    (list .Values.resources.repositoryCpu     .Values.resources.repositoryCpuLimit     "repository" 1) }}
  
{{- end -}}

{{/* 
Validate memory request/limit. 
*/}}
{{- define "streams.validateMemory" -}}
  {{- $request := (index . 0) -}}
  {{- $limit := (index . 1) -}}
  {{- $type := (index . 2) -}}
  {{- $min := int (index . 3) -}}
  {{- $minVal := int (mul $min 1000000000) -}}
  {{- $r := int64 (include "streams.getMemoryBytes" (list $request)) -}}
  {{- $l := int64 (include "streams.getMemoryBytes" (list $limit)) -}}

  {{- if (gt $min 0) -}}
     {{- if (lt $r $minVal) -}}
        {{- fail (printf "resources.%sMemory must be at least %dG" $type $min) -}}
     {{- end -}}
  {{- end -}}
  
  {{- if (gt $r $l) -}}
     {{- fail (printf "resources.%sMemory must be less than or equal to resources.%sMemoryLimit" $type $type) -}}
  {{- end -}}
{{- end -}}

{{/* 
Translate memory value into bytes. 
*/}}
{{- define "streams.getMemoryBytes" -}}
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
{{- define "streams.validateCpu" -}}
  {{- $request := (index . 0) -}}
  {{- $limit := (index . 1) -}}
  {{- $type := (index . 2) -}}
  {{- $min := int (index . 3) -}}
  {{- $minVal := int (mul $min 1000) -}}
  {{- $r := splitList " " (include "streams.getCpu" (list $request)) -}}
  {{- $l := splitList " " (include "streams.getCpu" (list $limit)) -}}
  {{- $rn := int (index $r 0) -}}
  {{- $rf := int (index $r 1) -}}
  {{- $ln := int (index $l 0) -}}
  {{- $lf := int (index $l 1) -}}

  {{- if (gt $min 0) -}}
     {{- if (lt $rn $minVal) -}}
        {{- fail (printf "resources.%sCpu must be at least %d" $type $min) -}}
     {{- end -}}
  {{- end -}}
  
  {{- if (gt $rn $ln) -}}
     {{- fail (printf "resources.%sCpu must be less then or equal to resources.%sCpuLimit" $type $type) -}}
  {{- else if (eq $rn $ln) -}}
     {{- if (gt $rf $lf) -}}
        {{- fail (printf "resources.%sCpu must be less than or equal to resources.%sCpuLimit" $type $type) -}}
     {{- end -}}
  {{- end -}}
{{- end -}}

{{/* 
Translate cpu value to number/fraction
*/}}
{{- define "streams.getCpu" -}}
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
