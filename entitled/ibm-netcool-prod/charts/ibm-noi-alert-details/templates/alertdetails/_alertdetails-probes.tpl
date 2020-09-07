{{- define "ibm-noi-alert-details.alertdetails.probes" -}}
readinessProbe:
  httpGet:
    path: /servicemonitor
    port: unsecure-port
  initialDelaySeconds: {{ .Values.readiness.initialDelaySeconds }}
  periodSeconds: {{ .Values.readiness.periodSeconds }}
  timeoutSeconds: {{ .Values.readiness.timeoutSeconds }}
  failureThreshold: {{ .Values.readiness.failureThreshold }}
livenessProbe:
  httpGet:
    path: /servicemonitor
    port: unsecure-port
  initialDelaySeconds: {{ .Values.liveness.initialDelaySeconds }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  timeoutSeconds: {{ .Values.liveness.timeoutSeconds }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
{{- end -}}
