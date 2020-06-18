{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"assistant.sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "assistant.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-watson-assistant-prod-1.4.2"
    labelType: new
    metering:
      productName:              "IBM Watson Assistant for IBM Cloud Pak for Data"
      productID:                "ICP4D-addon-fa92c14a5cd74c31aab1616889cbe97a-assistant"
      productVersion:           "1.4.2"
      cloudpakName:             "IBM Cloud Pak for Data"
      cloudpakId:               "eb9998dcc5d24e3eb5b6fb488f750fe2"
      cloudpakVersion:          "3.0.0"
      productChargedContainers: "All"
      productMetric:            "VIRTUAL_PROCESSOR_CORE"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
        - amd64
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
{{- end -}}
