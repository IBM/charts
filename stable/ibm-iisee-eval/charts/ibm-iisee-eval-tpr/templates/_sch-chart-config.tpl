{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "iiseesub.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-iisee-eval-tpr"
    components: 
      cassandra:
        name: "cassandra"
      elasticsearch:
        name: "elasticsearch"
      kafka:
        name: "shop4info-kafka"
      kibana:
        name: "kibana"
      logstash:
        name: "logstash"
      zookeeper:
        name: "zookeeper"
    metering:
      productName: "IBM InfoSphere Information Server for Evaluation v11.7"
      productID: "IBMInfoSphereInformationServerForEvaluationv11.7_117_EVALUATION_00000"
      productVersion: "11.7"        
{{- end -}}
