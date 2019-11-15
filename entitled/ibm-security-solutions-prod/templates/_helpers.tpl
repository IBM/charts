{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-security-solutions.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ibm-security-solutions.appName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ibm-security-solutions.replicas" -}}
{{- if .val.global.bindings }}
{{- with index .val.global.bindings .app }}
{{- if .replicas }}
    replicas: {{ .replicas }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "ibm-security-solutions.couch_db_instance" -}}
{{- if .val.global.bindings }}
{{- if index .val.global.bindings .app }}
{{- with index .val.global.bindings .app }}
    instance: couch-{{ .couchdbInstance | default "default" }}
{{- end }}
{{- else }}
    instance: couch-default
{{- end }}
{{- else }}
    instance: couch-default
{{- end }}
{{- end -}}

{{- define "ibm-security-solutions.couch_db_opts" -}}
{{- if .val.global.bindings }}
{{- if index .val.global.bindings .app }}
{{- with index .val.global.bindings .app }}
    instanceUser: {{ .couchdbInstanceUser | default "false" }}
{{- end }}
{{- else }}
    instanceUser: false
{{- end }}  
{{- else }}
    instanceUser: false
{{- end }}
{{- end -}}

{{- define "ibm-security-solutions.redis_init" }}
    - name: init redis for {{ .app }}
      operation: redis
      dependencies:
{{- if .val.global.bindings }}
{{- if index .val.global.bindings .app }}
{{- with index .val.global.bindings .app }}
      - redis-{{ .redis | default "default" }}
{{- end }}
{{- else }}
      - redis-default
{{- end }}  
{{- else }}
      - redis-default
{{- end }}
{{- end }}

{{- define "ibm-security-solutions.redis_dep" }}
{{- if .val.global.bindings }}
{{- if index .val.global.bindings .app }}
{{- with index .val.global.bindings .app }}
      - redis-{{ .redis | default "default" }}
{{- end }}
{{- else }}
      - redis-default
{{- end }}  
{{- else }}
      - redis-default
{{- end }}
{{- end }}

{{- define "ibm-security-solutions.etcd_init" }}
    - name: init etcd for {{ .app }}
      operation: etcd
      dependencies:
{{- if .val.global.bindings }}
{{- if index .val.global.bindings .app }}
{{- with index .val.global.bindings .app }}
      - etcd-{{ .etcd | default "default" }}
{{- end }}
{{- else }}
      - etcd-default
{{- end }}  
{{- else }}
      - etcd-default
{{- end }}
{{- end }}

{{- define "ibm-security-solutions.etcd_dep" }}
{{- if .val.global.bindings }}
{{- if index .val.global.bindings .app }}
{{- with index .val.global.bindings .app }}
      - etcd-{{ .etcd | default "default" }}
{{- end }}
{{- else }}
      - etcd-default
{{- end }}  
{{- else }}
      - etcd-default
{{- end }}
{{- end }}

{{- define "ibm-security-solutions.storage" }}
{{- if not .val.global.useDynamicProvisioning }}
    storageClass: ""
{{- else }}
{{- if .inst.installOptions.storageClass }}
    storageClass: {{ .inst.installOptions.storageClass }}
{{- end }}
{{- end }}
{{- end }}

{{- define "ibm-security-solutions.storageDefault" }}
{{- if not .Values.global.useDynamicProvisioning }}
    storageClass: ""
{{- end }}
{{- end }}
{{/*
Display license
*/}}
{{- define "ibm-security-solutions-prod.license" -}}
{{- $licenseName := .Values.global.licenseFileName -}}
{{- $license := .Files.Get $licenseName -}}
{{- $msg := "Please read the above license and set global.license=accept to install the product." -}}
{{- $border := printf "\n%s\n" (repeat (len $msg ) "=") -}}
{{- printf "\n%s\n\n\n%s%s%s" $license $border $msg $border -}}
{{- end -}}
