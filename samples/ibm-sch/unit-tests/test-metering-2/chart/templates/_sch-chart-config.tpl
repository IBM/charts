{{- define "test-01.sch.chart.config.values" -}}
sch:
  chart:
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
    components:
      common:
        name: "test01-common"
    labelType: prefixed
    metering:
      productName: "sch test chart"
      productVersion: "1.0.0"
      productID: "b39d3276f8464e15981ac292975243a2"
      productMetric: "PVU"
      productChargedContainers: "All"
{{- end -}}
