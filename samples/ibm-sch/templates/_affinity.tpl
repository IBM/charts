{{- /*
affinity helpers for SCH (Shared Configurable Helpers)

sch/affinity.tpl contains shared configurable helper templates for 
creating resource structures for node affinity and pod affinity/anti-affinity.

Usage of "sch.affinity.*" requires the following line be included at
the begining of template:
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- /*
`"sch.affinity.nodeAffinity"` constrain your pod to only be able to run on particular nodes
based on specified rules. Specify one or both of nodeAffinityRequiredDuringScheduling and
nodeAffinityPreferredDuringScheduling to set your node affinity.

Charts that support more than one architecture can include the 'arch' parameter in their
values.yaml. Doing so will override the default affinity values specified in
_sch-chart-config.yaml. See the examples below for more information on using the arch parameter.

For more information, see https://kubernetes.io/docs/concepts/configuration/assign-pod-node/

Note: the 'key' parameter in the config values map is optional and will default to 'beta.kubernetes.io/arch'
if not specified.

__Values Used__
- `.Values.arch` (optional)

__Config Values Used:__
- passed as argument

__Uses:__
- sch.affinity.nodeAffinityPreferredDuringScheduling
- sch.affinity.nodeAffinityRequiredDuringScheduling

__Parameters input as an list of values:__
- the root context (required)

__Usage:__
example chart config values
```
{{- define "sch.chart.config.values" -}}
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
used in template as follows:
```
spec:
  affinity:
{{- include "sch.affinity.nodeAffinity" (list .) | indent 8 }}
```
{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}
*/}}

{{- define "sch.affinity.nodeAffinity" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $defaultRoot := fromYaml (include "sch.chart.default.config.values" .) }}
  {{- $defaultNodeAffinity := $defaultRoot.sch.chart.nodeAffinity }}
  {{- $nodeAffinity := $root.sch.chart.nodeAffinity | default $defaultNodeAffinity }}
nodeAffinity:
  {{- if (gt (len $nodeAffinity) 0) -}}
  {{- /* Future item specified by kubernetes. Not currently available
    {{- if (hasKey $nodeAffinity "nodeAffinityRequiredDuringSchedulingRequiredDuringExecution") }}
  {{ include "sch.affinity.nodeAffinityRequiredDuringSchedulingRequiredDuringExecution" (list $root $nodeAffinity) }}
    {{- end }}
  */ -}}
    {{- if or (hasKey $nodeAffinity "nodeAffinityRequiredDuringScheduling") (hasKey $root.Values "arch") }}
  {{ include "sch.affinity.nodeAffinityRequiredDuringScheduling" (list $root $nodeAffinity) -}}
    {{- end }}
    {{- if or (hasKey $nodeAffinity "nodeAffinityPreferredDuringScheduling") (hasKey $root.Values "arch") }}
  {{- include "sch.affinity.nodeAffinityPreferredDuringScheduling" (list $root $nodeAffinity) | indent 2 }}
    {{- end }}
  {{- end }}
{{- end }}

{{/* Future method. Kubernetes states they plan to support this in the future, but do not support it currently

{{- define "sch.affinity.nodeAffinityRequiredDuringSchedulingRequiredDuringExecution" -}}
    {{- $params := . }}
    {{- $root := first $params -}}
    {{- $affinity := last $params -}}
    {{- $operator := $affinity.nodeAffinityRequiredDuringScheduling.operator -}}
    {{- $values := $affinity.nodeAffinityRequiredDuringScheduling.values -}}
requiredDuringSchedulingRequiredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: {{ default "beta.kubernetes.io/arch" $affinity.key }}
        operator: {{ $operator }}
        values:
    {{- range $key := $values }}
        - {{ $key }}
    {{- end -}}
{{- end -}}

*/}}

{{- define "sch.affinity.nodeAffinityRequiredDuringScheduling" -}}
    {{- $params := . }}
    {{- $root := first $params }}
    {{- $affinity := last $params -}}
    {{- $operator := $affinity.nodeAffinityRequiredDuringScheduling.operator -}}
    {{- $values := $affinity.nodeAffinityRequiredDuringScheduling.values -}}
    {{- if $root.Values.arch -}}
      {{- $archType := typeOf $root.Values.arch -}}
      {{- if eq $archType "map[string]interface {}" -}}
        {{- /* Helm templating has issues with reassigning variables within a loop in some versions of Helm. */ -}}
        {{- /* It also cannnot break from a loop. Using a dictionary in this way is a workaround for this issue. */ -}}
        {{- $firstFound := dict "firstFound" false }}
        {{- range $key, $value := $root.Values.arch }}
          {{- $splitValue := split " " $value }}
          {{- $weight := $splitValue._0 | int64 }}
          {{- if gt $weight 0 }}
            {{- if hasKey $firstFound "firstFound" }}
              {{- $_ := unset $firstFound "firstFound" }}
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: {{ default "beta.kubernetes.io/arch" $affinity.key }}
        operator: {{ $operator }}
        values:
            {{- end }}
        - {{ $key }}
          {{- end }}
        {{- end -}}
      {{- else }}
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: {{ default "beta.kubernetes.io/arch" $affinity.key }}
        operator: {{ $operator }}
        values:
        - {{ $root.Values.arch }}
      {{- end -}}
    {{- else -}}
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: {{ default "beta.kubernetes.io/arch" $affinity.key }}
        operator: {{ $operator }}
        values:
    {{- range $key := $values }}
        - {{ $key }}
    {{- end -}}
    {{- end -}}
{{- end }}

{{- define "sch.affinity.nodeAffinityPreferredDuringScheduling" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $nodeAffinity := last $params -}}
  {{- $affinityDefault := $nodeAffinity.nodeAffinityPreferredDuringScheduling -}}
  {{- $affinity := $root.Values.arch | default $affinityDefault -}}
  {{- if not $root.Values.arch }}
  {{- range $key, $value := $affinity }}
    {{- $weight := $value.weight | int64 }}
    {{- if gt $weight 0 }}
preferredDuringSchedulingIgnoredDuringExecution:
      {{- $operator := $value.operator }}
- weight: {{ $weight }}
  preference:
    matchExpressions:
    - key: {{ default "beta.kubernetes.io/arch" $value.key }}
      operator: {{ default "In" $operator }}
      values:
      - {{ $key }}
    {{ end -}}
  {{ end -}}
  {{- else if and ($root.Values.arch) (eq (typeOf $root.Values.arch) "map[string]interface {}") }}
    {{- $firstFound := dict "firstFound" false }}
    {{- range $key, $value := $root.Values.arch }}
      {{- $splitValue := split " " $value }}
      {{- $weight := $splitValue._0 | int64 }}
      {{- if gt $weight 0 }}
      {{- if hasKey $firstFound "firstFound" }}
        {{- $_ := unset $firstFound "firstFound" }}
preferredDuringSchedulingIgnoredDuringExecution:
      {{- end }}
- weight: {{ $weight }}
  preference:
    matchExpressions:
    - key: "beta.kubernetes.io/arch"
      operator: "In"
      values:
      - {{ $key }}
      {{- end -}}
    {{- end -}}
  {{- end }}
{{- end }}


{{- /*
`"sch.affinity.podAffinity"` Inter-pod affinity and anti-affinity allow you to constrain
which nodes your pod is eligible to be scheduled based on labels on pods that are already
running on the node rather than based on labels on nodes. Specify one or all of
requiredDuringScheduling, requiredDuringSchedulingRequiredDuringExecution,
and preferredDuringScheduling to set your node affinity.

For more information, see https://kubernetes.io/docs/concepts/configuration/assign-pod-node/

Note: the value specified in requiredDuringScheduling maps to
requiredDuringSchedulingIgnoredDuringExecution.

__Values Used__
- none

__Config Values Used:__
- passed as argument

__Uses:__
- sch.affinity.requiredDuringSchedulingRequiredDuringExecution
- sch.affinity.requiredDuringSchedulingIgnoredDuringExecution
- sch.affinity.preferredDuringScheduling

__Parameters input as an list of values:__
- the root context (required)
- config values map of annotations (required)

__Usage:__
example chart config values
```
{{- define "sch.chart.config.values" -}}
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
{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}
*/}}

{{- define "sch.affinity.podAffinity" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $defaultRoot := fromYaml (include "sch.chart.default.config.values" .) }}
  {{- $defaultPodAffinity := $defaultRoot.sch.chart.podAffinity }}
  {{- $podAffinity := $root.sch.chart.podAffinity | default $defaultPodAffinity }}
podAffinity:
  {{- if (gt (len $podAffinity) 0) }}
    {{- if (hasKey $podAffinity "requiredDuringSchedulingRequiredDuringExecution") }}
  {{ include "sch.affinity.requiredDuringSchedulingRequiredDuringExecution" (list $root $podAffinity) }}
    {{- end }}
    {{- if (hasKey $podAffinity "requiredDuringScheduling") }}
  {{ include "sch.affinity.requiredDuringSchedulingIgnoredDuringExecution" (list $root $podAffinity) }}
    {{- end }}
    {{- if (hasKey $podAffinity "preferredDuringScheduling") }}
  {{ include "sch.affinity.preferredDuringScheduling" (list $root $podAffinity) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "sch.affinity.requiredDuringSchedulingRequiredDuringExecution" -}}
    {{- $params := . }}
    {{- $root := first $params }}
    {{- $affinity := last $params }}
    {{- $operator := $affinity.requiredDuringSchedulingRequiredDuringExecution.operator -}}
    {{- $values := $affinity.requiredDuringSchedulingRequiredDuringExecution.values -}}
    {{- $topologyKey := $affinity.requiredDuringSchedulingRequiredDuringExecution.topologyKey -}}
requiredDuringSchedulingRequiredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: {{ default "beta.kubernetes.io/arch" $affinity.key }}
        operator: {{ $operator }}
        values:
    {{- range $key := $values }}
        - {{ $key }}
    {{- end }}
    topologyKey: {{ $topologyKey }}
{{- end -}}

{{- define "sch.affinity.requiredDuringSchedulingIgnoredDuringExecution" -}}
    {{- $params := . }}
    {{- $root := first $params }}
    {{- $affinity := last $params }}
    {{- $operator := $affinity.requiredDuringScheduling.operator -}}
    {{- $values := $affinity.requiredDuringScheduling.values -}}
    {{- $topologyKey := $affinity.requiredDuringScheduling.topologyKey -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: {{ default "beta.kubernetes.io/arch" $affinity.key }}
        operator: {{ $operator }}
        values:
    {{- range $key := $values }}
        - {{ $key }}
    {{- end }}
    topologyKey: {{ $topologyKey }}
{{- end -}}

{{- define "sch.affinity.preferredDuringScheduling" -}}
  {{- $params := . -}}
  {{- $root := first $params -}}
  {{- $podAffinity := last $params -}}
  {{- $affinity := $podAffinity.preferredDuringScheduling -}}
  {{- range $key, $value := $affinity -}}
preferredDuringSchedulingIgnoredDuringExecution:
    {{- $weight := $value.weight | int64 -}}
    {{- $operator := $value.operator -}}
    {{- $topologyKey := $value.topologyKey }}
  - weight: {{ $weight }}
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: {{ default "kubernetes.io/hostname" $value.key }}
          operator: {{ default "In" $operator }}
          values:
          - {{ $key }}
      topologyKey: {{ $topologyKey }}
  {{- end }}
{{- end }}

{{- /*
`"sch.affinity.podAntiAffinity"` Inter-pod affinity and anti-affinity allow you to constrain
which nodes your pod is eligible to be scheduled based on labels on pods that are already
running on the node rather than based on labels on nodes. Specify one or all of
requiredDuringScheduling, requiredDuringSchedulingRequiredDuringExecution,
and preferredDuringScheduling to set your node affinity.

For more information, see https://kubernetes.io/docs/concepts/configuration/assign-pod-node/

Note: the value specified in requiredDuringScheduling maps to
requiredDuringSchedulingIgnoredDuringExecution.

__Values Used__
- none

__Config Values Used:__
- passed as argument

__Uses:__
- sch.affinity.requiredDuringSchedulingRequiredDuringExecution
- sch.affinity.requiredDuringSchedulingIgnoredDuringExecution
- sch.affinity.preferredDuringScheduling

__Parameters input as an list of values:__
- the root context (required)
- config values map of annotations (required)

__Usage:__
example chart config values
```
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    podAntiAffinity:
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
{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ */}}
*/}}

{{- define "sch.affinity.podAntiAffinity" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $defaultRoot := fromYaml (include "sch.chart.default.config.values" .) }}
  {{- $defaultPodAntiAffinity := $defaultRoot.sch.chart.podAntiAffinity }}
  {{- $podAntiAffinity := $root.sch.chart.podAntiAffinity | default $defaultPodAntiAffinity }}
podAntiAffinity:
  {{- if (gt (len $podAntiAffinity) 0) }}
    {{- if (hasKey $podAntiAffinity "requiredDuringSchedulingRequiredDuringExecution") }}
  {{ include "sch.affinity.requiredDuringSchedulingRequiredDuringExecution" (list $root $podAntiAffinity) }}
    {{- end }}
    {{- if (hasKey $podAntiAffinity "requiredDuringScheduling") }}
  {{ include "sch.affinity.requiredDuringSchedulingIgnoredDuringExecution" (list $root $podAntiAffinity) }}
    {{- end }}
    {{- if (hasKey $podAntiAffinity "preferredDuringScheduling") }}
  {{ include "sch.affinity.preferredDuringScheduling" (list $root $podAntiAffinity) }}
    {{- end }}
  {{- end }}
{{- end }}
