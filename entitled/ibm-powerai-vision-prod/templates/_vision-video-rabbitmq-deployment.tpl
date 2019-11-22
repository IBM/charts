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
Common template for vision-video*-rabbitmq-deployment
Requires Variables .namePrefix .runMountPath (path in volume)
*/ -}}
{{- define "vision-video-rabbitmq-deployment-tpl" }}
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
          image: "{{ template "repoprefix" . }}powerai-vision-video-rabbitmq:{{ .Values.image.releaseTag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: amqp
              containerPort: 5672
              protocol: TCP
          volumeMounts:
            - mountPath: /var/lib/rabbitmq
              name: run-mount
              subPath: {{ .runMountPath }}
          env:
            - name: RABBITMQ_DEFAULT_USER
              value: {{ default "" .Values.poweraiVisionVideoRabbitmq.rabbitmqUsername | quote }}
            - name: RABBITMQ_DEFAULT_PASS
              valueFrom:
                secretKeyRef:
                  name: {{ template "shortname" . }}-secrets
                  key: rabbitmq-password
            - name: RABBITMQ_DEFAULT_VHOST
              value: {{ default "" .Values.poweraiVisionVideoRabbitmq.rabbitmqVhost | quote }}
          livenessProbe:
            exec:
              command:
              - rabbitmqctl
              - status
            initialDelaySeconds: 240
            timeoutSeconds: 5
            failureThreshold: 6
          readinessProbe:
            exec:
              command:
              - rabbitmqctl
              - status
            initialDelaySeconds: 10
            timeoutSeconds: 3
            periodSeconds: 5
          resources:
{{ toYaml .Values.resources | indent 12 }}
      nodeSelector:
        beta.kubernetes.io/arch: ppc64le
      affinity:
      {{- include "nodeaffinity-ppc64le" . | indent 6 }}
      volumes:
        - name: "run-mount"
          persistentVolumeClaim:
          {{- if .Values.poweraiVisionDataPvc.persistence.existingClaimName }}
            claimName: {{ .Values.poweraiVisionDataPvc.persistence.existingClaimName }}
          {{- else }}
            claimName: {{ tpl .Values.poweraiVisionDataPvc.name . }}
          {{- end }}
      {{ include "imagesecrets" . | indent 6 }}
{{- end }}