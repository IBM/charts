{{- define "datagate.annotations" }}
cloudpakName: "IBM Cloud Pak for Data"
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
cloudpakInstanceId: "{{ .Values.zenCloudPakInstanceId }}"
productName: "Db2 Data Gate"
productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
productVersion: "1.1.1"
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: "ALL"
{{- end }}
