
{{- define "ibm-hdm-common-ui.integrations.environmentVars" -}}
  {{- $root := . -}}
  {{- $globalIntegrations := .Values.global.integrations -}}
  {{- $localIntegrations := .Values.integrations -}}
  {{- $integrations := merge $localIntegrations $globalIntegrations -}}

  {{- $defaults := dict "releaseName" $root.Release.Name "namespace" $root.Release.Namespace -}}

  {{- range $integrationId, $_integration := $integrations -}}
    {{- $integration := merge $_integration $defaults -}}
    {{- if $integration.environment -}}
      {{- if $integration.environment.config -}}
        {{- range $urlId, $envVars := $integration.environment.config -}}
          {{- $url := index $integration.config $urlId -}}
          {{- if eq (kindOf $envVars) "string" -}}
            {{- include "ibm-hdm-common-ui.integrations.environmentVarString" (list $root $envVars $integration.releaseName $integration.namespace $url) -}}
          {{- else }}
            {{- range $envVar := $envVars -}}
              {{- include "ibm-hdm-common-ui.integrations.environmentVarString" (list $root $envVar $integration.releaseName $integration.namespace $url) -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

      {{- if $integration.environment.secrets -}}
        {{- range $secretId, $envVars := $integration.environment.secrets -}}
          {{- $secret := index $integration.secrets $secretId -}}
          {{- if eq (kindOf $envVars) "string" -}}
            {{- include "ibm-hdm-common-ui.integrations.environmentVarSecret" (list $root $envVars $integration.releaseName $integration.namespace $secret.template $secret.key $secret.optional) -}}
          {{- else }}
            {{- range $envVar := $envVars -}}
              {{- include "ibm-hdm-common-ui.integrations.environmentVarSecret" (list $root $envVar $integration.releaseName $integration.namespace $secret.template $secret.key $secret.optional) -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

      {{- if $integration.environment.configMaps -}}
        {{- range $configMapId, $envVars := $integration.environment.configMaps -}}
          {{- $configMap := index $integration.configMaps $configMapId -}}
          {{- if eq (kindOf $envVars) "string" -}}
            {{- include "ibm-hdm-common-ui.integrations.environmentVarConfigmap" (list $root $envVars $integration.releaseName $integration.namespace $configMap.template $configMap.key $configMap.optional) -}}
          {{- else }}
            {{- range $envVar := $envVars -}}
              {{- include "ibm-hdm-common-ui.integrations.environmentVarConfigmap" (list $root $envVar $integration.releaseName $integration.namespace $configMap.template $configMap.key $configMap.optional) -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-hdm-common-ui.integrations.environmentVarString" -}}
  {{- $root := index . 0 -}}
  {{- $varName := index . 1 -}}
  {{- $releaseName := default $root.Release.Name (index . 2) -}}
  {{- $namespace := default $root.Release.Namespace (index . 3) -}}
  {{- $varTpl := index . 4 -}}
  {{- $_ := set $root "releaseName" $releaseName }}
  {{- $_ := set $root "namespace" $namespace }}
  {{- $_ := set $root "ingressDomain" (include "ibm-hdm-common-ui.ingress.baseurl" $root ) }}
- name: {{ $varName | quote }}
  value: {{ tpl $varTpl $root | quote }}
{{ end -}}

{{- define "ibm-hdm-common-ui.integrations.environmentVarSecret" -}}
  {{- $root := index . 0 -}}
  {{- $varName := index . 1 -}}
  {{- $releaseName := default $root.Release.Name (index . 2) -}}
  {{- $namespace := default $root.Release.Namespace (index . 3) -}}
  {{- $secretTpl := index . 4 -}}
  {{- $secretKey := index . 5 -}}
  {{- $isOptional := default "true" (index . 6) -}}
  {{- $_ := set $root "releaseName" $releaseName }}
  {{- $_ := set $root "namespace" $namespace }}
  {{- $_ := set $root "ingressDomain" (include "ibm-hdm-common-ui.ingress.baseurl" $root ) }}
- name: {{ $varName | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ tpl $secretTpl $root | quote }}
      key: {{ $secretKey | quote }}
      optional: {{ $isOptional }}
{{ end -}}

{{- define "ibm-hdm-common-ui.integrations.environmentVarConfigmap" -}}
  {{- $root := index . 0 -}}
  {{- $varName := index . 1 -}}
  {{- $releaseName := default $root.Release.Name (index . 2) -}}
  {{- $namespace := default $root.Release.Namespace (index . 3) -}}
  {{- $configmapTpl := index . 4 -}}
  {{- $configmapKey := index . 5 -}}
  {{- $isOptional := default "true" (index . 6) -}}
  {{- $_ := set $root "releaseName" $releaseName }}
  {{- $_ := set $root "namespace" $namespace }}
  {{- $_ := set $root "ingressDomain" (include "ibm-hdm-common-ui.ingress.baseurl" $root ) }}
- name: {{ $varName | quote }}
  valueFrom:
    configMapKeyRef:
      name: {{ tpl $configmapTpl $root | quote }}
      key: {{ $configmapKey | quote }}
      optional: {{ $isOptional }}
{{ end -}}

{{- define "ibm-hdm-common-ui.integrations.volumes" -}}
  {{- $root := . -}}
  {{- $globalIntegrations := .Values.global.integrations -}}
  {{- $localIntegrations := .Values.integrations -}}
  {{- $integrations := merge $localIntegrations $globalIntegrations -}}

  {{- $defaults := dict "releaseName" $root.Release.Name "namespace" $root.Release.Namespace -}}

  {{- range $integrationId, $_integration := $integrations -}}
    {{- $integration := merge $_integration $defaults -}}
    {{- if $integration.directories -}}
      {{- if $integration.directories.secrets -}}
        {{- range $secretId, $directories := $integration.directories.secrets -}}
          {{- $secret := index $integration.secrets $secretId -}}
          {{- if eq (kindOf $directories) "string" -}}
            {{- include "ibm-hdm-common-ui.integrations.directorySecret" (list $root $integrationId $secretId $integration.releaseName $integration.namespace $secret.template $secret.optional) -}}
          {{- else }}
            {{- fail "Arrays of directories are not currently supported" -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

      {{- if $integration.directories.configMaps -}}
        {{- range $configMapId, $directories := $integration.directories.configMaps -}}
          {{- $configMap := index $integration.configMaps $configMapId -}}
          {{- if eq (kindOf $directories) "string" -}}
            {{- include "ibm-hdm-common-ui.integrations.directoryConfigmap" (list $root $integrationId $configMapId $integration.releaseName $integration.namespace $configMap.template $configMap.optional) -}}
          {{- else }}
            {{- fail "Arrays of directories are not currently supported" -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-hdm-common-ui.integrations.directorySecret" -}}
  {{- $root := index . 0 -}}
  {{- $integrationId := index . 1 -}}
  {{- $secretId := index . 2 -}}
  {{- $releaseName := default $root.Release.Name (index . 3) -}}
  {{- $namespace := default $root.Release.Namespace (index . 4) -}}
  {{- $secretTpl := index . 5 -}}
  {{- $isOptional := default "true" (index . 6) -}}
  {{- $_ := set $root "releaseName" $releaseName }}
  {{- $_ := set $root "namespace" $namespace }}
  {{- $_ := set $root "ingressDomain" (include "ibm-hdm-common-ui.ingress.baseurl" $root ) }}
- name: {{ printf "%s-%s" $integrationId $secretId | lower | quote }}
  secret:
    secretName: {{ tpl $secretTpl $root | quote }}
    optional: {{ $isOptional }}
{{ end -}}

{{- define "ibm-hdm-common-ui.integrations.directoryConfigmap" -}}
  {{- $root := index . 0 -}}
  {{- $integrationId := index . 1 -}}
  {{- $configMapId := index . 2 -}}
  {{- $releaseName := default $root.Release.Name (index . 3) -}}
  {{- $namespace := default $root.Release.Namespace (index . 4) -}}
  {{- $configMapTpl := index . 5 -}}
  {{- $isOptional := default "true" (index . 6) -}}
  {{- $_ := set $root "releaseName" $releaseName }}
  {{- $_ := set $root "namespace" $namespace }}
  {{- $_ := set $root "ingressDomain" (include "ibm-hdm-common-ui.ingress.baseurl" $root ) }}
- name: {{ printf "%s-%s" $integrationId $configMapId | lower | quote }}
  configMap:
    name: {{ tpl $configMapTpl $root | quote }}
    optional: {{ $isOptional }}
{{ end -}}

{{- define "ibm-hdm-common-ui.integrations.volumeMounts" -}}
  {{- $root := . -}}
  {{- $globalIntegrations := .Values.global.integrations -}}
  {{- $localIntegrations := .Values.integrations -}}
  {{- $integrations := merge $localIntegrations $globalIntegrations -}}

  {{- $defaults := dict "releaseName" $root.Release.Name "namespace" $root.Release.Namespace -}}

  {{- range $integrationId, $_integration := $integrations -}}
    {{- $integration := merge $_integration $defaults -}}
    {{- if $integration.directories -}}
      {{- if $integration.directories.secrets -}}
        {{- range $secretId, $directories := $integration.directories.secrets -}}
          {{- $secret := index $integration.secrets $secretId -}}
          {{- if eq (kindOf $directories) "string" -}}
            {{- include "ibm-hdm-common-ui.integrations.directoryMount" (list $root $integrationId $secretId $integration.releaseName $integration.namespace $directories ) -}}
          {{- else }}
            {{- fail "Arrays of directories are not currently supported" -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}

      {{- if $integration.directories.configMaps -}}
        {{- range $configMapId, $directories := $integration.directories.configMaps -}}
          {{- $configMap := index $integration.configMaps $configMapId -}}
          {{- if eq (kindOf $directories) "string" -}}
            {{- include "ibm-hdm-common-ui.integrations.directoryMount" (list $root $integrationId $configMapId $integration.releaseName $integration.namespace $directories ) -}}
          {{- else }}
            {{- fail "Arrays of directories are not currently supported" -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-hdm-common-ui.integrations.directoryMount" -}}
  {{- $root := index . 0 -}}
  {{- $integrationId := index . 1 -}}
  {{- $secretId := index . 2 -}}
  {{- $releaseName := default $root.Release.Name (index . 3) -}}
  {{- $namespace := default $root.Release.Namespace (index . 4) -}}
  {{- $directoryPath := index . 5 -}}
  {{- $_ := set $root "releaseName" $releaseName }}
  {{- $_ := set $root "namespace" $namespace }}
  {{- $_ := set $root "ingressDomain" (include "ibm-hdm-common-ui.ingress.baseurl" $root ) }}
- name: {{ printf "%s-%s" $integrationId $secretId | lower | quote }}
  mountPath: {{ $directoryPath | quote }}
  readOnly: true
{{ end -}}
