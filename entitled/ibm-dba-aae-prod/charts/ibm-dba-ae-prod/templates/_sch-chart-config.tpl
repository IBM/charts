################################################################################
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2019. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
################################################################################
{{- define "sch.appengine.config.values" -}}
sch:
  chart:
    appName: "ibm-dba-ae"
    components:
      ae:
        name: "ae"
      ae-initjob:
        name: "ae-initjob"
    # TODO: review product metadata
    metering:
      productName: "IBM Cloud Pak for Automation"
      productID: "5737-I23"
      productVersion: "19.0.2"
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
        ibm-dba-ae:
          weight: 100
          key: "app.kubernetes.io/name"
          topologyKey: "kubernetes.io/hostname"
    labelType: prefixed
{{- end -}}
