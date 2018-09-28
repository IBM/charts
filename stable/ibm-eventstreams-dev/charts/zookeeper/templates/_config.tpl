{{- define "zookeeper.sch.chart.config.values" -}}
sch:
  config:

    #
    # ZooKeeper-specific settings not intended for overriding
    #
    zookeeper:

      # Number of ZooKeeper nodes in the cluster
      replicas: 3

{{- end -}}
