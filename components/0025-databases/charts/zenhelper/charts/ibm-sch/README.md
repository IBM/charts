# "Shared Configurable Helpers" (referred to SCH)
* A chart of common helpers to be used as a sub chart by product content teams 
in their product chart.

## Introduction
The goal is to have the community of product content teams contribute and develop
a package of "Shared Configurable Helpers" (referred to SCH) as a sharable package
of helper templates which are configurable and reusable by various product 
content teams in their product chart templates.

## Chart Details
* This chart does not install any kubernetes resources directly.

## Documentation

### Helpers

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->
- [Naming](#naming)
- [Metadata](#metadata)
<!-- /TOC -->

### Naming
SCH helpers for naming are defined in `templates/_names.tpl` and are useful for configure 
resource and kubernetes object names.

The following are useful name templates: 

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->
- [`"sch.names.appName"`](#appName)
- [`"sch.names.fullName"`](#fullName)
- [`"sch.names.fullCompName"`](#fullCompName)
- [`"sch.names.statefulSetName"`](#statefulSetName)
- [`"sch.names.volumeClaimTemplateName"`](#volumeClaimTemplateName)
- [`"sch.names.persistentVolumeClaimName"`](#persistentVolumeClaimName)
<!-- /TOC -->

#### appName

`"sch.names.appName"` will generate a app name based on the precedence and existence 
of `.Values.nameOverride`, `.sch.chart.appName`, `.sch.chart.shortName`, `.Chart.Name`.

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

#### fullName
`"sch.names.fullName"` will generate a fullName made up of `.Release.name` and appName, 
it will truncate the name parts based on values defined in `sch.names.fullName.*`. 

When name parts are truncated, a "somewhat random" 4 character suffix is used for 
each part, which is the first 4 characters of the sha256 or the truncated string. 

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

#### fullCompName
`"sch.names.fullCompName"` will generate a compName made up of `.Release.name`, appName 
and if specified an optional component name, it will truncate the name parts 
based on values defined in `sch.names.fullCompName.*`.

When name parts are truncated, a "somewhat random" 4 digit suffix is used for each 
part, which is the first 4 characters of the sha256 or the truncated string. 

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

#### statefulSetName
`"sch.names.statefulSetName"` will generate a statefulSet name made up of 
release name, appName and if specified an optional component name, it will 
truncate the name parts based on values defined in `sch.names.statefulSetName.*`.

When name parts are truncated, a "somewhat random" 4 character suffix is used 
for each part, which is the first 4 characters of the sha256 or the truncated string.

Because statefulSet can have VolumeClaimTemplates, and if that VolumeClaimTemplates generates a dynamic PV with a storage class such as GlusterFS, it could result in generating a service with a name containing the statefulSet name; therefore, there may be cases in which the statefulSet name needs to be truncated based on the default or chart specified configuration.

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

#### volumeClaimTemplateName
`"sch.names.volumeClaimTemplateName"` will truncate the pvc name part based on values defined in `sch.names.volumeClaimTemplateName.*` and the length of the statefulSet name.

When name parts are truncated, a "somewhat random" 4 character suffix is used for each part, which is the first 4 characters of the sha256 or the truncated string.

Because VolumeClaimTemplates may generate a dynamic PV with a storage class such as GlusterFS, it could result in generating a service with a name containing the statefulSet name; therefore, there may be cases in which the statefulSet name needs to be used to determine length available for the pvc name.

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

#### persistentVolumeClaimName
`"sch.names.persistentVolumeClaimName"` will generate a persistentVolumeClaimName 
name made up of `.Release.name`, appName and the pvc name, it will truncate the name parts based on values defined in `sch.names.persistentVolumeClaimName.*`. 

When name parts are truncated, a "somewhat random" 4 character suffix is used for each part, which is the first 4 characters of the sha256 or the truncated string.

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
### Metadata

#### Labels
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

#### Metering Annotations
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

## Prerequisites
* Helm 2.6.0

## Resources Required
* NA - no resource requirements

## Installing the Chart
* This chart does not install as a standalone chart

### Configuration

The default configuration and initiation helpers for SCH (Shared Configurable Helpers) is defined in `templates/_config.tpl`. In addition a given chart can specify additional values and/or override values via defined yaml structure passed during `"sch.config.init"` ([see below](#initialization)).

#### Default
This default configuration defines the default values to use in the shared helpers.

__Example__

```
{{- /*
"sch.config.values" contains the default configuration values used by
the Shared Configurable Helpers.

To override any of these values, modify the templates/_sch-chart-config.tpl file 
*/ -}}
{{- define "sch.config.values" -}}
sch:
  chart:
    appName: ""
  names:
    fullName:
      maxLength: 63
      releaseNameTruncLength: 42
      appNameTruncLength: 20
    fullCompName:
      maxLength: 63
      releaseNameTruncLength: 36
      appNameTruncLength: 13
      compNameTruncLength: 12
    statefulSetName:
      maxLength: 37
      releaseNameTruncLength: 18
      appNameTruncLength: 7
      compNameTruncLength: 10
    volumeClaimTemplateName:
      maxLength: 63
      possiblePrefix: "glusterfs-dynamic-"
      claimNameTruncLength: 7
    persistentVolumeClaimName:
      maxLength: 63
      possiblePrefix: "glusterfs-dynamic-"
      releaseNameTruncLength: 18
      appNameTruncLength: 13
      claimNameTruncLength: 12
{{- end -}}
```
#### Chart Specific 
Charts can optionally override the default values and add additional values. By defining a chart specific definition of the sch.chart.config.values with <chartName>.sch.chart.config.values to make it unique for that specific chart. 

_Important_
It is important to include your chart name in this config template definition in case your chart is included in another chart as a subchart.

__Example__

```
{{- /*
"nginxRef.sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "nginxRef.sch.chart.config.values" -}}
sch:
  chart:
    appName: "nginxRef"
    components: 
      nginx:
        name: "nginx"
    fullName:
      maxLength: 63
      releaseNameTruncLength: 42
      appNameTruncLength: 20
{{- end -}}
```
## Initialization
The initialization step is needed in each template which uses the shared configurable helpers. 
This initialization step merges the config data into the root context of the template, referred 
to as the dot, “.”, root context.

This data can then be accesses by the template just a `.Values.<somekey>` or `.Release.name`, etc..

For example, `include "sch.config.init"` passing a list containing the root context and the name of 
the define with chart specific configuration containing the data for `.sch.chart.components.nginx.name`.

__Example__

```
{{- include "sch.config.init" (list . "nginxRef.sch.chart.config.values") -}}
{{- $compName :=  .sch.chart.components.nginx.name -}}
```

## Limitations
* TBD

