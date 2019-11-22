{{- define "db2wh.annotations" }}
productName: "Db2 Warehouse"
{{- if ( eq .Values.runtime "ICP4Data" ) }}
productID: "ICP4D-addon-Db2W_5725Z65"
{{- else }}
productID: "Db2W_5725Z65"
{{- end }}
productVersion: "11.5.1.0"
{{- end }}
