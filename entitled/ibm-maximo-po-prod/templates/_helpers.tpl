{{- define "tenant.service.name" -}}
{{ include "sch.names.fullCompName" (list . .sch.chart.components.tenantapi.name) }}
{{- end -}}

{{- define "graphmgmt.service.url" -}}
http://{{ include "sch.names.fullCompName" (list . .sch.chart.components.graphmgmt.name) }}:9080/graphdbmanagement
{{- end -}}

{{- define "up.service.url" -}}
http://{{ include "sch.names.fullCompName" (list . .sch.chart.components.up.name) }}:9080/solutiondataservice
{{- end -}}

{{- define "smm.service.url" -}}
http://{{ include "sch.names.fullCompName" (list . .sch.chart.components.smm.name) }}:9080/smm
{{- end -}}

{{- define "ts.service.url" -}}
http://{{ include "sch.names.fullCompName" (list . .sch.chart.components.ts.name) }}:9080/ts
{{- end -}}

{{- define "as.service.url" -}}
http://{{ include "sch.names.fullCompName" (list . .sch.chart.components.as.name) }}:9080/alertservice
{{- end -}}

{{- define "analyticsservice.service.url" -}}
http://{{ include "sch.names.fullCompName" (list . .sch.chart.components.analyticsservice.name) }}:9080/analytics
{{- end -}}

{{- define "analyticsservice.ootbmodel.dic" -}}
/opt/poresource
{{- end -}}

{{- define "po.image.pull.secret"}}
{{- if .Values.global.imageSecretName }}
imagePullSecrets:
  - name: {{ .Values.global.imageSecretName }}
{{- end }}
{{- end -}}

{{- define "po.securitycontext.couchdb.pod" }}
hostPID: false
hostIPC: false
hostNetwork: false
securityContext:
  runAsUser: 5984
  fsGroup: 5984
{{- end -}}

{{- define "po.securitycontext.couchdb.container" }}
securityContext:
  capabilities:
    drop:
    - all
    add: []
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  privileged: false
{{- end -}}


{{- define "po.securitycontext.dashboard.pod" }}
hostPID: false
hostIPC: false
hostNetwork: false
securityContext:
  runAsUser: 999
  fsGroup: 999
{{- end -}}

{{- define "po.securitycontext.pod" }}
hostPID: false
hostIPC: false
hostNetwork: false
securityContext:
  runAsUser: 1001
  fsGroup: 1001
{{- end -}}

{{- define "po.securitycontext.container" }}
securityContext:
  capabilities:
    drop:
    - all
    add: []
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  privileged: false
{{- end -}}

{{- define "po.secret.name" -}}
{{- if .Values.global.secretGen.autoSecret -}}
{{- $compName :=  .sch.chart.components.autogen.secName -}}
{{ include "sch.names.fullCompName" (list . $compName) }}
{{- else -}}
{{ .Values.global.secretGen.existingSecret }}
{{- end -}}
{{- end -}}

{{- define "ingress.cert.name" -}}
{{- if .Values.global.secretGen.autoCert -}}
{{- $compName :=  .sch.chart.components.autogen.cerName -}}
{{ include "sch.names.fullCompName" (list . $compName) }}
{{- else -}}
{{ .Values.global.secretGen.existingCert }}
{{- end -}}
{{- end -}}

{{- define "po.containers.env" -}}
env:
  - name: GDBM_URL
    value: {{ template "graphmgmt.service.url" . }}
  - name: SDS_URL
    value: {{ template "up.service.url" . }}
  - name: SMM_URL
    value: {{ template "smm.service.url" .  }}
  - name: TS_URL
    value: {{ template "ts.service.url" .  }}
  - name: AS_URL
    value: {{ template "as.service.url" . }}
  - name: AP_URL
    value: {{ template "analyticsservice.service.url" . }}
  - name: PO_RESOURCE_PATH
    value: {{ template "analyticsservice.ootbmodel.dic" . }}
  - name: PO_CONFIG_FILE
    value: "/po-config/po_config.json"
  - name: CONFIG_FILE_PATH
    value: "/po-config/reporting_dashboard_config.json"
  - name: PO_IS_SAAS #Use this flag to check whether it's on SaaS or not, don't use PO_ONPREM
    value: "false"
  - name: External_URL_Callback
    value: "https://{{ .Values.ingress.hostname }}"
  - name: DISABLE_AUTH
    value: {{ .Values.dashboard.authdisabled | quote }}
  - name: PO_ONPREM #It's not the real on preme flag, just for skipping APIKey authentication and get couchdb/jg from po_config.json instead of tenant management
    value: "false"
  - name: ENABLE_NPS
    value: "no"
{{- end -}}

{{- define "po.config.volume" -}}
- name: secret-volume
  secret:
    secretName: {{ template "po.secret.name" . }}
    defaultMode: 0666
- name: cert-volume
  secret:
    secretName: {{ template "couchdb.cert.name" . }}
- name: po-config-vol
  emptyDir: {}
- name: for-tenantapi-only
  emptyDir: {}
- name: tmpdir
  emptyDir: {}
- name: defaulttruststore
  emptyDir: {}
- name: jvm-option-vol
  configMap:
    name: {{ include "sch.names.fullCompName" (list . .sch.chart.components.jvmoptcfg.name) }}
    items:
    - key: file-from-cfgmap
      path: jvm.options
- name: po-pvc
  persistentVolumeClaim:
     claimName: {{ .Release.Name }}-popvc
{{- end -}}

{{- define "po.config.volumeMount" -}}
- name: po-config-vol
  mountPath: /po-config
- mountPath: /po-secret
  name: secret-volume
  readOnly: true
{{- end -}}

{{- define "po.ssl.volumeMount" -}}
- mountPath: /opt/ibm/wlp/usr/servers/defaultServer/configDropins/overrides
  name: jvm-option-vol
- name: po-pvc
  mountPath: /tmp
- mountPath: /opt/ibm/wlp/usr/servers/defaultServer/resources/security
  name: defaulttruststore
- mountPath: /po-cert
  name: cert-volume
{{- end -}}

{{- define "po.prepare.truststore" -}}
- name: "prepare-couchdb-truststore"
  image: "websphere-liberty:webProfile7"
  imagePullPolicy: "IfNotPresent"
  volumeMounts:
{{ include "po.ssl.volumeMount" . | indent 2 }}
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  command: ["sh", "-c", "keytool -importcert -trustcacerts -alias truststore4CouchdbCert -storepass passw0rd -keystore /tmp/truststore.jks  -file /po-cert/tls.crt -storetype jks -noprompt -v;keytool -importcert -trustcacerts -alias truststore4CouchdbCert -storepass passw0rd -keystore /opt/ibm/wlp/usr/servers/defaultServer/resources/security/trust.jks  -file /po-cert/tls.crt -storetype jks -noprompt -v;keytool -importcert -trustcacerts -alias truststore4CouchdbCert -storepass passw0rd -keystore /opt/ibm/wlp/usr/servers/defaultServer/resources/security/key.jks  -file /po-cert/tls.crt -storetype jks -noprompt -v"]
{{- end -}}

{{- define "po.config.initContainer" -}}
- name: "po-prepare-config"
  image: "{{ .Values.global.supportT.image.repository }}:{{.Values.global.supportT.image.tag  }}"
  imagePullPolicy: "IfNotPresent"
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  env:
    - name: CLUSTER_CA_DOMAIN
      value: {{ .Values.global.clusterCADomain }}
  volumeMounts:
{{ include "po.config.volumeMount" . | indent 2 }}
  command:
  - "/bin/bash"
  - -c
  - |
{{ tpl (.Files.Get "data/generate_poconfig.sh") . | indent 4 }}
{{- end -}}

{{- define "po.readiness.waitForCouchdb" -}}
- name: "wait-for-couchdb"
  image: "{{ .Values.global.supportT.image.repository }}:{{.Values.global.supportT.image.tag  }}"
  imagePullPolicy: "IfNotPresent"
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  env:
    - name: COUCHDB_USER
      valueFrom:
        secretKeyRef:
          name: {{ template "couchdb.secret.name" . }}
          key: couchdbAdminUsername
    - name: COUCHDB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ template "couchdb.secret.name" . }}
          key: couchdbAdminPassword
  command: ["sh", "-c", "date; echo 'Checking the status of Couchdb now....';while true; do echo 'checking Couchdb readiness'; wget -T 5 --spider http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@{{ include "couchdb.fullname" . }}/; if [ $? -eq 0 ]; then echo 'Success: CounchDB is ready'; break; fi; echo '...not ready yet; sleeping 3 seconds before retry'; sleep 3; done; date;"]
{{- end -}}

{{- define "po.readiness.waitForCouchdb_systemdb" -}}
- name: "wait-for-couchdb"
  image: "{{ .Values.global.supportT.image.repository }}:{{.Values.global.supportT.image.tag  }}"
  imagePullPolicy: "IfNotPresent"
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  env:
    - name: COUCHDB_USER
      valueFrom:
        secretKeyRef:
          name: {{ template "couchdb.secret.name" . }}
          key: couchdbAdminUsername
    - name: COUCHDB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ template "couchdb.secret.name" . }}
          key: couchdbAdminPassword
  command: ["sh", "-c", "date; echo 'Checking the status of _users database now....';while true; do echo 'checking _users database readiness'; wget -T 5 --spider http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@{{ include "couchdb.fullname" . }}/_users; if [ $? -eq 0 ]; then echo 'Success: _user database is ready'; break; fi; echo '... _user database not ready yet; sleeping 3 seconds before retry'; sleep 3; done; date;"]
{{- end -}}

{{- define "po.readiness.waitForCouchdb_tenant" -}}
- name: "wait-for-couchdb-tenant"
  image: "{{ .Values.global.supportT.image.repository }}:{{.Values.global.supportT.image.tag  }}"
  imagePullPolicy: "IfNotPresent"
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  env:
    - name: COUCHDB_USER
      valueFrom:
        secretKeyRef:
          name: {{ template "couchdb.secret.name" . }}
          key: couchdbAdminUsername
    - name: COUCHDB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ template "couchdb.secret.name" . }}
          key: couchdbAdminPassword
  command: ["sh", "-c", "date; echo 'Checking the status of po_tenant database now....';while true; do echo 'checking  po_tenant database readiness'; wget -T 5 --spider http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@{{ include "couchdb.fullname" . }}/po_tenant; if [ $? -eq 0 ]; then echo 'Success: po_tenant database is ready'; break; fi; echo '...po_tenant database not ready yet; sleeping 3 seconds before retry'; sleep 3; done; date;"]
{{- end -}}

{{- define "po.readiness.waitForCouchdb_bs" -}}
- name: "wait-for-couchdb-bs"
  image: "{{ .Values.global.supportT.image.repository }}:{{.Values.global.supportT.image.tag  }}"
  imagePullPolicy: "IfNotPresent"
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  env:
    - name: COUCHDB_USER
      valueFrom:
        secretKeyRef:
          name: {{ template "couchdb.secret.name" . }}
          key: couchdbAdminUsername
    - name: COUCHDB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ template "couchdb.secret.name" . }}
          key: couchdbAdminPassword
  command: ["sh", "-c", "date; echo 'Checking the status of po_backschedservice_storage database now....';while true; do echo 'checking  po_backschedservice_storage database readiness'; wget -T 5 --spider http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@{{ include "couchdb.fullname" . }}/po_backschedservice_storage; if [ $? -eq 0 ]; then echo 'Success: po_backschedservice_storage database is ready'; break; fi; echo '...po_backschedservice_storage database not ready yet; sleeping 3 seconds before retry'; sleep 3; done; date;"]
{{- end -}}


{{- define "po.readiness.waitForJanusgraph" -}}
- name: "wait-for-janusgraph"
  image: "{{ .Values.global.supportT.image.repository }}:{{.Values.global.supportT.image.tag  }}"
  imagePullPolicy: "Always"
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  env:
  - name: "READINESS_URL"
    value: {{ include "janusgraph.fullname" . }}
  command: ["sh", "-c", "date; until nslookup $READINESS_URL; do echo waiting for Janusgraph; sleep 3; done; date; echo 'Success: Janusgraph is ready!';"]
{{- end -}}


{{- define "po.readiness.waitForTenantManagement" -}}
- name: "wait-for-tenantapi"
  image: "{{ .Values.global.supportT.image.repository }}:{{.Values.global.supportT.image.tag  }}"
  imagePullPolicy: "IfNotPresent"
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  env:
  - name: "READINESS_URL"
    value: http://{{- template "tenant.service.name" . -}}:9080
  command: ["sh", "-c", "date; while true; do echo 'checking tenant api readiness'; wget -T 5 --spider $READINESS_URL; result=$?; if [ $result -eq 0 ]; then echo 'Success: tenant api is ready!'; break; fi; echo '...not ready yet; sleeping 3 seconds before retry'; sleep 3; done; date;"]
{{- end -}}

{{- define "po.readiness.waitForGraphManagement" -}}
- name: "wait-for-graphmanagement"
  image: "{{ .Values.global.supportT.image.repository }}:{{.Values.global.supportT.image.tag  }}"
  imagePullPolicy: "IfNotPresent"
  resources:
    requests:
      cpu: 50m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 500Mi
  env:
  - name: "READINESS_URL"
    value: http://{{ include "sch.names.fullCompName" (list . .sch.chart.components.graphmgmt.name) }}:9080
  command: ["sh", "-c", "date; while true; do echo 'checking graphmgmt api readiness'; wget -T 5 --spider $READINESS_URL; result=$?; if [ $result -eq 0 ]; then echo 'Success: graphmgmt api is ready!'; break; fi; echo '...not ready yet; sleeping 3 seconds before retry'; sleep 3; done; date;"]
{{- end -}}