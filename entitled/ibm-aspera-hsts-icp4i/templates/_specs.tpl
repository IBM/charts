{{- include "sch.config.init" (list . "hsts.sch.chart.config.values") -}}

{{ define "hsts.spec.volumes.common" -}}
- name: hsts-storage
  persistentVolumeClaim:
    claimName: {{ template "hsts.transfer.pvc" . }}
- name: asperanoded-cert
  secret:
    secretName: {{ include "hsts.cert" . }}
- name: external-process-log
  emptyDir: {}
- name: aspera-conf
  emptyDir: {}
- name: aspera-configmap
  configMap:
    name: {{ include "sch.names.fullCompName" (list . .sch.chart.components.asperanode.configMap ) | quote }}
- name: license-secret
  secret:
    secretName: {{ .Values.asperanode.serverSecret }}
{{- end }}

# ----
# Common container specs
# ----

{{ define "hsts.spec.container.asperanode" -}}
- name: asperanode
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.asperanode" . }}
  imagePullPolicy: {{ .Values.asperanode.image.pullPolicy }}
  resources:
    requests:
      memory: {{ .Values.asperanode.resources.requests.memory }}
      cpu: {{ .Values.asperanode.resources.requests.cpu }}
    limits:
      memory: {{ .Values.asperanode.resources.limits.memory }}
      cpu: {{ .Values.asperanode.resources.limits.cpu }}
  command:
  - /opt/aspera/sbin/asperanoded
  args:
  - -L
  - /opt/aspera/var/log
  - -!
  volumeMounts:
  - name: external-process-log
    mountPath: /opt/aspera/var/log
  - name: hsts-storage
    mountPath: {{ .Values.persistence.mountPath }}
  - name: aspera-conf
    mountPath: "/opt/aspera/etc/aspera.conf"
    subPath: aspera.conf
  - name: license-secret
    mountPath: "/opt/aspera/etc/aspera-license"
    subPath: ASPERA_LICENSE
  - name: asperanoded-cert
    mountPath: "/opt/aspera/etc/aspera_server_key.pem"
    subPath: tls.key
  - name: aspera-conf
    mountPath: "/opt/aspera/etc/aspera_server_cert.pem"
    subPath: aspera_server_cert.pem
  - name: asperanoded-cert
    mountPath: "/opt/aspera/etc/aspera_server_cert.chain"
    subPath: tls.crt
  ports:
  - name: node-port
    containerPort: {{ .Values.asperanode.httpsPort }}
  readinessProbe:
    initialDelaySeconds: 2
    httpGet:
      path: /ping
      port: node-port
      scheme: HTTPS
  livenessProbe:
    initialDelaySeconds: 20
    httpGet:
      path: /ping
      port: node-port
      scheme: HTTPS
{{- end }}

{{ define "hsts.spec.container.ascplog" -}}
- name: ascp-log
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.probe" . }}
  imagePullPolicy: {{ .Values.probe.image.pullPolicy }}
{{  include "hsts.resources.static.small" . | indent 2 }}
  command: ["/bin/sh","-c"]
  args: ["
          until [ -f /var/log/aspera/aspera-scp-transfer.log ]; do sleep 5; done && tail -n+1 -f /var/log/aspera/aspera-scp-transfer.log
        "]
  livenessProbe:
    exec:
      command:
      - ls
      - /var/log/aspera
    initialDelaySeconds: 20
    periodSeconds: 30
  readinessProbe:
    exec:
      command:
      - ls
      - /var/log/aspera
    initialDelaySeconds: 2
    periodSeconds: 30
  volumeMounts:
  - name: external-process-log
    mountPath: /var/log/aspera
{{- end }}

{{ define "hsts.spec.container.nodelog" -}}
- name: asperanode-log
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.probe" . }}
  imagePullPolicy: {{ .Values.probe.image.pullPolicy }}
  command: ["/bin/sh","-c"]
{{  include "hsts.resources.static.small" . | indent 2 }}
  args: ["
          until [ -f /var/log/aspera/asperanoded.log ]; do sleep 5; done && tail -n+1 -f /var/log/aspera/asperanoded.log
        "]
  livenessProbe:
    exec:
      command:
      - ls
      - /var/log/aspera
    initialDelaySeconds: 20
    periodSeconds: 30
  readinessProbe:
    exec:
      command:
      - ls
      - /var/log/aspera
    initialDelaySeconds: 2
    periodSeconds: 30
  volumeMounts:
  - name: external-process-log
    mountPath: /var/log/aspera
{{- end }}


# ----
# Common initContainer specs
# ----

{{ define "hsts.spec.init.probe.curl" -}}
  {{- $params := . -}}
  {{- $context := index $params 0 -}}
  {{- $name := index $params 1 -}}
  {{- $host := index $params 2 -}}
- name: {{ $name }}-probe
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.probe" $context }}
  imagePullPolicy: {{ $context.Values.probe.image.pullPolicy }}
{{  include "hsts.resources.static.small" . | indent 2 }}
  command: ['/bin/bash', '-c', 'until curl --connect-timeout 3 -ki {{ $host }}; do echo Waiting for {{ $name }}...; sleep 1; done']
{{- end }}

# Wait for asperanode api for be responsive
#   curl https://(asperanode api service):(asperanode port)/ping
{{ define "hsts.spec.init.probe.asperanode" -}}
{{- $curl := list . "node" -}}
{{- $port := int64 .Values.asperanode.httpsPort -}}
{{- $host := printf "https://%s:%d/%s" (include "sch.names.fullCompName" (list . .sch.chart.components.asperanode.service.api)) $port "ping" -}}
{{- $curl := append $curl $host }}
{{ include "hsts.spec.init.probe.curl" ($curl) }}
{{- end }}

# Wait for ascp swarm api for be responsive
#   curl (ascp_swarm_service)/nodes
{{ define "hsts.spec.init.probe.ascpSwarm" -}}
{{- $curl := list . "swarm" -}}
{{- $curl := append $curl (printf "%s/%s" (include "sch.names.fullCompName" (list . .sch.chart.components.ascpSwarm.compName))  "nodes") }}
{{ include "hsts.spec.init.probe.curl" ($curl) }}
{{- end }}

# Wait for noded swarm api for be responsive
#   curl (noded_swarm_service)/nodes
{{ define "hsts.spec.init.probe.nodedSwarm" -}}
{{- $curl := list . "swarm" -}}
{{- $curl := append $curl (printf "%s/%s" (include "sch.names.fullCompName" (list . .sch.chart.components.nodedSwarm.compName))  "nodes") }}
{{ include "hsts.spec.init.probe.curl" ($curl) }}
{{- end }}

# Wait for stats api for be responsive
#   curl (stats_service)/stats
{{ define "hsts.spec.init.probe.stats" -}}
{{- $curl := list . "stats" -}}
{{- $curl := append $curl (printf "%s/%s" (include "sch.names.fullCompName" (list . .sch.chart.components.stats.compName))  "stats") }}
{{ include "hsts.spec.init.probe.curl" ($curl) }}
{{- end }}

# Wait for ascp loadbalancer api for be responsive
#   curl (ascp_loadbalancer_service)/allocations
{{ define "hsts.spec.init.probe.ascpLoadbalancer" -}}
{{- $curl := list . "loadbalancer" -}}
{{- $curl := append $curl (printf "%s/%s" (include "sch.names.fullCompName" (list . .sch.chart.components.ascpLoadbalancer.compName))  "allocations") }}
{{ include "hsts.spec.init.probe.curl" ($curl) }}
{{- end }}

# Wait for noded loadbalancer api for be responsive
#   curl (noded_loadbalancer_service)/allocations
{{ define "hsts.spec.init.probe.nodedLoadbalancer" -}}
{{- $curl := list . "loadbalancer" -}}
{{- $curl := append $curl (printf "%s/%s" (include "sch.names.fullCompName" (list . .sch.chart.components.nodedLoadbalancer.compName))  "allocations") }}
{{ include "hsts.spec.init.probe.curl" ($curl) }}
{{- end }}

{{ define "hsts.spec.init.probe.aej" -}}
- name: aej-probe
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.probe" . }}
  imagePullPolicy: {{ .Values.probe.image.pullPolicy }}
{{  include "hsts.resources.static.small" . | indent 2 }}
  command: ['/bin/bash', '-c', 'until nc -zv {{ template "hsts.hosts.aej" . }} {{ template "hsts.ports.aej" . }}; do echo Waiting for aej...; sleep 1; done']
{{- end }}

{{ define "hsts.spec.init.probe.kafka" -}}
- name: kafka-probe
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.probe" . }}
  imagePullPolicy: {{ .Values.probe.image.pullPolicy }}
{{  include "hsts.resources.static.small" . | indent 2 }}
  command: ['/bin/bash', '-c', 'until timeout 3 nc -vz {{ template "hsts.hosts.kafka" . }} {{ template "hsts.ports.kafka" . }}; do echo Waiting for kafka...; sleep 1; done']
{{- end }}

{{ define "hsts.spec.init.probe.redis" -}}
- name: redis-probe
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.probe" . }}
  imagePullPolicy: {{ .Values.probe.image.pullPolicy }}
{{  include "hsts.resources.static.small" . | indent 2 }}
  command: ['/bin/bash', '-c', 'until redis-cli -h {{ template "hsts.hosts.redis" . }} -p {{ template "hsts.ports.redis" . }} ping; do echo Waiting for redis...; sleep 1; done']
{{- end }}

{{ define "hsts.spec.init.probe.redisMaster" -}}
- name: wait-redis-master
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.probe" . }}
  imagePullPolicy: {{ .Values.probe.image.pullPolicy }}
{{  include "hsts.resources.static.small" . | indent 2 }}
  command: ['/bin/bash', '-c', 'until [ -n "$(redis-cli -h {{ template "hsts.hosts.redis" . }} -p {{ template "hsts.ports.redis" . }} get skv:clmaster:str)" ]; do echo Waiting for redis...; sleep 1; done']
{{- end }}

{{ define "hsts.spec.init.asperacert" -}}
- name: asperacert
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.probe" . }}
  imagePullPolicy: {{ .Values.probe.image.pullPolicy }}
{{  include "hsts.resources.static.small" . | indent 2 }}
  volumeMounts:
  - name: asperanoded-cert
    mountPath: "/opt/aspera/tls"
  - name: aspera-conf
    mountPath: "/opt/aspera/tmp"
  command: ["/bin/sh","-c"]
  args: ["
          cat /opt/aspera/tls/tls.key > /opt/aspera/tmp/aspera_server_cert.pem &&
          cat /opt/aspera/tls/tls.crt >> /opt/aspera/tmp/aspera_server_cert.pem
        "]
{{- end }}

# Define an init container that configures the aspera.conf
#
# Takes in params:
#   1) scope
#   2) list of asconfigurator commands (i.e set_node_data;token_encryption_key,1234)
#
# Order of asconfigurator commands executed:
#   1) User values provided via .Values.asperaconfig
#   2) Parameters passed via calling template
#   3) Setting token_encryption_key specified via serverSecret
{{ define "hsts.spec.init.asperaconf" -}}
  {{- $params := . -}}
  {{- $top := first $params }}
- name: asperaconf
  securityContext:
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 8000
    capabilities:
      drop:
      - ALL
  image: {{ include "hsts.image.asperanode" $top }}
  imagePullPolicy: {{ $top.Values.asperanode.image.pullPolicy }}
{{  include "hsts.resources.static.small" . | indent 2 }}
  env:
    - name: SSHD_FINGERPRINT
      valueFrom:
        secretKeyRef:
          name: {{ include "hsts.secret.sshdKeys" $top }}
          key: SSHD_FINGERPRINT
    - name: TOKEN_ENCRYPTION_KEY
      valueFrom:
        secretKeyRef:
          name: {{ $top.Values.asperanode.serverSecret }}
          key: TOKEN_ENCRYPTION_KEY
    - name: NODE_ID
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
  volumeMounts:
  - name: aspera-conf
    mountPath: "/opt/aspera/tmp"
  - name: aspera-configmap
    mountPath: /opt/aspera/etc/aspera.conf.orig
    subPath: aspera.conf
  command: ["/bin/sh","-c"]
  args: ["
          cp /opt/aspera/etc/aspera.conf.orig /opt/aspera/tmp/aspera.conf &&
      {{- if $top.Values.asperaconfig -}}
        {{- range $k := $top.Values.asperaconfig }}
          {{- if eq (empty $k) false }}
          /opt/aspera/bin/asconfigurator -x \"{{ $k }}\" /opt/aspera/tmp/aspera.conf /opt/aspera/tmp/aspera.conf &&
          {{- end -}}
        {{- end }}
      {{- end -}}
          /opt/aspera/bin/asconfigurator -x \"set_server_data;ssh_host_key_fingerprint,$SSHD_FINGERPRINT\" /opt/aspera/tmp/aspera.conf /opt/aspera/tmp/aspera.conf &&
          /opt/aspera/bin/asconfigurator -x \"set_server_data;node_id,$NODE_ID\" /opt/aspera/tmp/aspera.conf /opt/aspera/tmp/aspera.conf &&
          /opt/aspera/bin/asconfigurator -x \"set_node_data;token_encryption_key,$TOKEN_ENCRYPTION_KEY\" /opt/aspera/tmp/aspera.conf /opt/aspera/tmp/aspera.conf &&
      {{- if (gt (len $params) 1) -}}
        {{- $moreLabels := (index $params 1) -}}
        {{- range $k := $moreLabels }}
          /opt/aspera/bin/asconfigurator -x \"{{ $k }}\" /opt/aspera/tmp/aspera.conf /opt/aspera/tmp/aspera.conf &&
        {{- end -}}
      {{- end }}
          ls /opt/aspera/tmp/aspera.conf
        "]

{{- end }}

{{ define "hsts.default.accessKeyConfig" -}}
transfer:
  target_rate_kbps: 100000
{{- end }}
