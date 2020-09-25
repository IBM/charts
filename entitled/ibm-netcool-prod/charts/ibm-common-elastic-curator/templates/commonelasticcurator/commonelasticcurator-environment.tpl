
{{- /*
Creates the environment for the service
*/ -}}

{{- define "ibm-common-elastic-curator.commonelasticcurator.environment" -}}
env:
  - name: LICENSE
    value: "{{ .Values.global.license }}"
{{- end -}}