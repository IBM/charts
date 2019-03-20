{{- /*
metadata helpers for SCH (Shared Configurable Helpers)

sch/_metadata.tpl contains shared configurable helper templates for 
creating resource metadata labels and annotations.

Usage of "sch.metadata.*" requires the following line be included at
the begining of template:
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- /*
"sch.metadata.version" contains the version information, tillerVersion constraint
and required tpl files for this version of sch/_metadata.tpl
*/ -}}
{{- define "sch.metadata.version" -}}
version: "1.2.7"
tillerVersion: ">=2.6.0"
{{- end -}}


{{- /*
`"sch.metadata.labels.standard"` will generate the 4 required labels: app, chart,
heritage and release, and will optional create component and a map of additionaly
passed labels.

Note: Kubernetes has updated their standard label names. They are now
app.kubernetes.io/name, helm.sh/chart, app.kubernetes.io/managed-by, and
app.kubernetes.io/instance. To use these new values, set the sch.chart.labelType
to `"prefixed"` in _sch-chart-config.yaml. This will use the new label names as
well as the old release label for backward compatibility reasons.

__Values Used__


__Config Values Used:__
- `.sch.chart.appName`
- `.sch.utils.getItem`

__Parameters input as an list of values:__
- the root context (required)
- component (required "" or "<compName>")
- dict of key value pairs for more labels

__Usage:__
```
  labels:
{{ include "sch.metadata.labels.standard" (list . "") | indent 4 }}  # no component label
or
  labels:
{{ include "sch.metadata.labels.standard" (list . $compName) | indent 4 }} # with component label
or
  labels:
{{ include "sch.metadata.labels.standard" (list . $compName (dict "labelA" "Avalue" "labelB" "Bvalue")) | indent 4 }} # with component label and additional labels
```
*/ -}}
{{- /*
*/ -}}
{{- define "sch.metadata.labels.standard" -}}
  {{- $params := . -}}
  {{- $top := first $params -}}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $labelType := $top.sch.chart.labelType | default "non-prefixed" -}}
  {{- if eq $labelType "non-prefixed" -}}
app: {{ include "sch.names.appName" (list $top)  | quote}}
chart: {{ $top.Chart.Name | quote }}
heritage: {{ $top.Release.Service | quote }}
release: {{ $top.Release.Name | quote }}
  {{- if $compName }}
component: {{ $compName | quote }}
  {{- end -}}
  {{- else -}}
app.kubernetes.io/name: {{ include "sch.names.appName" (list $top)  | quote}}
helm.sh/chart: {{ $top.Chart.Name | quote }}
app.kubernetes.io/managed-by: {{ $top.Release.Service | quote }}
app.kubernetes.io/instance: {{ $top.Release.Name | quote }}
release: {{ $top.Release.Name | quote }}
  {{- if $compName }}
app.kubernetes.io/component: {{ $compName | quote }}
  {{- end -}}
  {{- end -}}
  {{- if (gt (len $params) 2) -}}
    {{- $moreLabels := (index $params 2) -}}
    {{- range $k, $v := $moreLabels }}
{{ $k }}: {{ $v | quote }}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- /*
`"sch.metadata.annotations.metering"` will generate metering annotations based on
the values passed in. License parameters can be included for reporting to the IBM
License Metric Tool.

Licensing parameters include:

- **productMetric:** the install-based metric (PROCESSOR_VALUE_UNIT,
  VIRTUAL_PROCESSOR_CORE, RESOURCE_VALUE_UNIT, etc.)
- **productChargedContainers:** which containers are affected ("All", "", or a
  list of container names)
- **productFlexpointBundle:** the Flexpoint Bundle for this license (optional)
- **productSlmLocation:** the path to the SLM folder in each affected
  container (optional)

Note: When passing licensing values to the `sch.metadata.annotations.metering`
declaration, values for all parameters must be specified. Use `""` and `nil` for
values that are not set. If all licensing parameters are not specified when 
calling `sch.metadata.annotations.metering`, then no licensing parameters will be
included in the output.

__Config Values Used:__
- passed as argument

__Parameters input as an list of values:__
- the root context (required)
- config values map of annotations (required)
- the product metric name (optional)
- the Flexpoint bundle name (optional)
- the list of affected containers (optional)
- the list of paths to SLM folders in each container (optional)

__Usage:__
example chart config values for metering values only (no licensing)
```
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "refApp"
    deploymentName: "deployment3"
    metering:
      productName: "Reference Product"
      productID: "fbf6a96d49214c0abc6a3bc5da6e48cd"
      productVersion: "1.0.0.0"
{{- end -}}
```
used in template as follows:
```
      annotations:
{{- include "sch.metadata.annotations.metering" (list . .sch.chart.metering) | indent 8 }}
```

example chart config values for metering and licensing
```
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "refApp"
    deploymentName: "deployment3"
    metering:
      productName: "Reference Product"
      productID: "fbf6a96d49214c0abc6a3bc5da6e48cd"
      productVersion: "1.0.0.0"
      productMetric: "PROCESSOR_VALUE_UNIT"
      productChargedContainers: "All"
      productFlexpointBundle: "IBM Flexbundle One"
      productSlmLocation: "container1$/opt/ibm/product/slmtags;container2$/var/slmtags"
{{- end -}}
```
used in template as follows:
```
      annotations:
{{- include "sch.metadata.annotations.metering" (list . .sch.chart.metering .Values.ilmt.productMetric .Values.ilmt.productFlexpointBundle (list "container1" "container2" ) (list "container1$/path/to/slm" "container2$/path/to/slm")) | indent 8 }}
or
      annotations:
{{- include "sch.metadata.annotations.metering" (list . .sch.chart.metering "" "" nil nil) | indent 8 }}
```
*/ -}}

{{- define "sch.metadata.annotations.metering" -}}
  {{- $params := . -}}
  {{- $top := first $params -}}
  {{- if (gt (len $params) 1) -}}
    {{- $metering := (index $params 1) -}}
    {{- $excluded := (list "productChargedContainers" "productSlmLocation" "productMetric" "productFlexpointBundle")}}
    {{- range $k, $v := $metering }}
      {{- /* Handle these ilmt parameters outside of the loop */ -}}
      {{- if not (has $k $excluded) }}
{{ $k }}: {{ $v | quote }}
      {{- end }}
    {{- end }}
    {{- /* Future note: This section could be less clunky with Helm 2.12 which can handle parameter reassignment via `=` */}}
    {{- if (eq (len $params) 6) }}
productMetric: {{ (index $params 2) | default $metering.productMetric | quote }}
      {{- if or (index $params 3) (hasKey $metering "productFlexpointBundle") }}
productFlexpointBundle: {{ (index $params 3) | default $metering.productFlexpointBundle | quote }}
      {{- end }}
      {{- if (index $params 4) }}
productChargedContainers: {{ (index $params 4) | join ";" }}
      {{- else if (hasKey $metering "productChargedContainers")}}
productChargedContainers: {{ $metering.productChargedContainers | quote }}
      {{- end }}
      {{- if (index $params 5) }}
productSlmLocation: {{ (index $params 5) | join ";" }}
      {{- else if (hasKey $metering "productSlmLocation")}}
productSlmLocation: {{ $metering.productSlmLocation | quote }}
      {{- end }}
    {{- end }}
  {{- end -}}
{{- end -}}

{{- /*
`"sch.metadata.annotations.nginx.ingress"` will generate nginx ingress annotations based on the values passed in. These values will include both the old annotation prefix of `ingress.kubernetes.io` and the new value of `nginx.ingress.kubernetes.io`. The ingress controller will only use one set of the values and will ignore the other.

__Config Values Used:__
- None

__Parameters input as an list of values:__
- the root context (required)
- config values map of annotations (required)

__Usage:__
example chart config values
```
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "refApp"
    deploymentName: "deployment3"
    nginx:
      ingress:
        ingress.kubernetes.io/rewrite-target: /
        ingress.kubernetes.io/proxy-body-size: "0"
        ingress.kubernetes.io/proxy-buffering: "off"
{{- end -}}
```
used in an ingress template as follows:
```
  annotations:
{{- include "sch.metadata.annotations.nginx.ingress" (list . .sch.chart.nginx.ingress) | indent 4 }}
```
*/ -}}

{{- define "sch.metadata.annotations.nginx.ingress" -}}
  {{- $params := . -}}
  {{- $top := first $params -}}
  {{- if (gt (len $params) 1) -}}
    {{- $ingress := (index $params 1) -}}
{{- /*{{ toYaml $ingress }}*/ -}}
    {{- range $k, $v := $ingress -}}
      {{- if hasPrefix "nginx" $k }}
{{ $k }}: {{ $v | quote }}
{{ substr 6 (len $k) $k }}: {{ $v | quote }}
      {{- else }}
{{ $k }}: {{ $v | quote }}
nginx.{{ $k }}: {{ $v | quote }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
