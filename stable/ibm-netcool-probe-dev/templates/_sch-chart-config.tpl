{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "probe.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-netcool-probe"
    components: 
      prometheus:
        # the component name
        name: "prometheusprobe"
        configmap:
          config:
            name: "prometheusprobe-config"
          rules:
            name: "prometheusprobe-rules"

      logstash:
        # the component name
        name: "logstashprobe"
        configmap:
          config:
            name: "logstashprobe-config"
          rules:
            name: "logstashprobe-rules"

    metering:
      productName: "IBM Netcool/OMNIbus Probe for Message Bus"
      productID: "2150A086BAF34CE8959EC9B9182036E4"
      productVersion: '7.0'
{{- end -}}

