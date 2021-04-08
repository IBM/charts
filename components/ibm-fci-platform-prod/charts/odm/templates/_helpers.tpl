{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.ingress.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ingress"  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-secret"  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.oidc-client-id-secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-oidc-client-id-secret"  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.oidc-client-id-secret-value.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-oidc-client-id-secret-value"  | trunc 63 | trimSuffix "-" | b64enc | quote -}}
{{- end -}}

{{- define "odm.oidc-auth-secret.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-oidc-auth-secret"  | trunc 63 | trimSuffix "-" -}}
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

{{- define "odm.oidc-registration.fullname" -}}
{{- $name := default "odm-oidc-registration" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name "odm-oidc-registration" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.oidc-job-registration.fullname" -}}
{{- $name := default "odm-oidc-job-registration" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name "odm-oidc-job-registration" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.oidc-registration-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-oidc-registration-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.oidc-redirect-uris-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-oidc-redirect-uris-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.oidc-client-id.fullname" -}}
{{- $name := default "odm-oidc-client-id" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name "odm-oidc-client-id" | trunc 63 | trimSuffix "-" -}}
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

{{- define "odm.ds-runtime-xu-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-runtime-xu-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.dc-jvm-options-configmap.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dc-jvm-options-configmap" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm.default-network-policy.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-default-network-policy" | trunc 63 | trimSuffix "-" -}}
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

{{- define "odm-externaldatabase-security-secret-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-externaldatabase-security-secret-volume" | trunc 63 | trimSuffix "-" -}}
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

{{- define "odm-ds-runtime-xuconfigref-volume.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-runtime-xuconfigref-volume" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-dc-route.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dc-route" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-ds-console-route.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-console-route" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-ds-runtime-route.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-ds-runtime-route" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "odm-dr-route.fullname" -}}
{{- printf "%s-%s" .Release.Name "odm-dr-route" | trunc 63 | trimSuffix "-" -}}
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
Define Metering variable for Deployment
*/}}
{{- define "odm-metering-config" -}}
{{- if not (empty .Values.customization.usageMeteringSecretRef ) }}
- name: COM_IBM_RULES_METERING_ENABLE
  value: "true"
{{- end }}
{{- end }}
{{/*
Define database configuration for deployment
*/}}
{{- define "odm-db-config" -}}
- name: DB_TYPE
  value: "db2"
- name: DB_SERVER_NAME
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-db2
      key: db_host
- name: DB_PORT_NUMBER
  value: "50001"
- name: DB_NAME
  value: "FCIDB"
{{- include "common.import-secret" (list . "DB_PASSWORD" "db2" "db2_password") }}
- name: DB_USER
  valueFrom:
    configMapKeyRef:
      name: {{ .Release.Name }}-db2
      key: db_userid
{{- end -}}

{{- define "odm-additional-labels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ template "name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "odm-oidc-context" -}}
  {{- if .Values.oidc.enabled }}
- name: OPENID_CONFIG
  value: "true"
- name: OPENID_SERVER_URL
  value: "{{ .Values.oidc.serverUrl }}"
- name: OPENID_PROVIDER
  {{- if not (empty .Values.oidc.provider) }}
  value: "{{ .Values.oidc.provider }}"
  {{- else }}
  value: "ums"
  {{- end }}
- name: OPENID_ALLOWED_DOMAINS
  {{- if not (empty .Values.oidc.allowedDomains) }}
  value: "{{ .Values.oidc.allowedDomains }}"
  {{- else }}
  value: "*"
  {{- end }}
- name: OPENID_CLIENT_ID
  valueFrom:
    secretKeyRef:
      key: clientId
  {{- if not (empty .Values.oidc.clientRef) }}
      name: {{ .Values.oidc.clientRef }}
  {{- else }}
      name: {{ template "odm.oidc-client-id-secret.fullname" . }}
  {{- end }}
- name: OPENID_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      key: clientSecret
  {{- if not (empty .Values.oidc.clientRef) }}
      name: {{ .Values.oidc.clientRef }}
  {{- else }}
      name: {{ template "odm.oidc-client-id-secret.fullname" . }}
  {{- end }}
  {{- end }}
{{- end }}

{{- define "odm-dba-volumes-context" -}}
{{- if not (empty .Values.dba.rootCaSecretRef) }}
- name: root-ca
  secret:
    secretName: {{ .Values.dba.rootCaSecretRef }}
- name: tls-stores
  emptyDir: {}
{{- end }}
{{- if not (empty .Values.dba.ldapSslSecretRef) }}
- name: ldap-ssl-secret
  secret:
    secretName: {{ .Values.dba.ldapSslSecretRef }}
- name: ldap-trust-store
  emptyDir: {}
{{- end }}
{{- end -}}

{{- define "odm-dba-volumemounts-context" -}}
{{- if not (empty .Values.dba.rootCaSecretRef) }}
- name: tls-stores
  mountPath: /shared/tls
{{- end}}
{{- if not (empty .Values.dba.ldapSslSecretRef) }}
- name: ldap-trust-store
  mountPath: /config/security/ldap.jks
  subPath: truststore/jks/trusts.jks
{{- end}}
{{- end -}}

{{- define "odm-dba-production" -}}
{{- if not ( .Values.customization.deployForProduction) }}
- name: "DEPLOY_FOR_PRODUCTION"
  value: "FALSE"
{{- else }}
- name: "DEPLOY_FOR_PRODUCTION"
  value: "TRUE"
{{- end }}
{{- end -}}

{{- define "odm-dba-env-context" -}}
{{- if and (not (empty .Values.dba.passwordSecretRef )) (not (empty .Values.dba.rootCaSecretRef )) }}
- name: ROOTCA_KEYSTORE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.dba.passwordSecretRef }}
      key: sslKeystorePassword
- name: ROOTCA_TRUSTSTORE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.dba.passwordSecretRef }}
      key: sslTruststorePassword
{{- end }}
{{- if and (not (empty .Values.dba.passwordSecretRef )) (not (empty .Values.dba.ldapSslSecretRef )) }}
- name: LDAP_TRUSTSTORE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.dba.passwordSecretRef }}
      key: ldapSslTruststorePassword
{{- end }}
{{- end -}}

{{- define "odm-dba-context" -}}
{{- if not (empty .Values.dba.rootCaSecretRef)}}
- name: keytoolinit
  image: {{ .Values.dba.keytoolInitContainer.image }}
  {{- if (not (empty .Values.dba.keytoolInitContainer.imagePullPolicy )) }}
  imagePullPolicy: {{ .Values.dba.keytoolInitContainer.imagePullPolicy }}
  {{- else }}
  imagePullPolicy: "IfNotPresent"
  {{- end }}
  env:
    - name: CREATE_KEYPAIR
      value: "true"
    - name: KEYTOOL_ACTION
      value: "GENERATE-BOTH"
    - name: PRIVATE_LOGGING_ENABLED
      value: "false"
    {{- if (not (empty .Values.dba.passwordSecretRef )) }}
    - name: KEYSTORE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ .Values.dba.passwordSecretRef }}
          key: sslKeystorePassword
    {{- end }}
  volumeMounts:
    - name: root-ca
      mountPath: /shared/resources/cert-trusted
    - name: root-ca
      mountPath: /etc/predefined-ca
    - name: tls-stores
      mountPath: /shared/tls
{{ include "odm-security-context" . | indent 2 }}
  resources:
{{ toYaml .Values.decisionCenter.resources | indent 4 }}
{{- end }}
{{- if (not (empty .Values.dba.ldapSslSecretRef )) }}
- name: ldapsslkeytoolinit
  image: {{ .Values.dba.keytoolInitContainer.image }}
  {{- if (not (empty .Values.dba.keytoolInitContainer.imagePullPolicy )) }}
  imagePullPolicy: {{ .Values.dba.keytoolInitContainer.imagePullPolicy }}
  {{- else }}
  imagePullPolicy: "IfNotPresent"
  {{- end }}
  env:
    - name: KEYTOOL_ACTION
      value: "GENERATE-TRUSTSTORE"
    {{- if (not (empty .Values.dba.passwordSecretRef )) }}
    - name: KEYSTORE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ .Values.dba.passwordSecretRef }}
          key: ldapSslTruststorePassword
    {{- end }}
  volumeMounts:
    - name: ldap-trust-store
      mountPath: /shared/tls
    - name: ldap-ssl-secret
      mountPath: /shared/resources/cert-trusted
{{ include "odm-security-context" . | indent 2 }}
  resources:
{{ toYaml .Values.decisionCenter.resources | indent 4 }}
{{- end }}
{{- end -}}

{{- define "odm-pullsecret-spec" -}}
{{- if or (not (empty .Values.image.pullSecrets )) (not (empty .Values.dba.keytoolInitContainer.imagePullSecret )) }}
{{- if .Values.image.pullSecrets -}}
imagePullSecrets:
{{- if kindIs "string" .Values.image.pullSecrets }}
- name: {{ .Values.image.pullSecrets }}
{{- else -}}
{{- range .Values.image.pullSecrets }}
- name: {{ . }}
{{- end }}
{{- end }}
{{- end }}
{{- if (not (empty .Values.dba.keytoolInitContainer.imagePullSecret )) }}
- name: {{ .Values.dba.keytoolInitContainer.imagePullSecret }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "odm-serviceAccountName" -}}
{{- if .Values.serviceAccountName -}}
serviceAccountName: {{ .Values.serviceAccountName }}
{{- else -}}
serviceAccountName: {{ .Release.Name }}-common
{{- end }}
{{- end -}}

{{- define "odm-db-ssl-env-context" -}}
{{- include "common.import-secret" (list . "DB_SSL_TRUSTSTORE_PASSWORD" "platform" "FCI_JKS_PASSWORD") }}
{{- end }}

{{- define "odm-db-ssl-volumes-context" -}}
- name: {{ template "odm-externaldatabase-security-secret-volume.fullname" . }}
  secret:
    secretName: {{ .Release.Name }}-db2-truststore
    items:
      - key: truststore_file
        path: truststore.jks
{{- end}}

{{- define "odm-db-ssl-volumemounts-context" -}}
- name: {{ template "odm-externaldatabase-security-secret-volume.fullname" . }}
  mountPath: {{ template "odm-customdatasource-dir" . }}
{{- end}}

{{/*
Image tag or digest.

*/}}{{- define "image.tagOrDigest" -}}
{{- $tagTesting := default .root.Values.image.tag (.containerTag | quote) }}
{{- $tag := default .root.Values.image.tag .containerTag  }}
{{- if contains "sha256" $tagTesting -}}
image: {{ template "odm.repository.name" .root }}/{{ .containerName }}@{{ $tag }}
{{- else -}}
image: {{ template "odm.repository.name" .root }}/{{ .containerName }}:{{ $tag }}{{ template "platform" .root }}
{{- end -}}
{{- end }}

{{- define "odm-ingress-annotation-spec" -}}
annotations:
{{- range $key, $val := .Values.service.ingress.annotations }}
  {{- if kindIs "string" $val }}
  {{ $val -}}
   {{- else }}
  {{- range $mapKey, $mapValue := $val }}
  {{ $mapKey }}: {{ $mapValue -}}
{{ end -}}
  {{ end -}}
  {{ end -}}
{{- end -}}
