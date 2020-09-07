{{- /*
********************************************************** {COPYRIGHT-TOP} ****
* Licensed Materials - Property of IBM
*
* "Restricted Materials of IBM"
*
*  5737-H89, 5737-H64
*
* © Copyright IBM Corp. 2015, 2018  All Rights Reserved.
*
* US Government Users Restricted Rights - Use, duplication, or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
********************************************************* {COPYRIGHT-END} ****

Chart specific kubernetes security context
This file defines the security context for pods in the chart
*/ -}}

{{- define "ibmeaspark.container.security.context" -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1001 
  capabilities:
    drop:
    - ALL
{{- end -}}

{{- define "ibmeaspark.spec.security.context" -}}
hostNetwork: false
hostPID: false
hostIPC: false
securityContext:
  runAsNonRoot: true
  runAsUser: 1001 
{{- end -}}