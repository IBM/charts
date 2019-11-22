{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-dba-ums"
    components:
      ums:
        name: "ums"
      ums-initjob:
        name: "ums-initjob"
      ums-test:
        name: "ums-test"
    # TODO: review product metadata
    metering:
      productName: "IBM Cloud Pak for Automation"
      productID: "5737-I23"
      productVersion: "19.0.2"
    arch:
      amd64: "2 - No preference"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
        - amd64
    labelType: new
{{- end -}}
