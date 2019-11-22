{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018, 2019. All Rights Reserved.
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
{{- define "redis.sch.chart.config.values" -}}
sch:
  chart:
    appName: {{ .Chart.Name }}
    components:
      authsecret: "authsecret"
      credsCleanup: "creds-cleanup"
      credsGen: "creds-gen"
    metering:
      productID: "RedisHA_503r0_free_00000"
      productName: "Redis HA"
      productVersion: "5.0.5"
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
      runAsUser: 99
    credsContainerSecurityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
{{- end -}}
