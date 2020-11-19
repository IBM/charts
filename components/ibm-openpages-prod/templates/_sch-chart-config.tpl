#*******************************************************************************
# Licensed Materials - Property of IBM
#
#
# OpenPages GRC Platform (PID: 5725-D51)
#
#  © Copyright IBM Corporation 2020. All Rights Reserved.
#
# US Government Users Restricted Rights- Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
#*******************************************************************************
{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "op.sch.chart.config.values" -}}
sch:
  chart:
    appName: openpages
    components: 
      opapp:
        name: "opapp"
    metering:
      productName: "{{ .Values.global.productName }}"
      productID: {{ .Values.global.productID | quote }}
      productVersion: "{{ .Values.global.productVersion }}"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "All"
      cloudpakName: "{{ .Values.global.cloudpakName }}"
      cloudpakId: "{{ .Values.global.cloudpakId}}"
      cloudpakInstanceId: "{{ .Values.zenCloudPakInstanceId }}"
    podAntiAffinity:
      preferredDuringScheduling:
        opapp:
          weight: 5
          key: component
          operator: In
          topologyKey: kubernetes.io/hostname
    securityContextRestricted:
      securityContext:
        runAsNonRoot: true
        privileged: false
        allowPrivilegeEscalation: false
        fsGroup: {{ .Values.securityContext.fsGroup }}
  names:
    appName: {{ .Values.name }}
{{- end -}}