{{- define "assistant.ipcLabels" -}}
app:       "watson-assistant"
chart:     "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
heritage:  {{ .Release.Service | quote }}
release:   {{ .Release.Name    | quote }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "assistant.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Evaluates if a var is set to true or not.
  Support not only bool values true/false but also
    strings "true"/"false" and templates like "{{ .Values.global.etcd.tsl.enabled }}"
  Usage: {{ if "assistant.boolConverter" (list .Values.tls.enabled .) }}
*/}}
{{- define "assistant.boolConverter" -}}
  {{- if typeIs "bool" (first .) -}}
    {{- if (first .) }}    VALUE_IS_BOOL_TRUE_THUS_GENERATING_NON_EMPTY_STRING {{- end -}}
  {{- else if typeIs "string" (first .) -}}
    {{- if eq "true" ( tpl (first .) (last .) )  }}VAULT_IS_STRING_AND_RENDERS_TO_TRUE_THUS_GENERATING_NON_EMPTY_STRING{{- end -}}
  {{- end -}}
{{- end -}}

{{/*****************************************************************************
   * Postgres details
   **************************************************************************/}}
{{- define "assistant.ibm-postgresql.svc.proxyServiceName" -}}
   {{- $postgresSimulatedContext := (merge dict . ) }}
   {{- $_ := set $postgresSimulatedContext        "Values"   (dict "nameOverride" "store-postgres")         }}
   {{- include "ibm-postgresql.svc.proxyServiceName" $postgresSimulatedContext -}}
{{- end -}}

{{- define "assistant.postgres.hostname" -}}
  {{- if .Values.global.postgres.create -}}
    {{- include "assistant.ibm-postgresql.svc.proxyServiceName" . -}}
  {{- else -}}
    {{- .Values.global.postgres.hostname -}}
  {{- end -}}
{{- end -}}

{{- define "assistant.postgres.port" -}}
{{- if .Values.global.postgres.create -}}
5432
{{- else -}}
{{- .Values.global.postgres.port -}}
{{- end -}}
{{- end -}}

{{- define "assistant.postgres.store.database" -}}
{{- if .Values.global.postgres.store.database -}}
{{- .Values.global.postgres.store.database -}}
{{- else -}}
conversation_icp_{{ .Release.Name }}
{{- end -}}
{{- end -}}

{{- define "assistant.postgres.store.user" -}}
{{- if .Values.global.postgres.store.auth.user -}}
{{- .Values.global.postgres.store.auth.user -}}
{{- else -}}
store_icp_{{ .Release.Name }}
{{- end -}}
{{- end -}}


{{/*****************************************************************************
   * ETCD details
   **************************************************************************/}}

{{- define "assistant.etcd.endpoints" -}}
{{- if .Values.global.etcd.create -}}
  {{- if .Values.global.etcd.tls.enabled -}}https{{- else -}}http{{- end -}}://{{ .Release.Name -}}-etcd3.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:2379
{{- else -}}
  {{- .Values.global.etcd.connection -}}
{{- end -}}
{{- end -}}



{{/*****************************************************************************
   * Mongodb details
   **************************************************************************/}}
{{/* 
  Stored the simulated context for ibm-mongodb chart that can be used to generate default secret and service names.
  The template is not bullet proof but the best one we can create.
  Known limitations: does not support ".nameOverride" since helm provide no means to get actual values of nameOverride used in ibm-mongodb chart
  Can be used withing any sub-chart.
__Parameters input as a list of values:__
- the root context (required)
- key under which to store the context. Defaults to result. (optional)
*/}}

{{- define "assistant.mongodb.admin.secretName" -}}
  {{- if .Values.global.mongodb.auth.existingAdminSecret -}}
    {{- .Values.global.mongodb.auth.existingAdminSecret -}}
  {{- else -}}
    {{- include "ibm-mongodb.admin.secretName" . }}
  {{- end -}}
{{- end -}}

{{- define "assistant.mongodb.cert.secretName" -}}
  {{- if .Values.global.mongodb.tls.existingCaSecret -}}
    {{- .Values.global.mongodb.tls.existingCaSecret -}}
  {{- else -}}
    {{- include "ibm-mongodb.cert.secretName" . }}
  {{- end -}}
{{- end -}}

{{- define "assistant.mongodb.svc.connectionString" -}}
  {{- /* TODO: Hard-coded number of replicas. Made it templatable and move to globals so that any chart can use it */}}
  {{- $root := . -}}
  {{- range $podNum := (list 0 1 2 ) -}}
    {{- if not (eq $podNum 0) -}},{{- end -}}
    {{- include "ibm-mongodb.svc.statefulsetName" $root -}}-{{ $podNum }}.{{ include "ibm-mongodb.svc.fullName" $root }}:27017
  {{- end -}}
/admin?ssl={{ .Values.global.mongodb.tls.enabled }}
{{- end -}}


{{/*****************************************************************************
   * COS / Minio details
   **************************************************************************/}}

{{- define "assistant.cos.schema" -}}
   {{- if .Values.global.cos.create -}}
     https
   {{- else -}}
     {{- .Values.global.cos.schema }}
   {{- end -}}
{{- end -}}

{{- define "assistant.cos.hostname" -}}
   {{- if .Values.global.cos.create -}}
     {{- include "assistant.minio.fullname" . }}
   {{- else -}}
     {{- .Values.global.cos.hostname }}
   {{- end -}}
{{- end -}}

{{- define "assistant.cos.port" -}}
   {{- if .Values.global.cos.create -}}
     9000
   {{- else -}}
     {{- .Values.global.cos.port }}
   {{- end -}}
{{- end -}}

{{- define "assistant.cos.auth.secretName" -}}
  {{- if tpl .Values.global.cos.auth.secretName . -}}
    {{- /* Provided secret name credentials to be used for cos  */ -}}
    {{- tpl .Values.global.cos.auth.secretName . -}}
  {{- else -}}
    {{- /* Generated secret name with credentials */ -}}
    {{- .Release.Name -}}-clu-minio-auth
  {{- end -}}
{{- end -}}

{{- define "assistant.cos.tls.secretName" -}}
  {{- if tpl .Values.global.cos.tls.secretName . -}}
    {{- /* Provided secret name with certificates */ -}}
    {{- tpl .Values.global.cos.tls.secretName . -}}
  {{- else -}}
    {{- /* Generated secret name with certificates */ -}}
    {{- .Release.Name -}}-clu-minio-tls
  {{- end -}}
{{- end -}}

{{- define "assistant.cos.sse.secretName" -}}
  {{- if tpl .Values.global.cos.sse.secretName . -}}
    {{- /* Provided secret name with sse masterkey */ -}}
    {{- tpl .Values.global.cos.sse.secretName . -}}
  {{- else -}}
    {{- /* Generated secret name with sse masterkey */ -}}
    {{- .Release.Name -}}-clu-minio-sse
  {{- end -}}
{{- end -}}

{{/*****************************************************************************
   * Deployment Sizing:
   **************************************************************************/}}

{{- define "assistant.dialog.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.ed.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.master.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}


{{- define "assistant.nlu.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}


{{- define "assistant.recommends.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}


{{- define "assistant.store.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.tas.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.skillConversation.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.skillSearch.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.ui.replicas" -}}
  {{- if .Values.replicas -}}
    {{- .Values.replicas -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.sireg.de-tok-20160801.replicas" -}}
  {{- if not .Values.global.languages.german -}}
    {{- /* Deutch is disabled, thus no pods for German SireG will be created */ -}}
    0
  {{- else if .Values.replicas.german -}}
    {{- .Values.replicas.german -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.sireg.ja-tok-20160902.replicas" -}}
  {{- if not .Values.global.languages.japanese -}}
    {{- /* Japanese is disabled, thus no pods for japanese SireG will be created */ -}}
    0
  {{- else if .Values.replicas.japanese -}}
    {{- .Values.replicas.japanese -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.sireg.ko-tok-20181109.replicas" -}}
  {{- if not .Values.global.languages.korean -}}
    {{- /* Korean is disabled, thus no pods for korean SireG will be created */ -}}
    0
  {{- else if .Values.replicas.korean -}}
    {{- .Values.replicas.korean -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.sireg.zhcn-tok-20160801.replicas" -}}
  {{- if not (or .Values.global.languages.chineseSimplified .Values.global.languages.chineseTraditional ) -}}
    {{- /* Simplified Chinese is disabled, thus no pods for simplified chinese SireG will be created */ -}}
    0
  {{- else if .Values.replicas.chineseSimplified -}}
    {{- .Values.replicas.chineseSimplified -}}
  {{- else if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{- define "assistant.ingress.wcn-addon.replicas" -}}
  {{- if eq .Values.global.deploymentType "Production" -}}
    2
  {{- else -}}
    {{- /* Development (or other value) */ -}}
    1
  {{- end -}}
{{- end -}}

{{/*****************************************************************************
   * Languages support: (partially included in the sireg scaling in templates above)
   **************************************************************************/}}

{{- define "assistant.store.languages" -}}
  {{- $languages := dict "key" (list ) }}
  {{- if .Values.global.languages.english            }}{{- $_ := set $languages "key" ( append $languages.key "en"    ) -}}{{- end -}}
  {{- if .Values.global.languages.spanish            }}{{- $_ := set $languages "key" ( append $languages.key "es"    ) -}}{{- end -}}
  {{- if .Values.global.languages.portuguese         }}{{- $_ := set $languages "key" ( append $languages.key "pt-br" ) -}}{{- end -}}
  {{- if .Values.global.languages.french             }}{{- $_ := set $languages "key" ( append $languages.key "fr"    ) -}}{{- end -}}
  {{- if .Values.global.languages.italian            }}{{- $_ := set $languages "key" ( append $languages.key "it"    ) -}}{{- end -}}
  {{- if .Values.global.languages.japanese           }}{{- $_ := set $languages "key" ( append $languages.key "ja"    ) -}}{{- end -}}
  {{- if .Values.global.languages.german             }}{{- $_ := set $languages "key" ( append $languages.key "de"    ) -}}{{- end -}}
  {{- if .Values.global.languages.korean             }}{{- $_ := set $languages "key" ( append $languages.key "ko"    ) -}}{{- end -}}
  {{- if .Values.global.languages.arabic             }}{{- $_ := set $languages "key" ( append $languages.key "ar"    ) -}}{{- end -}}
  {{- if .Values.global.languages.dutch              }}{{- $_ := set $languages "key" ( append $languages.key "nl"    ) -}}{{- end -}}
  {{- if .Values.global.languages.chineseTraditional }}{{- $_ := set $languages "key" ( append $languages.key "zh-tw" ) -}}{{- end -}}
  {{- if .Values.global.languages.chineseSimplified  }}{{- $_ := set $languages "key" ( append $languages.key "zh-cn" ) -}}{{- end -}}
  {{- if .Values.global.languages.czech              }}{{- $_ := set $languages "key" ( append $languages.key "cs"    ) -}}{{- end -}}
  {{- $languages.key | join "," -}}
{{- end -}}

{{- define "assistant.store.fuzzy_match_languages" -}}
  {{- $languages := dict "key" (list ) }}
  {{- if .Values.global.languages.english            }}{{- $_ := set $languages "key" ( append $languages.key "en"    ) -}}{{- end -}}
  {{- if .Values.global.languages.spanish            }}{{- $_ := set $languages "key" ( append $languages.key "es"    ) -}}{{- end -}}
  {{- if .Values.global.languages.french             }}{{- $_ := set $languages "key" ( append $languages.key "fr"    ) -}}{{- end -}}
  {{- if .Values.global.languages.italian            }}{{- $_ := set $languages "key" ( append $languages.key "it"    ) -}}{{- end -}}
  {{- if .Values.global.languages.portuguese         }}{{- $_ := set $languages "key" ( append $languages.key "pt-br" ) -}}{{- end -}}
  {{- if .Values.global.languages.german             }}{{- $_ := set $languages "key" ( append $languages.key "de"    ) -}}{{- end -}}
  {{- if .Values.global.languages.czech              }}{{- $_ := set $languages "key" ( append $languages.key "cs"    ) -}}{{- end -}}
  {{- if .Values.global.languages.japanese           }}{{- $_ := set $languages "key" ( append $languages.key "ja"    ) -}}{{- end -}}
  {{- if .Values.global.languages.arabic             }}{{- $_ := set $languages "key" ( append $languages.key "ar"    ) -}}{{- end -}}
  {{- if .Values.global.languages.korean             }}{{- $_ := set $languages "key" ( append $languages.key "ko"    ) -}}{{- end -}}
  {{- if .Values.global.languages.dutch              }}{{- $_ := set $languages "key" ( append $languages.key "nl"    ) -}}{{- end -}}
  {{- $languages.key | join "," -}}
{{- end -}}


{{- define "assistant.ui.languages" -}}
  {{- $languages := dict "key" (list ) }}
  {{- if .Values.global.languages.arabic             }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"ar\",\"label\":\"ARABIC\",\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false}"                                                                                                                    ) -}}{{- end -}}
  {{- if .Values.global.languages.german             }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"de\",\"label\":\"GERMAN\",\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false}"                                                                                                                    ) -}}{{- end -}}
  {{- if .Values.global.languages.english            }}{{- $_ := set $languages "key" ( append $languages.key  ( printf "{\"value\":\"en\",\"label\":\"ENGLISH_US\",\"off-topic\":\"2017-02-03\",\"fuzzy-match\":true,\"search\":false, \"synonym-recommendations\" : %s, \"open-entities\" : true}" ( .Values.global.recommends.enabled | toString ) ) ) -}}{{- end -}}
  {{- if .Values.global.languages.spanish            }}{{- $_ := set $languages "key" ( append $languages.key  ( printf "{\"value\":\"es\",\"label\":\"SPANISH\",\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false, \"synonym-recommendations\" : %s}"                              ( .Values.global.recommends.enabled | toString ) ) ) -}}{{- end -}}
  {{- if .Values.global.languages.french             }}{{- $_ := set $languages "key" ( append $languages.key  ( printf "{\"value\":\"fr\",\"label\":\"FRENCH\",\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false, \"synonym-recommendations\" : %s}"                               ( .Values.global.recommends.enabled | toString ) ) ) -}}{{- end -}}
  {{- if .Values.global.languages.italian            }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"it\",\"label\":\"ITALIAN\",\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false}"                                                                                                                   ) -}}{{- end -}}
  {{- if .Values.global.languages.japanese           }}{{- $_ := set $languages "key" ( append $languages.key  ( printf "{\"value\":\"ja\",\"label\":\"JAPANESE\",\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false, \"synonym-recommendations\" : %s}"                             ( .Values.global.recommends.enabled | toString ) ) ) -}}{{- end -}}
  {{- if .Values.global.languages.korean             }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"ko\",\"label\":\"KOREAN\",\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false}"                                                                                                                    ) -}}{{- end -}}
  {{- if .Values.global.languages.portuguese         }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"pt-br\",\"label\":\"BRAZILIAN_PORTUGUESE\",\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false}"                                                                                                   ) -}}{{- end -}}
  {{- if .Values.global.languages.czech              }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"cs\",\"label\":\"CZECH\",\"experimental\":true,\"off-topic\":\"2017-04-21\",\"fuzzy-match\":true,\"search\":false}"                                                                                               ) -}}{{- end -}}
  {{- if .Values.global.languages.dutch              }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"nl\",\"label\":\"DUTCH\",\"off-topic\":\"2017-04-21\",\"search\":false,\"fuzzy-match\" : true}"                                                                                                                   ) -}}{{- end -}}
  {{- if .Values.global.languages.chineseTraditional }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"zh-tw\",\"label\":\"CHINESE_TRADITIONAL\",\"experimental\":true,\"off-topic\":\"2017-04-21\",\"search\":false}"                                                                                                   ) -}}{{- end -}}
  {{- if .Values.global.languages.chineseSimplified  }}{{- $_ := set $languages "key" ( append $languages.key           "{\"value\":\"zh-cn\",\"label\":\"CHINESE_SIMPLIFIED\",\"off-topic\":\"2017-04-21\",\"search\":false}"                                                                                                                          ) -}}{{- end -}}
  [{{- $languages.key | join "," -}}]
{{- end -}}

{{- define "assistant.ui.features" -}}
{"credentials": true, "recommendations": false, "export-delete": true, "channels": false, "mirroring": true, "pattern-entities": true, "new-intents": false, "new-entities": true, "hard-logout": false, "search": true, "search-show-more": true, "catalog": true, "beta-access-button": false, "enable-premium-features": true, "search-skill": true, "assistant-skills": true, "react-catalog": true, "react-intent-conflicts": true, "spell-check": false, "skill-settings": false, "integrations": false, "skill-versions": true, "intercom-integration": false, "system-entities-v2": false, "dialog-skill-options": true, "callouts": false, "clusters": false, "react-search": true, "analytics": false, "icp": true, "intent-conflicts": {{.Values.global.recommends.enabled}}, "synonym-recommendations": {{.Values.global.recommends.enabled}}, "wa-home": true, "wa-skills": true, "wa-assistants": true}
{{- end -}}

{{/*****************************************************************************
   * Redis details for UI 
   **************************************************************************/}}

{{- define "assistant.redis.hostname" -}}
{{- if .Values.global.redis.create -}}
{{ .Release.Name }}-redis-master-svc.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}
{{- else -}}
{{ .Values.global.redis.hostname }}
{{- end -}}
{{- end -}}

{{- define "assistant.redis.port" -}}
{{- if .Values.global.redis.create -}}
6379
{{- else -}}
{{ .Values.global.redis.port }}
{{- end -}}
{{- end -}}

{{- define "assistant.redis.user" -}}
{/* It sad, but the username is hardcoded (even for recommends) */}}
admin
{{- end -}}

{{- define "assistant.icp.proxyHostname" -}}
 {{- if .Values.global.icp.proxyHostname }}
   {{- .Values.global.icp.proxyHostname -}}
  {{- else -}}
   {{- .Values.global.icp.masterHostname -}}
  {{- end -}}
{{- end -}}

{{- define "assistant.ingressPath" -}}
  {{-  if .Values.global.ingress.path -}}
    {{- tpl .Values.global.ingress.path . -}}
  {{- else -}}
    /{{ .Release.Name }}/assistant
  {{- end -}}
{{- end -}}


{{- define "assistant.postgres_store.secretName" -}}
  {{- if .Values.global.postgres.store.auth.authSecretName -}}
    {{- .Values.global.postgres.store.auth.authSecretName -}}
  {{- else -}}
    {{ .Release.Name }}-postgres-store-creds
  {{- end -}}
{{- end -}}


{{- define "skillSearch.authorization-encryption.secretName" -}}
  {{- if tpl .Values.global.skillSearch.encryptionKey.existingSecretName . -}}
    {{- tpl .Values.global.skillSearch.encryptionKey.existingSecretName . -}}
  {{- else -}}
    {{ .Release.Name }}-skill-search-authorization-encryption-key
  {{- end -}}
{{- end }}


{{- define "assistant.unsed_template" -}}
# This template is intentianally unsed to get rid of linter errors about unused parameters.
# For each referenced value we explain why it is here

# In cv-test test-defautl we intentionally simulate "provided postgres with pre-created database" scenario, 
#   it means that subchart ibm-watson-assistant-create_slot_store_db is disabled
# This chart reads: {{ .Values.global.postgres.adminDatabase }} and {{ .Values.global.postgres.auth.user }}
#   as it is the only chart that needs to access to the database with higher rights. 
#
# Because linter does not see indirect reads of values
#  {{ .Values.global.mongodb.auth.enabled }} is read by ibm-mongodb suchart as ibm-watson-assistant-datastores-mongodb sub-chart sets value .Values.auth.enabled to "{{ .Values.global.mongodb.auth.enabled }}" and the ibm-mongodb chart renders this value using "ibm-mongodb.boolConvertor" templates.
#  {{ .Values.global.mongodb.tls.enabled }}  is read by ibm-mongodb suchart as ibm-watson-assistant-datastores-mongodb sub-chart sets value .Values.tls.enabled  to "{{ .Values.global.mongodb.tls.enabled }}"  and the ibm-mongodb chart renders this value using "ibm-mongodb.boolConvertor" templates.
# {{ .Values.global.keepDatastores }} is read by all the datastore subcharts and sets value .value.keep to "{{ .Values.global.keepDatastores }}" and the datastore charts render this value using he boolConvertor templates.
# These values are not used in out testing ga realm
# {{ .Values.master.slad.dockerRegistry }}, {{ .Values.master.slad.dockerRegistryPullSecret }} and {{ .Values.master.slad.dockerRegistryNamespace }}
{{- end }}

{{/*****************************************************************************
   * License
   **************************************************************************/}}

{{/*
Display license
*/}}
{{- define "assistant.license" -}}
  {{- $license := .Files.Get "LICENSES/license.txt" -}}
  {{- $msg := "Please read the above license and set license=accept to install the product." -}}
  {{- $border := printf "\n%s\n" (repeat (len $msg ) "=") -}}
  {{- printf "\n%s\n\n\n%s%s%s" $license $border $msg $border -}}
{{- end -}}

{{/*****************************************************************************
   * High Availability 
   **************************************************************************/}}
{{- define "assistant.podAntiAffinity" -}}
  {{- $compName := default "" .compName -}}
  {{- $modelName := default "" .modelName -}}
  {{- if (or (eq .Values.global.podAntiAffinity "Enable") (and (eq .Values.global.deploymentType "Production") (ne .Values.global.podAntiAffinity "Disable"))) -}}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: service
        operator: In
        values:
        - conversation
    {{- if (ne $compName "") }}
      - key: component
        operator: In
        values:
        - {{ $compName }}
    {{- else }}
      - key: model
        operator: In
        values:
        - {{ $modelName }}
    {{- end }}
      - key: slot
        operator: In
        values:
        - {{ .Release.Name }}
    topologyKey: "kubernetes.io/hostname"
  {{- end -}}
{{- end -}}
