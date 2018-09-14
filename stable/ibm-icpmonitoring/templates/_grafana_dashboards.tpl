{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Grafana Dashboards Configuration Files */}}
{{- define "grafanaDashboardsConfig" }}
dashboards.yaml: |-
  apiVersion: 1
  providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30 #how often Grafana will scan for changed dashboards
    options:
      path: /etc/grafana/dashboards/
{{- end }}