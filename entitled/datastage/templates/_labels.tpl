{{- define "ds.additional.labels" -}}
{{- $params := . -}}
{{- $root := first $params -}}
"app.kubernetes.io/instance": {{ $root.Release.Name }}
"app.kubernetes.io/managed-by": {{ $root.Release.Service }}
"app.kubernetes.io/name": {{ $root.Chart.Name }}
"helm.sh/chart": {{ printf "%s-%s" $root.Chart.Name $root.Chart.Version }}
{{- end -}}
