{{- /*
"restrict.namespace" is a helper function used in the eventstreams common
charts that prevents releases into restricted namespaces
*/ -}}
{{- define "restrict.namespace" -}}
    {{- $params := . -}}
    {{- /* root context required for accessing other sch files */ -}}
    {{- $root := first $params -}}
    {{- /* Chosen namespace */ -}}
    {{- $namespace := (include "sch.utils.getItem" (list $params 1 "")) -}}
    {{- $restrictedNamespaces := $root.sch.restrictedNamespaces -}}
    {{- /* Fail if chosen namespace is restricted */ -}}
    {{- range $restrictedNamespaces -}}
        {{- if eq $namespace . -}}
            {{ fail "Configuration error: You cannot deploy this chart into the chosen namespace." }}
        {{- end -}}
    {{- end -}}
    {{- print $namespace | quote -}}
{{- end -}}
