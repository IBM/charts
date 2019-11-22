{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}

{{- define "poRef.sch.chart.config.values" -}}
sch:
  chart:
    appName: "po"
    components:
      dashboard:
        name: "dashboard"
      graphmgmt:
        name: "graphmgmt"
      tenantapi:
        name: "tenantapi"
      up:
        name: "up"
      bs:
        name: "bs"
      smm:
        name: "smm"
      ts:
        name: "ts"
      as:
        name: "as"
      analyticsservice:
        name: "analyticsservice"
      doc:
        name: "doc"
      janusgraph:
        name: "jg"
      nginx:
        name: "nginx"
      autogen:
        secName: "autosecret"
        cerName: "autocert"
        generatorName: "secgen"
      createtenant:
        name: "createtenant"
      createcouchsystemdb:
        name: "createcouchsystemdb"
      createpodb:
        name: "createpodb"
      jvmoptcfg:
        name: "jvmoptcfg"
      popvc:
        name: "popvc"
      affinity:
        name: "po-affinity"
    metering:
      productName: IBM Maximo Production Optimization On-Premises
      productID: 5737J42
      productVersion: v1.0
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
{{ if ne .Values.global.arch.amd64 "0 - Do not use" }}
        - amd64
{{ end }}
{{ if ne .Values.global.arch.ppc64le "0 - Do not use" }}
        - ppc64le
{{ end }}
{{ if ne .Values.global.arch.s390x "0 - Do not use" }}
        - s390x
{{ end }}
      nodeAffinityPreferredDuringScheduling:
{{ if ne .Values.global.arch.amd64 "0 - Do not use" }}
        amd64:
          weight: 2
          operator: In
          key: beta.kubernetes.io/arch
{{ end }}
{{ if ne .Values.global.arch.ppc64le "0 - Do not use" }}
        ppc64le:
          weight: 2
          operator: In
          key: beta.kubernetes.io/arch
{{ end }}
{{ if ne .Values.global.arch.s390x "0 - Do not use" }}
        s390x:
          weight: 2
          operator: In
          key: beta.kubernetes.io/arch
{{ end }}
{{- end -}}