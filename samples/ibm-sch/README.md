# "Shared Configurable Helpers" (referred to SCH)
* A chart of common helpers to be used as a sub chart by product content teams in their product chart.

## Introduction
The goal of the Shared Configurable Helpers chart is to provide a set of Helm template helpers that are configurable and reusable by various product content teams to assist in conformity to standards and ease of use.

## Chart Details
* This chart does not install any kubernetes resources directly. It is meant to be included as a subchart.

## Prerequisites
* Helm 2.6.0 or greater.

## Resources Required
* NA - no resource requirements.

## Installing the Chart
* This chart does not install as a standalone chart.

## Documentation

### Including ibm-sch in your chart

There are two ways to include ibm-sch with your chart:

1. Include ibm-sch in your chart's requirements.yaml and use helm to download it

   Format of entry in requirements.yaml:

   ```
   dependencies:
   - name: ibm-sch
     repository: "@sch" ## where sch is based on [NAME] from the cmd: helm repo add [flags] [NAME] [URL]
     version: "^1.2.14"
     alias: sch
     condition: global.sch.enabled
   ```

   Explanation of parameters:
   - Set the alias to `sch` to guarantee that all functions will work successfully.
   - Set the version to `^1.2.14` to download the latest `1.x.x` version of ibm-sch.
   - Use a condition parameter to only install ibm-sch when intended. For example, if your chart is able to be installed standalone and as a subchart, then you want ibm-sch to be enabled when your chart is installed standalone, but you want to use the parent chart's ibm-sch when it is installed as a subchart. To achieve this, you would set `global.sch.enabled` to true in the subchart and false in the parent chart.

1. Download the source and copy it into your charts directory

   - You will want to delete the unit-tests and ibm_cloud_pak directories from ibm-sch or add them to the parent .helmignore file to avoid the 1 MB chart size limit from Helm.
   - The entry in requirements.yaml will still need to be created in this scenario for everything to function correctly.

### Configuration

The default configuration and initiation helpers for SCH (Shared Configurable Helpers) is defined in `templates/_config.tpl`. A given chart should specify additional values and/or override values via defined yaml structure passed during `"sch.config.init"` ([see below](#initialization)).

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
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
          - ppc64le
          - s390x
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
The initialization step is needed in each template which uses the shared configurable helpers. This initialization step merges the config data into the root context of the template, referred to as the dot, “.”, root context.

This data can then be accesses by the template just a `.Values.<somekey>` or `.Release.name`, etc..

For example, `include "sch.config.init"` passing a list containing the root context and the name of the define with chart specific configuration containing the data for `.sch.chart.components.nginx.name`.

__Example__

```
{{- include "sch.config.init" (list . "nginxRef.sch.chart.config.values") -}}
{{- $compName :=  .sch.chart.components.nginx.name -}}
```

### Helpers

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->
- [Naming](#naming)
- [Metadata](#metadata)
- [Affinity](#affinity)
- [Security](#security)
- [Secrets](#secrets)
<!-- /TOC -->

### Naming
SCH helpers for naming are defined in `templates/_names.tpl` and are useful for configuring resource and kubernetes object names.

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

`"sch.names.appName"` will generate a app name based on the precedence and existence of `.Values.nameOverride`, `.sch.chart.appName`, `.sch.chart.shortName`, `.Chart.Name`.

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
`"sch.names.fullName"` will generate a fullName made up of `.Release.name` and appName. It will truncate the name parts based on values defined in `sch.names.fullName.*`.

When name parts are truncated, a "somewhat random" 4 character suffix is used for each part, which is the first 4 characters of the sha256 or the truncated string.

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
`"sch.names.fullCompName"` will generate a compName made up of `.Release.name`, appName, and an optional component name. It will truncate the name parts based on values defined in `sch.names.fullCompName.*`.

When name parts are truncated, a "somewhat random" 4 digit suffix is used for each part, which is the first 4 characters of the sha256 or the truncated string. 

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
`"sch.names.statefulSetName"` will generate a statefulSet name made up of release name, appName, and an optional component name. It will truncate the name parts based on values defined in `sch.names.statefulSetName.*`.

When name parts are truncated, a "somewhat random" 4 character suffix is used for each part, which is the first 4 characters of the sha256 or the truncated string.

Note: If the statefulSet has a VolumeClaimTemplate that generates a dynamic PV with a storage class such as GlusterFS, it could result in generating a service with a name containing the statefulSet name. Due to this, the statefulSet name may need to be truncated further based on the default or chart specified configuration to avoid the service name being too large.

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
`"sch.names.volumeClaimTemplateName"` will truncate the persistentVolumeClaim name using values defined in `sch.names.volumeClaimTemplateName.*` and the length of the statefulSet name.

When name parts are truncated, a "somewhat random" 4 character suffix is used for each part, which is the first 4 characters of the sha256 or the truncated string.

If the statefulSet has a VolumeClaimTemplate that generates a dynamic PV with a storage class such as GlusterFS, it could result in generating a service with a name containing the statefulSet name. Due to this, the statefulSet name may need to be truncated further based on the default or chart specified configuration to avoid the service name being too large.

__Config Values Used:__
- `.sch.names.volumeClaimTemplateName.maxLength`
- `.sch.names.volumeClaimTemplateName.claimNameTruncLength`
- `.sch.names.volumeClaimTemplateName.possiblePrefix`

__Uses:__
- `"sch.utils.getItem"`
- `"sch.names.buildName"`

__Parameters input as a list of values:__
- the root context (required)
- persistentVolumeClaim name (required)
- statefulsetName name (required)

__Usage:__ 
```
  {{- $compName := "refComp" -}}
  {{- $pvcName := "dataPVC" -}}
  {{- $statefulSetName := include "sch.names.statefulSetName" (list . $compName) -}}
  
  name: {{ include "sch.names.volumeClaimTemplateName" (list . $pvcName $statefulSetName) }}
```

#### persistentVolumeClaimName
`"sch.names.persistentVolumeClaimName"` will generate a persistentVolumeClaimName name made up of `.Release.name`, appName, and the persistentVolumeClaim name. It will truncate the name parts based on values defined in `sch.names.persistentVolumeClaimName.*`. 

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
`"sch.metadata.labels.standard"` will generate the 4 required labels app, chart, heritage and release, and will optional create component and a map of additionaly passed labels.

Note: Kubernetes has updated their standard label names. They are now app.kubernetes.io/name, helm.sh/chart, app.kubernetes.io/managed-by, and app.kubernetes.io/instance. To use these new values, set the sch.chart.labelType to `prefixed` in `_sch-chart-config.yaml`. This will use the new label names as well as the old release label for backward compatibility reasons.

Note: To avoid upgrade issues related to Kubernetes selectors, only use the new labels if this is a new major version of your chart.

__Config Values Used:__
- `.sch.chart.appName`
- `.sch.utils.getItem`

__Parameters input as an list of values:__
- the root context (required)
- component (required "" or "<compName>")
- dict of key value pairs for more labels

__Usage:__

Example chart config values
```
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "refApp"
    deploymentName: "deployment3"
    labelType: "prefixed"       
{{- end -}}
```
Used in template as follows:
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
`"sch.metadata.annotations.metering"` will generate metering annotations based on the values passed in. License parameters can be included for reporting to the IBM License Metric Tool.

Licensing parameters include:

- **productMetric:** the install-based metric (PROCESSOR_VALUE_UNIT, VIRTUAL_PROCESSOR_CORE, RESOURCE_VALUE_UNIT, etc.)
- **productChargedContainers:** which containers are affected ("All", "", or a list of container names)
- **productFlexpointBundle:** the Flexpoint Bundle that this license belongs to (optional)
- **productSlmLocation:** the path to the SLM folder in the container (optional)

Note: When passing licensing values to the `sch.metadata.annotations.metering` declaration, values for all parameters must be specified. Use `""` and `nil` for values that are not set. If all licensing parameters are not specified when calling `sch.metadata.annotations.metering`, then no licensing parameters will be included in the output.

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

#### Ingress Annotations
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
used in template as follows:
```
  annotations:
{{- include "sch.metadata.annotations.nginx.ingress" (list . .sch.chart.nginx.ingress) | indent 4 }}
```

### Affinity

SCH helpers for affinity are defined in `templates/_affinity.tpl` and are useful for specifying node affinity to constrain your pod to only be able to run on particular nodes based on specified rules.

The following are affinity templates:

- [`"sch.affinity.nodeAffinity"`](#nodeAffinity)
- [`"sch.affinity.podAffinity"`](#podAffinity)
- [`"sch.affinity.podAntiAffinity"`](#podAntiAffinity)

#### nodeAffinity

`"sch.affinity.nodeAffinity"` constrains your pod to only be able to run on particular nodes based on specified rules. Specify one or both of `nodeAffinityRequiredDuringScheduling` and `nodeAffinityPreferredDuringScheduling` to set your node affinity. The `operator` supports the following options: `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`. The `key` defaults to `beta.kubernetes.io/arch` if not specified.

Alternatively, set your node affinity in your values.yaml using the arch parameter to allow the chart deployer to specify which platform they would like to deploy on. If arch is specified in values.yaml, then it will override what has been specified in _sch-chart-config.tpl. See the examples below for more information on using the arch parameter.

For more information, see https://kubernetes.io/docs/concepts/configuration/assign-pod-node/

Note: the 'key' parameter in the config values map is optional and will default to 'beta.kubernetes.io/arch' if not specified.

__Values Used__
- `.Values.arch` (optional)

__Config Values Used:__
- sch.chart.nodeAffinity

__Uses:__
- sch.affinity.nodeAffinityPreferredDuringScheduling
- sch.affinity.nodeAffinityRequiredDuringScheduling

__Parameters input as an list of values:__
- the root context (required)

__Usage:__

- Option 1: example chart config values
```
{{- define "sch.chart.nodeAffinity" -}}
sch:
  chart:
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        key: beta.kubernetes.io/arch
        operator: In
        values:
          - amd64
          - ppc64le
          - s390x
      nodeAffinityPreferredDuringScheduling:
        amd64:
          key: beta.kubernetes.io/arch
          operator: In
          weight: 3
{{- end -}}
```

- Option 2: example values.yaml arch String parameter. This will create a `requiredDuringSchedulingIgnoredDuringExecution` nodeAffinity parameter of amd64:
```
arch: "amd64"
```

- Option 3: example values.yaml arch Map parameter. This will create a `requiredDuringSchedulingIgnoredDuringExecution` and a `preferredDuringSchedulingIgnoredDuringExecution` parameter for the selected arch.
```
arch:
    amd64: "3 - most preferred"
    ppc64le: "2 - no preference"
```

- used in template as follows:
```
    spec:
      affinity:
{{- include "sch.affinity.nodeAffinity" (list . .sch.chart.nodeAffinity) | indent 8 }}
```

## Limitations
* TBD

#### podAffinity

`"sch.affinity.podAffinity"` Inter-pod affinity and anti-affinity allow you to constrain which nodes your pod is eligible to be scheduled based on labels on pods that are already running on the node rather than based on labels on nodes. Specify one or all of requiredDuringScheduling, requiredDuringSchedulingRequiredDuringExecution, and preferredDuringScheduling to set your node affinity.

For more information, see https://kubernetes.io/docs/concepts/configuration/assign-pod-node/

Note: the value specified in requiredDuringScheduling maps to requiredDuringSchedulingIgnoredDuringExecution.

__Values Used__
- none

__Config Values Used:__
- sch.chart.podAffinity

__Uses:__
- sch.affinity.preferredDuringScheduling
- sch.affinity.requiredDuringSchedulingRequiredDuringExecution
- sch.affinity.requiredDuringSchedulingIgnoredDuringExecution

__Parameters input as an list of values:__
- the root context (required)
- config values map of annotations (required)

__Usage:__

example chart config values

```
{{- define "sch.chart.podAffinity" -}}
sch:
  chart:
    podAffinity:
      requiredDuringScheduling:
        key: security
        operator: In
        topologyKey: failure-domain.beta.kubernetes.io/zone
        values:
        - S1
      requiredDuringSchedulingRequiredDuringExecution:
        key: security
        operator: In
        topologyKey: failure-domain.beta.kubernetes.io/zone
        values:
        - S3
      preferredDuringScheduling:
        store:
          weight: 5
          key: app
          operator: In
          topologyKey: kubernetes.io/hostname
{{- end -}}
```
used in template as follows:
```
spec:
  affinity:
{{- include "sch.affinity.podAffinity" (list .) | indent 8 }}
```


## Limitations
* TBD

#### podAntiAffinity

`"sch.affinity.podAntiAffinity"` Inter-pod affinity and anti-affinity allow you to constrain which nodes your pod is eligible to be scheduled based on labels on pods that are already running on the node rather than based on labels on nodes. Specify one or all of requiredDuringScheduling, requiredDuringSchedulingRequiredDuringExecution, and preferredDuringScheduling to set your node affinity.

For more information, see https://kubernetes.io/docs/concepts/configuration/assign-pod-node/

Note: the value specified in requiredDuringScheduling maps to requiredDuringSchedulingIgnoredDuringExecution.

__Values Used__
- none

__Config Values Used:__
- passed as argument

__Parameters input as an list of values:__
- the root context (required)
- config values map of annotations (required)

__Usage:__

example chart config values

```
{{- define "sch.chart.podAntiAffinity" -}}
sch:
  chart:
    podAffinity:
      requiredDuringScheduling:
        key: security
        operator: In
        topologyKey: failure-domain.beta.kubernetes.io/zone
        values:
        - S1
      requiredDuringSchedulingRequiredDuringExecution:
        key: security
        operator: In
        topologyKey: failure-domain.beta.kubernetes.io/zone
        values:
        - S3
      preferredDuringScheduling:
        store:
          weight: 5
          key: app
          operator: In
          topologyKey: kubernetes.io/hostname
{{- end -}}
```
used in template as follows:
```
spec:
  affinity:
{{- include "sch.affinity.podAntiAffinity" (list .) | indent 8 }}
```

## Limitations
* TBD

### Security

SCH helpers for security are defined in `templates/_security.tpl` and are useful for specifying pod security context information for your pods and containers.

The following are security templates:

- [`"sch.security.securityContext"`](#securityContext)

#### securityContext

`"sch.security.securityContext"` specifies the security context for your pod or container. Each pod
needs to be evaluated at a container level for their security requirements, but often there is a set of
attributes that is common to a number of pods within your deployment.

Specify one or more securityContexts in your _sch-chart-config.tpl and pass one to the `sch.security.securityContext`
definition to include a securityContext in your chart yaml.

__Values Used__
- None

__Config Values Used:__
- passed as argument

__Parameters input as an list of values:__
- the root context (required)
- config values map of securityContext (required)

__Usage:__

example chart config values

```
{{- define "sch.chart.securityContext" -}}
sch:
  chart:
    securityContext1:
      securityContext:
        runAsNonRoot: false
        runAsUser: 0
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
          add:
          - CHOWN
          - AUDIT_WRITE
          - DAC_OVERRIDE
          - FOWNER
          - SETGID
          - SETUID
          - NET_BIND_SERVICE
          - SYS_CHROOT
    securityContext2:
      securityContext:
        runAsNonRoot: false
        runAsUser: 0
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
```
used in template as follows:
```
spec:
  template:
    spec:
      containers:
{{- include "sch.security.securityContext" (list . .sch.chart.securityContext1) | indent 10 }}
or
spec:
  template:
    spec:
{{- include "sch.security.securityContext" (list . .sch.chart.securityContext2) | indent 6 }}
```

### Secrets

secret helpers for SCH (Shared Configurable Helpers)

sch/_secrets.tpl contains shared configurable helper templates for generating and deleting secrets.

#### Prerequisites

The secret generation code creates a Job resource that uses a container image to interact with Kubernetes. For this reason, using this function requires additional prerequisites beyond the typical items.

1. The ibm-sch subchart must be aliased as `sch` in requirements.yaml:
```
dependencies:
  - name: ibm-sch
    repository: "@sch"
    version: "^1.2.12"
    alias: sch
```

2. The container image used by the secret generator must be added to ibm_cloud_pak/manifest.yaml so that `cloudctl catalog create-archive` will include the image in the archive for airgap installation.

```
- image: opencontent-common-utils:1.1.2
  references:
  - repository: opencontent-common-utils:1.1.2
    pull-repository: ibmcom/opencontent-common-utils:1.1.2
    pull-authorization:
      username:
        env: ARTIFACTORY_USER
      password:
        env: ARTIFACTORY_PASS
```

3. PodSecurityPolicy Requirements

  This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement, there may be cluster-scoped as well as namespace-scoped actions that you must do before and after installation.

  The predefined PodSecurityPolicy name ibm-restricted-psp has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

4. Role-Based Access Control settings

  The following RBAC resources are required for the secret generation code to create and delete secrets. The ibm_cloud_pak/pak_extensions/pre-install/namespace-administration/setupNamespace.sh script has been provided to assist with the creation of these resources.

  To ease integration, the service account name can be specified in _sch-chart-config.yaml which allows for the role to be merged with an existing role that is bound to a chart's existing service account rather than needing to create all of these resources separately.

  1. ServiceAccount:

  ```
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: ibm-sch-secret-gen
    namespace: "{{ NAMESPACE }}" #Replace {{ NAMESPACE }} with the namespace you are deploying to
  ```

  2. Role:

  ```
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: ibm-sch-secret-gen
  rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["list", "create", "delete"]
  ```

  3. RoleBinding:

  ```
  apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: ibm-sch-secret-gen
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: ibm-sch-secret-gen
  subjects:
  - kind: ServiceAccount
    name: ibm-sch-secret-gen
    namespace: "{{ NAMESPACE }}"
  ```

#### Create Secret

`"sch.secretGen.job.create"` generates a Kubernetes Job resource to create one or more secrets.

Supported secret types:
- generic
- tls

Specify a list of secrets to be generated in the `sch.chart.secretGen` parameter in your _sch-chart-config.tpl. The yaml file containing the job will contain an import request to `sch.config.init` and an import request to `sch.secretGen.job.create`.

The TLS secret generated is a self-signed CA certificate.

In the event that a generic secret needs to generated in a different manner, the function used to generate the secret can be overridden. See the second example below for more information.

Notes:

- The cn parameter for a TLS secret has been deprecated. Specifying domains should be
done with the sans (Subject Alternate Name) parameter. 
- If the sans parameter is specified, then the cn parameter will be ignored.
- The first entry in the sans array will be set to the CN parametr in the subject if
it is 64 characters or smaller in length.

__Values Used__
- None

__Config Values Used:__
- `sch.chart.secretGen`

__Parameters input as an list of values:__
- the root context (required)

__Usage:__
Example 1: Create a generic secret and a secret containing a self-signed CA certificate. Use the chart's service account vs. the default
```
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    secretGen:
      suffix: default-suffix
      overwriteExisting: false
      serviceAccountName: mychart-serviceaccount  # Set this to your service account name or remove it to use ibm-sch-secret-gen
      secrets:
      - name: passwords  # this will include the suffix in the format of <name>-<suffix>
        create: true
        type: generic
        values:
        - name: MYSQL_ROOT_PASSWORD
          length: 30
        - name: MYSQL_PASSWORD
          length: 30
      - name: mysql.myhost.com # this will include the suffix in the format of <name>-<suffix>
        create: {{ empty .Values.tlsSecret }}
        type: tls
        cn: mysql.myhost.com
{{- end -}}
```

Example 2: Create a generic secret and specify the generation code

Define the generation function:
```
{{- define "mysql.secrets.generator.basicAuth" -}}
  $(echo "Basic $(openssl rand -hex 20):$(openssl rand -hex 20)" | base64 |  tr -d '\n')
{{- end -}}
```
Set the generator value for the corresponding secret:
```
{{- define "test.secretGen.values" -}}
sch:
  chart:
    secretGen:
      suffix: default-suffix
      overwriteExisting: false
      serviceAccountName: mychart-serviceaccount  # Set this to your service account name or remove it to use ibm-sch-secret-gen
      secrets:
      - name: passwords  # this will include the suffix in the format of <name>-<suffix>
        create: true
        type: generic
        values:
        - name: MYSQL_ROOT_PASSWORD
          generator: "mychart.secrets.generator.basicAuth"
        - name: MYSQL_PASSWORD
          length: 30
{{- end -}}
```

used in template as follows:
```
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
{{- include "sch.secretGen.job.create" (list .) -}}
```
or, to override the suffix:
```
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
{{- include "sch.secretGen.job.create"  (list . (include "sch.names.appName" (list .))) -}}
```

#### Delete Secret

`"sch.secretGen.job.delete"` generates a Kubernetes Job resource to delete one or more secrets when your Helm chart is deleted.

Specify a list of secrets to be deleted in the `sch.chart.secretGen` parameter in your _sch-chart-config.tpl. This should match the secrets that you created with `sch.secretGen.job.create`. The yaml file containing the job will contain an import request to `sch.config.init` and an import request to `sch.secretGen.job.create`.

__Values Used__
- None

__Config Values Used:__
- `sch.chart.secretGen`

__Parameters input as an list of values:__
- the root context (required)

__Usage:__
Delete two secrets with the tls being conditional
```
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    secretGen:
      suffix: default-suffix
      overwriteExisting: false
      serviceAccountName: mychart-serviceaccount  # Set this to your service account name or remove it to use ibm-sch-secret-gen
      secrets:
      - name: passwords  # this will include the suffix in the format of <name>-<suffix>
        create: true
        type: generic
        values:
        - name: MYSQL_ROOT_PASSWORD
          length: 30
        - name: MYSQL_PASSWORD
          length: 30
      - name: mysql.myhost.com # this will include the suffix in the format of <name>-<suffix>
        create: {{ empty .Values.tlsSecret }}
        type: tls
        cn: mysql.myhost.com
{{- end -}}
```
used in template as follows:
```
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
{{- include "sch.secretGen.job.delete" . -}}
```
