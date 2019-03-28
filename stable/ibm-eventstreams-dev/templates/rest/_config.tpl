{{- define "rest.sch.chart.config.values" -}}
sch:
  config:

    #
    # REST API-specific settings not intended for overriding
    #
    rest:

      # Resource limits to apply to the REST API chart
      # ref: http://kubernetes.io/docs/user-guide/compute-resources/
      resources:
        limits:
          cpu: 4000m
          memory: 2Gi
        requests:
          cpu: 500m
          memory: 1Gi

      # Number of replicas for the REST API server
      replicas: 1

    codegen:

      resources:
        limits:
          cpu: 500m
          memory: 500Mi
        requests:
          cpu: 200m
          memory: 300Mi

{{- end -}}
