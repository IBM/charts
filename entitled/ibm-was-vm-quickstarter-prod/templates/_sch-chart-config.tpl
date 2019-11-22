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
    appName: "ibm-was-vm-quickstarter-prod"
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
      dashboard:
        name: "dashboard"
        servicePort: "4446"
      couchdb:
        name: "couchdb"
        servicePort: "6984"
      common:
        name: "common"
        registryName: "registry"
        secretGeneratorName: "secret-generator"
    metering:
      productName: "IBM WebSphere Application Server for IBM Cloud Private VM Quickstarter"
      productID: "IBMWASQuickStarter_5737E67_3000_IPLA_00000"
      productVersion: "3.0.100.0"
{{- end -}}
