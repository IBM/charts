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
{{- define "sch.names.version" -}}
version: "1.2.7"
tillerVersion: ">=2.6.0"
{{- end -}}


{{- /*
`"sch.names.appName"` will generate a app name based on the precedence and
existanece of `.Values.nameOverride`, `.sch.chart.appName`,
 `.sch.chart.shortName`, `.Chart.Name`.

__Values Used__
- `.Values.nameOverride`
- `.Chart.Name`

__Config Values Used:__
- `.sch.chart.appName`
- `.sch.chart.shortName`

__Parameters input as an list of values:__
- the root context (required)

__Precedence is the following:__
1) `.Values.nameOverride`
2) `.sch.chart.appName`
3) `.sch.chart.shortName`
4) `.Chart.Name`

__Usage:__
```
  app: {{ include "sch.names.appName" (list .) }}
```
*/ -}}

{{- define "sch.names.appName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $schBase := dict "sch" (dict "chart" (dict "shortName" "" "appName" "")) -}}
  {{- $_ := merge $root $schBase -}}
  {{- $appName := coalesce $root.Values.nameOverride $root.sch.chart.appName  $root.sch.chart.shortName $root.Chart.Name -}}
  {{- $appName -}}
{{- end -}}

{{/*
`"sch.names.fullName"` will generate a fullName made up of `.Release.name` and
appName, it will truncate the name parts based on values defined in
`sch.names.fullName.*`.

When name parts are truncated, a "somewhat random" 4 character suffix is used
for each part, which is the first 4 characters of the sha256 or the truncated
string.

__Config Values Used:__
- `.sch.names.fullName.maxLength`
- `.sch.names.fullName.releaseNameTruncLength`
- `.sch.names.fullName.appNameTruncLength`

__Uses:__
- `"sch.utils.getItem"`
- `"sch.names.releaseAppCompName"`

__Parameters input as a list of values:__
- the root context (required)

__Usage:__
```
  name: {{ include "sch.names.fullName" (list .) }}
  or
  name: {{ include "sch.names.fullName" (list . 54) }}
```
*/}}
{{- define "sch.names.fullName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}

  {{/* $schBase values are defined in sch/_config.yaml and can be modified by chart in sch-chart-config.yaml*/}}
  {{- $schBase := dict "sch" (dict "names" (dict "fullName" (dict "maxLength" 253 "releaseNameTruncLength" 253 "appNameTruncLength" 253))) -}}
  {{- $_ := merge $root $schBase -}}
  {{- $maxLength := (int ($root.sch.names.fullName.maxLength)) -}}
  {{- $truncLength := (int (include "sch.utils.getItem" (list $params 1 $maxLength))) -}}
  {{- $releaseNameTruncLength := (int ($root.sch.names.fullName.releaseNameTruncLength)) -}}
  {{- $appNameTruncLength := (int ($root.sch.names.fullName.appNameTruncLength)) -}}
  {{- $compName := "" -}}
  {{- $compNameTruncLength := 0 -}}
  {{- $fullName := include "sch.names.releaseAppCompName" (list $root $compName $maxLength $releaseNameTruncLength $appNameTruncLength $compNameTruncLength) -}}
  {{- $fullName | lower | trunc $truncLength | trimSuffix "-" -}}
{{- end -}}


{{/*
`"sch.names.fullCompName"` will generate a compName made up of `.Release.name`,
appName and if specified an optional component name, it will truncate the name
parts based on values defined in `sch.names.fullCompName.*`.

When name parts are truncated, a "somewhat random" 4 digit suffix is used for
each part, which is the first 4 characters of the sha256 or the truncated string. 

__Config Values Used:__
- `.sch.names.fullCompName.maxLength`
- `.sch.names.fullCompName.releaseNameTruncLength`
- `.sch.names.fullCompName.appNameTruncLength`
- `.sch.names.fullCompName.compNameTruncLength`

__Uses:__
- `"sch.utils.getItem"`
- `"sch.names.releaseAppCompName"`

__Parameters input as a list of values:__
- the root context (required)
- component name (optional)

__Usage:__ 
```
  name: {{ include "sch.names.fullCompName" (list .) }}
  or
  compName: {{ include "sch.names.fullCompName" (list . $compName) }}
```
*/}}
{{- define "sch.names.fullCompName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) -}}

  {{/* $schBase values are defined in sch/_config.yaml and can be modified by chart in sch-chart-config.yaml*/}}
  {{- $schBase := dict "sch" (dict "names" (dict "fullCompName" (dict "maxLength" 253 "releaseNameTruncLength" 253 "appNameTruncLength" 253 "compNameTruncLength" 253))) -}}
  {{- $_ := merge $root $schBase -}}
  {{- $maxLength := (int ($root.sch.names.fullCompName.maxLength)) -}}
  {{- $releaseNameTruncLength := (int ($root.sch.names.fullCompName.releaseNameTruncLength)) -}}
  {{- $appNameTruncLength := (int ($root.sch.names.fullCompName.appNameTruncLength)) -}}
  {{- $compNameTruncLength := (int ($root.sch.names.fullCompName.compNameTruncLength)) -}}
  {{- include "sch.names.releaseAppCompName" (list $root $compName $maxLength $releaseNameTruncLength $appNameTruncLength $compNameTruncLength) -}}
{{- end -}}


{{/*
`"sch.names.statefulSetName"` will generate a statefulSet name made up of 
release name, appName and if specified an optional component name, it will 
truncate the name parts based on values defined in `sch.names.statefulSetName.*`.

When name parts are truncated, a "somewhat random" 4 character suffix is used
for each part, which is the first 4 characters of the sha256 or the truncated
string.

Because statefulSet can have VolumeClaimTemplates, and if that
VolumeClaimTemplates generates a dynamic PV with a storage class such as
GlusterFS, it could result in generating a service with a name containing the
statefulSet name; therefore, there may be cases in which the statefulSet name
needs to be truncated based on the default or chart specified configuration.

__Config Values Used:__
- `.sch.names.statefulSetName.maxLength`
- `.sch.names.statefulSetName.releaseNameTruncLength`
- `.sch.names.statefulSetName.appNameTruncLength`
- `.sch.names.statefulSetName.compNameTruncLength`

__Uses:__
- `"sch.utils.getItem"`
- `"sch.names.releaseAppCompName"`

__Parameters input as a list of values:__
- the root context (required)
- component name (optional)

__Usage:__ 
```
  {{- $compName := "refComp" -}}
  {{- $statefulSetName := include "sch.names.statefulSetName" (list . $compName) -}}
    or
  {{- $statefulSetName := include "sch.names.statefulSetName" (list .) -}}
```
*/}}
{{- define "sch.names.statefulSetName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) -}}

  {{/* $schBase values are defined in sch/_config.yaml and can be modified by chart in sch-chart-config.yaml*/}}
  {{- $schBase := dict "sch" (dict "names" (dict "statefulSetName" (dict "maxLength" 253 "releaseNameTruncLength" 253 "appNameTruncLength" 253 "compNameTruncLength" 253))) -}}
  {{- $_ := merge $root $schBase -}}

  {{- $maxLength := (int ($root.sch.names.statefulSetName.maxLength)) -}}
  {{- $releaseNameTruncLength := (int ($root.sch.names.statefulSetName.releaseNameTruncLength)) -}}
  {{- $appNameTruncLength := (int ($root.sch.names.statefulSetName.appNameTruncLength)) -}}
  {{- $compNameTruncLength := (int ($root.sch.names.statefulSetName.compNameTruncLength)) -}}
  {{- include "sch.names.releaseAppCompName" (list $root $compName $maxLength $releaseNameTruncLength $appNameTruncLength $compNameTruncLength) -}}
{{- end -}}
*/}}


{{/*
`"sch.names.volumeClaimTemplateName"` will truncate the pvc name part based on
values defined in `sch.names.volumeClaimTemplateName.*` and the length of the
statefulSet name.

When name parts are truncated, a "somewhat random" 4 character suffix is used
for each part, which is the first 4 characters of the sha256 or the truncated
string.

Because VolumeClaimTemplates may generate a dynamic PV with a storage class
such as GlusterFS, it could result in generating a service with a name containing
the statefulSet name; therefore, there may be cases in which the statefulSet
name needs to be used to determine length available for the pvc name.

__Config Values Used:__
- `.sch.names.volumeClaimTemplateName.maxLength`
- `.sch.names.volumeClaimTemplateName.claimNameTruncLength`
- `.sch.names.volumeClaimTemplateName.possiblePrefix`

__Uses:__
- `"sch.utils.getItem"`
- `"sch.names.buildName"`

__Parameters input as a list of values:__
- the root context (required)
- pvc name (required)
- statefulsetName name (required)

__Usage:__ 
```
  {{- $compName := "refComp" -}}
  {{- $pvcName := "dataPVC" -}}
  {{- $statefulSetName := include "sch.names.statefulSetName" (list . $compName) -}}
  
  name: {{ include "sch.names.volumeClaimTemplateName" (list . $pvcName $statefulSetName) }}
```
*/}}
{{- define "sch.names.volumeClaimTemplateName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $claimName := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $statefulSetName := (include "sch.utils.getItem" (list $params 2 "")) -}}

  {{/* $schBase values are defined in sch/_config.yaml and can be modified by chart in sch-chart-config.yaml*/}}
  {{- $schBase := dict "sch" (dict "names" (dict "volumeClaimTemplateName" (dict "maxLength" 253  "claimNameTruncLength" 253 "possiblePrefix" "glusterfs-dynamic-"))) -}}
  {{- $_ := merge $root $schBase -}}

  {{- $maxLength := (int ($root.sch.names.volumeClaimTemplateName.maxLength)) -}}
  {{- $possiblePrefix := $root.sch.names.volumeClaimTemplateName.possiblePrefix -}}
  {{- $claimNameTruncLength := (int ($root.sch.names.volumeClaimTemplateName.claimNameTruncLength)) -}}

  {{- $prefixLength := len $possiblePrefix -}}
  {{- $statefulSetNameLength := len $statefulSetName -}}
  {{- $claimNameLength := len $claimName -}}
  {{- $preClaimNameLength := add 5 (add $prefixLength $statefulSetNameLength) -}}
  {{- $claimNameMaxLength := max $claimNameTruncLength (int (sub $maxLength $preClaimNameLength)) -}}

  {{- $buildNameParms := list (dict "name" $claimName "length" $claimNameMaxLength "unique" 4) -}}
  {{- printf "%s" (include "sch.names.buildName" $buildNameParms) -}}
{{- end -}}
*/}}

{{/*
`"sch.names.persistentVolumeClaimName"` will generate a persistentVolumeClaimName 
name made up of `.Release.name`, appName and the pvc name, it will truncate the name
parts based on values defined in `sch.names.persistentVolumeClaimName.*`. 

When name parts are truncated, a "somewhat random" 4 character suffix is used for 
each part, which is the first 4 characters of the sha256 or the truncated string.

__Config Values Used:__
- `.sch.names.persistentVolumeClaimName.maxLength`
- `.sch.names.persistentVolumeClaimName.possiblePrefix`
- `.sch.names.persistentVolumeClaimName.releaseNameTruncLength`
- `.sch.names.persistentVolumeClaimName.appNameTruncLength`
- .`sch.names.persistentVolumeClaimName.claimNameTruncLength`

__Uses:__
- `"sch.utils.getItem"`
- `"sch.names.buildName"` 

__Parameters input as a list of values:__
- the root context (required)
- pcv name (required)

__Usage:__
```
  {{- $pvcName := "dataPVC" -}}
  
  name: {{ include "sch.names.persistentVolumeClaimName" (list . $pvcName) }}
```
*/}}
{{- define "sch.names.persistentVolumeClaimName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $claimName := (include "sch.utils.getItem" (list $params 1 "")) -}}

  {{/* $schBase values are defined in sch/_config.yaml and can be modified by chart in sch-chart-config.yaml*/}}
  {{- $schBase := dict "sch" (dict "names" (dict "persistentVolumeClaimName" (dict "maxLength" 253 "releaseNameTruncLength" 253 "appNameTruncLength" 253 "claimNameTruncLength" 253 "possiblePrefix" "glusterfs-dynamic-"))) -}}
  {{- $_ := merge $root $schBase -}}

  {{- $possiblePrefix := $root.sch.names.persistentVolumeClaimName.possiblePrefix -}}
  {{- $prefixLength := len $possiblePrefix -}}

  {{- $maxLength := (int (sub $root.sch.names.persistentVolumeClaimName.maxLength $prefixLength)) -}}
  {{- $releaseNameTruncLength := (int ($root.sch.names.persistentVolumeClaimName.releaseNameTruncLength)) -}}
  {{- $appNameTruncLength := (int ($root.sch.names.persistentVolumeClaimName.appNameTruncLength)) -}}
  {{- $claimNameTruncLength := (int ($root.sch.names.persistentVolumeClaimName.claimNameTruncLength)) -}}
  {{- include "sch.names.releaseAppCompName" (list $root $claimName $maxLength $releaseNameTruncLength $appNameTruncLength $claimNameTruncLength) -}}
{{- end -}}

{{/*
"sch.names.buildName" is a helper which takes a list of map of names and lengths
to iterate though and truncate each part to the length specified.

Config Values Used: NA

Uses:
  - "sch.utils.truncUnique"

Parameters input as an array of one values:
  - a list of dict with name and length key,values (required)

Usage:
    {{- $buildNameParms := (list) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" "name1" "length" 5) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" "longername" "length" 6) -}}
    {{- $shortResult := print (include "sch.names.buildName" $buildNameParms) -}}

*/}}
{{- define "sch.names.buildName" -}}
  {{- $parms := . -}}
  {{- range $index, $element := $parms -}}
    {{- if (gt $index 0) -}}
      {{- "-" -}}
    {{- end -}}
    {{- $nameLength := len $element.name -}}
    {{- if (gt (int $nameLength) 0) -}}
      {{- $truncUniqueParms := dict "text" $element.name "length" $element.length "unique" (default 4 $element.unique) -}}
      {{- printf "%s" (include "sch.utils.truncUnique" $truncUniqueParms | trimSuffix "-") -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
"sch.names.releaseAppCompName" is a shared helper to build a name based of the release
and app names and then a "component" name.

Config Values Used: NA

Uses:
  - "sch.utils.truncUnique"

Parameters input as an array of one values:
  - the root context (required)
  - component name (required)
  - max length (required)
  - releaseNameTruncLength (required)
  - appNameTruncLength (required)
  - compNameTruncLength (required)

Usage:
  {{- $maxLength := 63 -}}
  {{- $releaseNameTruncLength := 30 -}}
  {{- $appNameTruncLength := 20 -}}
  {{- $compNameTruncLength := 11 -}}
  {{- include "sch.names.releaseAppCompName" (list $root $compName $maxLength $releaseNameTruncLength $appNameTruncLength $compNameTruncLength) -}}

*/}}
{{- define "sch.names.releaseAppCompName" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $releaseName := $root.Release.Name -}}
  {{- $appName := (include "sch.names.appName" (list $root)) -}}
  {{- $compName := (include "sch.utils.getItem" (list $params 1 "")) -}}
  {{- $maxLength := (int (include "sch.utils.getItem" (list $params 2 "253"))) -}}
  {{- $releaseNameTruncLength := (int (include "sch.utils.getItem" (list $params 3 "253"))) -}}
  {{- $appNameTruncLength := (int (include "sch.utils.getItem" (list $params 4 "253"))) -}}
  {{- $compNameTruncLength := (int (include "sch.utils.getItem" (list $params 5 "253"))) -}}

  {{- $fullLengthResult := (printf "%s-%s-%s" $releaseName $appName $compName) -}}
  {{- $fullLengthResult :=  include "sch.utils.withinLength" (list $root $fullLengthResult $maxLength) -}}

  {{- if $fullLengthResult -}}
    {{- $fullLengthResult | lower | trimSuffix "-" -}}
  {{- else -}}
    {{- $buildNameParms := (list) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" $releaseName "length" $releaseNameTruncLength) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" $appName "length" $appNameTruncLength) -}}
    {{- $buildNameParms := append $buildNameParms (dict "name" $compName "length" $compNameTruncLength) -}}

    {{- $shortResult := print (include "sch.names.buildName" $buildNameParms) -}}
    {{- $shortResult | lower | trimSuffix "-" -}}
  {{- end -}}
{{/*   */}}
{{- end -}}
