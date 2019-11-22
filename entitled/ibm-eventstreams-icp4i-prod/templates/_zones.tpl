{{/*
    Helper function to name items for zone duplication
*/}}
{{- define "name.including.zone" }}
{{- $name := index . 0 -}}
{{- $zone := index . 1 -}}
{{- /* Remove 0 for old upgrades */ -}}
{{- if ne (int $zone) 0 -}}
  {{- printf "%s-%d" $name $zone -}}
{{- else -}}
  {{- printf "%s" $name -}}
{{- end -}}
{{- end -}}

{{/*
    Helper function that returns the number of zones to template for
*/}}
{{- define "zones.to.template" }}
  {{- $root := index . 0 -}}
  {{- $zoneCount := int $root.Values.global.zones.count -}}
  {{- if lt $zoneCount 1 -}}
    {{ fail "Configuration error: Minimum of 1 zones required." }}
  {{- end -}}
  {{- if and $root.Values.global.zones.safe (eq $zoneCount 2) -}}
    {{- fail "Configuration error: Zone count set to 2 is not supported" -}}
  {{- end -}}
  {{- if gt (len $root.Values.global.zones.labels) 1 -}}
    {{- if not (eq $zoneCount (len $root.Values.global.zones.labels)) -}}
      {{- fail "Zone Count does not match number of label" -}}
    {{- end -}}
    {{- int $zoneCount -}}
  {{- else -}}
    {{- /* Zones to template is one because cluster is zone aware, number of zones is used as number of replicas unless smaller than default */ -}}
    {{- int 1 -}}
  {{- end -}}
{{- end -}}

{{/*
    Helper function that returns replicas for the template
*/}}
{{- define "replicas.for.zone" }}
  {{- $root := index . 0 -}}
  {{- $defultReplicasForOneZone := index . 1 -}}
  {{- $replicasForEachZone := int (index . 2) -}}
  {{ $zonesToTemplate := int (include "zones.to.template" (list $root)) -}}
  {{- if eq $zonesToTemplate 1 -}}
    {{- /* For zone aware cluster set to number of zones times desired replicas per zone unless it is less than default */ -}}
    {{- /* Value is capped at 6 */ -}}
    {{- $replicasForZoneAware :=  mul $root.Values.global.zones.count $replicasForEachZone -}}
    {{- $replicas := max $defultReplicasForOneZone $replicasForZoneAware -}}
    {{- min $replicas 6 -}}
  {{- else }}
    {{- $replicasForEachZone -}}
  {{- end -}}
{{- end -}}

{{/*
    Helper function that returns replicas for the edge proxy (as this has different scaling rules).
    There will always be at least 2 instances and in zone aware / single zone capped at the number of kafka brokers
*/}}
{{- define "edgeproxy.replicas.for.zone" }}
  {{- $root := index . 0 -}}
  {{- $defultReplicasForOneZone := 2 -}}
  {{- $replicasForEachZone := int (index . 1) -}}
  {{ $zonesToTemplate := int (include "zones.to.template" (list $root)) -}}
  {{- if eq $zonesToTemplate 1 -}}
    {{- /* For zone aware cluster set to number of zones times desired replicas per zone unless it is less than default */ -}}
    {{- /* Value is capped at the number of Kafka brokers */ -}}
    {{- $replicasForZoneAware :=  mul $root.Values.global.zones.count $replicasForEachZone -}}
    {{- $replicas := max $defultReplicasForOneZone $replicasForZoneAware -}}
    {{- min $replicas $root.Values.kafka.brokers -}}
  {{- else }}
    {{- $replicasForEachZone -}}
  {{- end -}}
{{- end -}}