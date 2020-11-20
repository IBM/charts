{{- /*
metadata helpers for SCH (Shared Configurable Helpers)

sch/_metadata.tpl contains shared configurable helper templates for 
creating resource metadata labels and annotations.

Usage of "sch.metadata.*" requires the following line be include at 
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
version: "1.0.0"
tillerVersion: ">=2.6.0"
requires:
  - "templates/sch-2.6.0/_config.tpl"
  - "templates/sch-2.6.0/_utils.tpl"
{{- end -}}


{{- /*
`"sch.metadata.labels.standard"` will generate the 4 required labels app, chart, 
heritage and release, and will optional create component and a map of additionaly 
passed labels.

__Values Used__


__Config Values Used:__
- `.sch.chart.appName`
- `.sch.utils.getItem`

__Parameters input as an list of values:__
- the root context (required)
- component (required "" or "<compName>)
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
  {{- $chartNameWithVersion := (printf "%s-%s" $top.Chart.Name $top.Chart.Version) | replace "+" "_" -}}
app: {{ include "sch.names.appName" (list $top)  | quote}}
chart: {{ $chartNameWithVersion | quote }} 
heritage: {{ $top.Release.Service | quote }}
release: {{ $top.Release.Name | quote }}
  {{- if $compName }}
component: {{ $compName | quote }}
  {{- end -}}    
  {{- if (gt (len $params) 2) -}}
    {{- $moreLabels := (index $params 2) -}}
    {{- range $k, $v := $moreLabels }}
{{ $k }}: {{ $v | quote }}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- /*
`"sch.metadata.annotations.metering"` will generate metering annotations based
on values pass in. These values can (recommend) via the sch chart config values.


__Config Values Used:__
- passed as argument

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
*/ -}}
{{- /*
*/ -}}
{{- define "sch.metadata.annotations.metering" -}}
  {{- $params := . -}}
  {{- $top := first $params -}}
  {{- if (gt (len $params) 1) -}}
    {{- $metering := (index $params 1) -}}
{{- /*{{ toYaml $metering }}*/ -}}
    {{- range $k, $v := $metering }}
{{ $k }}: {{ $v | quote }}
    {{- end -}}

  {{- end -}}
{{- end -}}