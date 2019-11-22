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
{{- end }}

{{/*
Defines product metering
*/}}
{{- define "streams-addon.metering" }}
productID: "ICP4D-998edc72e0f04ec18cc5e2310eabafee-Management"
productName: "IBM Streams for IBM Cloud Pak For Data"
productVersion: {{.Chart.AppVersion | quote }}
{{- end }}

{{/*
Defines serviceability label
*/}}
{{- define "streams-addon.serviceability" }}
icpdsupport/addOnKey: "streams"
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

{/*
Name of the streams addon deployment
*/}}
{{- define "streams-addon.deployment" -}}
{{- include "streams-addon.name" . -}}
{{- end -}}

{/*
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
Add on service http port. 
*/}}
{{- define "streams-addon.chartUrl" -}}
{{- printf "%s%s.%s:%s%s" "http://" ( include "streams-addon.service" . ) .Release.Namespace ( include "streams-addon.httpport" . ) "/charts/" }}
{{- end -}}

{/*
Name of the streams addon service provider pvc, used if dynamically provisioned.
*/}}
{{- define "streams-addon.service-provider-pvc" -}}
{{- printf "%s-%s" ( include "streams-addon.name" . ) "service-provider-pvc" }}
{{- end -}}

{/*
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

{/*
Name of the pre-install hook.
*/}}
{{- define "streams-addon.notebook-job" -}}
{{- printf "%s-%s" (include "streams-addon.name" .) "notebook-job" -}}
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

{/*
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


{/*
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

{/*
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

{/*
Defines general pod securityContext values
*/}}
{{- define "streams-addon.podSecurityContext" }}
runAsNonRoot: true
runAsUser: {{ include "streams-addon.streamsinstall" . }}
runAsGroup: {{ include "streams-addon.streamsinstall" . }}
{{- end }}


{/*
Defines general pod securityContext values
*/}}
{{- define "streams-addon.podSecurityContextNotebookJob" }}
runAsNonRoot: false
# Do not specify a group here. Group is set in docker image.
runAsUser: 1000330999
{{- end }}