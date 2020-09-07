{{- define "ibm-ea-asm-mime.eaasmmime.probes" -}}
readinessProbe:
  exec:
    command:
    - "sh"
    - "-c"
    - >-
      if [[ $(curl -s -X GET localhost:8080/api/mime/servicemonitor | grep -e "\"status\":0" | wc -l)  > 0 ]] && [[ $(curl -s -X GET localhost:8080/api/mime/servicemonitor | grep -e "\"status\":1" | wc -l) == 0 ]]; then exit 0; else exit 1; fi
  initialDelaySeconds: {{ .Values.readiness.initialDelaySeconds }}
  periodSeconds: {{ .Values.readiness.periodSeconds }}
  timeoutSeconds: {{ .Values.readiness.timeoutSeconds }}
  failureThreshold: {{ .Values.readiness.failureThreshold }}
livenessProbe:
  exec:
    command:
    - "sh"
    - "-c"
    - >-
      if [[ $(curl -s -X GET localhost:8080/api/mime/servicemonitor | grep -e "\"status\":0" | wc -l)  > 0 ]] && [[ $(curl -s -X GET localhost:8080/api/mime/servicemonitor | grep -e "\"status\":1" | wc -l) == 0 ]]; then exit 0; else exit 1; fi
  initialDelaySeconds: {{ .Values.liveness.initialDelaySeconds }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  timeoutSeconds: {{ .Values.liveness.timeoutSeconds }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
{{- end -}}
