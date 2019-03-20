{{- define "test-01.sch.chart.config.values" -}}
sch:
  chart:
    podAntiAffinity:
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
