{{- define "kafka.listeners.sch.chart.config.values" -}}
{{- include "sch.config.init" (list . "ports.sch.chart.config.values") | trim -}}
{{ $ports := .sch.config.ports -}}
sch:
  config:
    kafka:
      listeners: "INTERNAL://:{{- $ports.kafka.internalKafka -}},EXTERNAL://:{{- $ports.kafka.externalSecure -}},INTERNAL_SECURE://:{{- $ports.kafka.internalEventStreamsSecure -}}"
      internalAdvertisedListeners: "INTERNAL://:{{- $ports.kafka.internalKafka -}},INTERNAL_SECURE://:{{- $ports.kafka.internalEventStreamsSecureIntercept -}}"
      protocols: "INTERNAL:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT,INTERNAL_SECURE:SASL_PLAINTEXT"
      kafkaProxyMappings: "{{- $ports.kafka.externalSecure -}}:{{- $ports.kafka.externalProxySecure -}},{{- $ports.kafka.internalEventStreamsSecure -}}:{{- $ports.kafka.internalEventStreamsSecureIntercept -}}"
{{- end -}}
