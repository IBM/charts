{{- define "db2oltp.annotations" }}
productName: "Db2 Advanced Edition"
productID: "5737-K73"
productVersion: "11.5.2.0"
cloudpakName: "{{ .Values.global.cloudpakName }}"
cloudpakId: "{{ .Values.global.cloudpakId }}"
cloudpakVersion: "{{ .Values.global.cloudpakVersion }}"
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: "All"
{{- end }}

{{- define "uc.annotations" }}
productName: "Db2 Advanced Edition"
productID: "5737-K73"
productVersion: "11.5.2.0"
cloudpakName: "{{ .Values.global.cloudpakName }}"
cloudpakId: "{{ .Values.global.cloudpakId }}"
cloudpakVersion: "{{ .Values.global.cloudpakVersion }}"
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: "All"
{{- end }}