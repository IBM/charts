{{- define "zookeeper.sch.chart.config.values" -}}
sch:
  config:

    #
    # ZooKeeper-specific settings not intended for overriding
    #
    zookeeper:

      resources:
        limits:
          memory: 250Mi
        requests:
          memory: 250Mi

      # Port numbers for ZooKeeper
      ports:
        # Incoming client connections
        client: 2181
        # Used for connections between ZooKeeper nodes
        server: 2888
        # Used by ZooKeeper nodes for connections to the leader
        election: 3888

      # Number of ZooKeeper nodes in the cluster
      replicas: 3

{{- end -}}
