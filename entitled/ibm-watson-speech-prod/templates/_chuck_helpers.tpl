{{- define "chuck.valueOrDefault" -}}
{{- $params := . -}}
{{- $value := (index $params 0) -}}
{{- $default := (index $params 1) -}}
{{- if eq "$value" "" -}}
{{- $default -}}
{{- else -}}
{{- $value -}}
{{- end -}}
{{- end -}}

{{- define "chuck.wait4resourcesHelper" -}}
{{ $params := . }}
{{ $global := (index $params 0) -}}
{{ $models := (index $params 1) -}}
{{ $name := (index $params 2) -}}
- name: {{ $name }}
  securityContext:
    runAsNonRoot: true
    {{- if not ($global.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
    runAsUser: 5001
    {{- end }}
    privileged: false
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
  image: "{{ $global.Values.global.image.repository }}/{{ $global.Values.images.miniomc.image }}:{{ $global.Values.images.miniomc.tag }}"
  resources:
    requests:
      memory: "1024Mi"
      cpu: "1"
    limits:
      memory: "1024Mi"
      cpu: "1"
  command: ['sh', '-c']
  args:
    - echo Waiting for all models being uploaded;
      echo MODEL_VERSION = ${MODEL_VERSION};
      echo MINIO_URL = ${MINIO_URL};
      echo BUCKET = ${BUCKET};
      echo MODELS = ${MODELS};
      ACCESKEY=`cat /etc/chuck/minio/accesskey`;
      SECRETKEY=`cat /etc/chuck/minio/secretkey`;
      MODELS_DIR=${BUCKET}/models;
      CATALOG_DIR=${MODELS_DIR}/${MODEL_VERSION};
      ENDPOINT_ALIAS=minio;
      mc --insecure config host add ${ENDPOINT_ALIAS} ${MINIO_URL} ${ACCESKEY} ${SECRETKEY} --api S3v4;
      until mc --insecure ls ${ENDPOINT_ALIAS}/${CATALOG_DIR}/catalog.json; do sleep 2; done;
      FILES=`mc --insecure cat ${ENDPOINT_ALIAS}/${CATALOG_DIR}/catalog.json | sed -ne "s/^.*\(pool\/.*tar.gz\).*$/\1/p"`;
      for file in ${FILES}; do echo $file; done;
      AMODELS=${MODELS//,/ };
      FILTERED_FILES=;
      for file in $FILES; do
          for model in `echo $MODELS | sed -e "s/,/ /g"`; do
              echo $file | grep "^pool\/${model}.*$";
              if [ $? -eq 0 ]; then FILTERED_FILES="${FILTERED_FILES} $file"; fi;
          done;
      done;
      echo "Mandatory files are - ${FILTERED_FILES}";
      mc --insecure ls ${ENDPOINT_ALIAS}/${MODELS_DIR};
      for file in ${FILTERED_FILES}; do
          until mc --insecure ls ${ENDPOINT_ALIAS}/${MODELS_DIR}/$file; do sleep 2; done;
      done;
      echo All models present;
  env:
  - name: MINIO_URL
    value: {{ include "ibm-watson-speech-prod.object-storage-endpoint" $global }}
  - name: MODEL_VERSION
    value: {{ $global.Values.modelVersion }}
  - name: BUCKET
    value: {{ $global.Values.global.datastores.minio.baseModelsBucket }}
  - name: MODELS
    value: {{ include "chuck.getEnabledModels" (list $models false ) | quote }}
  volumeMounts:
    - mountPath: /etc/chuck/minio
      name: minio-account
      readOnly: true
{{- end -}}

{{- define "chuck.wait4models" -}}
{{- $global := (index . 0) -}}
{{- $models := (index . 1) -}}
{{- include "chuck.wait4resourcesHelper" (list $global $models "wait4models") -}}
{{- end -}}

{{- define "chuck.wait4voices" -}}
{{- $global := (index . 0) -}}
{{- $models := (index . 1) -}}
{{ include "chuck.wait4resourcesHelper" (list $global $models "wait4voices") -}}
{{- end -}}

{{- define "chuck.isModelEnabled" -}}
{{- if (or (not (hasKey . "enabled")) .enabled) -}} true {{- else -}} {{- end -}}
{{- end -}}

{{- define "chuck.isModelEnabledAndNonGeneric" -}}
{{- if and (include "chuck.isModelEnabled" .) (hasKey . "catalogName") -}} true {{- else -}} {{- end -}}
{{- end -}}

{{- define "chuck.joinModels" -}}
  {{ $params := . }}
  {{ $models := index $params 0 }}
  {{ $doQuote := index $params 1 }}
  {{- range $key, $model := $models -}}
    {{/* FIXME: remove empty check when generic-models are out of scope */}}
    {{- if (and (include "chuck.isModelEnabled" $model) (hasKey $model "catalogName")) -}}
      {{- if $doQuote -}}
          {{ $model.catalogName | quote }},
      {{- else -}}
          {{ $model.catalogName }},
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "chuck.getEnabledModels" -}}
  {{ trim (trimSuffix "," (include "chuck.joinModels" . )) }}
{{- end -}}

{{- define "chuck.getResources" -}}
{{/* variable definition */}}
{{- $params := . -}}
{{- $models := index $params 0 -}}
{{- $group := index $params 1 -}}
{{- $resources := index $params 2 -}}
{{- $additionalCPU := mul (default 0.0 $group.resources.additionalCPU) $group.resources.threads -}}
{{/* code */}}
{{- if $group.resources.dynamicMemory -}}
{{- $cpus := $group.resources.requestsCpu -}}
{{- $maxSession := div (mul 1000 $cpus) $resources.sessionMemoryFactor }}
{{- $values := (dict "total" $resources.systemMemory "models" 0) -}}
{{/* calculate total memory requirements */}}
{{- range $key, $data := $models -}}
{{- if include "chuck.isModelEnabled" $data -}}
{{- $_ := set $values "models" (add1 $values.models) -}}
{{- $_ := set $values "total" (add $values.total $data.size) -}}
{{- end -}}
{{- end -}}
{{- $_ := set $values "total" (add $values.total (mul $maxSession $resources.sessionMemory)) -}}
{{/* render requirements */}}
requests:
  memory: {{ $values.total -}} Mi
  cpu: {{ add (mul $cpus 1000) $additionalCPU -}} m
limits:
  memory: {{ add $values.total (mul $resources.sessionMemory $resources.limitCPUs) -}} Mi
  cpu: {{ add (mul (add $cpus $resources.limitCPUs) 1000) $additionalCPU -}} m
{{- else }}
requests:
  memory: {{ $group.resources.requestsMemory -}} Mi
  cpu: {{ add (mul $group.resources.requestsCpu 1000) $additionalCPU -}} m
limits:
  memory: {{ add $group.resources.requestsMemory ( div $group.resources.requestsMemory 4 ) -}} Mi
  cpu: {{ add (mul (add $group.resources.requestsCpu ( div $group.resources.requestsCpu 4 )) 1000) $additionalCPU -}} m
{{- end -}}
{{- end -}}

{{- define "chuck.catalogNameToImageName" -}}
{{- $params := . -}}
{{- $catalogName := (index $params 0) -}}
{{- $default := (index $params 1) -}}
{{- if (empty $catalogName) -}}
{{- $default -}}
{{- else -}}
{{ $catalogName | lower | replace "_" "-" }}
{{- end -}}
{{- end -}}

{{- define "chuck.containerSecurityContext" -}}
{{- $params := . -}}
{{- $global := (index $params 0) -}}
{{- $user := (index $params 1) -}}
securityContext:
  privileged: false
  readOnlyRootFilesystem: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  {{- if not ($global.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
  runAsUser: {{ $user }}
  {{- end }}
  capabilities:
    drop:
    - ALL
{{- end }}

{{- define "chuck.defineSSLCertificateVolume" }}
{{- $params := . -}}
{{- $global := (index $params 0) -}}
{{- $volumeName := (index $params 1) -}}
{{- if empty $global.Values.global.runtimeSSLCertificate -}}
- name: {{ $volumeName }}
  secret: {
    secretName: {{ $global.Release.Name }}-speech-runtime-ssl-cert
  }
{{- else -}}
- name: {{ $volumeName }}
  secret: {
    secretName: {{ $global.Values.global.runtimeSSLCertificate }}
  }
{{- end -}}
{{- end }}
