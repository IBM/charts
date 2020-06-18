{{- define "gateway.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}-{{ .Values.addon.serviceId }}"
    components:
      metrics:
        name: "metrics"

    metering:
      productName:    {{ tpl ( .Values.metering.productName    | toString ) . | quote }}
      productID:      {{ tpl ( .Values.metering.productID      | toString ) . | quote }}
      productVersion: {{ tpl ( .Values.metering.productVersion | toString ) . | quote }}
      productMetric: {{ tpl ( .Values.metering.productMetric    | toString ) . | quote }}
      productChargedContainers: {{ tpl ( .Values.metering.productChargedContainers    | toString ) . | quote }}
      cloudpakName: {{ tpl ( .Values.metering.cloudpakName    | toString ) . | quote }}
      cloudpakId: {{ tpl ( .Values.metering.cloudpakId    | toString ) . | quote }}
      cloudpakVersion: {{ tpl ( .Values.metering.cloudpakVersion    | toString ) . | quote }}

    labelType: new
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
    securityContextSpec:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
    securityContextContainer:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
        privileged: false
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
