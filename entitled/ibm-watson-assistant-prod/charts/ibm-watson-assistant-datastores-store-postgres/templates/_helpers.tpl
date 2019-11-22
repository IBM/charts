{{- define "assistant.postgres.secret_name" -}}
{{ .Release.Name }}-postgres-secret
{{- end -}}



{{- define "assistant.ibm-postgres.keeper.affinity.nodeAffinity" -}}
  {{- include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
{{- end -}}
{{- define "assistant.ibm-postgres.keeper.affinity.podAntiAffinity" -}}
  {{- if or (eq .Values.global.podAntiAffinity "Enable") (and (eq .Values.global.deploymentType "Production") (ne .Values.global.podAntiAffinity "Disable")) }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
    {{- $labels := include "sch.metadata.labels.standard" (list . ) | fromYaml }}
    {{- range $name, $value := $labels }}
      - key: {{ $name | quote }}
        operator: In
        values:
        - {{ $value | quote }}
    {{- end }}
      - key: "component"
        operator: In
        values:
        - "stolon-keeper"
    topologyKey: "kubernetes.io/hostname"
  {{- end -}}
{{- end -}}

{{- define "assistant.ibm-postgres.sentinel.affinity.nodeAffinity" -}}
  {{- include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
{{- end -}}
{{- define "assistant.ibm-postgres.sentinel.affinity.podAntiAffinity" -}}
  {{- if or (eq .Values.global.podAntiAffinity "Enable") (and (eq .Values.global.deploymentType "Production") (ne .Values.global.podAntiAffinity "Disable")) }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
    {{- $labels := include "sch.metadata.labels.standard" (list . ) | fromYaml }}
    {{- range $name, $value := $labels }}
      - key: {{ $name | quote }}
        operator: In
        values:
        - {{ $value | quote }}
    {{- end }}
      - key: "component"
        operator: In
        values:
        - "stolon-sentinel"
    topologyKey: "kubernetes.io/hostname"
  {{- end -}}
{{- end -}}

{{- define "assistant.ibm-postgres.proxy.affinity.nodeAffinity" -}}
  {{- include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) }}
{{- end -}}
{{- define "assistant.ibm-postgres.proxy.affinity.podAntiAffinity" -}}
  {{- if or (eq .Values.global.podAntiAffinity "Enable") (and (eq .Values.global.deploymentType "Production") (ne .Values.global.podAntiAffinity "Disable")) }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
    {{- $labels := include "sch.metadata.labels.standard" (list . ) | fromYaml }}
    {{- range $name, $value := $labels }}
      - key: {{ $name | quote }}
        operator: In
        values:
        - {{ $value | quote }}
    {{- end }}
      - key: "component"
        operator: In
        values:
        - "stolon-proxy"
    topologyKey: "kubernetes.io/hostname"
  {{- end -}}
{{- end -}}

{{/*
  Because of the cv-linter silliness, we have to copy the templates from "optional" chart ibm-postgresql (in case of provided postgres) here.
  The logic in WA ensured that the tempaltes are used only if ibm-postgresql is enabled, however static analysis in the linter is not strong enought to detect this.
  
  At least linter does not complain if the exactly SAME template is defined twice
*/}}

{{/* Extract from sch char for initialization of sch context but without strange metadata-checks */}}
{{- define "ibm-postgresql.sch.config.init" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $schChartConfigName := (include "sch.utils.getItem" (list $params 1 "sch.chart.default.config.values")) -}}
  {{- $schChartConfig := fromYaml (include $schChartConfigName $root) -}}
  {{- $schConfig := fromYaml (include "sch.config.values" $root) -}}
  {{- $_ := merge $root $schChartConfig -}}
  {{- $_ := merge $root $schConfig -}}
  {{- /* appName and shortName are in $root by default and need to be forcefully overwritten if they exist */ -}}
  {{- if hasKey $schChartConfig.sch.chart "appName" }}
    {{- $_ := set $root.sch.chart "appName" $schChartConfig.sch.chart.appName }}
  {{- end }}
  {{- if hasKey $schChartConfig.sch.chart "shortName" }}
    {{- $_ := set $root.sch.chart "shortName" $schChartConfig.sch.chart.shortName }}
  {{- end }}
{{- end -}}

{{- define "ibm-postgresql.simulatedContext" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $keyForSimulatedContext := (include "sch.utils.getItem" (list $params 1 "result")) -}}

  {{- $postgresSimulatedContext := dict }}
  {{- $_ := set $postgresSimulatedContext        "Values"   (merge dict $root.Values)   }}
  {{- /*  Hacks needed to render "ibmPostgres.sch.chart.config.values"              */ -}}
  {{- $_ := set $postgresSimulatedContext.Values "metering" ""                          }}
  {{- $_ := set $postgresSimulatedContext.Values "securityContext" (dict "postgres" (dict "runAsUser" "" "runAsGroup" "" "fsGroup" "") "creds" (dict "runAsUser" "")) }}
  {{- $_ := set $postgresSimulatedContext        "Release" $root.Release                }}
  {{- $_ := set $postgresSimulatedContext        "Capabilities" $root.Capabilities      }}
  {{- $_ := set $postgresSimulatedContext        "Chart"   (dict "Name" "ibm-postgres") }}
  {{- include "ibm-postgresql.sch.config.init" (list $postgresSimulatedContext "ibmPostgres.sch.chart.config.values") -}}
  {{- $_ := set $root $keyForSimulatedContext $postgresSimulatedContext }}
{{- end -}}

{{- define "ibm-postgresql.svc.proxyServiceName" -}}
  {{- include "ibm-postgresql.simulatedContext" (list . "postgresSimulatedContext") }}
  {{- include "sch.names.fullCompName" (list .postgresSimulatedContext .postgresSimulatedContext.sch.chart.components.proxyService) -}}
{{- end -}}
