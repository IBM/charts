{{- define "zookeeper.sch.chart.config.values" -}}
sch:
  config:

    #
    # ZooKeeper-specific settings not intended for overriding
    #
    zookeeper:

      #
      # Number of ZooKeeper nodes in the cluster
      # The maximum number of ZK that can be supported is 9 due to the internal port range used in the ZK ConfigMap for the
      # pod-to-pod TLS connection.
      #
      replicas: 3

{{- end -}}
