{{- define "rest.sch.chart.config.values" -}}
sch:
  config:

    #
    # REST API-specific settings not intended for overriding
    #
    rest:

      # Number of replicas for the REST API server
      replicas: 1

{{- end -}}
