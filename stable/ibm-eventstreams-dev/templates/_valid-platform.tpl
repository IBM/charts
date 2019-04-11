{{- /*
"eventstreams.platform.valid" is a helper function used in the eventstreams
charts that validates the Chart is being installed on the correct platform
*/ -}}
{{- define "eventstreams.supported.platform" -}}
    {{- $params := . -}}
    {{- $root := first $params -}}
    {{- if $root.Values.checkSupportedPlatform -}}
        {{- /* This Chart is not supported on OpenShift, there should be no OpenShift security API presence */ -}}
        {{- if $root.Capabilities.APIVersions.Has "security.openshift.io/v1" -}}
            {{- fail "This chart is not supported on OpenShift." -}}
        {{- end -}}
    {{- end -}}
{{- end }}
