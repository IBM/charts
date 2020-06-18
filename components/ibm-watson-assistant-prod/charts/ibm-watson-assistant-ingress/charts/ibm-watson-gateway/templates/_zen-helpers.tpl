{{- define "gateway.common.service.name" -}}
{{ include "gateway.id" . }}-gw-common
{{- end -}}

{{- define "gateway.common.service.fullDNSName" -}}
  {{- $service := ( include "gateway.common.service.name" . ) -}}
  {{- printf "%s.%s.svc.%s:%.0f" $service .Release.Namespace (tpl .Values.clusterDomain . ) .Values.addonService.port -}}
{{- end -}}

{{- define "gateway.common.path" -}}
  {{- printf "/watson/%s%s" "common" (include "gateway.routing.basePath" . ) -}}
{{- end -}}

{{- define "gateway.common.service.yaml" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "gateway.common.service.name" . | quote }}
  labels:
{{ include "sch.metadata.labels.standard" (list . "gw-common-service") | indent 4 }}
  annotations:
    prometheus.io/scrape: 'true'
spec:
  ports:
  - port: {{ .Values.addonService.port }}
    targetPort: {{ .Values.addonService.image.containerPort }}
  selector:
{{- $comp := "gw-deployment" }}
{{ printf "%s: %s" "app.kubernetes.io/component" ( $comp | quote ) | indent 4 }}
{{ printf "%s: %s" "app.kubernetes.io/instance" ( .Release.Name | quote ) | indent 4 }}
{{- end -}}

{{- define "gateway.metaOverride" -}}
  {{- if and (hasKey .Values.addon "overridePath" ) (.Values.addon.overridePath) }}
    {{- .Values.addon.overridePath }}
  {{- else }}
    {{- include "gateway.common.path" . }}
  {{- end -}}
{{- end -}}


{{- define "gateway.addon.json" -}}
{{- $svcName := include "gateway.get-name-or-use-default" (list . "gateway-svc") -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: "{{ include "gateway.id" . }}"
  namespace: {{ include "gateway.addonService.zenNamespace" . }}
  labels:
    icpdata_addon_version: "{{ include "gateway.version" . }}"
    icpdata_addon: "true"
    supports_deployments: "true"
{{- include "sch.metadata.labels.standard" (list . "addon" ) | nindent 4 }}
data:
  add-ons.json: |
    {
    "{{ include "gateway.id" . }}": {
      "access_management_enable": true,
      "category": "ai",
      "add_on_type": "application",
      "details": {
        "short_description": "{{ include "gateway.shortDescription" . }}",
        "long_description": "{{ include "gateway.longDescription" . }}",
        "deploy_docs": "{{ include "gateway.deployDocs" . }}",
        "product_docs": "{{ include "gateway.productDocs" . }}",
        "iconURL": "{{ include "gateway.metaOverride" . }}/images/icons/{{ .Values.addon.serviceId }}.svg",
        "images": [
        {{- $numImages := .Values.addon.productImages | int }}
        {{- range $k, $v := until $numImages }}
          "{{ include "gateway.metaOverride" $ }}/images/{{ $.Values.addon.serviceId }}/{{ $k }}.png"{{- if ne $k (sub $numImages 1) -}},{{- end }}
        {{- end }}
        ],
        "service_provider_url": "https://{{ include "sch.names.fullCompName" (list . $svcName) }}.{{ .Release.Namespace}}:{{ .Values.addonService.port}}",
        "provisionURL" : "{{ include "gateway.common.path" . }}/",
        "accessManagementURL": "{{ include "gateway.common.path" . }}/users",
        "serviceDetailsURL": "{{ include "gateway.common.path" . }}",
        "premium": true
      },
      "display_name": "{{ include "gateway.displayName" . }}",
      "extensions":{},
      "supports_deployments": true,
      "max_instances": "{{ .Values.addon.maxInstances }}",
      "vendor": "IBM",
      "versions": {
        "{{ include "gateway.version" . }}" : {
        "description": "{{ include "gateway.shortDescription" . }}",
        "helm_location": null,
        "state": "installed",
        "details": {}
        }
      }
      }
    }
  nginx.conf: |
    # Routing for common "{{ include "gateway.id" . }}" paths
    
    # Custom error page returning JSON
    location @auth_error_json {
        default_type application/json;
        return 401 '{"code": "NotAuthorized", "message": "Access is denied due to invalid credentials"}';
    }

    # Redirect for unauthorized UI requests
    location @ui_redirect {
        add_header Set-Cookie "__preloginurl__=$scheme://$http_host$request_uri;Path=/";
        return 302 $scheme://$http_host/auth/login/sso;
    }

    # Redirects /gateway to /gateway/
    location = {{ include "gateway.common.path" . }} {
      return 301 $scheme://$http_host{{ include "gateway.routing.basePath" . }}/;
    }

    # Handles shared /gateway/ requests like icon, images, RC, GC and account mock API calls
    # proxy the requests to the gateway's k8s service
    location ~ {{ include "gateway.common.path" . }}/(^$|.*)$ {
      set $trail $1;
      set $svc "https://{{ include "gateway.common.service.fullDNSName" . }}";
{{ include "gateway.cors" . | indent 6 }}
      access_by_lua_file /nginx_data/checkjwt.lua;
      proxy_set_header  Host $host:$server_port;
      proxy_set_header  X-Real-IP $remote_addr;
      proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header  X-Forwarded-Proto $scheme;
      proxy_pass $svc/$trail$is_args$args;
    }

    # Validates that the user has access to the instance and set the X-Watson-UserInfo
    location = {{ include "gateway.common.path" . }}/auth {
      internal;
      proxy_pass_request_body off;
      proxy_set_header  Content-Length "";
      proxy_set_header  X-Original-URI $request_uri;
      proxy_pass        https://{{ include "gateway.common.service.fullDNSName" . }}/api/auth;
    }

{{- end -}}
