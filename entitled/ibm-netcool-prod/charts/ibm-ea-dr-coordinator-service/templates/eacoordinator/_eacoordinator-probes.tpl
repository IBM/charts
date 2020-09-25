{{- define "ibm-ea-dr-coordinator-service.eacoordinator.probes" -}}
readinessProbe:
  httpGet:
    path: /coordinator/status/health
    port: 8080
  initialDelaySeconds: {{ .Values.readiness.initialDelaySeconds }}
  periodSeconds: {{ .Values.readiness.periodSeconds }}
  timeoutSeconds: {{ .Values.readiness.timeoutSeconds }}
  failureThreshold: {{ .Values.readiness.failureThreshold }}
livenessProbe:
  httpGet:
    path: /coordinator/status/health
    port: 8080
  initialDelaySeconds: {{ .Values.liveness.initialDelaySeconds }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  timeoutSeconds: {{ .Values.liveness.timeoutSeconds }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
{{- end -}}
