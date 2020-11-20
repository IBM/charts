{{- define "db2wh.annotations" }}
{{- if (eq "db2wh" .Values.dbType) }}
productName: "IBM Db2 Warehouse"
{{- else if (eq "db2oltp" .Values.dbType) }}
productName: "IBM Db2"
{{- else if (eq "db2aaservice" .Values.dbType) }}
productName: "IBM Cloud Pak for Data Common Database Services"
{{- else if (eq "db2eventstore" .Values.dbType) }}
productName: "IBM Db2 Event Store"
{{- else if (eq "mongodb" .Values.dbType) }}
productName: "IBM Data Management Platform for MongoDB Enterprise Advanced"
{{- else }}
productName: "{{ .Values.dbType }} catalog"
{{- end }}
productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
productVersion: "3.5.0"
cloudpakName: "IBM Cloud Pak for Data"
cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
cloudpakInstanceId: "{{ .Values.global.cloudpakInstanceId  }}"
productChargedContainers: "All"
productMetric: "VIRTUAL_PROCESSOR_CORE"
{{- end }}
