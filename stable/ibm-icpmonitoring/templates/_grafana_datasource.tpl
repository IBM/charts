{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Grafana Datasource Configuration Files */}}
{{- define "grafanaDatasourceConfig" }}
datasource.yaml: |-
    apiVersion: 1
    datasources:
    - name: prometheus
      type: prometheus
      isDefault: true
      editable: false
    {{- if or (eq .Values.mode "managed") .Values.tls.enabled }}
      access: proxy
      url: https://{{ template "prometheus.fullname" . }}:{{ .Values.prometheus.port }}
      jsonData:
         tlsAuth: true
         tlsAuthWithCACert: true
      secureJsonData:
        tlsCACert: "CA_CONTENT"
        tlsClientCert: "CERT_CONTENT"
        tlsClientKey: "KEY_CONTENT"
    {{- else }}
      access: proxy
      url: http://{{ template "prometheus.fullname" . }}:{{ .Values.prometheus.port }}   
    {{- end }}
{{- end }}