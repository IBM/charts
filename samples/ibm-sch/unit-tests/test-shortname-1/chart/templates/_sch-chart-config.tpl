{{- define "test-01.sch.chart.config.values" -}}
sch:
  chart:
    shortName: "test-01-shortName"
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
{{- end -}}
