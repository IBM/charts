{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "iisee.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-iisee-eval"
    components: 
      appconfigservice:
        name: "gov-app-config-service"
      catalogsearchservice:
        name: "gov-catalog-search-service"
      finley:
        name: "finley"
      s4idemoapp:
        name: "shop4info-demoapp"
      iisserver:
        name: "iis-server"
      s4iserver:
        name: "shop4info-server"
      s4isolr:
        name: "shop4info-solr"
      socialkgbridge:
        name: "gov-social-kg-bridge"
      socialservice:
        name: "gov-social-service"
      userprefservice:
        name: "gov-user-prefs-service"
      haproxy:
        name: "haproxy"
    metering:
      productName: "IBM InfoSphere Information Server for Evaluation v11.7"
      productID: "IBMInfoSphereInformationServerForEvaluationv11.7_117_EVALUATION_00000"
      productVersion: "11.7"        
{{- end -}}
