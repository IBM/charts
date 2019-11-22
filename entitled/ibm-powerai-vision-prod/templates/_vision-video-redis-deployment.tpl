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
Common template for vision-video*-redis-deployment
Requires Variables .namePrefix
*/ -}}
{{- define "vision-video-redis-deployment-tpl" }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ .namePrefix }}
  labels:
    {{ include "vision-standard-labels" . | indent 4 }}
    run: {{ .namePrefix }}-dep
spec:
  replicas: 1
  selector:
    matchLabels:
      run: {{ .namePrefix }}-dp
  template:
    metadata:
      labels:
        {{ include "vision-standard-labels" . | indent 8 }}
        run: {{ .namePrefix }}-dp
      {{ include "vision-release-annotations" . | indent 6 }}
    spec:
      containers:
        - name: {{ .namePrefix }}
          image: "{{ template "repoprefix" . }}powerai-vision-video-redis:{{ .Values.image.releaseTag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: redis
              containerPort: 6379
              protocol: TCP
          volumeMounts:
            - mountPath: /data
              name: data-mount
              subPath: data
          env:
            # TODO - this is how it currently is configured...we need to fix this.
            - name: ALLOW_EMPTY_PASSWORD
              value: "yes"
          livenessProbe:
            exec:
              command:
              - redis-cli
              - ping
            initialDelaySeconds: 240
            timeoutSeconds: 5
          readinessProbe:
            exec:
              command:
              - redis-cli
              - ping
            initialDelaySeconds: 5
            timeoutSeconds: 1
          resources:
{{ toYaml .Values.resources | indent 12 }}
      nodeSelector:
        beta.kubernetes.io/arch: ppc64le
      affinity:
      {{- include "nodeaffinity-ppc64le" . | indent 6 }}
      volumes:
        # We don't need to persist anything in redis
        - name: data-mount
          emptyDir: {}
      {{ include "imagesecrets" . | indent 6 }}
{{- end }}