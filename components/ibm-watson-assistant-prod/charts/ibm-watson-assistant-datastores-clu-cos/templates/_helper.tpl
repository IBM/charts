{{- define "assistant.minio.fullname" -}}
  {{- include "assistant.ibm-minio.serviceName" . }}.{{ .Release.Namespace }}.svc.{{ tpl .Values.global.clusterDomain . }}
{{- end -}}

{{- define "assistant.minio.ibm-minio.affinities.nodeAffinity" -}}
  {{- $originalAffinitiesStr     := include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) -}}
  {{- $affinities                := fromYaml $originalAffinitiesStr -}}

  {{- /* Patch requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0] - that sch chard generated just with arch key with additional LabelSelectorRequirements is specified in umbrella chart */ -}}
  {{- $additionalRequirements    := .Values.global.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms.matchExpressions -}}
  {{- $tmpNodeSelectorTerms      := $affinities.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms -}}
  {{- $tmpFirstNodeSelectorTerm  := first $tmpNodeSelectorTerms -}}
  {{- $tmpMatchExpressions       := $tmpFirstNodeSelectorTerm.matchExpressions -}}

  {{- /* Append additional match expression keys */ -}}
  {{- $tmpDict := (dict "updatedMatchExpressions" $tmpMatchExpressions) -}}
  {{- range $additionalLabelSelectorRequirement := $additionalRequirements -}}
    {{- $_  := set $tmpDict "updatedMatchExpressions" ( append $tmpDict.updatedMatchExpressions $additionalLabelSelectorRequirement) -}}
  {{- end -}}

  {{- /* Modify the affinities in place */ -}}
  {{- $_ := set $tmpFirstNodeSelectorTerm "matchExpressions" $tmpDict.updatedMatchExpressions -}}
  {{- $affinities | toYaml -}}
{{- end -}}

{{/* Extract from sch char for initialization of sch context but without strange metadata-checks */}}
{{- define "assistant.ibm-minio.sch.config.init" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $schChartConfigName := (include "sch.utils.getItem" (list $params 1 "sch.chart.default.config.values")) -}}
  {{- $schChartConfig := fromYaml (include $schChartConfigName $root) -}}
  {{- $schConfig := fromYaml (include "sch.config.values" $root) -}}
  {{- $_ := merge $root $schChartConfig -}}
  {{- $_ := merge $root $schConfig -}}
  {{- /* appName and shortName are in $root by default and need to be forcefully overwritten if they exist */ -}}
  {{- if hasKey $schChartConfig.sch.chart "appName" }}
    {{- $_ := set $root.sch.chart "appName" $schChartConfig.sch.chart.appName }}
  {{- end }}
  {{- if hasKey $schChartConfig.sch.chart "shortName" }}
    {{- $_ := set $root.sch.chart "shortName" $schChartConfig.sch.chart.shortName }}
  {{- end }}
{{- end -}}

{{/* Define minimal context that can be used to render the sch config for ibm-minio chart */}}
{{- define "assistant.ibm-minio.minimalValues" -}}
nameOverride: "clu-minio"

# The values below are faked values, as they do not influence how secret / service names are computed.
#   they are here just to be able to render "ibmMinio.sch.config.values" template ( an sch config for ibm-minio chart)
metering: {}
securityContext:
  minio:
    runAsUser: ""
  creds:
    runAsUser: ""
global:
  metering:
    productName:    "IBM Watson Assistant for IBM Cloud Pak for Data"
    productID:      "ICP4D-addon-fa92c14a5cd74c31aab1616889cbe97a-assistant"
    productVersion: "1.4.2"
    productMetric: ""
    productChargedContainers: ""
    cloudpakName: ""
    cloudpakId: ""
    cloudpakVersion: ""
{{- end -}}

{{- define "assistant.ibm-minio.simulatedContext" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $keyForSimulatedContext := (include "sch.utils.getItem" (list $params 1 "result")) -}}

  {{- $minioSimulatedContext := dict }}
  {{- $values := fromYaml (include "assistant.ibm-minio.minimalValues" $root ) }}
  
  {{- $_ := set $minioSimulatedContext        "Values"       $values                   }}
  {{- $_ := set $minioSimulatedContext        "Release"      $root.Release             }}
  {{- $_ := set $minioSimulatedContext        "Capabilities" $root.Capabilities        }}
  {{- $_ := set $minioSimulatedContext        "Chart"        (dict "Name" "ibm-minio") }}
  {{- $_ := set $minioSimulatedContext        "Template"     $root.Template            }}
  
  {{- include "assistant.ibm-minio.sch.config.init" (list $minioSimulatedContext "ibmMinio.sch.config.values") -}}
  {{- $_ := set $root $keyForSimulatedContext $minioSimulatedContext }}
{{- end -}}



{{/*
******************************************************************************************
******************************************************************************************
*** Some helper templates for people using ibm-postgresql chart as subchart 
***   and want to get some object names (secrets, service) 
*** (not 100% reliable, especially .Values.nameOverride is not supported out-of-the-box -)
******************************************************************************************
******************************************************************************************
*/}}

{{/* 
  Gets names of the generated auth secrets (the secret with user and password to postgresql).
  Limitation: does not support nameOverride (key).
*/}}

{{- define "assistant.ibm-minio.existingSecret" -}}
  {{- include "assistant.ibm-minio.simulatedContext" (list . "ibmMinioSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .ibmMinioSimulatedContext .ibmMinioSimulatedContext.sch.chart.components.authSecret) -}}
{{- end -}}

{{- define "assistant.ibm-minio.tls.certSecret" -}}
  {{- include "assistant.ibm-minio.simulatedContext" (list . "ibmMinioSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .ibmMinioSimulatedContext .ibmMinioSimulatedContext.sch.chart.components.tlsSecret) -}}
{{- end -}}

{{- define "assistant.ibm-minio.serviceName" -}}
  {{- include "assistant.ibm-minio.simulatedContext" (list . "ibmMinioSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .ibmMinioSimulatedContext .ibmMinioSimulatedContext.sch.chart.components.service) -}}
{{- end -}}

# Assistant fix of possibly unused parameter:
#    minio.sse.masterKeySecert: {{ .Values.global.cos.sse.secretName }} is used by template in value of (minio).sse.masterKeySecret
