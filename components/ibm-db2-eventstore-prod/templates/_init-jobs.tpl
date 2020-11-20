
{{- define "eventstore.set-kernelParams" }}
- name: init-db2
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  args: ["-cx", "/eventstore/tools/hooks/pre-install/set_kernel_params.sh"]
  volumeMounts:
  - mountPath: /host/proc
    name: proc
    readOnly: false
  - mountPath: /host/proc/sys
    name: sys
    readOnly: false
  {{- include "eventstore.securityContextEngine.InitDb2" . | indent 2 }}
{{- end }}

{{- define "eventstore.wait-db2nodes-cfg" }}
- name: init-db2-node-cfg
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  args: ["-cx", "kubectl wait --timeout=60m --for=condition=complete job/{{ .Values.servicename }}-db2nodes-cfg-job"]
  {{- include "eventstore.securityContext" . | indent 2 }}
{{- end }}

{{- define "eventstore.wait-zookeeper" }}
- name: init-zkservice
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  # We need a minimum of (1/2 * num zookeeper) + 1 nodes in order to run.
  args: ["-cx", "until [ $(kubectl get pod -n {{ .Release.Namespace }} | grep {{ .Values.servicename }}-tenant-zk | grep 1/1 | wc -l) -ge 2 ];   do echo Waiting for Zookeeper StatefulSet; sleep 2; done;"]
  {{- include "eventstore.securityContext" . | indent 2 }}
{{- end }}

{{- define "eventstore.wait-db2-registry" }}
- name: init-db2-registry
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  args: ["-cx", "kubectl wait --timeout=60m --for=condition=complete job/{{ .Values.servicename }}-registry-job"]
  {{- include "eventstore.securityContext" . | indent 2 }}
{{- end }}

{{- define "eventstore.wait-engine" }}
- name: init-engine
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  args: ["-cx", "until [ $(kubectl get pod -n {{ .Release.Namespace }} | grep -E '{{ .Values.servicename }}-tenant-engine|{{ .Values.servicename }}-tenant-catalog' | grep 1/1 | wc -l) -eq $(({{ .Values.deployment.members }} + {{ .Values.catalog.replicas }})) ]; do echo Waiting for eventstore engine and catalog pods; sleep 2; done;"]
  {{- include "eventstore.securityContext" . | indent 2 }}
{{- end }}

{{- define "eventstore.wait-engine-scheduled" }}
- name: init-engine-scheduled
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  args: ["-cx", "until [ $(kubectl get pod --field-selector status.podIP!='' -n {{ .Release.Namespace }} | grep -E '{{ .Values.servicename }}-tenant-engine|{{ .Values.servicename }}-tenant-catalog' | wc -l) -eq $(({{ .Values.deployment.members }} + {{ .Values.catalog.replicas }})) ]; do echo Waiting for eventstore engine and catalog pods are scheduled; sleep 2; done;"]
  {{- include "eventstore.securityContext" . | indent 2 }}
{{- end }}

{{- define "eventstore.wait-sqllib-shared" }}
- name: init-sqllib-shared
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  args: ["-cx", "kubectl wait --timeout=60m --for=condition=complete job/{{ .Values.servicename }}-sqllib-shared-job"]
  {{- include "eventstore.securityContext" . | indent 2 }}
{{- end }}

{{- define "eventstore.wait-catalog" }}
- name: init-catalog
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  args: ["-cx", "until [ $(kubectl get pod -n {{ .Release.Namespace }} | grep {{ .Values.servicename }}-tenant-catalog | grep 1/1 | wc -l) -eq   {{ .Values.catalog.replicas }} ]; do echo Waiting for Catalog Deployment; sleep 2; done;"]
  {{- include "eventstore.securityContext" . | indent 2 }}
{{- end }}

{{- define "eventstore.wait-dts" }}
- name: init-dts
  {{- if .Values.eventstoreTools.image.tag }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.eventstoreTools.image.tag }}
  {{- else }}
  image: {{ .Values.eventstoreTools.image.repository }}:{{ .Values.image.universalTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  command: ['/bin/sh']
  args: ["-cx", "until [ $(kubectl get pod -n {{ .Release.Namespace }} | grep {{ .Values.servicename }}-dts | grep 1/1 | wc -l) -eq 1 ]; do echo Waiting for DTS Deployment; sleep 2; done;"]
  {{- include "eventstore.securityContext" . | indent 2 }}
{{- end }}
