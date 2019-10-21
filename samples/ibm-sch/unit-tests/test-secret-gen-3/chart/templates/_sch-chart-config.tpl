{{- define "test-sec-gen-01.sch.chart.config.values" -}}
sch:
  chart:
    secretGen:
      suffix: default-suffix
      overwriteExisting: false
      secrets:
      - name: passwords
        create: true
        type: generic
        values:
        - name: MYCHART_ROOT_PASSWORD
          generator: "mychart.secrets.generator.basicAuth"
        - name: MYCHART_PASSWORD
          length: 30
      - name: mychart.myhost.com
        create: {{ empty .Values.tlsSecret }}
        type: tls
        sans: 
        - mychart.myhost.com
    components:
      common:
        name: "test01-common"
    labelType: prefixed
{{- end -}}
