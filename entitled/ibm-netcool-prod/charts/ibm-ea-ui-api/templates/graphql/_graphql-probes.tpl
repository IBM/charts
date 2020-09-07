{{- define "ibm-ea-ui-api.graphql.probes" -}}
readinessProbe:
  httpGet:
    path: /status
    port: 8443
    scheme: HTTPS
  initialDelaySeconds: {{ .Values.readiness.initialDelaySeconds }}
  periodSeconds: {{ .Values.readiness.periodSeconds }}
  timeoutSeconds: {{ .Values.readiness.timeoutSeconds }}
  failureThreshold: {{ .Values.readiness.failureThreshold }}
livenessProbe:
  httpGet:
    path: /status
    port: 8443
    scheme: HTTPS
  initialDelaySeconds: {{ .Values.liveness.initialDelaySeconds }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  timeoutSeconds: {{ .Values.liveness.timeoutSeconds }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
{{- end -}}
