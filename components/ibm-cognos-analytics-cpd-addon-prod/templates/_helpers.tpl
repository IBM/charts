{{- define "addon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "addon.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name based on old chart name (CP4D upgrade compatibility).
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "addon.oldchartfullname" -}}
{{- if .Values.oldChartFullnameOverride -}}
{{- .Values.oldChartFullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.oldChartNameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "addon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the pvc name for addon. This pvc is shared by service provider chart to access helm package and store instance information
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "addon-pvc.name" -}}
{{- $instanceid := default "97-000000000-79" .Values.global.cloudpakInstanceId -}}
{{- printf "ca%s-%s" $instanceid "addon-data" | trunc 48 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create labels required by CPD.
*/}}
{{- define "addon.cpd.labels" -}}
{{- if semverCompare "< 3.5.0" .Values.global.buildff.dependency.cpd_version -}}
{{- else -}}
icpdsupport/addOnId: "cognos-analytics-app"
icpdsupport/app: "cognos-analytics"
{{- end -}}
{{- end -}}

{{/*
Create annotations required by CPD.
*/}}
{{- define "addon.cpd.annotations" -}}
{{- if semverCompare "< 3.5.0" .Values.global.buildff.dependency.cpd_version -}}
productName: "IBM Cloud Pak for Data Cognos Analytics Advanced"
productID: ed38a4bc92be42e98a3d1dcdfad529e0
productVersion: 11.1.7
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: All
productCloudpakRatio: "1:1"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakId: eb9998dcc5d24e3eb5b6fb488f750fe2
cloudpakVersion: {{ print .Values.global.buildff.dependency.cpd_version }}
{{- else -}}
{{- $instanceid := default "97-000000000-79" .Values.global.cloudpakInstanceId -}}
productName: "IBM Cognos Analytics Extension for IBM Cloud Pak for Data"
productID: 5c92123b253a492780e6c6d4fe151d57
productVersion: 11.1.7
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: All
productCloudpakRatio: "1:1"
cloudpakName: "IBM Cognos Analytics Extension for IBM Cloud Pak for Data"
cloudpakId: 5c92123b253a492780e6c6d4fe151d57
cloudpakInstanceId: {{ print $instanceid | quote }}
{{- end -}}
{{- end -}}
