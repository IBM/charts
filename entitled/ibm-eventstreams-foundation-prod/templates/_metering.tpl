{{- define "ibm-eventstreams.metering" }}
  {{- $params := . -}}
  {{- /* root context required for accessing other sch files and the edition */ -}}
  {{- $root := first $params -}}
  {{- /* The name of a specific pod, used to get spectic metering configs, default is empty string */ -}}
  {{- $pod := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $version := $root.Chart.AppVersion -}}
  {{- $edition := $root.sch.chart.edition -}}
  {{- $productName := index $root.sch.chart.productName $edition -}}
{{- /* ################### foundation-prod logic ###################### */ -}}
productName: {{ $productName }}
productID: 5737_H33_foundationEdition_nonChargeable
productVersion: {{ $version }}
{{- end }}
