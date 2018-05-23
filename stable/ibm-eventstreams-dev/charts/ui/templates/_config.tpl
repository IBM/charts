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
          cpu: 100m
          memory: 250Mi
        requests:
          cpu: 100m
          memory: 250Mi

      # Number of replicas for the UI server
      replicas: 1

      ports:
        # Port number for the UI web server on individual UI pods
        targetPort: 3000
        # Port number that the Service uses to expose the UI web server within the cluster
        port: 3000

      proxy:
        # Port number that the Service uses to expose the UI web server within the cluster
        port: 32000

{{- end -}}
