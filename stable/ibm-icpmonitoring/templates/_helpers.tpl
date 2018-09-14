{{/* vim: set filetype=mustache: */}}

{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{- /*
"sch.version" contains the version information and tillerVersion constraint
for this version of the Shared Configurable Helpers.
*/ -}}
{{- define "sch.version" -}}
version: "1.2.0"
tillerVersion: ">=2.7.0"
{{- end -}}


{{/*
Create a default fully qualified app name for monitoring.
*/}}
{{- define "monitoring.fullname" -}}
{{- $name := default "monitoring" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for prometheus.
*/}}
{{- define "prometheus.fullname" -}}
{{- $name := default "prometheus" .Values.prometheusNameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for grafana.
*/}}
{{- define "grafana.fullname" -}}
{{- $name := default "grafana" .Values.grafanaNameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a user name for grafana.
*/}}
{{- define "grafana.user" -}}
{{- $name := default "admin" .Values.grafana.user -}}
{{- printf $name | b64enc -}}
{{- end -}}

{{/*
Create a password for grafana.
*/}}
{{- define "grafana.password" -}}
{{- $defaultName := randAlphaNum 10 -}}
{{- $name := default $defaultName .Values.grafana.password -}}
{{- printf $name | b64enc -}}
{{- end -}}

{{- define "router.nginx.config" -}}
    {{- $params := . -}}
    {{- $list := first $params -}}
    {{- $port := (index $params 0) -}}
    {{- $listen := (index $params 1) -}}
    {{- $caCert := (index $params 2) -}}
        error_log stderr notice;

        events {
            worker_connections 1024;
        }

        http {
            access_log off;

            default_type application/octet-stream;
            sendfile on;
            keepalive_timeout 65;

            # Without this, cosocket-based code in worker
            # initialization cannot resolve localhost.

            upstream metrics {
                server 127.0.0.1:{{- $port -}};
            }
            
            proxy_cache_path /tmp/nginx-mesos-cache levels=1:2 keys_zone=mesos:1m inactive=10m;

            server {
                listen {{ $listen }} ssl default_server;
                ssl_certificate server.crt;
                ssl_certificate_key server.key;
                ssl_client_certificate /opt/ibm/router/caCerts/{{- $caCert -}};
                ssl_verify_client on;
                ssl_protocols TLSv1.2;
                # Ref: https://github.com/cloudflare/sslconfig/blob/master/conf
                # Modulo ChaCha20 cipher.
                ssl_ciphers EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:!EECDH+3DES:!RSA+3DES:!MD5;
                ssl_prefer_server_ciphers on;

                server_name dcos.*;
                root /opt/ibm/router/nginx/html;

                location / {
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header Host $http_host;
                  proxy_pass http://metrics/;
                }

            }
        }
{{- end -}}


