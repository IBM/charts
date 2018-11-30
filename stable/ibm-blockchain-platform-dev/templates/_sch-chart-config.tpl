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
  names:
    fullCompName:
      maxLength: 62
      releaseNameTruncLength: 30
      appNameTruncLength: 7
      compNameTruncLength: 25

  chart:
    appName: "ibm-ibp"

    components: 
      ca:
        compName: "ca"
        appName: "ibp-ca"
      orderer:
        compName: "orderer"
        appName: "ibp-orderer"
      peer:
        compName: "peer"
        appName: "ibp-peer"

    metering:
      productName: "IBM Blockchain Platform Community Edition"
      productID: "IBMBlockchainPlatformCommunityEdition_100_ilan_00000"
      productVersion: {{ .Chart.Version }}

{{- end -}}
