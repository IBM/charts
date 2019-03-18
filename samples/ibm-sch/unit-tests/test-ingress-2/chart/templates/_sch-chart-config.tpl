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
    nginx:
      ingress:
        ingress.kubernetes.io/rewrite-target: /
        ingress.kubernetes.io/proxy-body-size: "0"
        ingress.kubernetes.io/proxy-buffering: "off"
{{- end -}}
