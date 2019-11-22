{{- /* Utility functions. */ -}}

{{/*
Process the netcool.connectionMode and return "true" if
SSL connection is enabled. It is enabled when
netcool.connectionMode is either sslonly or sslandauth
*/}}
{{- define "ibm-netcool-probe.netcoolConnectionSslEnabled" -}}
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
{{- define "ibm-netcool-probe.netcoolConnectionAuthEnabled" -}}
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
{{- define "ibm-netcool-probe.keySecretRequired" -}}
{{- $netcoolsslenabled := include "ibm-netcool-probe.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolauthenabled := include "ibm-netcool-probe.netcoolConnectionAuthEnabled" ( . ) -}}
{{ if and (eq $netcoolsslenabled "false") (eq $netcoolauthenabled "false") }}
{{- printf "%s" "false" }}
{{- else -}}
{{- printf "%s" "true" }}
{{- end -}}
{{- end -}}

{{- define "ibm-netcool-probe.commonRoleName" -}}
{{- include "sch.config.init" (list . "probe.sch.chart.config.values") -}}
{{- $objName :=  .sch.chart.components.common.roleName -}}
{{- $fullName := include "sch.names.fullCompName" (list . $objName ) -}}
{{- printf "%s" $fullName -}}
{{- end -}}


{{- define "ibm-netcool-probe.commonRoleBindingName" -}}
{{- include "sch.config.init" (list . "probe.sch.chart.config.values") -}}
{{- $objName :=  .sch.chart.components.common.roleBindingName -}}
{{- $fullName := include "sch.names.fullCompName" (list . $objName ) -}}
{{- printf "%s" $fullName -}}
{{- end -}}

{{- define "ibm-netcool-probe.commonServiceAccountName" -}}
{{- $objName :=  .sch.chart.components.common.serviceAccountName -}}
{{- $fullName := include "sch.names.fullCompName" (list . $objName ) -}}
{{- printf "%s" $fullName -}}
{{- end -}}


{{- define "ibm-netcool-probe.roleName" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "ibm-netcool-probe.roleBindingName" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "ibm-netcool-probe.serviceAccountName" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- /*
Security settings for deployment templates. This is to be added
in a deployment and not within the containers specification section.
*/ -}}
{{- define "ibm-netcool-probe.securitySettingsDeployment" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  {{ if .Values.probe.setUIDandGID -}}
  runAsUser: 1001
  fsGroup: 2001
  {{- end }}
{{- end -}}

{{- /*
Security settings for pod templates. This is to be added into
each container specification section in a deployment template.
*/ -}}
{{- define "ibm-netcool-probe.securitySettingsContainer" -}}
securityContext:
  runAsNonRoot: true
  {{ if .Values.probe.setUIDandGID -}}
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
Common pod volume mounts.
*/ -}}
{{- define "ibm-netcool-probe.volumeMounts" -}}
{{- $netcoolsslenabled := include "ibm-netcool-probe.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolauthenabled := include "ibm-netcool-probe.netcoolConnectionAuthEnabled" ( . ) -}}
{{- $netcoolsecretrequired := include "ibm-netcool-probe.keySecretRequired" ( . ) -}}
- name: interfaces-file
  mountPath: /opt/IBM/tivoli/netcool/etc/omni.dat
  subPath: omni.dat
- name: rules-file
  mountPath: /opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus.rules
  subPath: message_bus.rules
{{- if and (.Values.netcool.secretName) (eq $netcoolauthenabled "true") }}
{{- /*  Mount a shared directory to place the original properties file
      so that it can be updated by the init.sh script.
*/}}
- name: shared-dir
  mountPath: /home/netcool/etc
- name: props-file
  mountPath:  /home/netcool/etc/message_bus.props
  subPath: message_bus.props
{{- else }}
- name: props-file
  mountPath: /opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus.props
  subPath: message_bus.props
{{- end }}
- name: transport-file
  mountPath: /opt/IBM/tivoli/netcool/omnibus/java/conf/webhookTransport.properties
  subPath: webhookTransport.properties
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
