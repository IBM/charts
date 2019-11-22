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
#      productName: "Redis HA"
#      productID: "RedisHA_3212r0_free_00000"
#      productVersion: "3.2.12-r0"
      productName: "IBM Watson Assistant for IBM Cloud Private for Data"
      productID: "ICP4D-addon-53256faf537b4d4d956f0c5a24d78b08-assistant"
      productVersion: "1.3.0"
 
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