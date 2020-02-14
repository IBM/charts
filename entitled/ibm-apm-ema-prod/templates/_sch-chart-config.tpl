{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "emaRef.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ema"
    components:
      nginx:
        name: "nginx"
      configmap:
        name: "config-map"
      secret:
        name: "secret"
      couchdb:
        name: "couchdb"
      adminConsole:
        name: "admin-console"
      api:
        name: "api"
      crawler:
        name: "crawler"
      diagnosis:
        name: "diagnosis"
      diagnosisDataloader:
        name: "diagnosis-dataloader"
      landingPage:
        name: "landing-page"
      auth:
        name: "auth"
      maximoIntegration:
        name: "maximo-integration"
      sampleApp:
        name: "sample-app"
      studio:
        name: "studio"
      emaAddon:
        name: "ema-addon"
      emaServiceProvider:
        name: "ema-service-provider"
      monitor:
        name: "monitor"
      multiTenant:
        name: "multi-tenant"
      emaLicense:
        name: "ema-license"
      sslJob:
        name: "secgen"
      sslDeleteJob:
        name: "secgen-delete"
      roleBinding:
        name: "role"
      createDBJob:
        name: "create-emadb"
      prereqCheckJob:
        name: "prereq-check"
      createInstanceJob:
        name: "create-instance"
      deleteInstanceJob:
        name: "delete-instance"
    metering:
      productID: "ICP4D-addon-2977879613e54cc2a38b8874c291cb57-EMA"
      productName: "IBM Maximo Equipment Maintenance Assistant On-Premises"
      productVersion: 1.1.0
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
        - ppc64le
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
    podSecurityContext:
      securityContext:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
          add:
          - CHOWN
          - DAC_OVERRIDE
          - SETGID
          - SETUID
          - NET_BIND_SERVICE
    specSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: false
        runAsUser: 0
    helmTestPodSecurityContext:
      securityContext:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
    labelType: "prefixed"

{{- end -}}
