{{/*
  app:       "{ { $k8s_names.icp.app } }"
  chart:     "{ { $kingdom.icp.chart } }" 
  heritage:  "{ { $kingdom.icp.heritage } }"
  release:   "{ { $kingdom.icp.release } }"
*/}}
{{ define "embeddings.labels" }}
labels:
  app:       "watson-assistant"
  chart:     {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
  heritage:  {{ .Release.Service | quote }}
  release:   {{ .Release.Name    | quote }}
{{ end }}

{{/*****************************************************************************
   * Languages support: builds a word_embeddings_settings string of available languages for this install
   **************************************************************************/}}
{{- define "assistant.recommends.languages" -}}
  {{- $languages := dict "key" (list ) }}
  {{- if .Values.global.languages.english            }}{{- $_ := set $languages "key" ( append $languages.key           "en:20181004-221011:300:1:2398834:1:4078495:1:1472280"   ) -}}{{- end -}}
  {{- if .Values.global.languages.spanish            }}{{- $_ := set $languages "key" ( append $languages.key           "es:20181017-131837:100:1:434197:1:434197:1:434197"      ) -}}{{- end -}}
  {{- if .Values.global.languages.french             }}{{- $_ := set $languages "key" ( append $languages.key           "fr:20181017-132950:100:1:491095:1:491095:1:491095"      ) -}}{{- end -}}
  {{- if .Values.global.languages.japanese           }}{{- $_ := set $languages "key" ( append $languages.key           "ja:20181017-133647:100:1:424793:1:424791:1:424793"      ) -}}{{- end -}}
  {{- $languages.key | join "," -}}
{{- end -}}

{{/*****************************************************************************
   * Security Context
   * Default value for runAsUSer can be overriden
   *
   * Example:
   * Change the id we run as to 2000....
   * {{ include "assistant.recommends.securityContext" (dict "runAsUser" "2000") | indent 8 }}
   **************************************************************************/}}
{{- define "assistant.recommends.securityContext" -}}
{{- $runAsUser := default "2000" .runAsUser -}}
privileged: false
readOnlyRootFilesystem: false 
allowPrivilegeEscalation: false
runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
runAsUser: {{ $runAsUser }}
{{- end }}
capabilities:
  drop:
    - ALL
{{- end -}}
