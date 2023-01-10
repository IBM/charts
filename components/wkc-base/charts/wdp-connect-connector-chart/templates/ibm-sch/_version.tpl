{{- /*
Config file for SCH (Shared Configurable Helpers)

sch/_version.tpl contains the version information and tillerVersion
constraint for this version of the Shared Configurable Helpers.
 
********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- /*
"sch.version" contains the version information and tillerVersion constraint
for this version of the Shared Configurable Helpers.
*/ -}}
{{- define "sch.version" -}}
version: "1.2.7"
tillerVersion: ">=2.6.0"
{{- end -}}
