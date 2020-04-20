{{- define "launch_yaml" -}}
#
# Objectives:
# - This yaml is rendered at helm deploy time into a string.
# - The string is base64-encoded and put into a secret.
# - It is used by the session manager to launch a session-flow container.
#
apiVersion: v1
kind: Pod
metadata:
  name:  {{ template "flow-session.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ template "flow-session.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
  annotations:
    build: {{ .Values.global.buildVersion | quote }}
    {{- if .Values.global.annotations }}
{{ toYaml .Values.global.annotations | trim | indent 4 }}
    {{- end }}
spec:
  automountServiceAccountToken: false
  {{ if .Values.global.docker.useImagePullSecret }}
  imagePullSecrets:
  - name: {{ .Values.global.imagePullSecretName }}
  {{ end }}

  volumes:
  {{- if .Values.usePVCForTempDiskSpace }}
  - name: pod-temp
    persistentVolumeClaim:
      # The flow-session cache will substitute the correct name in before this yaml gets used...
      claimName: "@PVC_NAME@"
  {{- end }}
  {{- if .Values.projectPVC.enabled }}
  - name: projects
    persistentVolumeClaim:
      claimName: {{ .Values.projectPVC.name | quote }}
  {{- end }}

  {{- if .Values.global.nginx.importSSLCertificate.enabled }}
  - name: certificates
    secret:
      secretName: {{ .Values.global.nginx.importSSLCertificate.certificateSecret.name }}
      items:
      # The key name is dictated by the installer team - who created the secret.
      - key: {{ .Values.global.nginx.importSSLCertificate.certificateSecret.key }}
        # The path where we mount the secret is up to us.
        path: {{ .Values.nginx.internalSSLCertificate.fileName }}
  {{- end }}

  restartPolicy: Never

  serviceAccount: {{ .Values.global.viewer.sa }}
  serviceAccountName: {{ .Values.global.viewer.sa }}

  containers:
  - name: {{ .Chart.Name }}
    image: {{ template "full-image-url" . }}
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    securityContext:
      runAsUser: {{ $.Values.global.runAsUser }}
      capabilities:
        drop:
        - ALL
      allowPrivilegeEscalation: false
      privileged: false
      runAsNonRoot: true
    ports:
    - containerPort: 9443
    - containerPort: 9445
    - containerPort: 9447
    resources:
      limits:
        cpu: {{ .Values.global.flowSession.cpuLimits }}
        memory: {{ .Values.global.flowSession.memLimits }}
      requests:
        cpu: {{ .Values.global.flowSession.cpuRequests }}
        memory: {{ .Values.global.flowSession.memRequests }}

    volumeMounts:
      {{- if .Values.usePVCForTempDiskSpace }}
      # Only cloud uses mounted PVC
      - name: pod-temp
        mountPath: /pod-tmp
        subPath: "tmp2"
      {{- end }}

      {{ if .Values.global.nginx.importSSLCertificate.enabled }}
      - name: certificates
        mountPath: {{ .Values.nginx.internalSSLCertificate.mountFolder }}
        readOnly: true
      {{- end }}

      {{- if .Values.projectPVC.enabled }}
      - name: projects
        mountPath: /projects
        subPath: "projects"
      {{- end }}

    env:
      # All the play service instances use the same crypto secret, so
      # they all sign SSL traffic in the same way.
      - name: PLAY_CRYPTO_SECRET
        valueFrom:
          secretKeyRef:
            name: {{ template "flow-session.playcryptosecret" . }}
            key: PLAY_CRYPTO_SECRET

      {{ if .Values.global.newRelic.enabled }}
      - name: NEW_RELIC_LICENSE_KEY
        valueFrom:
          secretKeyRef:
            name: {{ template "flow-session.secrets" . }}
            key: NEW_RELIC_LICENSE_KEY
      {{ end }}

      # Used to access the session cache database.
      - name: POSTGRES_JDBC
        valueFrom:
          secretKeyRef:
            name: {{ template "cache-db.password-secret" . }}
            key: POSTGRES_JDBC

      {{ if .Values.global.activityTracker.enabled }}
      - name: ACTIVITY_TRACKER_TOKEN
        valueFrom:
          secretKeyRef:
            name: {{ template "flow-session.secrets" . }}
            key: ACTIVITY_TRACKER_TOKEN
      {{ end }}

      - name: STREAMS_URL
        value: {{ .Values.global.canvasApi.url }}
      - name: DSX_URL
        value: {{ .Values.global.watsonStudio.url }}
      - name: SERVICE_IMAGE_NAME
        value: {{ .Chart.Name }}
      - name: SERVICE_CPU
        value: "{{ .Values.global.flowSession.cpuLimits }}"
      - name: SERVICE_MEM
        value: {{ .Values.resources.memory }}
      - name: SERVER_INSTALLATION_DIRECTORY
        value: "_"
      - name: MODELER_SERVER_HOST
        value: localhost
      - name: DEVELOPMENT_MODE
        value: "false"
      - name: USE_ICONSET
        value: "v1/"
      # TODO: Check the value here matches what Don P has coded.
      - name: MODEL_VIEWER_SERVICE
        value: "{{ .Values.global.modelViewer.url }}"
      - name: MODEL_VIEWER_BROWSER_PREFIX
        value: "/model-viewer"
      - name: LOCALFS_ROOT_PATH
        value: "/"
      {{ if .Values.global.auth.icp4d.enabled }}
      - name: ICP4D_PUBLIC_KEY_URL
        value: {{ .Values.global.auth.icp4d.publicKeyUrl | quote }}
      - name: ICP4D_AUTH_SERVICE_ID
        valueFrom:
          secretKeyRef:
            key: service-id-credentials
            name: wdp-service-id
      {{ end }}

      {{ if .Values.global.auth.iam.enabled }}
      - name: IAMID_KEYS_ENDPOINT
        value: "{{ .Values.global.auth.iam.jwks.url }}"
      - name: IAMID_TOKEN_ENDPOINT
        value: "{{ .Values.global.auth.iam.token.url }}"
      {{ end }}

      {{ if .Values.global.newRelic.enabled }}
      - name: NEW_RELIC_APP_NAME
        value: "{{ .Values.newRelic.applicationName }}"
      {{ end }}

      - name: DSX_OPERATING_ENVIRONMENT
        value: "{{ .Values.global.watsonStudio.operatingEnvironment }}"

      - name: ULIMIT_MEM
        value: "4194304"

      - name: PLAY_OPTS
        value: "-J-Xms1024M -J-Xmx3072M -J-Dfile.encoding=UTF-8"

      {{ if .Values.global.billing.enabled }}
      - name: ENVIRONMENTS_API_URL
        # This environment variable is used when billing is turned on.
        # Local doesn't do anything with billing...
        value: "https://api.dataplatform.cloud.ibm.com"

      # If a billing lookup is required, we do it using this service id...
      - name: SERVICE_ID_API_KEY
        valueFrom:
          secretKeyRef:
            name: {{ template "flow-session.secrets" . }}
            key: SERVICE_ID_API_KEY
      {{ end }}

      - name: OMP_NUM_THREADS
        value: "2"

      # This should only be set for Local. Any non-empty value will disable scripting.
      - name: DISABLE_SCRIPTING
        value: "1"

      {{ if .Values.global.watsonStudio.trustSelfSignedCertificates }}
      # Tells the play service to trust all SSL certificates of servers it connects to over SSL
      # If it is missing, or set to '0' then only properly signed server certificates are accepted.
      - name: TRUST_SELF_SIGNED_CERTIFICATES
        value: "1"
      {{ end }}

      - name: RUN_IN_FIREJAIL
        {{ if .Values.fireJail.enabled }}
        value: "1"
        {{ else }}
        value: "0"
        {{ end }}

      # Tells the canvas service how it can connect to the machine learning api
      - name: ML_SERVICE_BASE_URL
        value: "{{ .Values.global.wml.url }}"

      {{ if .Values.global.activityTracker.enabled }}
      - name: ACTIVITY_TRACKER_REGION
        value: "{{ .Values.global.activityTracker.region }}"
      - name: ACTIVITY_TRACKER_PROJECTID
        value: "{{ .Values.global.activityTracker.project.id }}"
      - name: ACTIVITY_TRACKER_URL
        value: "{{ .Values.global.activityTracker.url }}"

      # The CRN_* variables are used by activity tracker.
      # They indicate what is generating the activity.
      # eg: USA south staging...etc.
      - name: CRN_CNAME
        value: "{{ .Values.global.crn.name }}"
      - name: CRN_LOCATION
        value: "{{ .Values.global.crn.location }}"
      {{ end }}

      - name: USE_MOUNTED_ENCRYPTED_TEMP_DISK
        {{- if .Values.usePVCForTempDiskSpace }}
        # Tell the startup script we want to use the temp encrypted disk we mounted as a PVC
        value: "1"
        {{ else }}
        # Tell the startup script we don't want to use the mounted temp encrypted disk
        value: "0"
        {{- end }}

      {{- if .Values.global.nginx.importSSLCertificate.enabled }}
      - name: NGINX_SERVICE_SSL_CERTIFICATE_FILE_PATH
        value: "{{ .Values.nginx.internalSSLCertificate.mountFolder }}/{{ .Values.nginx.internalSSLCertificate.fileName }}"
      {{- end }}

    # Clean up the mounted encrypted temp disk space if it was used.
    {{- if .Values.usePVCForTempDiskSpace }}
    lifecycle:
      preStop:
        exec:
          command: ["/opt/IBM/SPSS/ModelerServer/Cloud/umount_encrypted_tmp.sh"]
    {{- end }}

    securityContext:
      {{- if .Values.usePVCForTempDiskSpace }}
      # Need privilege access so we can format the temp encrypted mounted drive to put customer data into.
      privileged: true
      {{- else }}
      # Don't need encrypted drive to store customer data.
      privileged: false
      {{- end }}

{{- end -}}
