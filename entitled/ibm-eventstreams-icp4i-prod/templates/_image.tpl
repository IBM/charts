{{- /*
"eventstreams.image" is a helper function used in the eventstreams common
charts that returns an image path that is appropriate for both its chart
and the image repository it is pulling from
*/ -}}
{{- define "eventstreams.image" -}}
    {{- $params := . -}}
    {{- /* root context required for accessing other sch files */ -}}
    {{- $root := first $params -}}
    {{- /* The image we are going to edit */ -}}
    {{- $imageName := (include "sch.utils.getItem" (list $params 1 "")) -}}
    {{- /* The image tag shared across editions */ -}}
    {{- $tagName := (include "sch.utils.getItem" (list $params 2 "")) -}}
    {{- $platformName := "icp" -}}
    {{- $osName := "linux" -}}
    {{- $archName := $root.Values.global.arch -}}
    {{- $repoName := trimSuffix "/" $root.Values.global.image.repository -}}
    {{- $edition := $root.sch.chart.edition -}}
    {{- /* Fail if no image repo has been defined in Values.yaml */ -}}
    {{- if empty $repoName -}}
        {{ fail "Configuration error: Please specify an image repository in global.image.repository." }}
    {{- end -}}
{{- /* dev edition logic */ -}}
    {{- if eq $edition "dev" -}}
        {{- /* If repoName is ibmcom, we are pulling from dockerhub */ -}}
        {{- /* add -ce */ -}}
        {{ printf "%s/%s-ce-%s-%s-%s:%s" $repoName $imageName $platformName $osName $archName $tagName }}
{{- /* prod-like logic */ -}}
    {{- else -}}
        {{ printf "%s/%s-%s-%s-%s:%s" $repoName $imageName $platformName $osName $archName $tagName }}
    {{- end -}}
{{- end -}}
