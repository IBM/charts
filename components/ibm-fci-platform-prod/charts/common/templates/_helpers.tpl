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
productID: "5f0d47196a954c5cb0985241f28ac577"
productVersion: "6.6.0"
productMetric: "INSTALL"
productChargedContainers: "All"
cloudpakId: "5f0d47196a954c5cb0985241f28ac577"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakInstanceId: "{{ .Values.global.cloudpakInstanceId }}"
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
