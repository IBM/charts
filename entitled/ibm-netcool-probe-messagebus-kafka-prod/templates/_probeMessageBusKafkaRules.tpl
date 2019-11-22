{{/* Message Bus Kafka Probe for configuration - only used when using standard rules*/}}
{{- define "ibm-netcool-probe-messagebus-kafka-prod.probeMessageBusKafkaRules" }}

message_bus.rules: |
{{- include "ibm-netcool-probe-messagebus-kafka-prod.probeMessageBusKafkaRules-kafka" . | indent 2 }}

message_bus_netcool.rules: |
{{- include "messagebus.probeMessageBusRules-netcool" . | indent 2 }}

message_bus_wbe.rules: |
{{- include "messagebus.probeMessageBusRules-wbe" . | indent 2 }}

message_bus_cbe.rules: |
{{- include "messagebus.probeMessageBusRules-cbe" . | indent 2 }}

message_bus_wef.rules: |
{{- include "messagebus.probeMessageBusRules-wef" . | indent 2 }}

{{- end }}