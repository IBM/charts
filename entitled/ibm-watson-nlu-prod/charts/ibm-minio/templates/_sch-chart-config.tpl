{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
*/}}

{{- /*
"sch.config.values" contains the default configuration values used by
the Shared Configurable Helpers.

To override any of these values, modify the templates/_sch-chart-config.tpl file
*/ -}}
{{- define "ibmMinio.sch.config.values" -}}
sch:
  chart:
    appName: "ibm-minio"
    labelType: new
    components:
      headless: "headless-svc"
      service: "svc"
      credsGen: "creds-gen"
      credsCleanup: "creds-cleanup"
      createBucket: "create-bucket"
      authSecret: "auth"
      tlsSecret: "tls"
      minioTest: "test"
      minioServer: "server"
    minioPodSecurityContext:
      runAsNonRoot: true
  {{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
      runAsUser: {{ .Values.securityContext.minio.runAsUser }}
  {{- end }}
    minioContainerSecurityContext:
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
    metering:
      productName: {{ .Values.global.metering.productName }}
      productID: {{ .Values.global.metering.productID }}
      productVersion: {{ .Values.global.metering.productVersion }}
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
  names:
    fullName:
      maxLength: 63
      releaseNameTruncLength: 42
      appNameTruncLength: 20
    fullCompName:
      maxLength: 63
      releaseNameTruncLength: 36
      appNameTruncLength: 13
      compNameTruncLength: 12
    statefulSetName:
      maxLength: 37
      releaseNameTruncLength: 18
      appNameTruncLength: 7
      compNameTruncLength: 10
    volumeClaimTemplateName:
      maxLength: 63
      claimNameTruncLength: 7
    persistentVolumeClaimName:
      maxLength: 63
      releaseNameTruncLength: 18
      appNameTruncLength: 13
      claimNameTruncLength: 12

{{- end -}}
