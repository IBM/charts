{{- /*
"db2z.sch.chart.config.values" contains a default configuration values used by
the Shared Configurable Helpers if the chart specific override file does not exist.
*/ -}}
{{- define "db2z.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Chart.Name }}"
    labelType: "prefixed"
    components:
      addon:
        name: "addon"
      svp:
        name: "svp"
      ui:
        name: "ui"
    metering:
      productID: "ICP4D-IBMDb2zConnector-Prod-00000"
      productName: "IBM Db2 for z/OS Connector"
      productVersion: "{{ .Chart.Version }}"
    security:
      podSecurityContext:
        hostIPC: false
        hostNetwork: false
        hostPID: false
        securityContext:
          runAsNonRoot: true
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
              - ALL
          privileged: false
          readOnlyRootFilesystem: false
{{- end -}}