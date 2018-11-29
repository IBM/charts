{{- define "metering" }}
  {{- $params := . -}}
  {{- /* root context required for accessing other sch files and the edition */ -}}
  {{- $root := first $params -}}
  {{- /* The name of a specific pod, used to get spectic metering configs, default is empty string */ -}}
  {{- $pod := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $version := $root.Chart.Version -}}
  {{- $edition := $root.sch.chart.edition -}}
  {{- $productName := index $root.sch.chart.productName $edition -}}
{{- /* ################### dev logic ################################# */ -}}
  {{- if eq $edition "dev" -}}
productName: {{ $productName }}
productID: 5737_H33_communityEdition_nonChargeable
productVersion: {{ $version }}
{{- /* #################### prod logic ################################ */ -}}
  {{- else if eq $edition "prod" -}}
    {{- if eq $pod "" -}}
productName: {{ $productName }}
productID: 5737_H33_nonChargeable
productVersion: {{ $version }}
    {{- else if eq $pod "kafka" -}}
productName: '|kafka:IBM Event Streams (Chargeable)|healthcheck:IBM Event Streams|metrics-reporter:IBM Event Streams|metrics-proxy:IBM Event Streams'
productID: '|kafka:5737_H33_chargeable|healthcheck:5737_H33_nonChargeable|metrics-reporter:5737_H33_nonChargeable|metrics-proxy:5737_H33_nonChargeable'
productVersion: '|kafka:{{ $version }}|healthcheck:{{ $version }}|metrics-reporter:{{ $version }}|metrics-proxy:{{ $version }}'
    {{- else if eq $pod "replicator" -}}
productName: '|replicator:IBM Event Streams (Chargeable)|metrics-reporter:IBM Event Streams'
productID: '|replicator:5737_H33_chargeable|metrics-reporter:5737_H33_nonChargeable'
productVersion: '|replicator:{{ $version }}|metrics-reporter:{{ $version }}'
    {{- else -}}
      {{- fail "Invalid pod" -}}
    {{- end -}}
{{- /* ################### foundation-prod logic ###################### */ -}}
  {{- else if eq $edition "foundation-prod" -}}
productName: {{ $productName }}
productID: 5737_H33_foundationEdition_nonChargeable
productVersion: {{ $version }}
{{- /* Invalid edition, fail the build as cannot define metering */ -}}
  {{- else -}}
    {{- fail "Invalid edition" -}}
  {{- end -}}
{{- end -}}
