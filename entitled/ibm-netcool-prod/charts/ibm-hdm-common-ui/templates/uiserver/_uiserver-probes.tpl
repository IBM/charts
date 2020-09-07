{{- define "ibm-hdm-common-ui.ui-server.probes" -}}
readinessProbe:
  httpGet:
    path: /version.json
    port: 8443
    scheme: HTTPS
  initialDelaySeconds: {{ .Values.readiness.initialDelaySeconds }}
  periodSeconds: {{ .Values.readiness.periodSeconds }}
  timeoutSeconds: {{ .Values.readiness.timeoutSeconds }}
  failureThreshold: {{ .Values.readiness.failureThreshold }}
livenessProbe:
  httpGet:
    path: /version.json
    port: 8443
    scheme: HTTPS
  initialDelaySeconds: {{ .Values.liveness.initialDelaySeconds }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  timeoutSeconds: {{ .Values.liveness.timeoutSeconds }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
{{- end -}}
