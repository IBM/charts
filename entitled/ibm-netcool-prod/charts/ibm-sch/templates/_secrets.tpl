{{- /*
secret helpers for SCH (Shared Configurable Helpers)

sch/_secrets.tpl contains shared configurable helper templates for 
generating and deleting secrets.

Usage of "sch.secretGen.*" requires the following:

1. This line must be included at the begining of the template:
   {{- include "sch.config.init" (list . "sch.chart.config.values") -}}

1. The ibm-sch subchart must be aliased as `sch` in requirements.yaml:

   ```
   dependencies:
     - name: ibm-sch
       repository: "@sch"
       version: "^1.2.10"
       alias: sch
   ```

1. The container image used by the secret generator must be added to ibm_cloud_pak/manifest.yaml:

   ```
   - image: opencontent-common-utils:1.1.2
     references:
     - repository: opencontent-common-utils:1.1.2
       pull-repository: ibmcom/opencontent-common-utils:1.1.2
   ```

1. PodSecurityPolicy Requirements

  This chart requires a PodSecurityPolicy to be bound to the target namespace prior
  to installation. To meet this requirement, there may be cluster-scoped as well as
  namespace-scoped actions that you must do before and after installation.

  The predefined PodSecurityPolicy name ibm-restricted-psp has been verified for
  this chart. If your target namespace is bound to this PodSecurityPolicy, you
  can proceed to install the chart.

1. Role-Based Access Control settings

  The following RBAC resources are required for the secret generation code to create
  and delete secrets. The ibm_cloud_pak/pak_extensions/pre-install/namespace-administration/setupNamespace.sh
  script has been provided to assist with the creation of these resources.

  To ease integration, the service account name can be specified in
  _sch-chart-config.yaml which allows for the role to be merged with an existing
  role that is bound to a chart's existing service account rather than needing to
  create all of these resources separately.

  1. ServiceAccount:

    ```
    apiVersion: v1
    kind: ServiceAccount
    metadata:
        name: ibm-sch-secret-gen
        namespace: "{{ NAMESPACE }}" #Replace {{ NAMESPACE }} with the namespace you are deploying to
    ```

  1. Role:

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

  1. RoleBinding:

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

********************************************************************
*** This file is shared across multiple charts, and changes must be 
*** made in centralized and controlled process. 
*** Do NOT modify this file with chart specific changes.
*****************************************************************
*/ -}}

{{- /*
`"sch.secretGen.job.create"` generates a Kubernetes Job resource to create one
or more secrets.

Supported secret types:
- generic
- tls

Specify a list of secrets to be generated in the `sch.chart.secretGen` parameter
in your _sch-chart-config.tpl. The yaml file containing the job will contain an
import request to `sch.config.init` and an import request to `sch.secretGen.job.create`.

The TLS secret generated is a self-signed CA certificate.

In the event that a generic secret needs to generated in a different manner, the
function used to generate the secret can be overridden. See the second example
below for more information.

Notes:

- The cn parameter for a TLS secret has been deprecated. Specifying domains should be
done with the sans (Subject Alternate Name) parameter. 
- If the sans parameter is specified, then the cn parameter will be ignored.
- The first entry in the sans array will be set to the CN parameter in the subject if
it is 64 characters or smaller in length.

__Values Used__
- None

__Config Values Used:__
- `sch.chart.secretGen`

__Parameters input as an list of values:__
- the root context (required)

__Usage:__
Example 1: Create a generic secret and a secret containing a self-signed CA certificate. Use the chart service account vs. the default
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
        cn: mysql.myhost.com  # cn is deprecated. Use sans.
        sans:
        - mysql.myhost.com
        - redis.myhost.com
{{- end -}}
```
used in template as follows:
```
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
{{- include "sch.secretGen.job.create" . -}}
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
*/ -}}

{{- define "sch.secretGen.job.create" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- /* $root.Values.sch refers to the alias name of ibm-sch set in requirements.yaml and points to the values in the ibm-sch values.yaml */ -}}
{{- if and $root.Values.sch $root.sch.chart.secretGen (gt (len $root.sch.chart.secretGen.secrets) 0) -}}
  {{- $secretGenRoot := omit $root "Values" -}}
  {{- $extraLabels := dict "role" "create" -}}
  {{- $_ := set $secretGenRoot "Values" $root.Values.sch -}}
  {{- $_ := set $secretGenRoot.Values "nameOverride" "secret-gen" -}}
  {{- $suffix := (include "sch.utils.getItem" (list $params 1 $root.sch.chart.secretGen.suffix)) -}}
  {{- $serviceAccountName := $root.sch.chart.secretGen.serviceAccountName | default $secretGenRoot.Values.rbac.serviceAccountName }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "sch.names.fullCompName" (list $secretGenRoot (printf "%s-%s" "create" $suffix)) | quote }}
  labels:
{{  include "sch.metadata.labels.standard" (list $secretGenRoot $suffix $extraLabels) | indent 4 }}
  annotations:
    "helm.sh/hook": "pre-install"
    "helm.sh/hook-weight": {{ $secretGenRoot.Values.jobPreinstallWeight | quote }}
    "helm.sh/hook-delete-policy": {{ $secretGenRoot.Values.jobPreinstallDeletePolicy }}
spec:
  backoffLimit: 0
  template:
    metadata:
      name: {{ include "sch.names.fullCompName" (list $secretGenRoot (printf "%s-%s" "create" $suffix)) | quote }}
      labels:
{{  include "sch.metadata.labels.standard" (list $secretGenRoot $suffix $extraLabels) | indent 8 }}
    spec:
      affinity:
{{- include "sch.affinity.nodeAffinity" (list $secretGenRoot) | indent 8 }}
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 8000
      restartPolicy: Never
      serviceAccountName: {{ $serviceAccountName }}
      {{- if $secretGenRoot.Values.image.pullSecret }}
      imagePullSecrets:
      - name: {{ $secretGenRoot.Values.image.pullSecret }}
      {{- end }}
      volumes:
      - name: tls-out
        emptyDir: {}
      containers:
      - name: secret-config
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 8000
          capabilities:
            drop:
            - ALL
        resources:
          requests:
            memory: 100Mi
            cpu: '.2'
          limits:
            memory: 200Mi
            cpu: '.5'
        image: "{{ if $secretGenRoot.Values.global.image.repository }}{{ trimSuffix "/" $secretGenRoot.Values.global.image.repository }}/{{ end }}{{ $secretGenRoot.Values.image.name }}:{{ $secretGenRoot.Values.image.tag }}"
        imagePullPolicy: {{ $secretGenRoot.Values.image.pullPolicy }}
        volumeMounts:
        - name: tls-out
          mountPath: /tmp/secretGen/tls
        command:
        - /bin/bash
        - -c
        - |
            set -e
{{- $labels := (include "sch.metadata.labels.standard" (list $secretGenRoot $suffix)) -}}
{{- $overwriteExisting := $root.sch.chart.secretGen.overwriteExisting | default false }}
{{ range $secret := $root.sch.chart.secretGen.secrets }}
{{- $secretFunction := (list "secretGen.secrets.spec" $secret.type) | join "." -}}
{{- $oldName := $secret.name -}}
{{- $_ := set $secret "name" (list $secret.name $suffix | join "-") -}}
{{ include $secretFunction  (list $secret $labels $overwriteExisting) | indent 12 }}
{{- $_ := set $secret "name" $oldName }}
{{ end }}
{{- end -}}
{{- end -}}

{{- /*
`"sch.secretGen.job.delete"` generates a Kubernetes Job resource to delete one
or more secrets when your Helm chart is deleted.

Specify a list of secrets to be deleted with the `sch.chart.secretGen` parameter
in your _sch-chart-config.tpl. This should match the secrets that you created with
`sch.secretGen.job.create`.The yaml file containing the job will contain an import
request to `sch.config.init` and an import request to `sch.secretGen.job.create`.

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
        cn: mysql.myhost.com  # cn is deprecated. Use sans.
        sans:
        - mysql.myhost.com
        - redis.myhost.com
{{- end -}}
```
used in template as follows:
```
{{- include "sch.config.init" (list . "sch.chart.config.values") -}}
{{- include "sch.secretGen.job.delete" . -}}
```
*/ -}}
{{- define "sch.secretGen.job.delete" -}}
{{- $params := . -}}
{{- $root := first $params -}}
{{- /* $root.Values.sch refers to the alias name of ibm-sch set in requirements.yaml and points to the values in the ibm-sch values.yaml */ -}}
{{- if and $root.Values.sch $root.sch.chart.secretGen (gt (len $root.sch.chart.secretGen.secrets) 0) -}}
  {{- $secretGenRoot := omit $root "Values" -}}
  {{- $extraLabels := dict "role" "delete" -}}
  {{- $_ := set $secretGenRoot "Values" $root.Values.sch -}}
  {{- $_ := set $secretGenRoot.Values "nameOverride" "secret-gen" -}}
  {{- $suffix := (include "sch.utils.getItem" (list $params 1 $root.sch.chart.secretGen.suffix)) -}}
  {{- $serviceAccountName := $root.sch.chart.secretGen.serviceAccountName | default $secretGenRoot.Values.rbac.serviceAccountName }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "sch.names.fullCompName" (list $secretGenRoot (printf "%s-%s" $suffix "delete")) | quote }}
  labels:
{{  include "sch.metadata.labels.standard" (list $secretGenRoot $suffix $extraLabels) | indent 4 }}
  annotations:
    "helm.sh/hook": "post-delete"
    "helm.sh/hook-weight": {{ $secretGenRoot.Values.jobPostDeleteWeight | quote }}
    "helm.sh/hook-delete-policy": {{ $secretGenRoot.Values.jobPostdeleteDeletePolicy }}
spec:
  backoffLimit: 0
  template:
    metadata:
      name: {{ include "sch.names.fullCompName" (list $secretGenRoot (printf "%s-%s" $suffix "delete")) | quote }}
      labels:
{{  include "sch.metadata.labels.standard" (list $secretGenRoot $suffix $extraLabels) | indent 8 }}
    spec:
      affinity:
{{- include "sch.affinity.nodeAffinity" (list $secretGenRoot) | indent 8 }}
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 8000
      restartPolicy: Never
      serviceAccountName: {{ $serviceAccountName }}
      {{- if $secretGenRoot.Values.image.pullSecret }}
      imagePullSecrets:
      - name: {{ $secretGenRoot.Values.image.pullSecret }}
      {{- end }}
      containers:
      - name: secret-config
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 8000
          capabilities:
            drop:
            - ALL
        resources:
          requests:
            memory: 100Mi
            cpu: '.2'
          limits:
            memory: 200Mi
            cpu: '.5'
        image: "{{ if $secretGenRoot.Values.global.image.repository }}{{ trimSuffix "/" $secretGenRoot.Values.global.image.repository }}/{{ end }}{{ $secretGenRoot.Values.image.name }}:{{ $secretGenRoot.Values.image.tag }}"
        imagePullPolicy: {{ $secretGenRoot.Values.image.pullPolicy }}
        command:
        - /bin/bash
        - -c
        - |
{{- range $secret := $root.sch.chart.secretGen.secrets }}
{{- /* TODO: There has to be a function where I dont have to do this. */ -}}
{{- $oldName := $secret.name -}}
{{- $_ := set $secret "name" (list $secret.name $suffix | join "-") }}
          kubectl delete secret {{ $secret.name }}
{{- $_ := set $secret "name" $oldName -}}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "secretGen.secrets.generator.generic" -}}
  $(openssl rand -base64 {{ .length }} | tr -d '\n' | base64 | tr -d '\n')
{{- end -}}

{{- define "secretGen.secrets.spec.generic" }}
{{- $params := . -}}
{{- $secret := first $params -}}
{{- $labels := index $params 1 -}}
{{- $overwriteExisting := index $params 2 -}}
{{- if eq $overwriteExisting true }}
cat <<EOF | kubectl apply -f -
{{- else }}
cat <<EOF | kubectl create -f -
{{- end }}
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  labels:
{{ $labels | indent 4 }}
  name: {{ $secret.name }}
data:
{{- range $field := $secret.values }}
  {{ $field.name }}: {{ include (coalesce $field.generator "secretGen.secrets.generator.generic") . }}
{{- end }}
EOF
{{- end }}

{{- define "secretGen.secrets.spec.tls" }}
{{- $params := . -}}
{{- $secret := first $params -}}
{{- $labels := index $params 1 -}}
{{- $overwriteExisting := index $params 2 -}}
{{- $tlsOutPath := (list "/tmp/secretGen/tls" $secret.name ) | join "/" -}}
{{- /* If a list of subject alt names have been specified, build the openssl request using them */}}
{{- if and (hasKey $secret "sans") (eq (typeOf $secret.sans) "[]interface {}") }}
  {{- if (gt (len $secret.sans) 0) -}}
    {{- $cmd := printf "openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -reqexts v3_req -extensions v3_ca -keyout %s.key -out %s.crt" $tlsOutPath $tlsOutPath -}}
    {{- $sansJoin := join ",DNS:" $secret.sans }}
    {{- $sans := printf "-addext subjectAltName=DNS:%s" $sansJoin }}
    {{- if lt (len (index $secret.sans 0)) 65 -}}
{{- printf "%s %s -subj \"/O=IBM/C=US/ST=MN/CN=%s\"" $cmd $sans (index $secret.sans 0) }}
    {{- else }}
{{- printf "%s %s -subj \"/O=IBM/C=US/ST=MN\"" $cmd $sans }}
    {{- end }}
  {{- end }}
{{- /* If a list of subject alt names have not been specified, try to build the openssl request using the deprecated cn */}}
{{- else if hasKey $secret "cn" }}
  {{- $cmd := printf "openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -reqexts v3_req -extensions v3_ca -addext subjectAltName=DNS:%s -keyout %s.key -out %s.crt" $secret.cn $tlsOutPath $tlsOutPath }}
  {{- if gt (len $secret.cn) 64 }}
{{- printf "%s -subj \"/O=IBM/C=US/ST=MN\"" $cmd }}
  {{- else }}
{{- printf "%s -subj \"/O=IBM/C=US/ST=MN/CN=%s\"" $cmd $secret.cn -}}
  {{- end }}
{{- else }}
{{- /* Neither cn nor sans was specified. Fail the request. */}}
{{- fail (printf "No cn or sans property specified for secret %s" $secret.name) }}
{{- end }}
{{ if eq $overwriteExisting true }}
cat <<EOF | kubectl apply -f -
{{- else }}
cat <<EOF | kubectl create -f -
{{- end }}
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
metadata:
  name: {{ $secret.name }}
  labels:
{{ $labels | indent 4 }}
data:
  tls.crt: $(cat {{ $tlsOutPath }}.crt | base64 | tr -d '\n')
  tls.key: $(cat {{ $tlsOutPath }}.key | base64 | tr -d '\n')
EOF
{{- end }}

