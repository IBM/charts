{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibmMongodb.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-mongodb"
    labelType: new
    components:
      server: "server"
      headless: "headless-svc"
      credsGen: "creds-gen"
      credsCleanup: "creds-cleanup"
      authSecret: "auth-secret"
      tlsSecret: "tls-secret"
      keySecret: "keyfile-secret"
      mongodbTest: "test"
      metricsSecret: "metrics"
      initConfigmap: "init"
      mongodConfigmap: "mongod"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
    metering:
  {{- if .Values.metering }}
    {{- if kindIs "string" .Values.metering }}
{{ tpl .Values.metering              . | indent 6 }}
    {{- else }}
{{ tpl ( .Values.metering | toYaml ) . | indent 6 }}
    {{- end }}
  {{- else }}
      productID: "Mongodb_36_free_00000"
      productName: "Mongodb"
      productVersion: "3.6.0"
      cloudpakName: "IBM Cloud Pak for Data"
      cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
  {{- end }}
    mongoPodSecurityContext:
      runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      fsGroup: {{ .Values.securityContext.mongodb.fsGroup }}
      runAsUser: {{ .Values.securityContext.mongodb.runAsUser }}
      runAsGroup: {{ .Values.securityContext.mongodb.runAsGroup }}
    {{- end }} 
    mongoContainerSecurityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
    credsPodSecurityContext:
      runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      runAsUser: {{ .Values.securityContext.creds.runAsUser }}
    {{- end }} 
    credsContainerSecurityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
{{- end -}}
