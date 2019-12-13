{{- /* ICAM LICENSE ACCEPT CONDITION */ -}}
{{- $icamLicense := dict "accept" "false" -}}
{{- if (hasKey .Values "ibm-cloud-appmgmt-prod") -}}
  {{- $icamValues := index .Values "ibm-cloud-appmgmt-prod" -}}
  {{- if (hasKey $icamValues "license") -}}
    {{- if (eq $icamValues.license "accept") -}}
      {{- $_ := set $icamLicense "accept" "true" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- /* GLOBAL LICENSE ACCEPT */ -}}
{{- if (hasKey .Values.global "license") -}}
  {{- if (eq .Values.global.license "accept") -}}
    {{- $_ := set $icamLicense "accept" "true" -}}
  {{- end -}}
{{- end -}}
{{- /* ICAM LICENSE TAG CHECK IGNORE */ -}}
{{- if (hasKey .Values "tags") -}}
  {{- if (hasKey .Values.tags "baseInstall") -}}
    {{- if (eq .Values.tags.baseInstall false) -}}
      {{- $_ := set $icamLicense "accept" "true" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- /* ICAM LICENSE FAIL MESSAGE */ -}}
{{- if ne $icamLicense.accept "true" -}}
  {{- fail "Error: The ICAM license must be accepted in order to install the product." -}}
{{- end -}}

{{- /* ADVANCED SERVICES CHECK */ -}}
{{- $productSpecs := dict "advancedName" "false" "advancedCondition" "true" -}}

{{- /* PRODUCT NAME CHECKS */ -}}
{{- $advProductNames := list "IBM Cloud App Management Advanced" "IBM Cloud App Management for Multicloud Manager" -}}

{{- /* DETERMINE IF PRODUCT NAME IS CONSIDERED ADVANCED */ -}}
{{- if (hasKey .Values "ibm-cem") -}}
  {{- $cemValues := index .Values "ibm-cem" -}}
  {{- if (hasKey $cemValues "productName" ) -}}
    {{- if (has $cemValues.productName $advProductNames) -}}
      {{- $_ := set $productSpecs "advancedName" "true" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /*  DETERMINE IF THE PRODUCT IS DEPLOYING ADVANCED SERVICES */ -}}
{{- if (hasKey .Values "global") -}}
  {{- if (hasKey .Values.global "monitoring") -}}
    {{- if (hasKey .Values.global.monitoring "advanced") -}}
      {{- if (eq (toString .Values.global.monitoring.advanced) "false") -}}
        {{- $_ := set $productSpecs "advancedCondition" "false" -}}
      {{- end -}}
    {{- else if (hasKey .Values.global.monitoring "resources") -}}
      {{- if (eq (toString .Values.global.monitoring.resources) "false") -}}
        {{- $_ := set $productSpecs "advancedCondition" "false" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if (hasKey .Values "tags" ) -}}
  {{- if (hasKey .Values.tags "advanced") -}}
    {{- if (eq .Values.tags.advanced false) -}}
      {{- $_ := set $productSpecs "advancedCondition" "false" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- if (eq $productSpecs.advancedCondition "true") -}}
  {{- if (eq $productSpecs.advancedName "false") -}}
    {{- fail "Advanced services are not being deployed properly. Product name and advanced tag must align." -}}
  {{- end -}}
{{- end -}}



{{- /* CEM COMMON COMPONENT CONDITIONS */ -}}
{{- $cemKafka := dict "fail" "false" -}}
{{- $cemCassandra := dict "fail" "false" -}}
{{- $cemZookeeper := dict "fail" "false" -}}
{{- if (hasKey .Values "ibm-cem") -}}
  {{-  $cemValues := index .Values "ibm-cem" -}}
  {{- if (hasKey $cemValues "kafka" ) -}}
    {{- $_ := set $cemKafka "fail" $cemValues.kafka.enabled -}}
  {{- end -}}
  {{- if (hasKey $cemValues "cassandra") -}}
      {{- $_ := set $cemCassandra "fail" $cemValues.cassandra.enabled -}}
  {{- end -}}
  {{- if (hasKey $cemValues "zookeeper") -}}
      {{- $_ := set $cemZookeeper "fail" $cemValues.zookeeper.enabled -}}
  {{- end -}}
{{- end -}}

{{- /* ASM COMMON COMPONENT CONDITIONS */ -}}
{{- $asmKafka := dict "fail" "false" -}}
{{- $asmCassandra := dict "fail" "false" -}}
{{- $asmZookeeper := dict "fail" "false" -}}
{{- if (hasKey .Values "asm") -}}
  {{-  $asmValues := index .Values "asm" -}}
  {{- if (hasKey $asmValues "kafka" ) -}}
    {{- $_ := set $asmKafka "fail" $asmValues.kafka.enabled -}}
  {{- end -}}
  {{- if (hasKey $asmValues "cassandra") -}}
      {{- $_ := set $asmCassandra "fail" $asmValues.cassandra.enabled -}}
  {{- end -}}
  {{- if (hasKey $asmValues "zookeeper") -}}
      {{- $_ := set $asmZookeeper "fail" $asmValues.zookeeper.enabled -}}
  {{- end -}}
{{- end -}}

{{- /* COMMON COMPONENT FAILURE MESSAGE */ -}}
{{- $conditionList := pluck "fail" $asmKafka $asmZookeeper $asmCassandra $cemZookeeper $cemKafka $cemCassandra -}}
{{- range $condition := $conditionList -}}
  {{- if $condition -}}
    {{- fail "Common component conditons for ibm-cem and asm should not be enabled (cassandra, kafka, and zookeeper)." -}}
  {{- end -}}
{{- end -}}
