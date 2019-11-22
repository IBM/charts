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
{{- define "ibmPostgres.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-postgresql"
    labelType: new
    components:
      keeper: "keeper"
      sentinel: "sentinel"
      proxy: "proxy"
      keeperService: "keeper-svc"
      proxyService: "proxy-svc"
      credsGen: "creds-gen"
      credsCleanup: "creds-cleanup"
      authSecret: "auth-secret"
      tlsSecret: "tls-secret"
      masterTest: "test"
      createCluster: "create-cluster"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
    metering:
  {{- if .Values.metering }}
    {{- if kindIs "string" .Values.metering }}
{{ tpl .Values.metering              . | indent 6 }}
    {{- else }}
{{ tpl ( .Values.metering | toYaml ) . | indent 6 }}
    {{- end }}
  {{- else }}
      productID: PostgressqlHA_stolon_free_0000
      productName: PostgressqlHA
      productVersion: 9.6.9
  {{- end }}
    postgresPodSecurityContext:
      runAsNonRoot: true
    {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      runAsUser: {{ .Values.securityContext.postgres.runAsUser }}
      runAsGroup: {{ .Values.securityContext.postgres.runAsGroup }}
    {{- end }}
    postgresContainerSecurityContext:
      privileged: false
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
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
{{- end -}}