{{- define "icam.notes.b" -}}
1. Wait for all pods to become ready. You can keep track of the pods either through the dashboard or through the command line interface: kubectl get pods -l release={{ .Release.Name }} -n {{ .Release.Namespace }}

2. (Optional) Validate health of pods by running helm tests: helm test {{ .Release.Name }} --tls --cleanup

3. {{ if .Release.IsUpgrade }}(Optional) {{ end }}OIDC registration with IBM Cloud Pak for Multicloud Management is required to be able to login to the Performance Monitoring UI. As an IBM Cloud Pak user with the Cluster Administrator role, run the following kubectl command:
kubectl exec -n {{ .Release.Namespace }} -t `kubectl get pods -l release={{ .Release.Name }} -n {{ .Release.Namespace }} | grep "{{ .Release.Name }}-ibm-cem-cem-users" | grep "Running" | head -n 1 | awk '{print $1}'` bash -- "/etc/oidc/oidc_reg.sh" "`echo $(kubectl get secret platform-oidc-credentials -o yaml -n kube-system | grep OAUTH2_CLIENT_REGISTRATION_SECRET: | awk '{print $2}')`"

{{- if (include "icam.isMCM" .)  }}
{{ if .Release.IsUpgrade }}(Optional) {{ end }}Policy registration with IBM Cloud Pak for Multicloud Management is required to allow the Performance Monitoring services to be able to access other services. As an IBM Cloud Pak user with the Cluster Administrator role, run the following kubectl command:
kubectl exec -n {{ .Release.Namespace }} -t `kubectl get pods -l release={{ .Release.Name }} -n {{ .Release.Namespace }} | grep "{{ .Release.Name }}-ibm-cem-cem-users" | grep "Running" | head -n 1 | awk '{print $1}'` bash -- "/etc/oidc/registerServicePolicy.sh" "`echo $(kubectl get secret {{ .Release.Name }}-cem-service-secret -o yaml -n kube-system | grep cem-service-id: | awk '{print $2}')`" "`cloudctl tokens --access`"
{{- end }}
{{- end -}}
