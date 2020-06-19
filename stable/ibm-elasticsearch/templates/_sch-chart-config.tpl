{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibmElasticsearch.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-elasticsearch"
    labelType: new
    components:
      esServer: "elasticsearch-server"
      service: "svc"
      headless: "headless-svc"
      credsGen: "creds-gen"
      credsCleanup: "creds-cleanup"
      authsecret: "auth-secret"
      tlssecret: "tls-secret"
      mainTest: "main-test"
      haproxyConfig: "haproxy"
      secretConfig: "secret-config"
      secretJob: "secret-job"
      esCert: "cert"
      esSecret: "secret"
      ingress: "ingress"
      helmTest: "test"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
    elasticsearchPodSecurityContext:
      runAsNonRoot: true
  {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      runAsUser: {{ .Values.securityContext.elasticsearch.runAsUser }}
  {{- end }}
    elasticsearchContainerSecurityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
  {{- if .Values.setSysctls }}
      sysctls:
      - name: vm.max_map_count
        value: "{{ .Values.sysctlVmMaxMapCount }}"
  {{- end }}
    elasticsearchmastergracefulterminationhandlerContainerSecurityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
    esplugininstallContainerSecurityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
    haproxyContainerSecurityContext:
      privileged: false
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      runAsNonRoot: true
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
      productID: {{ tpl (.Values.global.metering.productID    | toString ) . }}
      productName: {{ tpl (.Values.global.metering.productName    | toString ) . }}
      productVersion: {{ tpl (.Values.global.metering.productVersion    | toString ) . }}
      productMetric:  {{ tpl (.Values.global.metering.productMetric    | toString ) . }}
      productChargedContainers: {{ tpl (.Values.global.metering.productChargedContainers    | toString ) . }}
      cloudpakId: {{ tpl (.Values.global.metering.cloudpakId    | toString ) . }}
      cloudpakName: {{ tpl (.Values.global.metering.cloudpakName    | toString ) . }}
      cloudpakVersion: {{ tpl (.Values.global.metering.cloudpakVersion    | toString ) . }}
{{- end -}}
