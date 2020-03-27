{{- define "autoConfigurator.sizeData" -}}
autoConfiguratorGo:
  size0:
    resources:
      requests:
        memory: "75Mi"
        cpu: "0.1"
      limits:
        memory: "150Mi"
        cpu: "0.5"
  size0_amd64:
    resources:
      requests:
        memory: "75Mi"
        cpu: "0.1"
      limits:
        memory: "150Mi"
        cpu: "0.5"
  size0_ppc64le:
    resources:
      requests:
        memory: "75Mi"
        cpu: "0.05"
      limits:
        memory: "150Mi"
        cpu: "0.25"
  size1:
    resources:
      requests:
        memory: "100Mi"
        cpu: "0.2"
      limits:
        memory: "200Mi"
        cpu: "1.0"
  size1_amd64:
    resources:
      requests:
        memory: "100Mi"
        cpu: "0.2"
      limits:
        memory: "200Mi"
        cpu: "1.0"
  size1_ppc64le:
    resources:
      requests:
        memory: "100Mi"
        cpu: "0.1"
      limits:
        memory: "200Mi"
        cpu: "0.5"
{{- end -}}
{{- define "autoConfigurator.comp.size.data" -}}
{{- $root := (index . 0) -}}
{{- $resName := (index . 1) -}}
{{- $keyName := (index . 2) -}}
{{- $sizeData := fromYaml (include "autoConfigurator.sizeData" .) -}}
{{- $resData := index $sizeData $resName -}}
{{- $resSizeData := index $resData $root.Values.global.environmentSize -}}
{{- $result := index $resSizeData $keyName -}}
{{- if eq $keyName "jvmArgs" -}}
  {{- $result -}}
{{- else -}}
  {{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}
{{- end -}}
