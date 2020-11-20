{{/* Generate Cloud Pak annotations */}}
{{- define "notebooks.cloudpak_annotations" }}
    cloudpakName: IBM Cloud Pak for Data
    cloudpakId: eb9998dcc5d24e3eb5b6fb488f750fe2
    cloudpakInstanceId: {{ .Values.global.cloudpakInstanceId }} 
    productCloudpakRatio: "1:1" 
    productMetric: VIRTUAL_PROCESSOR_CORE
    productChargedContainers: All
    productID: eb9998dcc5d24e3eb5b6fb488f750fe2
    productName: IBM Watson Studio
    productVersion: "3.5.0"
    hook.deactivate.cpd.ibm.com/command: "[]"
    hook.activate.cpd.ibm.com/command: "[]"
{{- end }}

{{/* Generate basic labels */}}
{{- define "notebooks.deployment_labels" }}
    app.kubernetes.io/managed-by: {{.Release.Service | quote }}
    app.kubernetes.io/instance: {{.Release.Name | quote }}
    app.kubernetes.io/name: "ax-{{ .Values.deployAppName }}-deploy"
    helm.sh/chart: {{.Chart.Name}}-{{.Chart.Version | replace "+" "_" }}
    generator: "helm"
    date: {{ now | htmlDate | quote }}
    appversion: {{ .Chart.AppVersion | quote }}
    wdp-service: "notebooks"
    heritage: tiller
    chart: "{{ .Chart.Name }}"
    app: notebooks
    release: "{{ .Release.Name }}"
{{- end }}

{{/* Generate basic labels */}}
{{- define "notebooks.pod_labels" }}
    app.kubernetes.io/managed-by: {{.Release.Service | quote }}
    app.kubernetes.io/instance: {{.Release.Name | quote }}
    app.kubernetes.io/name: {{ .Values.deployAppName | quote }}
    helm.sh/chart: {{.Chart.Name}}-{{.Chart.Version | replace "+" "_" }}
    wdp-service: "notebooks"
    heritage: tiller
    chart: "{{ .Chart.Name }}"
    release: "{{ .Release.Name }}"
    icpdsupport/addOnId: "ws"
{{- end }}

{{- define "global.arch" }} {{- if eq .Values.global.currentModuleArch "x86_64" -}} amd64 {{- else }} {{- .Values.global.currentModuleArch -}} {{ end -}} {{ end -}}
