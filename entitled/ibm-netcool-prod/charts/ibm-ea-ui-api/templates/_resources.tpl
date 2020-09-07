{{- define "ibm-ea-ui-api.sizeData" -}}
hpa:
  size0:
    enabled: false
  size1:
    enabled: false
ui:
  size0:
    nodeHeapSizeMB: 256
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.5"
  size1:
    nodeHeapSizeMB: 512
    resources:
      requests:
        memory: "600Mi"
        cpu: "0.2"
      limits:
        memory: "800Mi"
        cpu: "1.0"
{{- end -}}

{{- define "ibm-ea-ui-api.comp.size.data" -}}
  {{- $root := (index . 0) -}}
  {{- $resName := (index . 1) -}}
  {{- $keyName := (index . 2) -}}
  {{- $sizeData := fromYaml (include "ibm-ea-ui-api.sizeData" .) -}}
  {{- $resData := index $sizeData $resName -}}
  {{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
  {{- $result := index $resSizeData $keyName -}}

  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
