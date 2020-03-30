{{- define "kafka.listeners.sch.chart.config.values" -}}
{{- include "sch.config.init" (list . "ports.sch.chart.config.values") | trim -}}
{{- $internalPrefix := .sch.chart.components.proxy.internalPrefix -}}
{{ $ports := .sch.config.ports -}}
sch:
  config:
    kafka:
      listeners: "{{ $internalPrefix }}://:{{- $ports.kafka.internalKafka -}},EXTERNAL://:{{- $ports.kafka.externalSecure -}},{{ $internalPrefix }}_SECURE://:{{- $ports.kafka.internalEventStreamsSecure -}},{{ $internalPrefix }}_LOOPBACK://:{{- $ports.kafka.internalLoopback -}}"
      internalAdvertisedListeners: "{{ $internalPrefix }}_SECURE://:{{- $ports.kafka.internalEventStreamsSecureIntercept -}},{{ $internalPrefix }}_LOOPBACK://:{{- $ports.kafka.internalLoopbackIntercept -}}"
      protocols: "{{ $internalPrefix }}:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT,{{ $internalPrefix }}_SECURE:SASL_PLAINTEXT,{{ $internalPrefix }}_LOOPBACK:SASL_PLAINTEXT"
      kafkaProxyMappings: "{{- $ports.kafka.externalSecure -}}:{{- $ports.kafka.externalProxySecure -}},{{- $ports.kafka.internalEventStreamsSecure -}}:{{- $ports.kafka.internalEventStreamsSecureIntercept -}},{{- $ports.kafka.internalLoopback -}}:{{- $ports.kafka.internalLoopbackIntercept -}}"
{{- end -}}