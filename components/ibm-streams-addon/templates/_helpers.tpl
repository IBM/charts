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
Defines default chart labels
*/}}
{{- define "streams-addon.defaultLabels" }}
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
release: "{{ .Release.Name }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
app.kubernetes.io/component: "{{ .Chart.Name }}"
streams-addon: {{ .Release.Name }}
{{- include "streams-addon.serviceability" . }}
{{- end }}

{{/*
Defines product metering
*/}}
{{- define "streams-addon.metering" }}
productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
productName: "IBM Streams"
productVersion: {{.Chart.AppVersion | quote }}
productMetric: "VIRTUAL_PROCESSOR_CORE"
productCloudpakRatio: "1:1"  
productChargedContainers: "All"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
{{- if ( .Values.global.cloudpakInstanceId )  }}
cloudpakInstanceId: {{ .Values.global.cloudpakInstanceId }}
{{- end }}
{{- end }}

{{/*
Defines quiesce online noop annotation 
*/}}
{{- define "streams-addon.quiesceOnlineNoop" }}
hook.quiesce.cpd.ibm.com/command: "/opt/ibm/streams/bin/quiesce-unquiesce-noop.sh"
hook.unquiesce.cpd.ibm.com/command: "/opt/ibm/streams/bin/quiesce-unquiesce-noop.sh"
{{- end }}

{{/*
Defines quiesce offline noop annotation 
*/}}
{{- define "streams-addon.quiesceOfflineNoop" }}
hook.deactivate.cpd.ibm.com/command: "/opt/ibm/streams/bin/quiesce-unquiesce-noop.sh"
hook.activate.cpd.ibm.com/command: "/opt/ibm/streams/bin/quiesce-unquiesce-noop.sh"
{{- end }}

{{/*
Defines quiesce offline scale to zero annotation 
*/}}
{{- define "streams-addon.quiesceOfflineScaleToZero" }}
hook.deactivate.cpd.ibm.com/command: "[]"
hook.activate.cpd.ibm.com/command: "[]"
{{- end }}

{{/*
Defines serviceability label
*/}}
{{- define "streams-addon.serviceability" }}
icpdsupport/addOnId: "streams"
icpdsupport/app: "service"
icpdsupport/assemblyName: "streams"
icpdsupport/addon: "true"
{{- end }}

{{/*
Install owner and user uid
*/}}
{{- define "streams-addon.streamsinstall" -}}
{{- printf "%d" 1000321000 -}}
{{- end -}}

{{/*
Default name to use for all objects.
*/}}
{{- define "streams-addon.name" -}}
{{- default  .Release.Name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name of the streams addon deployment
*/}}
{{- define "streams-addon.deployment" -}}
{{- include "streams-addon.name" . -}}
{{- end -}}

{{/*
Name of the streams addon service
*/}}
{{- define "streams-addon.service" -}}
{{- include "streams-addon.name" . -}}
{{- end -}}

{{/*
Add on service http port.  
*/}}
{{- define "streams-addon.httpport" -}}
8080
{{- end -}}

{{/*
Add on service http port.  
*/}}
{{- define "streams-addon.httpsport" -}} 
8443
{{- end -}}

{{/*
Add on service http port. This is required for helm/tiller to be able to access charts from add pod.
*/}}
{{- define "streams-addon.chartUrl" -}}
{{- printf "%s%s.%s:%s%s" "http://" ( include "streams-addon.service" . ) .Release.Namespace ( include "streams-addon.httpport" . ) "/charts/" }}
{{- end -}}

{{/*
Name of the streams addon service provider pvc, used if dynamically provisioned.
*/}}
{{- define "streams-addon.service-provider-pvc" -}}
{{- printf "%s-%s" ( include "streams-addon.name" . ) "service-provider-pvc" }}
{{- end -}}

{{/*
Proxy URL for nginx 
*/}}
{{- define "streams-addon.nginx-proxy" -}}
{{- printf "%s%s:%s%s" "https://" ( include "streams-addon.service" . ) ( include "streams-addon.httpsport" . ) "/" -}}
{{- end -}}

{{/*
Name of the service provider. This is used for the pod name and the endpoint. 
*/}}
{{- define "streams-addon.service-provider-name" -}}
{{- printf "%s-%s" (include "streams-addon.name" .) "service-provider" -}}
{{- end -}}

{{/*
Service provider port. This is hard coded here because it needs to be set in the addon.json file.
*/}}
{{- define "streams-addon.service-provider-httpport" -}}
8080 
{{- end -}}

{{/*
Service provider port name. 
*/}}
{{- define "streams-addon.service-provider-port-name" -}}
http-sp 
{{- end -}}

{{/*
Service provider port. This is hard coded here because it needs to be set in the addon.json file.
*/}}
{{- define "streams-addon.service-provider-httpsport" -}}
8443
{{- end -}}

{{/*
Service provider https port name. 
*/}}
{{- define "streams-addon.service-provider-httpsport-name" -}}
https-sp 
{{- end -}}

{{/*
Service provider URL. 
*/}}
{{- define "streams-service-provider.httpurl" -}}
{{- printf "%s%s:%s" "http://" (include "streams-addon.service-provider-name" .) (include "streams-addon.service-provider-httpport" .) -}}
{{- end -}}

{{/*
Service provider URL. 
*/}}
{{- define "streams-service-provider.httpsurl" -}}
{{- printf "%s%s:%s" "https://" (include "streams-addon.service-provider-name" .) (include "streams-addon.service-provider-httpsport" .) -}}
{{- end -}}

{{/*
Proxy URL for nginx 
*/}}
{{- define "streams-service-provider.nginx-proxy" -}}
{{- printf "%s%s:%s%s" "https://" (include "streams-addon.service-provider-name" .) (include "streams-addon.service-provider-httpsport" .) "/" -}}
{{- end -}}

{{/*
Name of the pre-install hook.
*/}}
{{- define "streams-addon.notebook-job" -}}
{{- printf "%s-%s" (include "streams-addon.name" .) "notebook-job" -}}
{{- end -}}

{{/*
Name of the pre-install hook.
*/}}
{{- define "streams-addon.notebook-delete-job" -}}
{{- printf "%s-%s" (include "streams-addon.name" .) "notebook-delete-job" -}}
{{- end -}}

{{/*
Metadata configmap name
*/}}
{{- define "streams-addon.meta-configmap" -}}
{{- printf "%s-%s" (include "streams-addon.name" .) "meta-configmap" -}}
{{- end -}}

{{/*
Service provider configmap name
*/}}
{{- define "streams-addon.service-provider-configmap" -}}
{{- printf "%s-%s" (include "streams-addon.name" .) "service-configmap" -}}
{{- end -}}

{{- define "streams-addon.nodeaffinity" }}
nodeAffinity:
{{- include "streams-addon.nodeAffinityRequiredDuringScheduling" . | indent 2}}
{{- end }}

{{- define "streams-addon.nodeAffinityRequiredDuringScheduling" }}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: beta.kubernetes.io/arch
      operator: In
      values:
      - amd64
{{- end }}

{{/*
The persistent volume claim for the notebook template.
*/}}
{{- define "streams-addon.user-home-pvc" }}
- name: user-home-mount
  persistentVolumeClaim:
    claimName: "user-home-pvc"
{{- end }}

{{/*
Validate required values
*/}}
{{- define "streams-addon.checkValues" -}}
 
  {{- if and (empty .Values.serviceProvider.persistence.existingClaimName) (empty .Values.global.storageClassName) -}} 
     {{- fail "You must specify global.storageClassName or serviceProvider.persistence.existingClaimName." -}}
  {{- end -}}
  
{{- end -}}

{{/*
Defines container security context values
*/}}
{{- define "streams-addon.containerSecurityContext" }}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: false
runAsNonRoot: true
capabilities:
  drop:
  - ALL
{{- end }}


{{/*
Defines container security context values
*/}}
{{- define "streams-addon.containerSecurityContextNotebookJob" }}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: false
runAsNonRoot: false
capabilities:
  drop:
  - ALL
{{- end }}

{{/*
Defines pod general security policies
HostPID - Controls whether the pod containers can share the host process ID namespace. Note that when 
paired with ptrace this can be used to escalate privileges outside of the container (ptrace is forbidden by default).
HostIPC - Controls whether the pod containers can share the host IPC namespace.
HostNetwork - Controls whether the pod may use the node network namespace. Doing so gives the pod access to the 
loopback device, services listening on localhost, and could be used to snoop on network activity of other pods on the same node.
*/}}
{{- define "streams-addon.podGeneralSecurityPolicies" }}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end }}

{{/*
Defines general pod securityContext values
*/}}
{{- define "streams-addon.podSecurityContext" }}
runAsNonRoot: true
runAsUser: {{ include "streams-addon.streamsinstall" . }}
runAsGroup: {{ include "streams-addon.streamsinstall" . }}
{{- end }}

{{/*
Defines general pod securityContext values
*/}}
{{- define "streams-addon.podSecurityContextNotebookJob" }}
runAsNonRoot: false
# Do not specify a group here. Group is set in docker image.
runAsUser: 1000330999
{{- end }}
