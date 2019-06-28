{{- /*
"eventstreams.platform.valid" is a helper function used in the eventstreams
charts that validates the Chart is being installed on the correct platform
*/ -}}
{{- define "eventstreams.supported.platform" -}}
    {{- $params := . -}}
    {{- $root := first $params -}}
    {{- if $root.Values.checkSupportedPlatform -}}
        {{- /* This Chart is supported on OpenShift, check for OpenShift security API presence to validate platform */ -}}
        {{- if not ($root.Capabilities.APIVersions.Has "security.openshift.io/v1") -}}
            {{- fail "This chart is not compatible with OpenShift." -}}
        {{- end -}}
    {{- end -}}
{{- end }}
