{{/*********************************************************** {COPYRIGHT-TOP} ****
* Licensed Materials - Property of IBM
*
* "Restricted Materials of IBM"
*
*  5737-H89, 5737-H64
*
* © Copyright IBM Corp. 2019  All Rights Reserved.
*
* US Government Users Restricted Rights - Use, duplication, or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
********************************************************* {COPYRIGHT-END} ****/}}
{{- include "sch.config.init" (list . "cem.sch.chart.config.values") -}}
{{- if .Values.global.internalTLS.enabled }}
{{- $fullName := include "sch.names.fullName" (list .) }}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: {{ $fullName }}-certificate
  namespace: {{ .Release.Namespace }}
  labels:
{{ include "sch.metadata.labels.standard" (list . $fullName) | indent 4 }}
    origin: helm-cem
spec:
  commonName: {{ include "sch.names.fullName" (list .) }}.{{ .Release.Namespace }}.svc
  dnsNames:
  - {{ include "sch.names.fullCompName" (list . "rba-as") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "brokers") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "cem-users") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "channelservices") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "datalayer") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "event-analytics-ui") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "eventpreprocessor") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "incidentprocessor") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "integration-controller") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "normalizer") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "notificationprocessor") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "rba-rbs") }}.{{ .Release.Namespace }}.svc
  - {{ include "sch.names.fullCompName" (list . "scheduling-ui") }}.{{ .Release.Namespace }}.svc
  issuerRef:
    kind: ClusterIssuer
    name: icp-ca-issuer
  secretName: {{ $fullName }}-certificate
...
{{- end }}
