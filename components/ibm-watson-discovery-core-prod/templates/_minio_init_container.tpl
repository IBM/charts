{{- define "discovery.minioInitContainer" -}}
{{- $minioSecret := include "discovery.crust.minio.secret" . -}}
- name: minio-init-container
  image: {{ .Values.global.dockerRegistryPrefix }}/
    {{- .Values.initContainers.minio.image.name }}:
    {{- .Values.initContainers.minio.image.tag }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
{{ include "sch.security.securityContext" (list . .sch.chart.restrictedSecurityContext) | indent 2 }}
  resources:
    requests:
      memory: {{ .Values.initContainers.minio.resources.requests.memory | quote }}
      cpu: {{ .Values.initContainers.minio.resources.requests.cpu | quote }}
    limits:
      memory: {{ .Values.initContainers.minio.resources.limits.memory | quote }}
      cpu: {{ .Values.initContainers.minio.resources.limits.cpu | quote }}
  env:
  - name: MINIO_ENDPOINT
    valueFrom:
      configMapKeyRef:
        name: {{ include "discovery.crust.minio.configmap" . }}
        key: host
  - name: MINIO_PORT
    valueFrom:
      configMapKeyRef:
        name: {{ include "discovery.crust.minio.configmap" . }}
        key: port
  - name: ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: {{ $minioSecret }}
        key: accesskey
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: {{ $minioSecret }}
        key: secretkey
  volumeMounts:
  - name: mc-config-dir
    mountPath: {{ .Values.initContainers.minio.configPathmc }}
  command:
  - "bin/sh"
  - "-c"
  - |
    #!/bin/sh
    set -e ; # Have script exit in the event of a failed command.

    CONFIG_MC_PATH={{ .Values.initContainers.minio.configPathmc }}
    # connectToMinio
    # Use a check-sleep-check loop to wait for Minio service to be available
    {{- if .Values.minio.tls.enabled }}
    SCHEME=https
    {{- else }}
    SCHEME=http
    {{- end }}
    ATTEMPTS=0 ;
    set -e ; # fail if we can't read the keys.
    ACCESS=$(echo -n $ACCESS_KEY) ; SECRET=$(echo -n $SECRET_KEY) ;
    set +e ; # The connections to minio are allowed to fail.
    echo "Connecting to Minio server: $SCHEME://$MINIO_ENDPOINT:$MINIO_PORT" ;
    MC_COMMAND="mc -C $CONFIG_MC_PATH  config host add myminio $SCHEME://$MINIO_ENDPOINT:$MINIO_PORT $ACCESS $SECRET --insecure" ;
    $MC_COMMAND ;
    STATUS=$? ;
    until [ $STATUS = 0 ]
    do
      ATTEMPTS=`expr $ATTEMPTS + 1` ;
      echo \"Failed attempts: $ATTEMPTS\" ;
      sleep 2 ; # 1 second intervals between attempts
      $MC_COMMAND ;
      STATUS=$? ;
    done ;
    echo "Minio is up and running!"
{{- end -}}