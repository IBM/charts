{{- define "test-sec-gen-01.sch.chart.config.values" -}}
sch:
  chart:
    secretGen:
      suffix: default-suffix
      overwriteExisting: true
      createJobHookOverride: pre-install,pre-upgrade
      secrets:
      - name: passwords
        create: true
        type: generic
        values:
        - name: MYCHART_ROOT_PASSWORD
          length: 30
        - name: MYCHART_PASSWORD
          length: 30
      - name: mychart.myhost.com
        create: {{ empty .Values.tlsSecret }}
        type: tls
        cn: mychart.myhost.com
    components:
      common:
        name: "test01-common"
    labelType: prefixed
{{- end -}}
