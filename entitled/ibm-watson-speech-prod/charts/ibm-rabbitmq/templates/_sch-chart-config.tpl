{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibmRabbitmq.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-rabbitmq"
    labelType: new
    components:
      server: "rabbitmq-server"
      service: "svc"
      headless: "headless-svc"
      credsGen: "creds-gen"
      credsCleanup: "creds-cleanup"
      authsecret: "auth-secret"
      tlssecret: "tls-secret"
      mainTest: "main-test"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
    rabbitPodSecurityContext:
      runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      runAsUser: {{ .Values.securityContext.rabbitmq.runAsUser }}
    {{- end }} 
    rabbitContainerSecurityContext:
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
    metering:
      productID: "RabbitMQ_373_free_00000"
      productName: "RabbitMQ"
      productVersion: "3.7.3"
{{- end -}}