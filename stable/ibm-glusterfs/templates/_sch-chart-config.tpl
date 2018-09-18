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
        name: "daemonset"
      heketicfgcm:
        name: "heketi-config"
      heketisvc:
        name: "heketi-service"
      heketideploy:
        name: "heketi-deployment"
      heketitopocm:
        name: "heketi-topology"
      precheckresultscm:
        name: "precheck-results-cm"
      precheckcm:
        name: "precheck-cm"
      precheckds:
        name: "precheck-daemonset"
      precheckjob:
        name: "precheck-job"
      predeletejob:
        name: "predelete-job"
      predeletecm:
        name: "predelete-cm"
      scjob:
        name: "storageclass-job"
      sccm:
        name: "storageclass-cm"
{{- end -}}
