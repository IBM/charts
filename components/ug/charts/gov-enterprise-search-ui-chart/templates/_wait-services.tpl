{{- define "wait-services" }}
- name: wait-services
  image: {{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}{{ .Values.global.image.wkcinitcontainer.repository }}:{{ .Values.global.image.wkcinitcontainer.tag }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
  resources:
     requests:
        memory: "0"
        cpu: "0"
     limits:
        memory: "0"
        cpu: "0"
  securityContext:
    privileged: false
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    readOnlyRootFilesystem: false
    capabilities:
      drop:
      - ALL
  command: ['sh', '-c', '--']
  args: [ "sleep 60; while [ ! -f /tmp/jwtkey.cer ]; do sleep 2; done;"
        ]
  volumeMounts:
  - name: secrets-pv-volume
    mountPath: /tmp
{{- end }}

{{- define "wait-xmeta" }}
- name: xmeta-wait
  image: {{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}{{ .Values.global.image.wkcinitcontainer.repository }}:{{ .Values.global.image.wkcinitcontainer.tag }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
  resources:
     requests:
        memory: "0"
        cpu: "0"
     limits:
        memory: "0"
        cpu: "0"
  securityContext:
    privileged: false
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    readOnlyRootFilesystem: false
    capabilities:
      drop:
      - ALL
  command: ['sh', '-c', '--']
  args: [ "xmeta_status=1;
           while [ $xmeta_status != 0  ];
           do sleep 2;
           xmeta_status=`nc is-xmetadocker 50000 < /dev/null; echo $?`;
           done;"
        ]
{{- end }}

{{- define "wait-kafka" }}
- name: wait-kafka
  image: {{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}{{ .Values.global.image.wkcinitcontainer.repository }}:{{ .Values.global.image.wkcinitcontainer.tag }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
  resources:
     requests:
        memory: "0"
        cpu: "0"
     limits:
        memory: "0"
        cpu: "0"
  securityContext:
    privileged: false
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    readOnlyRootFilesystem: false
    capabilities:
      drop:
      - ALL
  command: ['sh', '-c', '--']
  args: [ "kafka_status=1;
           while [ $kafka_status != 0  ];
           do sleep 2;
           kafka_status=`nc kafka 9092 < /dev/null; echo $?`;
           done;"
        ]
{{- end }}

{{- define "wait-redis" }}
- name: wait-redis
  image: {{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}{{ .Values.global.image.wkcinitcontainer.repository }}:{{ .Values.global.image.wkcinitcontainer.tag }}
  imagePullPolicy: {{ .Values.global.image.pullPolicy }}
  resources:
     requests:
        memory: "0"
        cpu: "0"
     limits:
        memory: "0"
        cpu: "0"
  securityContext:
    privileged: false
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    readOnlyRootFilesystem: false
    capabilities:
      drop:
      - ALL
  command: ['sh', '-c', '--']
  args: [ "redis_status=1;
           while [ $redis_status != 0  ];
           do sleep 2;
           redis_status=`nc redis-ha 6379 < /dev/null; echo $?`;
           done;"
        ]
{{- end }}

