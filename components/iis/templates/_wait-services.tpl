{{- define "wait-services" }}
- name: wait-services
  image: {{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}{{ .Values.release.image.wkcinitcontainer.repository }}:{{ .Values.release.image.wkcinitcontainer.tag }}
  imagePullPolicy: {{ .Values.release.image.pullPolicy }}
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
  args: [ "iis_status=1;
           while [ $iis_status != 0  ];
           do sleep 30;
           iis_status=`nc is-servicesdocker 9446 < /dev/null; echo $?`;
           done;"
        ]
{{- end }}

{{- define "wait-xmeta" }}
- name: xmeta-wait
  image: {{ if .Values.global.dockerRegistryPrefix }}{{ trimSuffix "/" .Values.global.dockerRegistryPrefix }}/{{ end }}{{ .Values.release.image.wkcinitcontainer.repository }}:{{ .Values.release.image.wkcinitcontainer.tag }}
  imagePullPolicy: {{ .Values.release.image.pullPolicy }}
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
  resources:
    requests:
      memory: "{{ .Values.release.image.wkcinitcontainer.requests.memory }}"
      cpu: "{{ .Values.release.image.wkcinitcontainer.requests.cpu }}"
    limits:
      memory: "{{ .Values.release.image.wkcinitcontainer.limits.memory }}"
      cpu: "{{ .Values.release.image.wkcinitcontainer.limits.cpu }}"
{{- end }}
