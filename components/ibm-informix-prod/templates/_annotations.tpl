{{- define "informix.annotations" }}
productName: "Informix Enterprise Edition"
{{- if ( eq .Values.runtime "ICP4D" ) }}
productID: "ICP4D-addon-5737-N11"
{{- else }}
productID: "d3c53358d507405b9909087b9bc4c3c4"
{{- end }}
productVersion: "14.10.4"
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: "All"
cloudpakId: "{{ .Values.global.cloudpakId }}"
cloudpakName: "{{ .Values.global.cloudpakName }}"
cloudpakVersion: "{{ .Values.global.cloudpakVersion }}"
{{- end }}
