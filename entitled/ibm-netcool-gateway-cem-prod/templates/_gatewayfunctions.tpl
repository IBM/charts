{{- /* Utility functions. */ -}}

{{/*
Process the netcool.connectionMode and return "true" if
SSL connection is enabled. It is enabled when
netcool.connectionMode is either sslonly or sslandauth
*/}}
{{- define "ibm-netcool-gateway-cem-prod.netcoolConnectionSslEnabled" -}}
{{- $connectionMode := ( default "default" .Values.netcool.connectionMode | lower) -}}
{{ if or (eq $connectionMode "sslonly") (eq $connectionMode "sslandauth") }}
{{- printf "%s" "true" }}
{{- else -}}
{{- printf "%s" "false" }}
{{- end -}}
{{- end -}}

{{/*
Process the netcool.connectionMode and return "true" if
Authentication is enabled. It is enabled when
netcool.connectionMode is either authonly or sslandauth
*/}}
{{- define "ibm-netcool-gateway-cem-prod.netcoolConnectionAuthEnabled" -}}
{{- $connectionMode := ( default "default" .Values.netcool.connectionMode | lower) -}}
{{ if or (eq $connectionMode "authonly") (eq $connectionMode "sslandauth") }}
{{- printf "%s" "true" }}
{{- else -}}
{{- printf "%s" "false" }}
{{- end -}}
{{- end -}}

{{/*
Process the netcool.connectionMode and return "true" if
a keys secret is required. This is when
netcool.connectionMode is either authonly, sslonly or sslandauth
*/}}
{{- define "ibm-netcool-gateway-cem-prod.keySecretRequired" -}}
{{- $netcoolsslenabled := include "ibm-netcool-gateway-cem-prod.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolauthenabled := include "ibm-netcool-gateway-cem-prod.netcoolConnectionAuthEnabled" ( . ) -}}
{{ if and (eq $netcoolsslenabled "false") (eq $netcoolauthenabled "false") }}
{{- printf "%s" "false" }}
{{- else -}}
{{- printf "%s" "true" }}
{{- end -}}
{{- end -}}

{{- define "ibm-netcool-gateway-cem-prod.commonRoleName" -}}
{{- include "sch.config.init" (list . "gw.cem.sch.chart.config.values") -}}
{{- $objName :=  .sch.chart.components.common.roleName -}}
{{- $fullName := include "sch.names.fullCompName" (list . $objName ) -}}
{{- printf "%s" $fullName -}}
{{- end -}}


{{- define "ibm-netcool-gateway-cem-prod.commonRoleBindingName" -}}
{{- include "sch.config.init" (list . "gw.cem.sch.chart.config.values") -}}
{{- $objName :=  .sch.chart.components.common.roleBindingName -}}
{{- $fullName := include "sch.names.fullCompName" (list . $objName ) -}}
{{- printf "%s" $fullName -}}
{{- end -}}

{{- define "ibm-netcool-gateway-cem-prod.commonServiceAccountName" -}}
{{- $objName :=  .sch.chart.components.common.serviceAccountName -}}
{{- $fullName := include "sch.names.fullCompName" (list . $objName ) -}}
{{- printf "%s" $fullName -}}
{{- end -}}


{{- define "ibm-netcool-gateway-cem-prod.roleName" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "ibm-netcool-gateway-cem-prod.roleBindingName" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "ibm-netcool-gateway-cem-prod.serviceAccountName" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- /*
Security settings for deployment templates. This is to be added
in a deployment and not within the containers specification section.
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.securitySettingsStatefulset" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  supplementalGroups:
  {{- range $group := .Values.global.persistence.supplementalGroups }}
    - {{ $group -}}
  {{ end }}
  {{- if .Values.cemgateway.setUIDandGID }}
  runAsUser: 1001
  fsGroup: 2001
  {{- end }}
{{- end -}}

{{- /*
Security settings for pod templates. This is to be added into
each container specification section in a deployment template.
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.securitySettingsContainer" -}}
securityContext:
  runAsNonRoot: true
  {{- if .Values.cemgateway.setUIDandGID }}
  runAsUser: 1001
  {{- end }}
  privileged: false
  allowPrivilegeEscalation: false
  {{/* readOnlyRootFilesystem must be false to allow probe to create interfaces file */ -}}
  readOnlyRootFilesystem: false
  capabilities:
    drop:
    - ALL
{{- end -}}

{{- /*
Common configuration for Object Server.
This function constructs the omni.dat file.
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.commonConfigObjserv" -}}
omni.dat.init: |
{{ include "ibm-netcool-gateway-cem-prod.getInterfacesRaw" . | replace "$" "\n" | indent 2 }}
{{- end }}

{{- /*
Common configuration for Object Server.
This function returns the name of the target object server from the omni.dat file.
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.getObjservName" -}}
{{- if .Values.netcool.backupServer -}}
{{- printf "%s" "AGG_V" -}}
{{- else -}}
{{- printf "%s" .Values.netcool.primaryServer -}}
{{- end -}}
{{- end }}


{{- /*
Common configuration for Object Server.
This function returns the name of the target object server from the omni.dat file 
in a single line with "$" character as a replacement for line delimiter.
The output of this function can be piped to a "replaceAll" function to create multiline
output or single line (using with spaces).

## Old omni.dat without IP support.
[{{ .Values.netcool.primaryServer }}]
{
  Primary: {{ .Values.netcool.primaryHost }}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.primaryPort }}
}
{{ if .Values.netcool.backupServer -}}
[{{ .Values.netcool.backupServer }}]
{
  Primary: {{ .Values.netcool.backupHost }}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.backupPort }}
}
[AGG_V]
{
  Primary: {{ .Values.netcool.primaryHost }}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.primaryPort }}
  Backup: {{ .Values.netcool.backupHost }}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.backupPort }}
}


## NEW with IP specified. The hostname takes precedence over IP. If only IP is specified, use IP.
Each "{{ .Values.netcool.primaryHost }}" is replaced with "{{ if and .Values.netcool.primaryIP .Values.netcool.primaryHost }}{{.Values.netcool.primaryHost}}{{ else if .Values.netcool.primaryIP }}{{.Values.netcool.primaryIP }}{{else}}{{.Values.netcool.primaryHost}}{{end}}".
And similarly for backup Object Server.

[{{ .Values.netcool.primaryServer }}]
{
  Primary: {{ if and .Values.netcool.primaryIP .Values.netcool.primaryHost }}{{.Values.netcool.primaryHost}}{{ else if .Values.netcool.primaryIP }}{{.Values.netcool.primaryIP }}{{else}}{{.Values.netcool.primaryHost}}{{end}}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.primaryPort }}
}
{{ if .Values.netcool.backupServer -}}
[{{ .Values.netcool.backupServer }}]
{
  Primary: {{ if and .Values.netcool.backupIP .Values.netcool.backupHost }}{{.Values.netcool.backupHost}}{{ else if .Values.netcool.backupIP }}{{.Values.netcool.backupIP }}{{else}}{{.Values.netcool.backupHost}}{{end}}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.backupPort }}
}
[AGG_V]
{
  Primary: {{ if and .Values.netcool.primaryIP .Values.netcool.primaryHost }}{{.Values.netcool.primaryHost}}{{ else if .Values.netcool.primaryIP }}{{.Values.netcool.primaryIP }}{{else}}{{.Values.netcool.primaryHost}}{{end}}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.primaryPort }}
  Backup: {{ if and .Values.netcool.backupIP .Values.netcool.backupHost }}{{.Values.netcool.backupHost}}{{ else if .Values.netcool.backupIP }}{{.Values.netcool.backupIP }}{{else}}{{.Values.netcool.backupHost}}{{end}}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.backupPort }}
}
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.getInterfacesRaw" -}}
{{- $netcoolsslenabled := include "ibm-netcool-gateway-cem-prod.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolauthenabled := include "ibm-netcool-gateway-cem-prod.netcoolConnectionAuthEnabled" ( . ) -}}
[{{ .Values.netcool.primaryServer }}]${$  Primary: {{ if and .Values.netcool.primaryIP .Values.netcool.primaryHost }}{{.Values.netcool.primaryHost}}{{ else if .Values.netcool.primaryIP }}{{.Values.netcool.primaryIP }}{{else}}{{.Values.netcool.primaryHost}}{{end}}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.primaryPort }}$}${{ if .Values.netcool.backupServer -}}$[{{ .Values.netcool.backupServer }}]${$  Primary: {{ if and .Values.netcool.backupIP .Values.netcool.backupHost }}{{.Values.netcool.backupHost}}{{ else if .Values.netcool.backupIP }}{{.Values.netcool.backupIP }}{{else}}{{.Values.netcool.backupHost}}{{end}}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.backupPort }}$}$[AGG_V]${$  Primary: {{ if and .Values.netcool.primaryIP .Values.netcool.primaryHost }}{{.Values.netcool.primaryHost}}{{ else if .Values.netcool.primaryIP }}{{.Values.netcool.primaryIP }}{{else}}{{.Values.netcool.primaryHost}}{{end}}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.primaryPort }}$  Backup: {{ if and .Values.netcool.backupIP .Values.netcool.backupHost }}{{.Values.netcool.backupHost}}{{ else if .Values.netcool.backupIP }}{{.Values.netcool.backupIP }}{{else}}{{.Values.netcool.backupHost}}{{end}}{{ if (eq $netcoolsslenabled "true") }} ssl{{ end }} {{ .Values.netcool.backupPort }}$}
{{- end -}}
{{- end }}

{{- /* Returns the omni.dat entry for gateway using the service name and port number. */}}
{{- define "ibm-netcool-gateway-cem-prod.getGatewayInterfacesRaw" -}}
{{- include "sch.config.init" (list . "gw.cem.sch.chart.config.values") -}}
{{- $gateServiceName := include "sch.names.fullName" (list .) }}
{{- $gatewayName :=  .sch.chart.components.gatecem.gatewayName -}}
{{- $gatewayPort :=  .sch.chart.components.gatecem.gatewayPort -}}
[{{ $gatewayName }}]${$  Primary: {{ $gateServiceName }}   {{ $gatewayPort }} $}
{{- end }}

{{- /*
Common configuration for Object Server.
This function returns the name of the target object server from the omni.dat file in a single line.
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.getInterfacesOneLine" -}}
{{ include "ibm-netcool-gateway-cem-prod.getInterfacesRaw" . | replace "$" " " }}
{{- end }}

{{- /*
Common configuration for Object Server.
This function returns the name of the gateway service from omni.dat file in a single line.
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.getGatewayInterfacesOneLine" -}}
{{ include "ibm-netcool-gateway-cem-prod.getGatewayInterfacesRaw" . | replace "$" " " }}
{{- end }}



{{- /*
Common configuration for Object Server.
This function adds a hostAliases in the pod spec object. For example
hostAliases:
- ip: "IP1"
  hostnames:
  - "hostname1"
- ip: "IP2"
  hostnames:
  - "hostname2"
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.addHostAliases" -}}
{{- if or (and .Values.netcool.backupIP (.Values.netcool.backupHost)) (and .Values.netcool.primaryIP (.Values.netcool.primaryHost)) -}}
hostAliases:
{{- if eq .Values.netcool.primaryIP .Values.netcool.backupIP }}
- ip: {{ .Values.netcool.primaryIP | quote }}
  hostnames:
  - {{ .Values.netcool.primaryHost | quote }}
{{- if .Values.netcool.primaryIDUCHost }}
  - {{ .Values.netcool.primaryIDUCHost | quote}}
{{- end }}
  - {{ .Values.netcool.backupHost | quote }}
{{- if .Values.netcool.backupIDUCHost }}
  - {{ .Values.netcool.backupIDUCHost | quote }}
{{- end }}
{{ else }}
{{- if and .Values.netcool.primaryIP .Values.netcool.primaryHost }}
- ip: {{ .Values.netcool.primaryIP | quote }}
  hostnames:
  - {{ .Values.netcool.primaryHost | quote }}
{{- if .Values.netcool.primaryIDUCHost }}
  - {{ .Values.netcool.primaryIDUCHost | quote }}
{{- end }}
{{ end }}
{{- if and .Values.netcool.backupIP .Values.netcool.backupHost }}
- ip: {{ .Values.netcool.backupIP | quote }}
  hostnames:
  - {{ .Values.netcool.backupHost | quote }}
{{- if .Values.netcool.backupIDUCHost }}
  - {{ .Values.netcool.backupIDUCHost | quote }}
{{- end }}
{{ end -}}
{{- end }}
{{- end }}
{{- end }}



{{- /*
Lines for volume mounts.
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.volumeMounts" -}}
{{- include "sch.config.init" (list . "gw.cem.sch.chart.config.values") -}}
{{- $netcoolsslenabled := include "ibm-netcool-gateway-cem-prod.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolauthenabled := include "ibm-netcool-gateway-cem-prod.netcoolConnectionAuthEnabled" ( . ) -}}
{{- $netcoolsecretrequired := include "ibm-netcool-gateway-cem-prod.keySecretRequired" ( . ) -}}
{{- $pvcName := "pvc" -}}
{{- $statefulSetName := include "sch.names.statefulSetName" (list .) -}}
{{- $volumeClaimTemplateName := include "sch.names.volumeClaimTemplateName" (list . $pvcName $statefulSetName) -}}
{{/* Mount omni.dat.init so that it can be modified by pod init.sh. */}}
- name: interfaces-file
  mountPath: /opt/IBM/tivoli/netcool/etc/omni.dat.init
  subPath: omni.dat.init
- name: {{ $volumeClaimTemplateName }}
  mountPath: /opt/IBM/tivoli/netcool/omnibus/var/G_CEM
- name: shared-dir
  mountPath: /home/netcool/etc
{{- if .Values.cemgateway.cemTlsSecretName }}
- name: cem-tls-secret
  mountPath: /home/netcool/etc/certs
{{- end }}
{{- if and (.Values.netcool.secretName) (eq $netcoolauthenabled "true") }}
{{- /*  Mount a shared directory to place the original properties file
      so that it can be updated by the init.sh script.
*/}}
- name: props-file
  mountPath: /home/netcool/etc/G_CEM.props
  subPath: G_CEM.props
{{- else }}
- name: props-file
  mountPath: /opt/IBM/tivoli/netcool/omnibus/etc/G_CEM.props
  subPath: G_CEM.props
{{- end }}
- name: gw-tblrep-replace
  mountPath: /home/netcool/etc/cem.rdrwtr.tblrep.def.replace
  subPath: cem.rdrwtr.tblrep.def.replace
- name: gw-map-replace
  mountPath: /home/netcool/etc/cem.map.replace
  subPath: cem.map.replace
{{- if and .Values.netcool.secretName (eq $netcoolsecretrequired "true") }}
{{- if (eq $netcoolauthenabled "true") }}
- name: netcool-secret
  mountPath: /opt/IBM/tivoli/netcool/etc/security/keys/encryption.keyfile
  subPath: encryption.keyfile
{{- end }}
{{- if (eq $netcoolsslenabled "true") }}
- name: netcool-secret
  mountPath: /opt/IBM/tivoli/netcool/etc/security/keys/omni.kdb
  subPath: omni.kdb
- name: netcool-secret
  mountPath: /opt/IBM/tivoli/netcool/etc/security/keys/omni.sth
  subPath: omni.sth
{{- end }}
{{- end }}
{{- end -}}


{{- /*
Get the image registry to construct the test image repo.
*/ -}}
{{- define "ibm-netcool-gateway-cem-prod.constructTestImageReponame" -}}
{{- include "sch.config.init" (list . "gw.cem.sch.chart.config.values") -}}
{{- $testImage :=  .sch.chart.components.gatecemtest.imageName -}}
{{- $testImageVersion :=  .sch.chart.components.gatecemtest.version -}}
{{- $registryName := trimSuffix "netcool-gateway-cem" .Values.image.repository -}}
{{ if hasSuffix "/" $registryName }}
{{- $registryName := trimSuffix "/" $registryName }}
{{- printf "%s/%s:%s" $registryName $testImage $testImageVersion }}
{{- else }}
{{- printf "%s:%s" $testImage $testImageVersion }}
{{- end -}}
{{- end -}}
