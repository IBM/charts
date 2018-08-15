{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-was-vm-quickstarter"
    components:
      devops:
        name: "devops"
      broker:
        name: "broker"
        servicePort: "4444"
      cloudsmBackend:
        name: "cloudsm-backend"
      cloudsmFrontend:
        name: "cloudsm-frontend"
        servicePort: "4443"
      cloudsmCommon:
        name: "cloudsm-common"
      console:
        name: "console"
        servicePort: "4445"
      couchdb:
        name: "couchdb"
        servicePort: "6984"
      common:
        name: "common"
        registryName: "registry"
        secretGeneratorName: "secret-generator"
    metering:
      productName: "IBM WebSphere Application Server for IBM Cloud Private VM Quickstarter"
      productID: "IBMWASQuickStarter_1000_ILAN_00000"
      productVersion: "1.0.0.0"
{{- end -}}
