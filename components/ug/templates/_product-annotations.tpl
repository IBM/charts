{{- define "product-metering" }}
productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
productName: "IBM Watson Knowledge Catalog for IBM Cloud Pak for Data"
productVersion: "3.5.1"
productMetric: "VIRTUAL_PROCESSOR_CORE"
productChargedContainers: "All"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
cloudpakInstanceId: "{{ .Values.global.cloudpakInstanceId }}"
productCloudpakRatio: "1:1"
{{- end }}
