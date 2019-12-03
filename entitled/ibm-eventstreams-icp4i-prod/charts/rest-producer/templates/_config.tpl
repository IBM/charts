{{- define "restproducer.sch.chart.config.values" -}}
sch:
  config:

    #
    # REST Producer API-specific settings not intended for overriding
    #
    restproducer:
      # Number of replicas for the REST Producer API server
      replicas: 1

{{- end -}}
