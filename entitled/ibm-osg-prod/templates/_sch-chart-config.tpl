{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "osgui.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ui"
    labelType: "prefixed"
    metering:
      productName: IBM Open Source Management
      productID: ICP4D-addon-OSG_10_Prod_00000
      productVersion: 1.0.0.0
{{- end -}}

{{- define "osgflask.sch.chart.config.values" -}}
sch:
  chart:
    appName: "flaskapi"
    labelType: "prefixed"
    metering:
      productName: IBM Open Source Management
      productID: ICP4D-addon-OSG_10_Prod_00000
      productVersion: 1.0.0.0
{{- end -}}

{{- define "osgdb.sch.chart.config.values" -}}
sch:
  chart:
    appName: "db"
    labelType: "prefixed"
    metering:
      productName: IBM Open Source Management
      productID: ICP4D-addon-OSG_10_Prod_00000
      productVersion: 1.0.0.0
{{- end -}}

{{- define "osgapi.sch.chart.config.values" -}}
sch:
  chart:
    appName: "api"
    labelType: "prefixed"
    metering:
      productName: IBM Open Source Management
      productID: ICP4D-addon-OSG_10_Prod_00000
      productVersion: 1.0.0.0
{{- end -}}

{{- define "osgnginx.sch.chart.config.values" -}}
sch:
  chart:
    appName: "nginx-configmap"
    labelType: "prefixed"
{{- end -}}

{{- define "osgaddon.sch.chart.config.values" -}}
sch:
  chart:
    appName: "addon-configmap"
    labelType: "prefixed"
{{- end -}}

{{- define "osghpa.sch.chart.config.values" -}}
sch:
  chart:
    appName: "hpa"
    labelType: "prefixed"
{{- end -}}
