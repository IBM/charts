{{- /*
"dvAddon.sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "dvAddon.sch.chart.config.values" -}}
sch:
  chart:
    appName: "dv"
    labelType: "prefixed"
    components:
      addon:
        name: "addon"
      serviceProvider:
        name: "service-provider"
      homepageQuickNavExtensions:
        name: "homepage-quick-nav-extensions"
      navExtensions:
        name: "nav-extensions"
    security:
      addonPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
      serviceProviderPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
        serviceAccountName: cpd-editor-sa
      addonContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
      serviceProviderContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
    metering:
      productName: "IBM Data Virtualization"
      productID: "ICP4D-IBMDataVirtualizationv141_00000"
      productVersion: "1.4.1"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "All"
      cloudpakName: "IBM Cloud Pak for Data"
      cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
      cloudpakVersion: "3.0.1"
{{- end -}}
