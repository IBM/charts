{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "ibm-hdm-common-ui.ui-server.environment" -}}
env:
  - name: LICENSE
    value: "{{ .Values.global.license }}"
  - name: PORT
    value: "8080"
  - name: SECUREPORT
    value: "8443"
  - name: PUBLICURL
    value: {{ include "ibm-hdm-common-ui.ingress.baseurl" . | quote }}
  - name: AUTHENTICATION_MODE
    value: {{ .Values.authentication.mode | quote }}
  - name: TLS__CERTIFICATE
    value: /internal-tls-keys/tls.crt
  - name: TLS__KEY
    value: /internal-tls-keys/tls.key
  - name: SESSION__SECRET
    valueFrom:
      secretKeyRef:
        name: {{ include "sch.names.fullCompName" (list . "session-secret") | quote }}
        key: session
  - name: NODE_TLS_REJECT_UNAUTHORIZED
    value: "0"
  - name: CLIENTCONFIGURATION
    value: "services:hdm_noi:tenantid"
{{ include "ibm-hdm-common-ui.ui-server.environment.auth.was" . | indent 2 }}
{{ include "ibm-hdm-common-ui.ui-server.environment.auth.cem" . | indent 2 }}
{{ include "ibm-hdm-common-ui.ui-server.environment.dashci" . | indent 2 }}
{{ include "ibm-hdm-common-ui.ui-server.environment.services" . | indent 2 }}
{{- end -}}

{{- define "ibm-hdm-common-ui.ui-server.environment.auth.was" -}}
  {{- $wasConfig := .Values.authentication.was -}}
  {{- $authzTemplate := "%s/ibm/console" -}}
  {{- $userinfoTemplate := "https://%s-webgui:16311/ibm/console/dashauth/DASHUserAuthServlet" -}}

  {{- if eq .Values.authentication.mode "was" -}}
- name: WASAUTH__AUTHORIZATION_ENDPOINT
  value: {{ include "ibm-hdm-common-ui.getingressurl" (list . $wasConfig.authorizationEndpoint $wasConfig.ingressUrl $authzTemplate) }}
- name: WASAUTH__USERINFO_ENDPOINT
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $wasConfig.userinfoEndpoint $wasConfig.releaseName $userinfoTemplate) | quote }}
  {{- end -}}
{{- end -}}

{{- define "ibm-hdm-common-ui.ui-server.environment.auth.cem" -}}
  {{- $cemConfig := .Values.authentication.cem -}}
  {{- $issuerTemplate := "https://%s-cem-users:6002" -}}
  {{- $usersApiTemplate := printf "%s/api" $issuerTemplate -}}
  {{- $tokenTemplate := printf "%s/authprovider/v1/token" $usersApiTemplate -}}
  {{- $userinfoTemplate := printf "%s/usermgmt/v1/userinfo" $usersApiTemplate -}}
  {{- $userinfoTenantTemplate := printf "%s/usermgmt/v1/tenants/{tenantId}/userinfo" $usersApiTemplate -}}

  {{- $authorizationUrl := printf "%susers/api/authprovider/v1/authorize" (include "ibm-hdm-common-ui.ingress.baseurl" .) -}}

  {{- if eq .Values.authentication.mode "openid-cem" -}}
- name: SERVICES__HDM_CEMUSERS__URL
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $cemConfig.apiEndpoint $cemConfig.releaseName $usersApiTemplate) | quote }}
- name: OPENID__ISSUER__ISSUER
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $cemConfig.issuer $cemConfig.releaseName $issuerTemplate) | quote }}
- name: OPENID__ISSUER__TOKEN_ENDPOINT
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $cemConfig.tokenEndpoint $cemConfig.releaseName $tokenTemplate) | quote }}
- name: OPENID__ISSUER__USERINFO_ENDPOINT
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $cemConfig.userinfoEndpoint $cemConfig.releaseName $userinfoTemplate) | quote }}
- name: OPENID__ISSUER__TENANT_USERINFO_ENDPOINT
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $cemConfig.userinfoTenantEndpoint $cemConfig.releaseName $userinfoTenantTemplate) | quote }}
- name: OPENID__ISSUER__AUTHORIZATION_ENDPOINT
  value: {{ $authorizationUrl | quote }}
  {{- else -}}
- name: SERVICES__HDM_CEMUSERS__URL
  value: '-'
  {{- end -}}
{{- end -}}

{{- define "ibm-hdm-common-ui.ui-server.environment.dashci" -}}
  {{- $dashConfig := .Values.dash.consoleIntegration -}}
  {{- $urlTemplate := "https://%s-webgui:16311" -}}

  {{- if $dashConfig.enabled -}}
- name: DASHFEDERATION__ENABLED
  value: "true"
- name: DASHFEDERATION__CI__DASH_ENDPOINT
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $dashConfig.host $dashConfig.releaseName $urlTemplate) | quote }}
- name: DASHFEDERATION__CI__ADMIN_USERNAME
  value: {{ $dashConfig.username | quote }}
- name: DASHFEDERATION__CI__ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ tpl $dashConfig.passwordSecret . | quote }}
      key: WAS_PASSWORD
      optional: {{ $dashConfig.passwordOptional }}
- name: DASHFEDERATION__CI__API_ENDPOINT
  value: {{ printf "https://%s:8443" (include "sch.names.fullCompName" (list . "uiserver")) | quote }}
- name: DASHFEDERATION__CI__INTEGRATION_ID
  value: {{ $dashConfig.integrationId | quote }}
  {{- end -}}
{{- end -}}

{{- define "ibm-hdm-common-ui.ui-server.environment.services" -}}
  {{- $services := merge .Values.services .Values.global.integrations -}}
  {{- $webguiUrlTemplate := "https://%s-webgui:16311/ibm/console/webtop" -}}
  {{- $eauiapiUrlTemplate := "http://%s-ibm-ea-ui-api-graphql:8080/graphql" -}}
  {{- $dashUrlTemplate := "https://%s-webgui:16311" -}}
  {{- $wasConfig := .Values.authentication.was -}}
  {{- $userinfoTemplate := "%s-webgui:16311" -}}
  {{- $asmuiapiUrlTemplate := "https://%s-ui-api:3080" -}}
  {{- $asmSecretTemplate := "%s-asm-credentials" -}}

- name: SERVICES__HDM_NOI_WEBGUI__URL
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $services.webgui.url $services.webgui.releaseName $webguiUrlTemplate) | quote }}
- name: SERVICES__HDM_EA_UIAPI__URL
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $services.eauiapi.url $services.eauiapi.releaseName $eauiapiUrlTemplate) | quote }}
- name: SERVICES__HDM_NOI_DASH__URL
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $services.dash.url $services.dash.releaseName $dashUrlTemplate) | quote }}
- name: SERVICES__HDM_ASM_UI_API__URL
{{ if and .Values.global.integrations.asm.enabled .Values.global.integrations.asm.onPremSecureRemote.enabled }}
  value: {{ ( printf "https://%s:%s"  $services.asm.onPremSecureRemote.remoteHost $services.asm.onPremSecureRemote.uiApiPort ) | quote }}
{{ else }}
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $services.asm.uiApiUrl $services.asm.releaseName $asmuiapiUrlTemplate) | quote }}
{{ end }}
  {{ if or $services.asm.useDefaultAsmCredentialsSecret $services.asm.asmCredentialsSecret }}
- name: SERVICES__HDM_ASM_UI_API__USERNAME
  valueFrom:
    secretKeyRef:
    {{ if and .Values.global.integrations.asm.enabled .Values.global.integrations.asm.onPremSecureRemote.enabled }}
      name: "external-asm-proxy-client"
    {{ else }}
      name: {{ include "ibm-hdm-common-ui.geturl" (list . $services.asm.asmCredentialsSecret $services.asm.releaseName $asmSecretTemplate) | quote }}
    {{ end }}
      key: username
      optional: true
- name: SERVICES__HDM_ASM_UI_API__PASSWORD
  valueFrom:
    secretKeyRef:
    {{ if and .Values.global.integrations.asm.enabled .Values.global.integrations.asm.onPremSecureRemote.enabled }}
      name: "external-asm-proxy-client"
    {{ else }}
      name: {{ include "ibm-hdm-common-ui.geturl" (list . $services.asm.asmCredentialsSecret $services.asm.releaseName $asmSecretTemplate) | quote }}
    {{ end }}
      key: password
      optional: true
  {{ end }}
- name: SERVICES__HDM_NOI__TENANTID
  {{ if .Values.global.common.eventanalytics.tenantId }}
  value: {{ .Values.global.common.eventanalytics.tenantId | quote }}
  {{- else -}}
    {{- /* Right now, the tenant id defaults to the hostname and port of DASH */ -}}
  value: {{ include "ibm-hdm-common-ui.geturl" (list . $wasConfig.userinfoEndpoint $wasConfig.releaseName $userinfoTemplate) | quote }}
  {{- end -}}

{{- end -}}
