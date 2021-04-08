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
icpdsupport/addOnId: {{ $release }}
icpdsupport/app: {{ $release }}
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
Metering Annotations for CP4D
*/}}
{{- define "common.meteringAnnotations" -}}
productName: "IBM Financial Crimes Insight Entity Research Software"
productID: "1ae8c6d21f7f4c77ac277d693ad2ca88"
productVersion: "6.6.0"
productMetric: "RESOURCE_VALUE_UNIT"
productChargedContainers: "All"
cloudpakId: "1ae8c6d21f7f4c77ac277d693ad2ca88"
cloudpakName: "IBM Cloud Pak for Data"
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
  initialDelaySeconds: 60
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
        {{- range $val := .Values.archs }}
        - {{ $val | quote }}
        {{- end }}
{{- end -}}

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
Create the initialize-pv string required for a given pod.

call like this:
{{ template "common.init-pv" dict "release" .Release.Name "initContainer" "init-pv" "app" "common-scripts" "archive" "fci-common-scripts-data.tar.gz" }}

*/}}
{{- define "common.init-pv" -}}
./initialize-pv -p "$(kubectl get pod -l app={{ $.app }},release={{ $.release }}  | grep -v Terminating | grep -v NAME | awk '{print $1}' | head -1)" -i {{ $.initContainer }} -t __DATA_FILE_ARCHIVE_DIRECTORY__/{{ $.archive }}
{{- end -}}
{{- define "common.init-pv-db2" -}}
./initialize-pv -p "$(kubectl get pod -l statefulset.kubernetes.io/pod-name={{ $.app }},release={{ $.release }}  | grep -v Terminating | grep -v NAME | awk '{print $1}' | head -1)" -i {{ $.initContainer }} -t __DATA_FILE_ARCHIVE_DIRECTORY__/{{ $.archive }}
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
      name: {{ .Release.Name }}-security-auth
      key: LDAP_SERVER_BINDCREDENTIALS
{{- end }}
{{- end -}}
 */}}

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
      name: {{ printf "%s-%s-%s"  ($root.Values.global.coreReleaseName) $cat "secrets-env" }}
      key: {{ $key_name | quote }}
{{- end -}}
