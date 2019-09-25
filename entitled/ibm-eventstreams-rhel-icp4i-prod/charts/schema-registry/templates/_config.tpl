{{- define "schemaregistry.sch.chart.config.values" -}}
sch:
  config:

    #
    # Schema Registry-specific settings not intended for overriding
    #
    schemaregistry:
      # Number of replicas for the Schema Registry API server
      replicas: 1

{{- end -}}
