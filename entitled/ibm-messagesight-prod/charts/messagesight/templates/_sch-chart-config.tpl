{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "server.sch.chart.config.values" -}}
sch:
  chart:
    appName: "messagesight"
    metering:
      prod:
        productName: "IBM IoT MessageSight Server"
        productID: "8202fafbef5943eea9520750c3424be6"
      nonprod:
        productName: "IBM IoT MessageSight Server Non-Production"
        productID: "f5ac98f854d54682896b56c9958989f4"
      standby:
        productName: "IBM IoT MessageSight Server Idle Standby"
        productID: "5628710ec4fb48baa206ff2c096c474e"
      dev:
        productName: "IBM IoT MessageSight Server for Developers"
        productID: "IBMIoTMessageSightServer_2.0.0.2_Developers_00000"
{{- end -}}

{{- /*
"sch.chart.nodeAffinity" contains the chart specific values used to provide
information about which nodes are suitable for installation of the chart.
*/ -}}
{{- define "server.sch.chart.nodeAffinity" -}}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
        - amd64
{{- end -}}
