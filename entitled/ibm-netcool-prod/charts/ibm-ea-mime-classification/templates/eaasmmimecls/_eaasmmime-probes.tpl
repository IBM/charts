{{- define "ibm-ea-mime-classification.eaasmmimecls.probes" -}}
readinessProbe:
  exec:
    command:
    - "sh"
    - "-c"
    - >-
      test -f "custom_models/custom_model_default_tenant_id.ftz"
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
      /opt/app/scripts/healthcheck-orchestration.sh
  initialDelaySeconds: {{ .Values.liveness.initialDelaySeconds }}
  periodSeconds: {{ .Values.liveness.periodSeconds }}
  timeoutSeconds: {{ .Values.liveness.timeoutSeconds }}
  failureThreshold: {{ .Values.liveness.failureThreshold }}
{{- end -}}
