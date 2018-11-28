{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Prometheus Configuration Files */}}
{{- define "prometheusConfig" }}
prometheus.yml: |-
  global:
    scrape_interval: {{ .Values.prometheus.scrapeInterval }}
    evaluation_interval: {{ .Values.prometheus.evaluationInterval }}

  alerting:
    alertmanagers:
    - static_configs:
      - targets:
        - '{{ template "prometheus.fullname" . }}-alertmanager:{{ .Values.alertmanager.port }}'
    {{- if or (eq .Values.mode "managed") .Values.tls.enabled }}
      scheme: https
      tls_config:
        cert_file: /opt/ibm/monitoring/certs/{{ .Values.tls.client.certFieldName }}
        key_file: /opt/ibm/monitoring/certs/{{ .Values.tls.client.keyFieldName }}
        insecure_skip_verify: true
    {{- else }}
      scheme: http
      path_prefix: /alertmanager
    {{- end }}

  rule_files:
    - /etc/alert-rules/*.rules
    - /etc/alert-rules/*.yml

  scrape_configs:
    - job_name: prometheus
      static_configs:
        - targets:
          - 127.0.0.1:9090
      metrics_path: /prometheus/metrics

    # A scrape configuration for running Prometheus on a Kubernetes cluster.
    # This uses separate scrape configs for cluster components (i.e. API server, node)
    # and services to allow each to use different authentication configs.
    #
    # Kubernetes labels will be added as Prometheus labels on metrics via the
    # `labelmap` relabeling action.

    # Scrape config for API servers.
    #
    # Kubernetes exposes API servers as endpoints to the default/kubernetes
    # service so this uses `endpoints` role and uses relabelling to only keep
    # the endpoints associated with the default/kubernetes service using the
    # default named port `https`. This works for single API server deployments as
    # well as HA API server deployments.
    - job_name: 'kubernetes-apiservers'

      kubernetes_sd_configs:
        - role: endpoints

      # Default to scraping over https. If required, just disable this or change to
      # `http`.
      scheme: https

      # This TLS & bearer token file config is used to connect to the actual scrape
      # endpoints for cluster components. This is separate to discovery auth
      # configuration because discovery & scraping are two separate concerns in
      # Prometheus. The discovery auth config is automatic if Prometheus runs inside
      # the cluster. Otherwise, more config options have to be provided within the
      # <kubernetes_sd_config>.
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        # If your node certificates are self-signed or use a different CA to the
        # master CA, then disable certificate verification below. Note that
        # certificate verification is an integral part of a secure infrastructure
        # so this should only be disabled in a controlled environment. You can
        # disable certificate verification by uncommenting the line below.
        #
        insecure_skip_verify: true
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

      # Keep only the default/kubernetes service endpoints for the https port. This
      # will add targets for each API server which Kubernetes adds an endpoint to
      # the default/kubernetes service.
      relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https

    - job_name: 'kubernetes-nodes'

      # Default to scraping over https. If required, just disable this or change to
      # `http`.
      scheme: https

      # This TLS & bearer token file config is used to connect to the actual scrape
      # endpoints for cluster components. This is separate to discovery auth
      # configuration because discovery & scraping are two separate concerns in
      # Prometheus. The discovery auth config is automatic if Prometheus runs inside
      # the cluster. Otherwise, more config options have to be provided within the
      # <kubernetes_sd_config>.
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        # If your node certificates are self-signed or use a different CA to the
        # master CA, then disable certificate verification below. Note that
        # certificate verification is an integral part of a secure infrastructure
        # so this should only be disabled in a controlled environment. You can
        # disable certificate verification by uncommenting the line below.
        #
        insecure_skip_verify: true
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

      kubernetes_sd_configs:
        - role: node

      relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics

    # Scrape config for Kubelet cAdvisor.
    #
    # This is required for Kubernetes 1.7.3 and later, where cAdvisor metrics
    # (those whose names begin with 'container_') have been removed from the
    # Kubelet metrics endpoint.  This job scrapes the cAdvisor endpoint to
    # retrieve those metrics.
    #
    # In Kubernetes 1.7.0-1.7.2, these metrics are only exposed on the cAdvisor
    # HTTP endpoint; use "replacement: /api/v1/nodes/${1}:4194/proxy/metrics"
    # in that case (and ensure cAdvisor's HTTP server hasn't been disabled with
    # the --cadvisor-port=0 Kubelet flag).
    #
    # This job is not necessary and should be removed in Kubernetes 1.6 and
    # earlier versions, or it will cause the metrics to be scraped twice.
    - job_name: 'kubernetes-cadvisor'

      # Default to scraping over https. If required, just disable this or change to
      # `http`.
      scheme: https

      # This TLS & bearer token file config is used to connect to the actual scrape
      # endpoints for cluster components. This is separate to discovery auth
      # configuration because discovery & scraping are two separate concerns in
      # Prometheus. The discovery auth config is automatic if Prometheus runs inside
      # the cluster. Otherwise, more config options have to be provided within the
      # <kubernetes_sd_config>.
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

      kubernetes_sd_configs:
      - role: node

      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor

      metric_relabel_configs:
      - source_labels: ['namespace']
        regex: (.*)
        target_label: kubernetes_namespace

    # Scrape config for service endpoints.
    #
    # The relabeling allows the actual service scrape endpoint to be configured
    # via the following annotations:
    #
    # * `prometheus.io/scrape`: Only scrape services that have a value of `true`
    # * `prometheus.io/scheme`: If the metrics endpoint is secured then you will need
    # to set this to `https` & most likely set the `tls_config` of the scrape config.
    # * `prometheus.io/path`: If the metrics path is not `/metrics` override this.
    # * `prometheus.io/port`: If the metrics are exposed on a different port to the
    # service then set this appropriately.
    - job_name: 'kubernetes-service-endpoints'

      kubernetes_sd_configs:
        - role: endpoints

      relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: drop
          regex: https
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: replace
          target_label: __scheme__
          regex: (https?)
        - source_labels: [__meta_kubernetes_endpoint_port_name, __meta_kubernetes_service_annotation_filter_by_port_name]
          action: drop
          regex: ^([^m].+|m[^e].+|me[^t].+|met[^r].+|metr[^i].+|metri[^c].+|metric[^s]).*;true 
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name

    # Scrape config for service endpoints with tls enabled.
    #
    # The relabeling allows the actual service scrape endpoint to be configured
    # via the following annotations:
    #
    # * `prometheus.io/scrape`: Only scrape services that have a value of `true`
    # * `prometheus.io/scheme`: If the metrics endpoint is secured then you will need
    # to set this to `https` & most likely set the `tls_config` of the scrape config.
    # * `prometheus.io/path`: If the metrics path is not `/metrics` override this.
    # * `prometheus.io/port`: If the metrics are exposed on a different port to the
    # service then set this appropriately.
    - job_name: 'kubernetes-service-endpoints-with-tls'

      kubernetes_sd_configs:
        - role: endpoints

      relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_skip_verify]
          action: drop
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: keep
          regex: https
        - source_labels: [__meta_kubernetes_endpoint_port_name, __meta_kubernetes_service_annotation_filter_by_port_name]
          action: drop
          regex: ^([^m].+|m[^e].+|me[^t].+|met[^r].+|metr[^i].+|metri[^c].+|metric[^s]).*;true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_namespace]
          action: replace
          target_label: __address__
          regex: (\d+).(\d+).(\d+).(\d+):(\d+);(.+)
          replacement: $1-$2-$3-$4.$6.pod.{{ .Values.clusterDomain }}:$5
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name

      scheme: https

      tls_config:
        ca_file: /opt/ibm/monitoring/caCerts/{{ .Values.tls.ca.certFieldName }}
        cert_file: /opt/ibm/monitoring/certs/{{ .Values.tls.client.certFieldName }}
        key_file: /opt/ibm/monitoring/certs/{{ .Values.tls.client.keyFieldName }}
        insecure_skip_verify: false

  {{- if or (eq .Values.mode "managed") .Values.tls.enabled }}
    - job_name: 'node-exporter-endpoints-with-tls'

      kubernetes_sd_configs:
        - role: endpoints

      relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_skip_verify]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: keep
          regex: https
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name

      scheme: https

      tls_config:
        ca_file: /opt/ibm/monitoring/caCerts/{{ .Values.tls.ca.certFieldName }}
        cert_file: /opt/ibm/monitoring/certs/{{ .Values.tls.client.certFieldName }}
        key_file: /opt/ibm/monitoring/certs/{{ .Values.tls.client.keyFieldName }}
        insecure_skip_verify: true
  {{- end }}

    # Example scrape config for probing services via the Blackbox Exporter.
    #
    # The relabeling allows the actual service scrape endpoint to be configured
    # via the following annotations:
    #
    # * `prometheus.io/probe`: Only probe services that have a value of `true`
    - job_name: 'kubernetes-services'

      metrics_path: /probe
      params:
        module: [http_2xx]

      kubernetes_sd_configs:
        - role: service

      relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_probe]
          action: keep
          regex: true
        - source_labels: [__address__]
          target_label: __param_target
        - target_label: __address__
          replacement: blackbox
        - source_labels: [__param_target]
          target_label: instance
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          target_label: kubernetes_name

    # Example scrape config for pods
    #
    # The relabeling allows the actual pod scrape endpoint to be configured via the
    # following annotations:
    #
    # * `prometheus.io/scrape`: Only scrape pods that have a value of `true`
    # * `prometheus.io/path`: If the metrics path is not `/metrics` override this.
    # * `prometheus.io/port`: Scrape the pod on the indicated port instead of the default of `9102`.
    - job_name: 'kubernetes-pods'

      kubernetes_sd_configs:
        - role: pod

      relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: ${1}:${2}
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_target]
          action: replace
          target_label: __param_target
          regex: (.*)
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_module]
          action: replace
          target_label: __param_module
          regex: (.*)

  {{- if .Values.prometheus.etcdTarget.enabled }}
    - job_name: etcd
      scheme: https
      static_configs:
      - targets:
      {{- range .Values.prometheus.etcdTarget.etcdAddress }}
        - {{ printf "%s:%s" . $.Values.prometheus.etcdTarget.etcdPort | quote }}
      {{- end }}
      tls_config:
      {{- if eq .Values.mode "managed" }}
        ca_file: /etc/etcd/etcd-ca
        cert_file: /etc/etcd/etcd-cert
        key_file: /etc/etcd/etcd-key
        insecure_skip_verify: true
      {{- end }}
      {{- if .Values.prometheus.etcdTarget.tlsConfig }}
{{ toYaml .Values.prometheus.etcdTarget.tlsConfig | indent 8 }}
      {{- end }}
  {{- end }}
{{- end }}
