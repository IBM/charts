{{- define "test-01.sch.chart.config.values" -}}
sch:
  chart:
    podAffinity:
      requiredDuringScheduling:
        key: security
        operator: In
        topologyKey: failure-domain.beta.kubernetes.io/zone
        values:
        - S1
      requiredDuringSchedulingRequiredDuringExecution:
        key: security
        operator: In
        topologyKey: failure-domain.beta.kubernetes.io/zone
        values:
        - S3
      preferredDuringScheduling:
        S2:
          weight: 200
          key: security
          operator: In
          topologyKey: kubernetes.io/hostname
    components:
      common:
        name: "test01-common"
    labelType: prefixed
{{- end -}}
