###############################################################################
# Licensed Materials - Property of IBM
# 5737-E67
# (C) Copyright IBM Corporation 2016, 2018 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
###############################################################################
{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-rook-rbd-cluster.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-rook-rbd-cluster"
    components: 
      defaultrolebinding:
        name: "rook-default-psp"
      defaultrole:
        name: "privileged-psp-user"
      defaultsa:
        name: "default"
      rookclustersa:
        name: "rook-ceph-cluster"
      rookclusterrole:
        name: "rook-ceph-cluster"
      rookclusterrb:
        name: "rook-ceph-cluster"
      cephosdrolebinding:
        name: "rook-ceph-osd-psp"
      cephosdrole:
        name: "privileged-psp-user"
      rookclustermgmtrole:
        name: "rook-ceph-cluster-mgmt"
      cephosdsa:
        name: "rook-ceph-cluster"
      cluster:
        name: "rook-ceph-cluster"
      prcjob:
        name: "rook-cluster-precheck-job"
      pool:
        name: "rook-ceph-pool"
{{- end -}}
