# (C) Copyright 2019-2020 Syncsort Incorporated. All rights reserved.

{{/*
A function to validate if passed parameter is a valid integer
*/}}
{{- define "integerValidation" -}}
{{- $type := kindOf . -}}
{{- if or (eq $type "float64") (eq $type "int") -}}
    {{- $isIntegerPositive := include "isIntegerPositive" . -}}
    {{- if eq $isIntegerPositive "true" -}}
    	true
    {{- else -}}
    	false
    {{- end -}}	
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to validate if passed integer is non negative
*/}}
{{- define "isIntegerPositive" -}}
{{- $inputInt := int64 . -}}
{{- if gt $inputInt -1 -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to validate if passed parameter is a valid string
*/}}
{{- define "stringValidation" -}}
{{- $type := kindOf . -}}
{{- if or (eq $type "string") (eq $type "String") -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check for mandatory arguments
*/}}
{{- define "mandatoryArgumentsCheck" -}}
{{- if . -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check for port range
*/}}
{{- define "portRangeValidation" -}}
{{- $portNo := int64 . -}}
{{- if and (gt $portNo 0) (lt $portNo 65536) -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check if port is valid
*/}}
{{- define "isPortValid" -}}
{{- $result := include "integerValidation" . -}}
{{- if eq $result "true" -}}
	{{- $isPortValid := include "portRangeValidation" . -}}
	{{- if eq $isPortValid "true" -}}
	true
	{{- else -}}
	false
	{{- end -}}
{{- else -}}
	false
{{- end -}}
{{- end -}}

{{/*
A function to check if port range is valid
*/}}
{{- define "isPortRangeValid" -}}
{{- $result := false -}}
{{- $portRangeNumbers := split "-" . -}}
{{- $isPortRangeStartValid := include "isPortValid" ($portRangeNumbers._0|int) -}}
{{- if eq $isPortRangeStartValid "true" -}}
	{{- $isPortRangeEndValid := include "isPortValid" ($portRangeNumbers._1|int) -}}
	{{- if eq $isPortRangeEndValid "true" -}}
	{{- $isPortRangeOrderValid := ge ($portRangeNumbers._1|int) ($portRangeNumbers._0|int) -}}
	{{- if eq $isPortRangeOrderValid true -}}
	{{- $result = true -}}
	{{- end -}}
	{{- end -}}
{{- end -}}
{{- if eq $result true -}}
  true
{{- else -}}
  false
{{- end -}}
{{- end -}}

{{/*
A function to check if name is valid
*/}}
{{- define "isNameValid" -}}
{{- $result := regexMatch "[a-z0-9]([-a-z0-9]*[a-z0-9])?" . -}}
{{- if eq $result true -}}
  true
{{- else -}}
  false
{{- end -}}
{{- end -}}


{{/*
A function to check for validity of service ports
*/}}
{{- define "frontendServiceCheck" -}}
{{- $result := include "mandatoryArgumentsCheck" .type -}}
{{- if eq $result "false" -}}
{{- fail "frontendService.type cannot be empty" -}}
{{- end -}}
{{- $result := .type -}}
{{- if not (or (eq $result "NodePort") (eq $result "LoadBalancer") (eq $result "ClusterIP") (eq $result "ExternalName")) -}}
{{- fail "frontendService.type is not valid. Valid values are NodePort,LoadBalancer, ClusterIP or ExternalName" -}}
{{- end -}}
{{- include "servicePortCheck" .ports.http -}}
{{- if .ports.https }}
{{- include "servicePortCheck" .ports.https -}}
{{- end -}}
{{- range $i, $port := .extraPorts -}}
{{- include "servicePortCheck" $port -}}
{{- end -}}
{{- end -}}

{{- define "backendServiceCheck" -}}
{{- $result := include "mandatoryArgumentsCheck" .type -}}
{{- if eq $result "false" -}}
{{- fail "backendService.type cannot be empty" -}}
{{- end -}}
{{- $result := .type -}}
{{- if not (or (eq $result "NodePort") (eq $result "LoadBalancer") (eq $result "ClusterIP") (eq $result "ExternalName")) -}}
{{- fail "backendService.type is not valid. Valid values are NodePort,LoadBalancer, ClusterIP or ExternalName" -}}
{{- end -}}
{{- range $i, $port := .ports -}}
{{- include "servicePortCheck" $port -}}
{{- end -}}
{{- range $i, $portRange := .portRanges -}}
{{- include "servicePortRangeCheck" $portRange -}}
{{- end -}}
{{- end -}}

{{/*
A function to check for validity of service ports
*/}}
{{- define "servicePortCheck" -}}
{{- $result := include "isPortValid" .port -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for port in service" -}}
{{- end -}}
{{- $result := include "isPortValid" .targetPort -}}
{{- if eq $result "false" -}}
{{- $nameCheck := include "isNameValid" .targetPort -}}
{{- if eq $nameCheck "false" -}}
{{- fail "Provide a valid value for targetPort in service" -}}
{{- end -}}
{{- end -}}

{{- $nodePortValue := .nodePort -}}
{{- if $nodePortValue -}}
{{- $result := include "isPortValid" .nodePort -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for nodePort in service" -}}
{{- end -}}
{{- end -}}

{{- $result := include "isNameValid" .name -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for name in service" -}}
{{- end -}}

{{- $result := .protocol -}}
{{- if $result -}}
{{- if not (or (eq $result "TCP") (eq $result "UDP") (eq $result "HTTP") (eq $result "SCTP") (eq $result "PROXY")) -}}
{{- fail "Provide a valid value for protocol in service. Valid values are TCP, UDP, HTTP, SCTP or PROXY" -}}
{{- end -}}
{{- end -}}

{{- end -}}

{{/*
A function to check for validity of service ports
*/}}
{{- define "servicePortRangeCheck" -}}

{{- $result := include "isPortRangeValid" .portRange -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for port range in service" -}}
{{- end -}}

{{- $result := include "isPortRangeValid" .targetPortRange -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for target port range in service" -}}
{{- end -}}

{{- if .nodePortRange -}}
{{- $result := include "isPortRangeValid" .nodePortRange -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for node port range in service" -}}
{{- end -}}
{{- end -}}

{{- $result := include "isNameValid" .name -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for name in service" -}}
{{- end -}}

{{- $result := .protocol -}}
{{- if $result -}}
{{- if not (or (eq $result "TCP") (eq $result "UDP") (eq $result "HTTP") (eq $result "SCTP") (eq $result "PROXY")) -}}
{{- fail "Provide a valid value for protocol in service. Valid values are TCP, UDP, HTTP, SCTP or PROXY" -}}
{{- end -}}
{{- end -}}

{{- end -}}

{{/*
A function to validate an email address
*/}}
{{- define "emailValidator" -}}
{{- $emailRegex := "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$" -}}
{{- $isValid := regexMatch $emailRegex . -}}
{{- if eq $isValid true -}}
	true
{{- else -}}
	false	
{{- end -}}
{{- end -}}

{{/*
A function to validate the user or group name and ID
*/}}
{{- define "userOrGroupNameIDValidator" -}}
{{- $isInteger := include "integerValidation" . -}}
{{- if eq $isInteger "true" -}}
	true
{{- else -}}
	{{- $userOrGroupNameRegex := "^[a-z][-a-z0-9]*$" -}}
	{{- $isValid := regexMatch $userOrGroupNameRegex . -}}
	{{- if eq $isValid true -}}
		true
	{{- else -}}
		false
	{{- end -}}				
{{- end -}}
{{- end -}}




{{/*
Main function to test the input validations
*/}}

{{- define "validateInput" -}}

{{- $result := include "integerValidation" .Values.asi.replicaCount -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for .Values.asi.replicaCount" -}}
{{- end -}}

{{- $result := include "integerValidation" .Values.ac.replicaCount -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for .Values.ac.replicaCount" -}}
{{- end -}}

{{- $result := include "integerValidation" .Values.api.replicaCount -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for .Values.api.replicaCount" -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.global.image.repository -}}
{{- if eq $result "false" -}}
{{- fail ".Values.global.image.repository cannot be empty." -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.global.image.tag -}}
{{- if eq $result "false" -}}
{{- fail ".Values.global.image.tag cannot be empty" -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.global.image.pullPolicy -}}
{{- if eq $result "false" -}}
{{- fail ".Values.global.image.pullPolicy cannot be empty" -}}
{{- end -}}

{{ if .Values.setupCfg.basePort }}
	{{- $result := include "isPortValid" .Values.setupCfg.basePort -}}
	{{- if eq $result "false" -}}
	{{- fail "Values.setupCfg.basePort field is not valid." -}}
	{{- end -}}
{{- end }}

{{- $isValid := .Values.dataSetup.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for field Values.dataSetup.enabled. Value can be either true or false." -}}
{{- end -}}

{{- $isValid := .Values.dataSetup.upgrade | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for field Values.dataSetup.upgrade. Value can be either true or false." -}}
{{- end -}}

{{- include "frontendServiceCheck" .Values.asi.frontendService -}}
{{- include "frontendServiceCheck" .Values.ac.frontendService -}}
{{- include "frontendServiceCheck" .Values.api.frontendService -}}

{{- include "backendServiceCheck" .Values.asi.backendService -}}
{{- include "backendServiceCheck" .Values.ac.backendService -}}

{{/*
{{- $result := .Values.readinessCheck.asiNodes.path -}}
{{- if not ( eq $result "/dashboard/") -}}
 	{{- fail "Provide a valid value for Values.readinessCheck.asiNodes.path. Applicable value is /dashboard/ " -}}
{{- end -}}

{{- $result := .Values.readinessCheck.asiNodes.scheme -}}
{{- if not (or (eq $result "HTTP") (eq $result "HTTPS") (eq $result "http") (eq $result "https")) -}}
{{- fail ".Values.readinessCheck.asiNodes.scheme is not valid. Valid values are HTTP or HTTPS" -}}
{{- end -}}

{{- $result := .Values.readinessCheck.apiNode.path -}}
{{- if not ( eq $result "/propertyUI/app") -}}
	{{- fail "Provide a valid value for Values.readinessCheck.apiNode.path. Applicable value is /propertyUI/app " -}}
{{- end -}}

{{- $result := .Values.readinessCheck.apiNode.scheme -}}
{{- if not (or (eq $result "HTTP") (eq $result "HTTPS") (eq $result "http") (eq $result "https")) -}}
{{- fail ".Values.readinessCheck.apiNode.scheme is not valid. Valid values are HTTP or HTTPS" -}}
{{- end -}}
*/}}

{{- $isValid := .Values.persistence.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for field Values.persistence.enabled. Value can be either true or false." -}}
{{- end -}}

{{- $dynamicProvisioning := .Values.persistence.useDynamicProvisioning | toString -}}
{{- if not ( or (eq $dynamicProvisioning "false") (eq $dynamicProvisioning "true")) -}}
{{- fail "Please provide value for field Values.persistence.useDynamicProvisioning. Value can be either true or false." -}}
{{- end -}}

{{- $resourcesPVCEnabled := .Values.appResourcesPVC.enabled | toString -}}
{{- if eq $resourcesPVCEnabled "true" -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.appResourcesPVC.name -}}
{{- if eq $isValid "false" -}}
{{- fail "Please provide value for Values.appResourcesPVC.name." -}}
{{- end -}}

{{- $isValid := .Values.appResourcesPVC.accessMode -}}
{{- if not ( or (eq $isValid "ReadWriteOnce") (eq $isValid "ReadOnlyMany") (eq $isValid "ReadWriteMany")) -}}
{{- fail "Please specify Values.appResourcesPVC.accessMode as one of these supported databases - ReadWriteOnce | ReadOnlyMany | ReadWriteMany" -}}
{{- end -}}

{{- end -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.appLogsPVC.name -}}
{{- if eq $isValid "false" -}}
{{- fail "Please provide value for Values.appLogsPVC.name." -}}
{{- end -}}

{{- $isValid := .Values.appLogsPVC.accessMode -}}
{{- if not ( or (eq $isValid "ReadWriteOnce") (eq $isValid "ReadOnlyMany") (eq $isValid "ReadWriteMany")) -}}
{{- fail "Please specify Values.appLogsPVC.accessMode as one of these supported databases - ReadWriteOnce | ReadOnlyMany | ReadWriteMany" -}}
{{- end -}}
		
{{- if .Values.security.supplementalGroups -}}
    {{- range .Values.security.supplementalGroups }}
    	{{- $isValid := include "userOrGroupNameIDValidator" . -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Values.security.supplementalGroups is invalid. Either provide a numeric value for group ID or follow the pattern ^[a-z][-a-z0-9]*$ to provide valid group name in an array." -}}
		{{- end -}}
    {{- end }}
{{- end -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.security.fsGroup -}}
{{- if eq $isValid "false" -}}
{{- fail "Please provide value for Values.security.fsGroup." -}}
{{- end -}}

{{- $isValid := include "userOrGroupNameIDValidator" .Values.security.fsGroup -}}
{{- if eq $isValid "false" -}}
{{- fail "Values.security.fsGroup is invalid. Either provide a numeric value for group ID or follow the pattern ^[a-z][-a-z0-9]*$ to provide valid group name." -}}
{{- end -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.security.runAsUser -}}
{{- if eq $isValid "false" -}}
{{- fail "Please provide values for Values.security.runAsUser." -}}
{{- end -}}

{{- $isValid := include "userOrGroupNameIDValidator" .Values.security.runAsUser -}}
{{- if eq $isValid "false" -}}
{{- fail "Values.security.runAsUser is invalid. Either provide a numeric value for user ID or follow the pattern ^[a-z][-a-z0-9]*$ to provide valid user name." -}}
{{- end -}}

{{- $isValid := .Values.env.license -}}
{{- if not (or (eq $isValid "view") (eq $isValid "accept")) -}}
{{- fail "Please provide Values.env.license. Value is accept." -}}
{{- end -}}
{{- $isValid := .Values.env.upgradeCompatibilityVerified -}}
{{- if not ( or (eq $isValid false) (eq $isValid true)) -}}
{{- fail "Please provide value for Values.env.upgradeCompatibilityVerified. Value can be either true or false." -}}
{{- end -}}

{{- $isValid := .Values.ingress.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for Values.ingress.enabled. Value can be either false or true." -}}
{{- end -}}
{{- $isValid := .Values.ingress.enabled | toString -}}
{{- if eq $isValid "true" -}}
	{{- $result := include "mandatoryArgumentsCheck" .Values.asi.ingress.internal.host -}}
	{{- if eq $result "false" -}}
	{{- fail ".Values.asi.ingress.internal.host cannot be empty" -}}
	{{- end -}}

	{{- $noOfAPIReplica := .Values.api.replicaCount | int -}}
    {{- if gt $noOfAPIReplica 0 -}}
		{{- $result := include "mandatoryArgumentsCheck" .Values.api.ingress.internal.host -}}
		{{- if eq $result "false" -}}
		{{- fail ".Values.api.ingress.internal.host cannot be empty" -}}
		{{- end -}}
    {{- end -}}
{{- end -}}

{{- $isValid := .Values.asi.autoscaling.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for Values.asi.autoscaling.enabled. Value can be either false or true." -}}
{{- end -}}

{{- $isValid := .Values.asi.autoscaling.enabled | toString -}}
{{- if eq $isValid "true" -}}
	{{- $isValid := include "integerValidation" .Values.asi.autoscaling.minReplicas -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.asi.autoscaling.minReplicas is not valid." -}}
	{{- end -}}

	{{- $isValid := include "integerValidation" .Values.asi.autoscaling.maxReplicas -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.asi.autoscaling.maxReplicas is not valid." -}}
	{{- end -}}

	{{- $isValid := include "integerValidation" .Values.asi.autoscaling.targetCPUUtilizationPercentage -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.asi.autoscaling.targetCPUUtilizationPercentage is not valid." -}}
	{{- end -}}
{{- end -}}


{{- $isValid := .Values.ac.autoscaling.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for  Values.ac.autoscaling.enabled. Value can be either false or true." -}}
{{- end -}}

{{- $isValid := .Values.ac.autoscaling.enabled | toString -}}
{{- if eq $isValid "true" -}}
	{{- $isValid := include "integerValidation" .Values.ac.autoscaling.minReplicas -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.autoscaling.ac.minReplicas is not valid." -}}
	{{- end -}}

	{{- $isValid := include "integerValidation" .Values.ac.autoscaling.maxReplicas -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.ac.autoscaling.maxReplicas is not valid." -}}
	{{- end -}}

	{{- $isValid := include "integerValidation" .Values.ac.autoscaling.targetCPUUtilizationPercentage -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Values.ac.autoscaling.targetCPUUtilizationPercentage is not valid." -}}
	{{- end -}}
{{- end -}}

{{- $enableAppLogOnConsole := .Values.logs.enableAppLogOnConsole | toString -}}
{{- if not ( or (eq $enableAppLogOnConsole "false") (eq $enableAppLogOnConsole "true")) -}}
{{- fail "Please provide correct value for Values.logs.enableAppLogOnConsole. Value can be either false or true." -}}
{{- end -}}	

{{- $applyPolicyToKubeSystem := .Values.applyPolicyToKubeSystem | toString -}}
{{- if not ( or (eq $applyPolicyToKubeSystem "false") (eq $applyPolicyToKubeSystem "true")) -}}
{{- fail "Please provide value for applyPolicyToKubeSystem. Value can be either false or true." -}}
{{- end -}}

{{/*
Starting Validation of setup configuration properties.
*/}}

{{- $isValid := .Values.setupCfg.licenseAcceptEnableSfg | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for Values.setupCfg.licenseAcceptEnableSfg. Value can be either false or true." -}}
{{- end -}}

{{- $isValid := .Values.setupCfg.licenseAcceptEnableEbics | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for Values.setupCfg.licenseAcceptEnableEbics. Value can be either false or true." -}}
{{- end -}}

{{- $isValid := .Values.setupCfg.licenseAcceptEnableFinancialServices | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for Values.setupCfg.licenseAcceptEnableFinancialServices. Value can either be false or true." -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.setupCfg.systemPassphraseSecret -}}
{{- if eq $result "false" -}}
{{- fail ".Values.setupCfg.systemPassphraseSecret cannot be empty" -}}
{{- end -}}

{{- $isValid := .Values.setupCfg.enableFipsMode | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for Values.setupCfg.enableFipsMode. Value can be either false or true." -}}
{{- end -}}

{{- $isValid := .Values.setupCfg.nistComplianceMode | toString -}}
{{- if not (or (eq $isValid "strict") (eq $isValid "transition") (eq $isValid "off")) -}}
{{- fail "Invalid value for nistComplianceMode. Valid values are strict,transition or off" -}}
{{- end -}}

{{- $isValid := .Values.setupCfg.dbVendor -}}
{{- if not ( or (eq $isValid "DB2") (eq $isValid "Oracle") (eq $isValid "MSSQL") (eq $isValid "db2") (eq $isValid "oracle") (eq $isValid "mssql")) -}}
{{- fail "Please specify dbVendor as one of these supported databases - DB2 | Oracle | MSSQL" -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.setupCfg.dbSecret -}}
{{- if eq $result "false" -}}
{{- fail ".Values.setupCfg.dbSecret cannot be empty" -}}
{{- end -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.dbHost -}}
{{- if eq $isValid "false" -}}
{{- fail "Please specify the dbHost." -}}
{{- end -}}

{{- $isValid := include "isPortValid" .Values.setupCfg.dbPort -}}
{{- if eq $isValid "false" -}}
{{- fail "Please specify the dbPort correctly." -}}
{{- end -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.dbData -}}
{{- if eq $isValid "false" -}}
{{- fail "Please specify the dbData." -}}
{{- end -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.dbDrivers -}}
{{- if eq $isValid "false" -}}
{{- fail "Please specify the dbDrivers." -}}
{{- end -}}

{{- $isValid := .Values.setupCfg.dbCreateSchema | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide Value for dbCreateSchema. Value can be either false or true." -}}
{{- end -}}

{{- $isValid := .Values.setupCfg.oracleUseServiceName | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide Value for oracleUseServiceName. Value can be either false or true." -}}
{{- end -}}

{{- $isValid := .Values.setupCfg.usessl | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide Value for usessl. Value can be either false or true." -}}
{{- end -}}

{{- $isSSL := .Values.setupCfg.usessl | toString -}}
{{- $dbVendor := .Values.setupCfg.dbVendor -}}
{{- if and (eq $isSSL "true") ( or (eq $dbVendor "oracle") (eq $dbVendor "Oracle")) -}}
	{{- if not .Values.setupCfg.dbTruststore -}}
	{{- fail "Please provide the path of dbTruststore file." -}}
        {{- end -}}
	{{- if not .Values.setupCfg.dbKeystore -}}
        {{- fail "Please provide the path of dbKeystore file." -}}
        {{- end -}}
{{- end -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.adminEmailAddress -}}
{{- if eq $isValid "false" -}}
{{- fail "Please specify the adminEmailAddress." -}}
{{- end -}}

{{- $isValid := include "emailValidator" .Values.setupCfg.adminEmailAddress -}}
{{- if eq $isValid "false" -}}
{{- fail "Please specify a valid adminEmailAddress." -}}
{{- end -}}

{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.smtpHost -}}
{{- if eq $isValid "false" -}}
{{- fail "Please specify the smtpHost." -}}
{{- end -}}

{{- if .Values.setupCfg.softStopTimeout -}}
	{{- $isValid := include "integerValidation" .Values.setupCfg.softStopTimeout -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Invalid value for softStopTimeout" -}}
	{{- end -}}
{{- end -}}

{{- if .Values.setupCfg.jmsVendor -}}
	
	{{- $queueVendor := .Values.setupCfg.jmsVendor -}}
	{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsConnectionFactory -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Please specify the jmsConnectionFactory." -}}
	{{- end -}}

	{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsQueueName -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Please specify the jmsQueueName." -}}
	{{- end -}}

	{{- if not .Values.setupCfg.jmsConnectionNameList -}}

		{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsHost -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Please specify the jmsHost correctly." -}}
		{{- end -}}

		{{- $isValid := include "isPortValid" .Values.setupCfg.jmsPort -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Please specify the jmsPort correctly." -}}
		{{- end -}}
        {{- else if not (eq $queueVendor "IBMMQ") -}}
		{{- $connectionNameListRegex := "^[a-zA-Z0-9_\\.\\-]{1,}:[0-9]{1,5}(,[a-zA-Z0-9_\\.\\-]{1,}:[0-9]{1,5})*$" -}}
		{{- $isValid := regexMatch $connectionNameListRegex .Values.setupCfg.jmsConnectionNameList -}}
		{{- if eq $isValid false -}}
        	{{- fail "Invalid jmsConnectionNameList format. Please specify comma separated list of FQDN:PORT" -}}
		{{- end -}}
		
	{{- end -}}

	{{- $isSSLEnabled := .Values.setupCfg.jmsEnableSsl | toString -}}
	{{- if not ( or (eq $isSSLEnabled "false") (eq $isSSLEnabled "true")) -}}
	{{- fail "Please provide Value for jmsEnableSsl. Value can be either false or true." -}}
	{{- end -}}

	{{- if eq $isSSLEnabled "true" -}}
		{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsKeystorePath -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Please specify the jmsKeystorePath." -}}
		{{- end -}}

		{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsTruststorePath -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Please specify the jmsTruststorePath." -}}
		{{- end -}}
	{{- end -}}

	{{- if eq $queueVendor "IBMMQ" -}}
		{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsChannel -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Please specify the jmsChannel." -}}
		{{- end -}}
	{{- end -}}

	{{- if and (eq $isSSLEnabled "true") ( or (eq $queueVendor "IBMMQ") (eq $queueVendor "ibmmq")) -}}
		{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsCiphersuite -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Please specify the jmsCiphersuite." -}}
		{{- end -}}

		{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsProtocol -}}
		{{- if eq $isValid "false" -}}
		{{- fail "Please specify the jmsProtocol." -}}
		{{- end -}}

	{{- end -}}



	{{- $result := include "mandatoryArgumentsCheck" .Values.setupCfg.jmsSecret -}}
    {{- if eq $result "false" -}}
    {{- fail ".Values.setupCfg.jmsSecret cannot be empty" -}}
    {{- end -}}

{{- end -}}


{{- $jcePolicyFileUpdate := .Values.setupCfg.updateJcePolicyFile | toString -}}
{{- if not ( or (eq $jcePolicyFileUpdate "false") (eq $jcePolicyFileUpdate "true")) -}}
{{- fail "Please provide value for updateJcePolicyFile. Value can be either false or true." -}}
{{- end -}}

{{- if eq $jcePolicyFileUpdate "true" -}}
	
	{{- $isValid := include "mandatoryArgumentsCheck" .Values.setupCfg.jcePolicyFile -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Please specify the jcePolicyFile." -}}
	{{- end -}}

{{- end -}}

{{- $isValid := .Values.purge.enabled | toString -}}
{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
{{- fail "Please provide value for Values.purge.enabled. Value can be either false or true." -}}
{{- end -}}

{{- $purgeEnabled := .Values.purge.enabled | toString -}}
{{- if eq $purgeEnabled "true" -}}

	{{- $result := include "mandatoryArgumentsCheck" .Values.purge.image.repository -}}
	{{- if eq $result "false" -}}
	{{- fail ".Values.purge.image.repository cannot be empty." -}}
	{{- end -}}
	
	{{- $result := include "mandatoryArgumentsCheck" .Values.purge.image.tag -}}
	{{- if eq $result "false" -}}
	{{- fail ".Values.purge.image.tag cannot be empty" -}}
	{{- end -}}
	
	{{- $result := include "mandatoryArgumentsCheck" .Values.purge.image.pullPolicy -}}
	{{- if eq $result "false" -}}
	{{- fail ".Values.purge.image.pullPolicy cannot be empty" -}}
	{{- end -}}
	
	{{- $isValid := include "mandatoryArgumentsCheck" .Values.purge.schedule -}}
	{{- if eq $isValid "false" -}}
	{{- fail "Please specify the purge schedule." -}}
	{{- end -}}
	
	{{- if .Values.purge.startingDeadlineSeconds -}}
		{{- $result := include "integerValidation" .Values.purge.startingDeadlineSeconds -}}
		{{- if eq $result "false" -}}
		{{- fail "Provide a valid value for .Values.purge.startingDeadlineSeconds" -}}
		{{- end -}}
	{{- end -}}
	
	{{- if .Values.purge.activeDeadlineSeconds -}}
		{{- $result := include "integerValidation" .Values.purge.activeDeadlineSeconds -}}
		{{- if eq $result "false" -}}
		{{- fail "Provide a valid value for .Values.purge.activeDeadlineSeconds" -}}
		{{- end -}}
	{{- end -}}
	
	{{- $isValid := .Values.purge.suspend | toString -}}
	{{- if not ( or (eq $isValid "false") (eq $isValid "true")) -}}
	{{- fail "Please provide value for Values.purge.suspend. Value can be either false or true." -}}
	{{- end -}}
	
	{{- if .Values.purge.successfulJobsHistoryLimit -}}
		{{- $result := include "integerValidation" .Values.purge.successfulJobsHistoryLimit -}}
		{{- if eq $result "false" -}}
		{{- fail "Provide a valid value for .Values.purge.successfulJobsHistoryLimit" -}}
		{{- end -}}
	{{- end -}}
	
	{{- if .Values.purge.failedJobsHistoryLimit -}}
		{{- $result := include "integerValidation" .Values.purge.failedJobsHistoryLimit -}}
		{{- if eq $result "false" -}}
		{{- fail "Provide a valid value for .Values.purge.failedJobsHistoryLimit" -}}
		{{- end -}}
	{{- end -}}
	
	{{- if .Values.purge.concurrencyPolicy -}}
		{{- $result := .Values.purge.concurrencyPolicy -}}
		{{- if not (or (eq $result "Forbid") (eq $result "Replace")) -}}
		{{- fail ".Values.purge.concurrencyPolicy is not valid. Valid values are Forbid or Replace" -}}
		{{- end -}}
	{{- end -}}

{{- end -}}

{{ if .Values.asi.externalAccess.port }}
	{{- $result := include "isPortValid" .Values.asi.externalAccess.port -}}
	{{- if eq $result "false" -}}
	{{- fail "Values.asi.externalAccess.port field is not valid." -}}
	{{- end -}}
{{- end }}
{{ if .Values.api.externalAccess.port }}
	{{- $result := include "isPortValid" .Values.api.externalAccess.port -}}
	{{- if eq $result "false" -}}
	{{- fail "Values.api.externalAccess.port field is not valid." -}}
	{{- end -}}
{{- end }}
{{ if and (.Values.asi.internalAccess.enableHttps) (.Values.asi.internalAccess.httpsPort) }}
	{{- $result := include "isPortValid" .Values.asi.internalAccess.httpsPort -}}
	{{- if eq $result "false" -}}
	{{- fail "Values.asi.internalAccess.httpsPort field is not valid." -}}
	{{- end -}}
{{- end }}

{{/*
{{ if .Values.apiGateway.port }}
	{{- $result := include "isPortValid" .Values.apiGateway.port -}}
	{{- if eq $result "false" -}}
	{{- fail "Values.apiGateway.port field is not valid." -}}
	{{- end -}}
{{- end }}

{{ if .Values.apiGateway.protocol }}
	{{- $result := .Values.apiGateway.protocol -}}
	{{- if not (or (eq $result "http") (eq $result "https")) -}}
	{{- fail "Values.apiGateway.protocol is not valid. Valid values are http or https" -}}
	{{- end -}}
{{- end }}
*/}}

{{- if .Values.asi.myFgAccess.myFgPort -}}
	{{- $result := include "isPortValid" .Values.asi.myFgAccess.myFgPort -}}
	{{- if eq $result "false" -}}
	{{- fail "Values.asi.myFgAccess.myFgPort field is not valid." -}}
	{{- end -}}
{{- end -}}

{{- if .Values.asi.myFgAccess.myFgProtocol -}}
	{{- $result := .Values.asi.myFgAccess.myFgProtocol -}}
	{{- if not (or (eq $result "http") (eq $result "https")) -}}
	{{- fail "Values.asi.myFgAccess.myFgProtocol is not valid. Valid values are http or https" -}}
	{{- end -}}
{{- end -}}

{{- if .Values.ac.myFgAccess.myFgPort -}}
	{{- $result := include "isPortValid" .Values.ac.myFgAccess.myFgPort -}}
	{{- if eq $result "false" -}}
	{{- fail "Values.ac.myFgAccess.myFgPort field is not valid." -}}
	{{- end -}}
{{- end -}}

{{- if .Values.ac.myFgAccess.myFgProtocol -}}
	{{- $result := .Values.ac.myFgAccess.myFgProtocol -}}
	{{- if not (or (eq $result "http") (eq $result "https")) -}}
	{{- fail "Values.ac.myFgAccess.myFgProtocol is not valid. Valid values are http or https" -}}
	{{- end -}}
{{- end -}}

{{- end -}}
