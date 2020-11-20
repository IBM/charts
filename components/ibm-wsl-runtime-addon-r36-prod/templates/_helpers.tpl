{{/* Generate Cloud Pak annotations */}}
{{- define "runtime_addon_r36.cloudpak_annotations" }}
    cloudpakName: {{ .Values.annotations.cloudpakName }}
    cloudpakId: {{ .Values.annotations.cloudpakId }}
    productCloudpakRatio: {{ .Values.annotations.productCloudpakRatio }}
    productMetric: {{ .Values.annotations.productMetric }}
    productChargedContainers: {{ .Values.annotations.productChargedContainers }}
    productID: {{ .Values.annotations.productID }}
    productName: {{ .Values.annotations.productName }}
    productVersion: {{ .Values.annotations.productVersion | quote }}
    hook.deactivate.cpd.ibm.com/command: "[]"
    hook.activate.cpd.ibm.com/command: "[]"
{{- end }}

{{- define "global.arch" }} {{- if eq .Values.global.currentModuleArch "x86_64" -}} amd64 {{- else }} {{- .Values.global.currentModuleArch -}} {{ end -}} {{ end -}}
