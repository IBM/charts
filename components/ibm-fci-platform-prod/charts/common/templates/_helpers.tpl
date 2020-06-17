{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{-   default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{-   if .Values.fullnameOverride -}}
{{-     .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{-   else -}}
{{-     $name := default .Chart.Name .Values.nameOverride -}}
{{-     if contains $name .Release.Name -}}
{{-       .Release.Name | trunc 63 | trimSuffix "-" -}}
{{-     else -}}
{{-       printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Metering Annotations for CP4D
*/}}
{{- define "common.meteringAnnotations" -}}
productName: "IBM Cloud Pak for Data Financial Crimes Insight"
productID: "5737-E41"
productVersion: "6.5.2"
productMetric: "INSTALL"
productChargedContainers: "All"
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakVersion: "3.0.1"
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{-   printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create readiness probe to execute healthcheck
*/}}
{{- define "common.readinessProbe" -}}
readinessProbe:
  exec:
    command:
    - sh
    - -c
    - "if [ -e /opt/ibm/fci/scripts/healthcheck.sh ]; then /opt/ibm/fci/scripts/healthcheck.sh; else exit {{ default 0 .Values.global.enforceHealthCheck }}; fi"
  initialDelaySeconds: 60
  periodSeconds: 60
  timeoutSeconds: 10
{{- end -}}

{{/*
Create liveness probe to execute healthcheck
*/}}
{{- define "common.livenessProbe" -}}
livenessProbe:
  exec:
    command:
    - sh
    - -c
    - "if [ -e /opt/ibm/fci/scripts/healthcheck.sh ]; then /opt/ibm/fci/scripts/healthcheck.sh; else exit {{ default 0 .Values.global.enforceHealthCheck }}; fi"
  initialDelaySeconds: 300
  periodSeconds: 60
  timeoutSeconds: 10
{{- end -}}


{{/*
Create healthcheck probe for sidecars to execute healthcheck
*/}}
{{- define "common.sideCarHealthCheck" -}}
livenessProbe:
  exec:
    command:
    - echo
  initialDelaySeconds: 120
  periodSeconds: 60
readinessProbe:
  exec:
    command:
    - echo
  initialDelaySeconds: 30
  periodSeconds: 60
{{- end -}}

{{/*
Architecture Affinity for the containers
*/}}
{{- define "common.ArchNodeAffinity" -}}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
        - {{ .Values.arch }}
{{- end -}}



{{/*
*/}}
{{- define "common.label.metadata" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $app := (index $params 1) }}
  {{- $chart := (index $params 2) }}
  {{- $release := (index $params 3) }}
  {{- $heritage := (index $params 4) }}
app: {{ $app }}
chart: {{ $chart }}
heritage: {{ $heritage }}
release: {{ $release }}
app.kubernetes.io/name: {{ $app }}
helm.sh/chart: {{ $chart }}
app.kubernetes.io/managed-by: {{ $heritage }}
app.kubernetes.io/instance: {{ $release }}
{{- end}}

{{/*
*/}}
{{- define "common.selector.labels" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $app := (index $params 1) }}
  {{- $release := (index $params 2) }}
app.kubernetes.io/name: {{ $app }}
app.kubernetes.io/instance: {{ $release }}
{{- end}}


{{/*
*/}}
{{- define "common.configureHostAliases" -}}
{{-   if hasKey $.Values.global "hostAliases" -}}
hostAliases:
{{    toYaml $.Values.global.hostAliases -}}
{{-   end -}}
{{- end -}}

{{/*
Check if component should be disabled
*/}}
{{- define "common.scaleDownIfDisabled" -}}
{{   if .Values.enabled }}
replicas: 1
{{   else }}
replicas: 0
{{   end }}
{{- end -}}


{{/*
Add LDAP information for DB2
*/}}
{{- define "common.db2LdapEnv" -}}
- name: LDAP_IMPL
  value: {{ .Values.global.IDENTITY_SERVER_TYPE }}
- name: LDAP_SERVER_URL
{{ if .Values.global.LDAP_SERVER_SSL }}
  value: ldaps://{{ .Values.global.LDAP_SERVER_HOST }}:{{ .Values.global.LDAP_SERVER_PORT }}
{{ else }}
  value: ldap://{{ .Values.global.LDAP_SERVER_HOST }}:{{ .Values.global.LDAP_SERVER_PORT }}
{{ end }}
- name: LDAP_SERVER_BINDDN
  value: {{ .Values.global.LDAP_SERVER_BINDDN | quote }}
- name: LDAP_USER_BASEDN
  value: {{ .Values.global.LDAP_SERVER_SEARCHBASE | quote }}
- name: LDAP_GROUP_BASEDN
  value: {{ .Values.global.LDAP_SERVER_SEARCHBASE | quote }}
- name: LDAP_USERID_ATTRIBUTE
  value: {{ .Values.global.LDAP_PROFILE_ID | quote }}
- name: LDAP_AUTHID_ATTRIBUTE
  value: {{ .Values.global.LDAP_PROFILE_ID | quote }}
- name: LDAP_GROUP_LOOKUP_ATTRIBUTE
  value: {{ .Values.global.LDAP_PROFILE_GROUPS | quote }}
- name: ENABLE_SSL
  value: {{ lower (.Values.global.LDAP_SERVER_SSL | quote) }}
- name: LDAP_SSL_PW
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-platform-secrets-env
      key: FCI_JKS_PASSWORD
{{- if and (ne .Values.global.IDENTITY_SERVER_TYPE "none") (ne .Values.global.IDENTITY_SERVER_TYPE "appid") }}
- name: LDAP_SERVER_BINDPW
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.externalSecretName }}
      key: LDAP_SERVER_BINDCREDENTIALS
{{- end }}
{{- end -}}

{{/*
Imports a secret into the pod from the secrets created by the pre-install job.
Used in templates as follows:
```
    env:
{{- include "common.import-secret (list . "name" "secret-category" "secret-key") | indent 6 }}
```

An example getting the db2 password:
```
    env:
{{- include "common.import-secret (list . "FLYWAY_PASSWORD" "db2" "DB2INST1_PASSWORD") | indent 6 }}
```

*/}}
{{- define "common.import-secret" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $env_name := (index $params 1) }}
  {{- $cat := (index $params 2) }}
  {{- $key_name := (index $params 3) }}
- name: {{ $env_name | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-%s-%s"  $root.Release.Name $cat "secrets-env" }}
      key: {{ $key_name | quote }}
{{- end -}}

{{- define "common.import-all-secrets" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $cat := (index $params 1) }}
- secretRef:
    name: {{ printf "%s-%s-%s" "fci" $cat "secrets-env" }}
{{- end -}}

{{- define "common.using-secrets" -}}
  {{- $params := . }}
  {{- range $key := $params }}
{{ printf "%s-%s-%s" "fci" $key "secrets-env" }}: "1"
  {{- end -}}
{{- end -}}
