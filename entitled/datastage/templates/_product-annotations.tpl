{{- define "ds-product-metering" }}
productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
productName: "IBM DataStage Enterprise Plus for Cloud Pak for Data"
productVersion: "11.7.1.1"
productMetric: "VIRTUAL_PROCESSOR_CORE"
productCloudpakRatio: "1:1"
productChargedContainers: "All"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
premium: "true"
cloudpakInstanceId: {{ $.Values.global.cloudpakInstanceId }}
{{- end }}

{{- define "ds.pod.labels" }}
icpdsupport/addOnId: "dfd"
icpdsupport/app: {{ include "sch.names.appName" ( list .) | quote}}
{{- end -}}

{{- define "ds.cpdbr.annotations" }}
hook.deactivate.cpd.ibm.com/command: '[]'
hook.activate.cpd.ibm.com/command: '[]'
{{- end -}}
