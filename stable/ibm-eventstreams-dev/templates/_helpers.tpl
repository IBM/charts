{{/*
    Helper function to reverse arg order for regexReplaceAllLiteral so that it can fit in
    a template pipeline. Eg:
    {{ . | list "[^a-zA-Z0-9-]+" "" | include "ibm-eventstreams.replaceAll" | ... }}

    'list' builds the argument list, appending the current pipeline, and passes the result to this template
*/}}
{{- define "ibm-eventstreams.replaceAll" }}
{{- $pattern := index . 0 }}
{{- $replacement := index . 1 }}
{{- $text := index . 2 }}
{{- regexReplaceAllLiteral $pattern $text $replacement }}
{{- end }}

{{- define "ibm-eventstreams.asDnsLabel" -}}
{{- regexReplaceAllLiteral "[^a-zA-Z0-9-]+" . "" | lower | trunc 63 | trimAll "-" -}}
{{- end -}}

{{- define "ibm-eventstreams.asK8sLabel" -}}
{{- regexReplaceAllLiteral "[^a-zA-Z0-9-._]+" . "" | trimAll "-_." -}}
{{- end -}}
