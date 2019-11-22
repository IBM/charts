{{- define "ibm-apiconnect-pro.delete-subsys-job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ template "ibm-apiconnect-pro.fullname" . }}-delete-$SUBSYS_RELEASE
  labels:
    app: {{ template "ibm-apiconnect-pro.name" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    component: {{ template "ibm-apiconnect-pro.name" . }}-delete-$SUBSYS_RELEASE
spec:
  backoffLimit: 1
  template:
    metadata:
      labels:
        app: {{ template "ibm-apiconnect-pro.name" . }}
        chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
        release: {{ .Release.Name }}
        heritage: {{ .Release.Service }}
        component: {{ template "ibm-apiconnect-pro.name" . }}-delete-$SUBSYS_RELEASE
    spec:
      serviceAccountName: {{ template "ibm-apiconnect-pro.fullname" . }}
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: beta.kubernetes.io/arch
                operator: In
                values:
                  - {{ .Values.operator.arch }}
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
{{ include "ibm-apiconnect-pro.podSecurityContext" . | indent 8 }}
      restartPolicy: Never
      containers:
        - name: "subsys-delete"
{{- if .Values.operator.registry }}
          image: {{ regexReplaceAll "/$" .Values.operator.registry "" }}/{{ .Values.operator.image }}:{{ .Values.operator.tag }}
{{- else }}
          image: {{ regexReplaceAll "/$" .Values.global.registry "" }}/{{ .Values.operator.image }}:{{ .Values.operator.tag }}
{{- end }}
          imagePullPolicy: {{ .Values.operator.pullPolicy }}
          command: [ "/apicop/init.sh" ]
          args: 
            - "/apicop/delete-subsys.sh"
            - "$SUBSYS_RELEASE"
          env:
            - name: HELM_HOME
              value: "/home/apic/.helm"
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          securityContext:
{{ include "ibm-apiconnect-pro.securityContext" . | indent 12 }}
{{- if .Values.operator.helmTlsSecret }}
          volumeMounts:
          - name: cr-files
            mountPath: /apicop/delete-subsys.sh
            subPath: delete-subsys.sh
          - name: helm-tls
            mountPath: "/home/apic/.helm"
      volumes:
      - name: cr-files
        configMap:
          name: {{ template "ibm-apiconnect-pro.fullname" . }}-cr-files
          defaultMode: 0755
          items:
            - key: delete-subsys
              path: delete-subsys.sh
      - name: helm-tls
        secret:
          secretName: {{ .Values.operator.helmTlsSecret }}
          defaultMode: 0644
          items:
            - key: cert.pem
              path: cert.pem
            - key: ca.pem
              path: ca.pem
            - key: key.pem
              path: key.pem
{{- end -}}
{{- end -}}