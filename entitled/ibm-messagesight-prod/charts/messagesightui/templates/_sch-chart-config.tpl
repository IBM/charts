{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "webui.sch.chart.config.values" -}}
sch:
  chart:
    appName: "messagesightui"
    metering:
      productName: "IBM IoT MessageSight Web UI"
      productID: "IBMIoTMessageSight_2.0.0.2_WebUI_00000"
      productVersion: "2.0.0.2"
{{- end -}}

{{- /*
"sch.chart.nodeAffinity" contains the chart specific values used to provide
information about which nodes are suitable for installation of the chart.
*/ -}}
{{- define "webui.sch.chart.nodeAffinity" -}}
#https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    #If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    #then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    #If you specify multiple matchExpressions associated with nodeSelectorTerms,
    #then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    #valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
    nodeSelectorTerms:
    - matchExpressions:
      - key: beta.kubernetes.io/arch
        operator: In
        values:
        - amd64
{{- end -}}
