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
productName: '|kafka:IBM Event Streams (Chargeable)|healthcheck:IBM Event Streams|metrics-reporter:IBM Event Streams|metrics-proxy:IBM Event Streams|tls-proxy:IBM Event Streams'
productID: '|kafka:5737_H33_chargeable|healthcheck:5737_H33_nonChargeable|metrics-reporter:5737_H33_nonChargeable|metrics-proxy:5737_H33_nonChargeable|tls-proxy:5737_H33_nonChargeable'
productVersion: '|kafka:{{ $version }}|healthcheck:{{ $version }}|metrics-reporter:{{ $version }}|metrics-proxy:{{ $version }}|tls-proxy:{{ $version }}'
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
{{- /* ################### icp4i-prod logic ###################### */ -}}
  {{- else if eq $edition "icp4i-prod" -}}
    {{- $prodNameLabel := or (and (not $root.Values.global.production) " (non-production)") ""  }}
    {{- $prodIDLabel := or (and (not $root.Values.global.production) "_nonProd") ""  }}
    {{- if eq $pod "" -}}
productName: IBM Cloud Pak for Integration{{ $prodNameLabel }} - Event Streams
productID: EventStreams_5737_I89_ICP4I{{ $prodIDLabel }}_nonChargeable
productVersion: {{ $version }}
    {{- else if eq $pod "kafka" -}}
productName: '|kafka:IBM Cloud Pak for Integration{{ $prodNameLabel }} - Event Streams (Chargeable)|healthcheck:IBM Cloud Pak for Integration{{ $prodNameLabel }} - Event Streams|metrics-reporter:IBM Cloud Pak for Integration{{ $prodNameLabel }} - Event Streams|metrics-proxy:IBM Cloud Pak for Integration{{ $prodNameLabel }} - Event Streams|tls-proxy:IBM Cloud Pak for Integration{{ $prodNameLabel }} - Event Streams'
productID: '|kafka:EventStreams_5737_I89_ICP4I{{ $prodIDLabel }}_chargeable|healthcheck:EventStreams_5737_I89_ICP4I{{ $prodIDLabel }}_nonChargeable|metrics-reporter:EventStreams_5737_I89_ICP4I{{ $prodIDLabel }}_nonChargeable|metrics-proxy:EventStreams_5737_I89_ICP4I{{ $prodIDLabel }}_nonChargeable|tls-proxy:EventStreams_5737_I89_ICP4I{{ $prodIDLabel }}_nonChargeable'
productVersion: '|kafka:{{ $version }}|healthcheck:{{ $version }}|metrics-reporter:{{ $version }}|metrics-proxy:{{ $version }}|tls-proxy:{{ $version }}'
    {{- else if eq $pod "replicator" -}}
productName: '|replicator:IBM Cloud Pak for Integration{{ $prodNameLabel }} - Event Streams (Chargeable)|metrics-reporter:IBM Cloud Pak for Integration{{ $prodNameLabel }} - Event Streams'
productID: '|replicator:EventStreams_5737_I89_ICP4I{{ $prodIDLabel }}_chargeable|metrics-reporter:EventStreams_5737_I89_ICP4I{{ $prodIDLabel }}_nonChargeable'
productVersion: '|replicator:{{ $version }}|metrics-reporter:{{ $version }}'
    {{- else -}}
      {{- fail "Invalid pod" -}}
    {{- end -}}
{{- /* Invalid edition, fail the build as cannot define metering */ -}}
  {{- else -}}
    {{- fail "Invalid edition" -}}
  {{- end -}}
{{- end -}}
