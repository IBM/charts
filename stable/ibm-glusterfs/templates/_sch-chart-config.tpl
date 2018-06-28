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
{{- define "glusterfs.sch.chart.config.values" -}}
sch:
  chart:
    appName: "glusterfs"
    components:
      glusterfsds:
        name: "glusterfs-daemonset"
      heketicfgcm:
        name: "heketi-config"
      heketisvc:
        name: "heketi-service"
      heketideploy:
        name: "heketi-deployment"
      heketisecret:
        name: "heketi-secret"
      heketitopocm:
        name: "heketi-topology"
      precheckresultscm:
        name: "glusterfs-precheck-results-cm"
      precheckcm:
        name: "glusterfs-precheck-cm"
      precheckds:
        name: "glusterfs-precheck-daemonset"
      precheckjob:
        name: "glusterfs-precheck-job"
      predeletejob:
        name: "glusterfs-predelete-job"
      predeletecm:
        name: "glusterfs-predelete-cm"
      scjob:
        name: "glusterfs-sc-job"
      sccm:
        name: "glusterfs-sc-cm"
{{- end -}}
