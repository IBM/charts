{{- /*
"dvapi.sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "dvapi.sch.chart.config.values" -}}
sch:
  chart:
    appName: "dv"
    labelType: "prefixed"
    components:
      dvapi:
        name: "api"
    pods:
      dvapi:
        name: "dv-api"
    security:
      defaultPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false      
        serviceAccountName:  "cpd-viewer-sa"     
        securityContext:
          runAsNonRoot: true
        {{- if .Values.runAsUser }}
          runAsUser: {{ .Values.runAsUser }}
        {{- end }}      
      dvapiContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: true
          runAsNonRoot: true
        {{- if .Values.runAsUser }}
          runAsUser: {{ .Values.runAsUser }}
        {{- end }} 
          capabilities:
            drop:
            - ALL
    metering:
      productName: "IBM Data Virtualization"
      productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
      productVersion: "1.5.0"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "All"
      productCloudpakRatio: "1:1"
      cloudpakName: "IBM Cloud Pak for Data"
      cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
      cloudpakInstanceId: {{ .Values.zenCloudPakInstanceId }}
      hook.activate.cpd.ibm.com/command: "[]"
      hook.deactivate.cpd.ibm.com/command: "[]"
      hook.quiesce.cpd.ibm.com/command: "[]"
      hook.unquiesce.cpd.ibm.com/command: "[]"     
{{- end -}}
