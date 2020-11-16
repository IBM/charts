{{- define "dg.addOnLevelLabels" -}}
icpdsupport/addOnId: dg
icpdsupport/assemblyName: datagate
{{- end }}

{{- define "dg.addOnInstanceLabels" -}}
icpdsupport/serviceInstanceId: "{{ .Values.zenServiceInstanceId | int64 }}"
icpdsupport/createdBy: "{{ .Values.zenServiceInstanceUID | int64 }}"
icpd-addon/status: "{{ .Values.zenServiceInstanceId | int64 }}"
{{- end }}
