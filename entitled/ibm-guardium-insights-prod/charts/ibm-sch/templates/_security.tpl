{{- /*
security helpers for SCH (Shared Configurable Helpers)

sch/_security.tpl contains shared configurable helper templates for 
specifying securityContext resources.

Usage of "sch.security.*" requires the following line be included at
the begining of template:
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- /*
`"sch.security.securityContext"` specifies the security context for your pod or
container. Each pod needs to be evaluated at a container level for their security
requirements, but often there is a set of attributes that is common to a number
of pods within your deployment.

Specify one or more securityContexts in your _sch-chart-config.tpl and pass one
to the `sch.security.securityContext` definition to include a securityContext in
your chart yaml.

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
{{- define "sch.chart.config.values" -}}
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
        - name: {{ $containerName }}
{{- include "sch.security.securityContext" (list . .sch.chart.securityContext1) | indent 10 }}
or
spec:
  template:
    spec:
{{- include "sch.security.securityContext" (list . .sch.chart.securityContext2) | indent 6 }}
```
*/}}

{{- define "sch.security.securityContext" -}}
  {{- $params := . }}
  {{- $root := first $params }}
  {{- $securityParams := (index $params 1) }}
{{ toYaml $securityParams }}
{{- end }}
