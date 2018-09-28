{{- define "ui.sch.chart.config.values" -}}
sch:
  config:

    #
    # UI-specific settings not intended for overriding
    #
    ui:

      # resource limits to apply to the UI pods
      # ref: http://kubernetes.io/docs/user-guide/compute-resources/
      resources:
        limits:
          cpu: 1000m
          memory: 1Gi
        requests:
          cpu: 1000m
          memory: 1Gi

      # Number of replicas for the UI server
      replicas: 1

{{- end -}}
