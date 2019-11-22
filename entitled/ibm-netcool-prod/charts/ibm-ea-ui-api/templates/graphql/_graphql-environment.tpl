{{- /*
Creates the environment for the UI server
*/ -}}
{{- define "ibm-ea-ui-api.graphql.environment" -}}
{{- $servicePort := .sch.chart.components.graphql.servicePort -}}
env:
  - name: LICENSE
    value: "{{ .Values.global.license }}"
  - name: PORT
    value: {{ $servicePort | quote }}
  - name: SECUREPORT
    value: "8443"
  - name: PUBLICURL
    value: {{ include "ibm-ea-ui-api.ingress.baseurl" . | quote }}
  - name: PLAYGROUND
    value: "{{ .Values.enablePlayground }}"
  - name: EXPERIMENTALAUTH
    value: "{{ .Values.enableExperimentalAuth }}"
{{ include "ibm-ea-ui-api.graphql.environment.services" . | indent 2 }}
{{- end -}}


{{- define "ibm-ea-ui-api.graphql.environment.services" -}}
  {{- $services := .Values.services -}}
  {{- $policyApiUrlTemplate := "http:///%s-ibm-hdm-analytics-dev-policyregistryservice:5600/api/policies" -}}
  {{- $eqsApiUrlTemplate := "http://%s-ibm-hdm-analytics-dev-eventsqueryservice:5600/api/events" -}}

- name: POLICYAPIURL
  value: {{ include "ibm-ea-ui-api.geturl" (list . $services.analytics.policyRegistryUrl $services.analytics.releaseName $policyApiUrlTemplate) | quote }}
- name: EVENTQUERYAPIURL
  value: {{ include "ibm-ea-ui-api.geturl" (list . $services.analytics.eventQueryApiUrl $services.analytics.releaseName $eqsApiUrlTemplate) | quote }}
{{- end -}}
