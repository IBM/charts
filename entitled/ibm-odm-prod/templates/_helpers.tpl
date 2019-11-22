{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "productID" -}}
{{- printf "OperationalDecisionManagerForProduction" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-secret"  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dbserver.fullname" -}}
{{- $name := default "dbserver" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name "dbserver" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.decisionserverconsole.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-decisionserverconsole" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.decisionserverconsole.notif.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-decisionserverconsole-notif" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.decisionserverruntime.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-decisionserverruntime" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.decisioncenter.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-decisioncenter" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.decisionrunner.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-decisionrunner" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.persistenceclaim.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-pvclaim" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.test.fullname" -}}
{{- $name := default "odm-test" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name "odm-test" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.test-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-test-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dc-logging-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dc-logging-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dr-logging-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dr-logging-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.ds-console-logging-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-console-logging-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.ds-runtime-logging-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-runtime-logging-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dc-jvm-options-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dc-jvm-options-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dr-jvm-options-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dr-jvm-options-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.ds-console-jvm-options-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-console-jvm-options-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.ds-runtime-jvm-options-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-runtime-jvm-options-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dbserver-network-policy.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dbserver-network-policy" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dc-network-policy.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dc-network-policy" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dr-network-policy.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dr-network-policy" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.ds-console-network-policy.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-console-network-policy" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.ds-runtime-network-policy.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-runtime-network-policy" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-security-secret-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-security-secret-volume" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-baiemitterconfig-secret-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-baiemitterconfig-secret-volume" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-auth-secret-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-auth-secret-volume" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-custom-secret-ds.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-custom-secret-ds" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "odm-custom-secret-ds-file.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-custom-secret-ds-file" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "odm-customdatasource-dir" -}}
"/config/customdatasource/"
{{- end -}}

{{- define "odm-logging-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-logging-volume" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-jvm-options-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-jvm-options-volume" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-driver-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-driver-volume" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-dc-customlib-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dc-customlib-volume" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-sql-internal-db-check" -}}
until [ $CHECK_DB_SERVER -eq 0 ]; do echo {{ template "odm.dbserver.fullname" . }} on port 5432 state $CHECK_DB_SERVER; CHECK_DB_SERVER=$(psql -q -h {{ template "odm.dbserver.fullname" . }}   -d $PGDATABASE  -c "select 1" -p 5432 >/dev/null;echo $?); echo "Check $CHECK_DB_SERVER"; sleep 2; done;
{{- end -}}

{{- define "odm-sql-internal-db-check-env" -}}
- name: PGDATABASE
  value: "{{ .Values.internalDatabase.databaseName }}"
- name: PGCONNECT_TIMEOUT
  value: "2"
{{- if not (empty .Values.internalDatabase.secretCredentials) }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.internalDatabase.secretCredentials }}
      key: db-user
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.internalDatabase.secretCredentials }}
      key: db-password
{{- else }}
- name: PGUSER
  value: "{{ .Values.internalDatabase.user }}"
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "odm.secret.fullname" . }}
      key: db-password
{{- end }}
{{- end -}}

{{- define "odm-tolerations" -}}
tolerations:
  - key: {{ .Values.customization.dedicatedNodeLabel }}
    operator: "Exists"
    effect: "NoSchedule"
{{- end -}}

{{- define "odm-annotations" -}}
annotations:
  {{- if not (empty (.Values.customization.productName)) }}
  productName: {{ .Values.customization.productName}}
  {{ else }}
  productName: {{ .Chart.Description | quote }}
  {{- end }}
  {{- if not (empty (.Values.customization.productID)) }}
  productID: {{ .Values.customization.productID}}
  {{ else }}
  productID: {{ template "productID" . }}
  {{- end }}
  {{- if not (empty (.Values.customization.productVersion)) }}
  productVersion: {{ .Values.customization.productVersion}}
  {{ else }}
  productVersion: {{ .Chart.AppVersion }}
  {{- end }}
{{- end -}}

{{- define "odm-security-dir" -}}
"/config/security"
{{- end -}}

{{- define "odm-auth-dir" -}}
"/config/auth"
{{- end -}}

{{- define "odm-log-dir" -}}
"/config/logging"
{{- end -}}

{{- define "odm-jvm-options-dir" -}}
"/config/configDropins/overrides"
{{- end -}}

{{- define "odm-driver-dir" -}}
"/drivers"
{{- end -}}

{{- define "odm-dc-customlib-dir" -}}
"/config/customlib"
{{- end -}}

{{- define "odm-baiemitterconfig-dir" -}}
"/config/baiemitterconfig/"
{{- end -}}

{{- define "odm-keystore-password-key" -}}
"keystore_password"
{{- end -}}

{{- define "odm-truststore-password-key" -}}
"truststore_password"
{{- end -}}

## Utilities
# Method to strip the / at the end of the repository name
{{- define "odm.repository.name" -}}
{{- $reponame := default "ibmcom" .Values.image.repository -}}
{{- printf "%s"  $reponame |  trimSuffix "/" -}}
{{- end -}}
## End Utilities

{{- define "odm.http.protocol" -}}
{{- if .Values.service.enableTLS }}
{{- printf "https" | quote -}}
{{- else }}
{{- printf "http" | quote -}}
{{- end }}
{{- end -}}

{{- define "odm.dr.checkurl" -}}
{{- if .Values.service.enableTLS }}{{ printf "https://%s:9443/DecisionRunner"  (include "odm.decisionrunner.fullname" .)  | quote }}
{{- else }}{{ printf "http://%s:9443/DecisionRunner"  (include "odm.decisionrunner.fullname" .) | quote }}
{{- end -}}
{{- end -}}

{{- define "odm.dsr.checkurl" -}}
{{- if .Values.service.enableTLS }}{{ printf "https://%s:9443/DecisionService"  (include "odm.decisionserverruntime.fullname" .) | quote  }}
{{- else }}{{ printf "http://%s:9443/DecisionService"  (include "odm.decisionserverruntime.fullname" .) | quote  }}
{{- end -}}
{{- end -}}

{{- define "odm.dsc.checkurl" -}}
{{- if .Values.service.enableTLS }}{{ printf "https://%s:9443/res"  (include "odm.decisionserverconsole.fullname" .) | quote  }}
{{- else }}{{ printf "http://%s:9443/res"  (include "odm.decisionserverconsole.fullname" .) | quote  }}
{{- end -}}
{{- end -}}

{{- define "odm.dc.checkurl" -}}
{{- if .Values.service.enableTLS }}{{ printf "https://%s:9453"  (include "odm.decisioncenter.fullname" .) | quote  }}
{{- else }}{{ printf "http://%s:9453"  (include "odm.decisioncenter.fullname" .) | quote  }}
{{- end -}}
{{- end -}}

{{/*
Check if tag contains specific platform suffix and if not set based on kube platform
*/}}
{{- define "platform" -}}
{{- if not .Values.image.arch }}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "amd64" }}
  {{- end -}}
  {{- if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "ppc64le" }}
  {{- end -}}
  {{- if (eq "linux/s390x" .Capabilities.KubeVersion.Platform) }}
    {{- printf "-%s" "s390x" }}
  {{- end -}}
{{- else -}}
    {{- printf "-%s" .Values.image.arch }}
{{- end -}}
{{- end -}}

{{/*
Return arch based on kube platform
*/}}
{{- define "arch" -}}
  {{- if (eq "linux/amd64" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "amd64" }}
  {{- else if (eq "linux/ppc64le" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "ppc64le" }}
  {{- else if (eq "linux/s390x" .Capabilities.KubeVersion.Platform) }}
    {{- printf "%s" "s390x" }}
  {{- else }}
    {{- printf "%s" "amd64" }}
  {{- end -}}
{{- end -}}

{{- define "odm-security-context" -}}
securityContext:
  runAsUser: 1001
  runAsNonRoot: true
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
{{- end -}}
{{- define "odm-spec-security-context" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
{{- end -}}
{{- define "odm-kubeVersion" -}}
  {{- if .Values.customization.kubeVersion }}
- name: "KubeVersion"
  value: "{{ .Values.customization.kubeVersion }}"
  {{- else -}}
- name: "KubeVersion"
  value: "{{ .Capabilities.KubeVersion.GitVersion }}"
  {{- end -}}
{{- end -}}

{{/*
Define database configuration for deployment
*/}}
{{- define "odm-db-config" -}}
{{- if empty (.Values.externalCustomDatabase.datasourceRef) -}}
{{- if empty .Values.externalDatabase.serverName -}}
- name: DB_TYPE
  value: "postgresql"
- name: "DB_SERVER_NAME"
  value: {{ template "odm.dbserver.fullname" . }}
- name: DB_PORT_NUMBER
  value: "5432"
- name: DB_NAME
  value: "{{ .Values.internalDatabase.databaseName }}"
{{- if not (empty .Values.internalDatabase.secretCredentials) }}
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.internalDatabase.secretCredentials }}
      key: db-user
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.internalDatabase.secretCredentials }}
      key: db-password
{{- else }}
- name: DB_USER
  value: "{{ .Values.internalDatabase.user }}"
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "odm.secret.fullname" . }}
      key: db-password
{{- end }}
{{- else }}
- name: DB_TYPE
  value: "{{ .Values.externalDatabase.type }}"
- name: DB_SERVER_NAME
  value: "{{ .Values.externalDatabase.serverName }}"
- name: DB_PORT_NUMBER
  value: "{{ .Values.externalDatabase.port }}"
- name: DB_NAME
  value: "{{ .Values.externalDatabase.databaseName }}"
{{- if not (empty .Values.externalDatabase.secretCredentials) }}
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.secretCredentials }}
      key: db-user
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.secretCredentials }}
      key: db-password
{{- else }}
- name: DB_USER
  value: "{{ .Values.externalDatabase.user }}"
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "odm.secret.fullname" . }}
      key: db-password
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
