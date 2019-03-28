{{- define "restproducer.sch.chart.config.values" -}}
sch:
  config:

    #
    # REST Producer API-specific settings not intended for overriding
    #
    restproducer:

      # Resource limits to apply to the REST Producer API chart
      # ref: http://kubernetes.io/docs/user-guide/compute-resources/
      resources:
        limits:
          cpu: 4000m
          memory: 2Gi
        requests:
          cpu: 500m
          memory: 1Gi

      # Number of replicas for the REST Producer API server
      replicas: 1

{{- end -}}
