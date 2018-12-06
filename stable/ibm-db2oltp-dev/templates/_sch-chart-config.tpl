{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "db2oltp.sch.chart.config.values" -}}
sch:
  chart:
    appName: db2oltp
    components: 
      db2:
        name: "db2"
      etcd:
        name: "etcd"
    metering:
      productName: "Db2 Developer-C Edition"
      productID: "IBMDb2DeveloperCEdition_11133_dev_00000"
      productVersion: "11.1.4.4"        
{{- end -}}
