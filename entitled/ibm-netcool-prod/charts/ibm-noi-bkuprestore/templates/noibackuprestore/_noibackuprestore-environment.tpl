{{- /*
Creates the environment for the noi backuprestore service
*/ -}}
{{- define "ibm-noi-bkuprestore.noibackuprestore.environment" -}}

env:
  - name: LICENSE
    value: {{ .Values.global.license | quote }}
  - name: LOGGING_LEVEL
    value: "INFO"
  - name: username
{{- if .Values.noibackuprestore.systemuser }}
    value: "{{ .Values.noibackuprestore.systemuser }}"
{{- else }}
    valueFrom:
      secretKeyRef:
        name: {{ .Release.Name }}-systemauth-secret
        key: username
{{- end }}
  - name: password
{{- if .Values.noibackuprestore.systempassword }}
    value: "{{ .Values.noibackuprestore.systempassword }}"
{{- else }}
    valueFrom:
      secretKeyRef:
        name: {{ .Release.Name }}-systemauth-secret
        key: password
{{- end }}
  - name: tenantid
    value: {{ .Values.global.common.eventanalytics.tenantId | quote }}
  - name: policysvcurl
{{- if .Values.noibackuprestore.policysvcurl }}
    value: "{{ .Values.noibackuprestore.policysvcurl }}"
{{- else }}
    value: {{ printf "http://%s-ibm-hdm-analytics-dev-policyregistryservice:5600" .Release.Name| quote }}
{{- end }}
  - name: outputdir
    value: "/noibackups/cneapolicies/workingarea"
  - name: backuphostname
    value: "{{ .Values.noibackuprestore.backupDestination.hostname }}"
  - name: backupusername
    value: "{{ .Values.noibackuprestore.backupDestination.username }}"
  - name: destinationdirectory
    value: "{{ .Values.noibackuprestore.backupDestination.directory }}"
  - name: maxbackups
    value: "{{ .Values.noibackuprestore.maxbackups }}"
{{- end -}}
