{{/* IBM_SHIP_PROLOG_BEGIN_TAG                                              */}}
{{/* *****************************************************************      */}}
{{/*                                                                        */}}
{{/* Licensed Materials - Property of IBM                                   */}}
{{/*                                                                        */}}
{{/* (C) Copyright IBM Corp. 2018. All Rights Reserved.                     */}}
{{/*                                                                        */}}
{{/* US Government Users Restricted Rights - Use, duplication or            */}}
{{/* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.      */}}
{{/*                                                                        */}}
{{/* *****************************************************************      */}}
{{/* IBM_SHIP_PROLOG_END_TAG                                                */}}
{{- /*
Common template for vision-video*-rabbitmq-svc
Requires Variables .namePrefix
*/ -}}
{{- define "vision-video-rabbitmq-svc-tpl" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .namePrefix }}
  labels:
    {{ include "vision-standard-labels" . | indent 4 }}
    run: {{ .namePrefix }}-svc
spec:
  type: ClusterIP
  ports:
  - name: amqp
    port: 5672
  selector:
    run: {{ .namePrefix }}-dp
{{- end }}