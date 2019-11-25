{{- define "db2oltp.annotations" }}
productName: "Db2 Advanced Edition"
{{- if ( eq .Values.runtime "ICP4Data" ) }}
productID: "ICP4D-addon-5725-L47"
{{- else }}
productID: "5725-L47"
{{- end }}
productVersion: "11.5.1.0"
{{- end }}
