###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
{{- /*
Chart specific config file for SLT (Shared Liberty Templates)

_slt-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the slt/_config.tpl file.
 
*/ -}}

{{- /*
"slt.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Liberty Templates.
*/ -}}
{{- define "slt.chart.config.values" -}}
slt:
  paths:
    wlpInstallDir: "/opt/ibm/wlp"
  product:
    id: "IBMWebSphereLiberty_5724J08_18002_151_00000"
    name: "IBM WebSphere Application Server Liberty"
    version: "18.0.0.2"
  kube:
    provider: Any
{{- end -}}

