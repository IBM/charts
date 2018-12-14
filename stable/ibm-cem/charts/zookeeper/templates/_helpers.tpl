{{/* TEMPLATE TO GENERATE A COMMA SEPARATED LIST OF ZOOKEEPER SERVERS */}}
{{/* WILL ONLY WORK WITH GLOBAL CLUSTERSIZE OPTION */}}
{{- define "zookeeper.getServerList" -}}
  {{- if .Values.global.zookeeper.clusterSize }}
    {{- range $i := until (int $.Values.global.zookeeper.clusterSize ) }}
        {{- printf "%s-zookeeper-%d.%s-zkensemble.%s:2181," $.Release.Name $i $.Release.Name $.Release.Namespace -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
