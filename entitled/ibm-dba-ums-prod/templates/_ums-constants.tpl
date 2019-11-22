{{/* User Management Service constants */}}

{{/* User Management Service Pod Security Context */}}
{{- define "ums.constants.pod.securityContext" -}}
hostNetwork: false
hostPID: false
hostIPC: false
{{- end -}}

{{/* User Management Service Container Security Context */}}
{{- define "ums.constants.container.securityContext" -}}
privileged: false
readOnlyRootFilesystem: false
allowPrivilegeEscalation: false
runAsNonRoot: true
{{- if eq .Values.global.isOpenShift false }}
runAsGroup: 0
runAsUser: 50001
{{- end }}
capabilities:
  drop:
  - ALL
{{- end -}}

{{/* User Management Service ingress paths*/}}
{{- define "ums.constants.ingress.endpoints" -}}
paths:
- name: OpenID Connect (OIDC) 1.0 endpoints
  prefix: /oidc
  extension: /endpoint/ums/{service}
  description: where {service} is "authorize", "introspect", "registration", "token", "userinfo", and others
- name: Open Authorization (OAuth) 2.0 endpoints
  prefix: /oauth2
  extension: /endpoint/oidcOAuthProvider/{service}
  description: where {service} is "authorize" or "token"
- name: System for Cross-domain Identity Management (SCIM) 1.1 resources
  prefix: /ibm/api/scim
  extension: /{resource}
  description: where {resource} is "Users" or "Groups"
- name: User Management Service (UMS) user interface
  prefix: /ums
  extension: /{page}
  description: where {page} is "welcome.jsp" (default) or "login.jsp"
- name: Team Server API
  prefix: /teamserver
  extension: /{route}
  description: where {route} is a valid Team Server API
- name: User Management Service (UMS) OpenAPI specification
  prefix: /ibm/api
  extension: /explorer
  description: Main API specification endpoint
- name: User Management Service (UMS) OpenAPI specification
  prefix: /api
  extension: /explorer
  description: Secondary API specification endpoint
{{- end -}}

{{/* User Management Service service */}}
{{- define "ums.constants.service.portname" -}}https{{- end -}}
{{- define "ums.constants.service.port" -}}9443{{- end -}}

{{/* User Management Service container */}}
{{- define "ums.constants.container.portname" -}}https{{- end -}}
{{- define "ums.constants.container.port" -}}9443{{- end -}}

{{/* User Management Service OAuth database */}}
{{- define "ums.constants.oauth.database.properties" -}}
  {{- $dbtype := (.Values.oauth.database.type | default "unknown") -}}
  {{- if eq $dbtype "db2" -}}properties.db2.jcc{{- end -}}
  {{- if eq $dbtype "mssql" -}}properties.microsoft.sqlserver{{- end -}}
  {{- if eq $dbtype "oracle" -}}properties.oracle{{- end -}}
{{- end -}}

{{- define "ums.constants.oauth.database.driverType" -}}
  {{- $dbtype := (.Values.oauth.database.type | default "unknown") -}}
  {{- if eq $dbtype "db2" -}}"4"{{- end -}}
  {{- if eq $dbtype "mssql" -}}"4"{{- end -}}
  {{- if eq $dbtype "oracle" -}}"thin"{{- end -}}
{{- end -}}

{{/* User Management Service Team Server database */}}
{{- define "ums.constants.ts.database.properties" -}}
  {{- $dbtype := (.Values.teamserver.database.type | default "unknown") -}}
  {{- if eq $dbtype "db2" -}}properties.db2.jcc{{- end -}}
  {{- if eq $dbtype "mssql" -}}properties.microsoft.sqlserver{{- end -}}
  {{- if eq $dbtype "oracle" -}}properties.oracle{{- end -}}
{{- end -}}

{{- define "ums.constants.ts.database.driverType" -}}
  {{- $dbtype := (.Values.teamserver.database.type | default "unknown") -}}
  {{- if eq $dbtype "db2" -}}"4"{{- end -}}
  {{- if eq $dbtype "mssql" -}}"4"{{- end -}}
  {{- if eq $dbtype "oracle" -}}"thin"{{- end -}}
{{- end -}}

{{- define "ums.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- if kindIs "string" .Values.global.imagePullSecrets }}
- name: {{ .Values.global.imagePullSecrets }}
{{- else }}
{{- range .Values.global.imagePullSecrets }}
- name: {{ . }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
