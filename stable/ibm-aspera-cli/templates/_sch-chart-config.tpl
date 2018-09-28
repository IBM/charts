{{- define "sch.chart.config.values" -}}
sch:
  names:
    fullCompName:
      maxLength: 92
      releaseNameTruncLength: 36
      appNameTruncLength: 17
      compNameTruncLength: 39

  chart:
    appName: "ibm-aspera-cli"
    components:
      cli:
        prefix: "ibm-aspera-cli"
        compName: "ibm-aspera-cli"
        cronJob:
          name: "cronjob"
        job:
          name: "job"
        configMap:
          name: "cm"
        test:
          name: "test"
    metering:
      productName: "IBM Aspera Command-Line Interface (CLI)"
      productID: "IBMAsperaCLI_3900_ilan_00000"
      productVersion: "3.9.0.0"
{{- end -}}
