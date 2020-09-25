{{- define "ibm-noi-bkuprestore.sizeData" -}}
hpa:
  size0:
    enabled: false
  size1:
    enabled: false
template:
  size0:
    resources:
      limits:
        memory: 700Mi
        cpu: 600m
      requests:
        memory: 300Mi
        cpu: 500m
  size1:
    resources:
      limits:
        memory: 700Mi
        cpu: 600m
      requests:
        memory: 300Mi
        cpu: 500m
{{- end -}}

{{- define "ibm-noi-bkuprestore.comp.size.data" -}}
  {{- $root := (index . 0) -}}
  {{- $resName := (index . 1) -}}
  {{- $keyName := (index . 2) -}}
  {{- $sizeData := fromYaml (include "ibm-noi-bkuprestore.sizeData" .) -}}
  {{- $resData := index $sizeData $resName -}}
  {{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
  {{- $result := index $resSizeData $keyName -}}

  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
