{{- define "sduStatsdExporter.container" -}}
{{- $root := (index . 0) -}}
{{- if $root.Values.global.metricsCollection.enabled -}}
# Statsd Prometheus Exporter Sidecar Container
- name: stats
  image: {{ $root.Values.global.dockerRegistryPrefix }}/
     {{- $root.Values.sdu.statsd.image.name }}:
     {{- $root.Values.sdu.statsd.image.tag }}
{{ include "sch.security.securityContext" (list $root $root.sch.chart.watsonUserSecurityContext) | indent 2 }}
  resources:
{{ toYaml $root.Values.sdu.statsd.resources | indent 4 }}  
  args:
    - "--statsd.listen-udp=localhost:{{- $root.Values.sdu.statsd.port -}}"
    - "--statsd.mapping-config"
    - "/etc/statsd/statsd_exporter_mapping.yml"
    - "--web.listen-address=:{{ $root.Values.sdu.statsd.prom_port }}"
  ports:
    - containerPort: {{ $root.Values.sdu.statsd.prom_port }}
  livenessProbe:
    tcpSocket:
      port: {{ $root.Values.sdu.statsd.prom_port }}
    initialDelaySeconds: {{ $root.Values.sdu.statsd.livenessProbe.initialDelaySeconds }}
    timeoutSeconds: {{ $root.Values.sdu.statsd.livenessProbe.timeoutSeconds }}
    periodSeconds: {{ $root.Values.sdu.statsd.livenessProbe.periodSeconds }}
    failureThreshold: {{ $root.Values.sdu.statsd.livenessProbe.failureThreshold }}
  readinessProbe:
    tcpSocket:
      port: {{ $root.Values.sdu.statsd.prom_port }}
    initialDelaySeconds: {{ $root.Values.sdu.statsd.readinessProbe.initialDelaySeconds }}
    timeoutSeconds: {{ $root.Values.sdu.statsd.readinessProbe.timeoutSeconds }}
    periodSeconds: {{ $root.Values.sdu.statsd.readinessProbe.periodSeconds }}
    failureThreshold: {{ $root.Values.sdu.statsd.readinessProbe.failureThreshold }}
  volumeMounts:
    - name: statsd-exporter-config
      mountPath: /etc/statsd
{{- end -}}
{{- end -}}
