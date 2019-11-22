###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2019. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################
{{- define "sch.bastudio.config.values" -}}
sch:
  chart:
    labelType: prefixed
    appName: "bastudio"
    arch:
      amd64: "3 - Most preferred"
      ppc64le: "0 - Do not use"
      s390x: "0 - Do not use"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
    podAntiAffinity:
      preferredDuringScheduling:
        bastudio:
          weight: 100
          key: "app.kubernetes.io/name"
          topologyKey: "kubernetes.io/hostname"
    metering:
      productName: "IBM Cloud Pak for Automation"
      productID: "5737-I23"
      productVersion: "19.0.2"
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
      possiblePrefix: "glusterfs-dynamic-"
      claimNameTruncLength: 7
    persistentVolumeClaimName:
      maxLength: 63
      possiblePrefix: "glusterfs-dynamic-"
      releaseNameTruncLength: 18
      appNameTruncLength: 13
      claimNameTruncLength: 12
{{- end -}}
