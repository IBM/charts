{{- define "ibm-eventstreams.metering" }}
  {{- $params := . -}}
  {{- /* root context required for accessing other sch files and the edition */ -}}
  {{- $root := first $params -}}
  {{- /* The name of a specific pod, used to get spectic metering configs, default is empty string */ -}}
  {{- $pod := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $version := $root.Chart.AppVersion -}}
  {{- $edition := $root.sch.chart.edition -}}
  {{- $productName := index $root.sch.chart.productName $edition -}}
{{- /* ################### icp4i-prod logic ###################### */ -}}
productVersion: {{ $version }}
productMetric: VIRTUAL_PROCESSOR_CORE
  {{- if $root.Values.global.production }}
productName: IBM Cloud Pak for Integration - Event Streams
productID: 2cba508800504d0abfa48a0e2c4ecbe2
productCloudpakRatio: 1:1
  {{- else }}
productName: IBM Event Streams for Non Production
productID: 2a79e49111f44ec3acd89608e56138f5
productCloudpakRatio: 2:1
  {{- end }}
  {{- if or (eq $pod "") $root.Values.global.supportingProgram }}
# if supporting program, or not chargable pod, set metering to non chargable
productChargedContainers: ""
  {{- else if eq $pod "kafka" }}
productChargedContainers: "kafka"
  {{- else if eq $pod "replicator" }}
productChargedContainers: "replicator"
  {{- else }}
    {{- fail "Invalid pod" }}
  {{- end }}
cloudpakName: IBM Cloud Pak for Integration
cloudpakId: c8b82d189e7545f0892db9ef2731b90d
cloudpakVersion: 2020.1.1
{{- end }}
