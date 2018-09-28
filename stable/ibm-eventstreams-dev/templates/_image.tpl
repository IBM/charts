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
    {{- /*
    A boolean string for whether this is an eventstreams owned image
    this only effects whether we pull from ibmcom or not from dockerhub
    If another string then pull from that directory instead
    */ -}}
    {{- $ibmImage := (include "sch.utils.getItem" (list $params 3 "")) -}}
    {{- $repoName := $root.Values.global.image.repository -}}
    {{- $edition := $root.sch.chart.edition -}}
    {{- /* Fail if no image repo has been defined in Values.yaml */ -}}
    {{- if empty $repoName -}}
        {{ fail "Configuration error: Please specify an image repository in global.image.repository." }}
    {{- end -}}
{{- /* dev edition logic */ -}}
    {{- if eq $edition "dev" -}}
        {{- /* If repoName is ibmcom, we are pulling from dockerhub */ -}}
        {{- if eq $repoName "ibmcom" -}}
            {{- /* If eventstreams image template as normal */ -}}
            {{- if eq $ibmImage "true" -}}
                {{ printf "%s/%s-ce:%s" $repoName $imageName $tagName }}
            {{- /* if not ibmImage pull from dockerhub directly */ -}}
            {{- else if eq $ibmImage "false" -}}
                {{ printf "%s:%s" $imageName $tagName }}
            {{- /* Used for pulling from custom dockerhub repos */ -}}
            {{- else -}}
                {{ printf "%s/%s:%s" $ibmImage $imageName $tagName }}
            {{- end }}
        {{- /* else pulling from a private repo */ -}}
        {{- else -}}
            {{- /* if ibmImage add -ce */ -}}
            {{- if eq $ibmImage "true" -}}
                {{ printf "%s/%s-ce:%s" $repoName $imageName $tagName }}
            {{- else -}}
                {{ printf "%s/%s:%s" $repoName $imageName $tagName }}
            {{- end }}
        {{- end -}}
{{- /* prod and foundation-prod edition logic */ -}}
    {{- else -}}
        {{ printf "%s/%s:%s" $repoName $imageName $tagName }}
    {{- end -}}
{{- end -}}
