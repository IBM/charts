{/* agent configuration for predictiveinsights */}}
{{- define "agentConfig" }}
RestCommand_service_cpu_metrics.json: |
 {
   "name" : "service_cpu_metrics",
   "description" : "Get the service metrics for my application from prometheus",
   "method" : "GET",
   "url" : "https://{{ "{{" }}prometheus_endpoint{{ "}}" }}/api/v1/query_range?query=sum(rate(container_cpu_usage_seconds_total{{ "{{" }}container_labels{{ "}}" }}[5m])) by (instance,cpu)&start={{ "{{" }}start_time{{ "}}" }}&end={{ "{{" }}end_time{{ "}}" }}&step={{ "{{" }}step_time{{ "}}" }}",
   "headers" : { },
   "parameters" : { },
   "commandInputs" : [ {
     "id" : "query_string",
     "prompt" : "prometheus query string"
   }, {
     "id" : "step_time",
     "prompt" : "time intervals for which to get metrics for e.g 30s"
   }, {
     "id" : "start_time",
     "prompt" : "start time given in RFC3339 format"
   }, {
     "id" : "end_time",
     "prompt" : "end time given in RFC3339 format"
   } ],
   "dataToPost" : ""
 }
RestCommand_post_metrics_pi.json: |
 {
   "name" : "post_metrics_pi",
   "description" : "Post metrics to Predictive Insights",
   "method" : "POST",
   "url" : "http://{{ "{{" }}pi_endpoint{{ "}}" }}/ioa/metrics",
   "headers" : {
     "tenantID" : "{{ "{{" }}tenant_id{{ "}}" }}",
     "Content-Type" : "application/json"
   },
   "parameters" : { },
   "commandInputs" : [ ],
   "dataToPost" : ""
 }
ChainedCommandGroup_icpPromCpu.json: |
 {
   "groupName" : "icpPromCpu",
   "chainedCommands" : [ {
     "name" : "sendCpuUsageToPI",
     "description" : "Get CPU usage for containers by core and instance",
     "commandChain" : [ "service_cpu_metrics", "prometheus_cpu" , "post_metrics_pi"],
     "pollerConfig" : {
       "pollingInterval" : {{ .Values.icpProm.pollingInterval | quote }},
       "attributeArgumentsVals" : {
         "step_time" : {{ .Values.icpProm.attributeArgumentsVals.stepTime | quote }},
         "container_labels" : {{ .Values.icpProm.attributeArgumentsVals.containerLabels | quote }},
         "pi_endpoint" : {{ .Values.icpProm.attributeArgumentsVals.piEndpoint | quote }},
         "tenant_id" : {{ .Values.icpProm.attributeArgumentsVals.tenantId | quote }},
         "prometheus_endpoint" : {{ .Values.icpProm.attributeArgumentsVals.prometheusEndpoint | quote }},
         "group_label": {{ cat .Values.icpProm.attributeArgumentsVals.groupLabel "CPU" | nospace |  quote }}
       },
       "attributeTimestampFmt" : "yyyy-MM-dd'T'HH:mm:ssXXX" 
     }
   }, {
     "name" : "sendMemoryUsageToPI",
     "description" : "Get Memory usage for containers",
     "commandChain" : [ "service_memory_metrics", "prometheus_memory" , "post_metrics_pi"],
     "pollerConfig" : {
       "pollingInterval" : {{ .Values.icpProm.pollingInterval | quote }},
       "attributeArgumentsVals" : {
         "step_time" : {{ .Values.icpProm.attributeArgumentsVals.stepTime | quote }},
         "container_labels" : {{ .Values.icpProm.attributeArgumentsVals.containerLabels | quote }},
         "pi_endpoint" : {{ .Values.icpProm.attributeArgumentsVals.piEndpoint | quote }},
         "tenant_id" : {{ .Values.icpProm.attributeArgumentsVals.tenantId | quote }},
         "prometheus_endpoint" : {{ .Values.icpProm.attributeArgumentsVals.prometheusEndpoint | quote }},
         "group_label": {{ cat .Values.icpProm.attributeArgumentsVals.groupLabel "MEM" | nospace |  quote }}
       },
       "attributeTimestampFmt" : "yyyy-MM-dd'T'HH:mm:ssXXX"
     }
   } ]
 }
TransformerCode_prometheus_cpu.json: |
 {
   "name" : "prometheus_cpu",
   "code" : "var payload = JSON.parse(input.getFirstAttributeValue(\"payload\"));\nvar groupLabel;\nvar pi_input={};\ngroupLabel = input.getFirstAttributeValue(\"group_label\");\nif ( groupLabel === null ) {\n  groupLabel=\"kubecontainer\";\n}\npi_input.groups=[];\n\nif (('status' in payload) && payload.status==\"success\") {\n  var result=payload.data.result;\n  result.forEach( function(result_item){\n    var values = result_item.values;\n    for (index in values) {\n      var pi_timestamp_datum={};\n      var instance=result_item.metric.instance;\n      var cpu=result_item.metric.cpu;\n      pi_timestamp_datum.resourceID = instance + cpu;\n      pi_timestamp_datum.attributes={};\n      pi_timestamp_datum.attributes.group=groupLabel;\n      pi_timestamp_datum.attributes.node=instance;\n      pi_timestamp_datum.timestamp='' + values[index][0]*1000;\n      pi_timestamp_datum.metrics = { \"cpu_usage\" : parseFloat(values[index][1]) };\n      pi_input.groups.push(pi_timestamp_datum);\n    }\n  });\n  input.setAttribute(\"payload\",JSON.stringify(pi_input));\n}"
 }
TransformerCode_prometheus_memory.json: |
 {
   "name" : "prometheus_memory",
   "code" : "var payload = JSON.parse(input.getFirstAttributeValue(\"payload\"));\nvar groupLabel;\nvar pi_input={};\ngroupLabel = input.getFirstAttributeValue(\"group_label\");\nif ( groupLabel === null ) {\n  groupLabel=\"kubecontainer\";\n}\npi_input.groups=[];\n\nif (('status' in payload) && payload.status==\"success\") {\n  var result=payload.data.result;\n  result.forEach( function(result_item){\n    var values = result_item.values;\n    for (index in values) {\n      var pi_timestamp_datum={};\n      var instance=result_item.metric.instance;\n      pi_timestamp_datum.resourceID = instance + \"memory\";\n pi_timestamp_datum.attributes={};\n      pi_timestamp_datum.attributes.group=groupLabel;\n      pi_timestamp_datum.attributes.node=instance;\n      pi_timestamp_datum.timestamp='' + values[index][0]*1000;\n      pi_timestamp_datum.metrics = { \"memory_usage\" : parseFloat(values[index][1]) };\n      pi_input.groups.push(pi_timestamp_datum);\n    }\n  });\n  input.setAttribute(\"payload\",JSON.stringify(pi_input));\n}"
 }
 }
RestCommand_service_memory_metrics.json: |
 {
   "name" : "service_memory_metrics",
   "description" : "Get the service memory metrics for my application from prometheus",
   "method" : "GET",
   "url" : "https://{{ "{{" }}prometheus_endpoint{{ "}}" }}/api/v1/query_range?query=sum(container_memory_usage_bytes{{ "{{" }}container_labels{{ "}}" }}) by (instance)&start={{ "{{" }}start_time{{ "}}" }}&end={{ "{{" }}end_time{{ "}}" }}&step={{ "{{" }}step_time{{ "}}" }}",
   "headers" : { },
   "parameters" : { },
   "commandInputs" : [ {
     "id" : "query_string",
     "prompt" : "prometheus query string"
   }, {
     "id" : "step_time",
     "prompt" : "time intervals for which to get metrics for e.g 30s"
   }, {
     "id" : "start_time",
     "prompt" : "start time given in RFC3339 format"
   }, {
     "id" : "end_time",
     "prompt" : "end time given in RFC3339 format"
   } ],
   "dataToPost" : ""
 }
{{- end }}
