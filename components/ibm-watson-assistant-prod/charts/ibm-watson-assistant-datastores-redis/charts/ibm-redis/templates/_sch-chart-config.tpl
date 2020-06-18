{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
*/}}
{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.

*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibmRedis.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-redis"
    labelType: new
    components:
      server: "server"
      sentinel: "sentinel"
      masterService: "master-svc"
      slaveService: "slave-svc"
      sentinelService: "sentinel-svc"
      credsGen: "creds-gen"
      credsCleanup: "creds-cleanup"
      authsecret: "authsecret"
    metering:
  {{- if .Values.metering }}
    {{- if kindIs "string" .Values.metering }}
{{ tpl .Values.metering              . | indent 6 }}
    {{- else }}
{{ tpl ( .Values.metering | toYaml ) . | indent 6 }}
    {{- end }}
  {{- else }}
      productID: {{ tpl (.Values.global.metering.productID    | toString ) . }}
      productName: {{ tpl (.Values.global.metering.productName    | toString ) . }}
      productVersion: {{ tpl (.Values.global.metering.productVersion    | toString ) . }}
      productMetric: {{ tpl (.Values.global.metering.productMetric    | toString ) . }}
      productChargedContainers: {{ tpl (.Values.global.metering.productChargedContainers    | toString ) . }}
      cloudpakName: {{ tpl (.Values.global.metering.cloudpakName    | toString ) . }}
      cloudpakId: {{ tpl (.Values.global.metering.cloudpakId    | toString ) . }}
      cloudpakVersion: {{ tpl (.Values.global.metering.cloudpakVersion    | toString ) . }}
  {{- end }}
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
        - ppc64le
        - s390x
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 3
          operator: In
          key: beta.kubernetes.io/arch
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
    redisPodSecurityContext:
      runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      fsGroup: {{ .Values.securityContext.redis.fsGroup }}
      runAsUser: {{ .Values.securityContext.redis.runAsUser }}
      runAsGroup: {{ .Values.securityContext.redis.runAsGroup }}
    {{- end }} 
    redisContainerSecurityContext:
      runAsNonRoot: true
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
{{- end -}}
