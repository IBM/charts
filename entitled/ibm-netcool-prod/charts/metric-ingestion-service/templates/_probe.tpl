{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}

{{- define "metric-ingestion-service.probe.smonitor.readiness" -}}
readinessProbe:
  exec:
    command:
    - "sh"
    - "-c"
    - >-
      if [[ $(curl -s -X GET localhost:8080/api/metricingestion/servicemonitor | grep -e "\"status\":0" | wc -l)  > 0 ]] && [[ $(curl -s -X GET localhost:8080/api/metricingestion/servicemonitor | grep -e "\"status\":1" | wc -l) == 0 ]]; then exit 0; else exit 1; fi
  timeoutSeconds: 60
  initialDelaySeconds: 30
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "metric-ingestion-service.probe.smonitor.liveness" -}}
livenessProbe:
  exec:
    command:
    - "sh"
    - "-c"
    - >-
      if [[ $(curl -s -X GET localhost:8080/api/metricingestion/servicemonitor | grep -e "\"status\":0" | wc -l)  > 0 ]] && [[ $(curl -s -X GET localhost:8080/api/metricingestion/servicemonitor | grep -e "\"status\":1" | wc -l) == 0 ]]; then exit 0; else exit 1; fi
  timeoutSeconds: 60
  initialDelaySeconds: 60
  periodSeconds: 60
  successThreshold: 1
  failureThreshold: 3
{{- end -}}

{{- define "metric-ingestion-service.probe.smonitor.all" -}}
{{ include "metric-ingestion-service.probe.smonitor.liveness" . }}
{{ include "metric-ingestion-service.probe.smonitor.readiness" . }}
{{- end -}}
