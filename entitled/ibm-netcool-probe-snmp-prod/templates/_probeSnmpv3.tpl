{{/*
Generate a list if users for snmp v3 security
*/}}
{{- define "snmpv3users" -}}
{{- range $index, $user :=  . -}}
{{- if .name }}
createUser {{- if .authEngineIdentifier }} -e {{.authEngineIdentifier}}{{end}} {{ .name }}{{ if .authEncryptionMethod }} {{ .authEncryptionMethod }}{{end}}{{ if .authEncryptionPassword }} {{.authEncryptionPassword }}{{end}}{{ if .privacyEncryptionMethod }} {{ .privacyEncryptionMethod }}{{end}}{{if .privacyEncryptionPassword}} {{ .privacyEncryptionPassword }}{{end}}
{{- end -}}
{{- end }}  
{{- end -}}
