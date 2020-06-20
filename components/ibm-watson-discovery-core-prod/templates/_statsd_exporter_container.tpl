{{- define "wire.statsdExporter.container" -}}
{{- $root := (index . 0) -}}
{{- if $root.Values.global.metricsCollection.enabled -}}
# Statsd Prometheus Exporter Sidecar Container
- name: statsd-exporter
  image: {{ $root.Values.global.dockerRegistryPrefix }}/
    {{- $root.Values.wire.statsd.image.name }}:
    {{- $root.Values.wire.statsd.image.tag }}
{{ include "sch.security.securityContext" (list $root $root.sch.chart.restrictedSecurityContext) | indent 2 }}
  resources:
{{ toYaml $root.Values.wire.statsd.resources | indent 4 }}
  args:
  - "--statsd.listen-udp=localhost:8125"
  - "--statsd.mapping-config"
  - "/etc/statsd/statsd_exporter_mapping.yml"
  - "--web.listen-address=:{{ $root.Values.wire.statsd.exporterPrometheusPort }}"
  ports:
  - containerPort: {{ $root.Values.wire.statsd.exporterPrometheusPort }}
  livenessProbe:
    httpGet:
      path: "/"
      port: {{ $root.Values.wire.statsd.exporterPrometheusPort }}
      scheme: HTTP
    initialDelaySeconds: 20
    timeoutSeconds: 20
    periodSeconds: 60
  readinessProbe:
    httpGet:
      path: "/"
      port: {{ $root.Values.wire.statsd.exporterPrometheusPort }}
      scheme: HTTP
    initialDelaySeconds: 20
    timeoutSeconds: 20
    periodSeconds: 60
  volumeMounts:
  - name: {{ $root.Values.wire.configVolume }}
    mountPath: /etc/statsd/statsd_exporter_mapping.yml
    subPath: statsd_exporter_mapping.yml
{{- end -}}
{{- end -}}
