{{- /*
Name helpers for SCH (Shared Configurable Helpers)

sch/_names.tpl contains shared configurable helper templates for 
creating resource names.

Usage of "sch.names.*" requires the following line be include at 
the begining of template:
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- /*
"sch.names.version" contains the version information, tillerVersion constraint
and required tpl files for this version of sch/_names.tpl
*/ -}}
{{- define "sch.utils.version" -}}
version: "1.0.0"
tillerVersion: ">=2.6.0"
requires:
{{- end -}}

{{/*
"sch.utils.truncUnique" is a shared helper which takes a string and truncates
it to a specified length, making the last part "somewhat random" with a specified 
amount of character suffix based of the sha256 of the truncated string.

Config Values Used: NA
  
Uses: NA
    
Parameters input a dict:
  - a dict with with fields (required)
    - text (required)
    - length (required)
    - unique (optional)

Usage:
      {{- $truncUniqueParms := dict "text" $element.name "length" $element.length "unique" (default 4 $element.unique) -}}
      {{- printf "%s" (include "sch.utils.truncUnique" $truncUniqueParms | trimSuffix "-") -}}
 
*/}}
{{- define "sch.utils.truncUnique" -}}
  {{- $parms := . -}}
  {{- $totalLength := len $parms.text -}}
  {{- $uniqueSize := add 1 (min (default 4 $parms.unique) (int (sub $parms.length 1))) -}}
  {{- if (gt (int $totalLength) (int $parms.length)) -}}
    {{- $prefixLength := int (sub $parms.length $uniqueSize) -}}
    {{- $prefix := substr 0 $prefixLength $parms.text -}}
    {{- $discard := substr $prefixLength $totalLength $parms.text -}}
    {{- $uniqueSuffix := $discard | sha256sum | trunc (int (sub $uniqueSize 1)) -}}
    {{- $result := cat $prefix "-" $uniqueSuffix | replace " " "" -}}  
    {{- $result -}}
  {{- else -}}
    {{- $parms.text -}}
  {{- end -}}
{{- end -}}


{{/*
"sch.utils.withinLength" is a shared helper which takes a string and a length.
if the the string fits within the length it is generated, else not text is 
generated.

Config Values Used: NA
  
Uses: NA
    
Parameters input as an array of one values:
  - the root context (required)
  - the text to test (required)
  - the length to test (required)

Usage:
  {{- $lengthTestResult :=  include "sch.utils.withinLength" (list $root "sometext" 4) -}}
 
*/}}
{{- define "sch.utils.withinLength" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $text := (index $params 1) -}}
  {{- $length := (index $params 2) -}}
  {{- if (not (gt (len $text) (int $length))) -}}
    {{- $text -}}
  {{- end -}}
{{- end -}}


{{/*
"sch.utils.getItem" is a shared helper to get an item based on the index in the 
list and default value if the item does not exist. If the item exists, its text is 
generated, if the index is out of range of the list, then the default text is generated.

Config Values Used: NA
  
Uses: NA
    
Parameters input as an array of one values:
  - a list of items (required)
  - the index of the list (required)
  - the default text (required)

Usage:
  {{- $param1 := (include "sch.utils.getItem" (list $params 1 "defaultValue")) -}}
 
*/}}
{{- define "sch.utils.getItem" -}}
  {{- $params := . -}}
  {{- $list := first $params -}}
  {{- $index := (index $params 1) -}}
  {{- $default := (index $params 2) -}}
  {{- if (gt (add $index 1) (len $list) ) -}}
    {{- $default -}}
  {{- else -}}
    {{- index $list $index -}}
  {{- end -}}
{{- end -}}




