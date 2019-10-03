{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "nodejsLoopbackRef.sch.chart.config.values" -}}
sch:
  chart:
    appName: "nodejsLoopbackRef"
    components:
      nodejsLoopback:
        name: "nodejsLoopback"
      configmap:
        name: "index"
      dashboard:
        name: "grafana"
    labelType: "prefixed"
    nodejsLoopback:
      ingress:
        nodejsLoopback.ingress.kubernetes.io/rewrite-target: /
        nodejsLoopback.ingress.kubernetes.io/secure-backends: "true"
    metering:
      productName: ibm-nodejs-loopback
      productID: ibm_nodejs_loopback_1.0.0_perpetual_00000
      productVersion: 1.0.0
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
    specSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: 1000
{{- end }}
    helmTestPodSecurityContext:
      securityContext:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
