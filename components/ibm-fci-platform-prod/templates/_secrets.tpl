{{- define "fci.password.generator" -}}
  $(< /dev/urandom tr -dc "A-Za-z0-9" | head "-c10"| base64 | tr -d '\n')
{{- end -}}

{{- define "jwt.password.generator" -}}
  $(< /dev/urandom tr -dc "A-Za-z0-9" | head "-c32"| base64 | tr -d '\n')
{{- end -}}

{{- define "jks.password.generator" -}}
  $(printf %s%s%s%s $(< /dev/urandom tr -dc "A-Za-z" | head "-c8") $(< /dev/urandom tr -dc "0-9" | head "-c2") $(< /dev/urandom tr -dc "A-Za-z" | head "-c8") $(< /dev/urandom tr -dc "0-9" | head "-c2") | base64 | tr -d '\n')
{{- end -}}

{{- define "kafka.p12.password.generator" -}}
  $(echo -n "PltAdmin1PltAdmin1" | base64)
{{- end -}}

{{- define "jks.aliasname.generator" -}}
  $(echo -n "fci_kafka_msg_key_label" | base64)
{{- end -}}

{{- define "fci.sch.chart.config.values" -}}
sch:
  chart:
    secretGen:
      suffix: env # I don't like this, but for now to go forward, testing with this.  Need to see if we can set it to null
      overwriteExisting: false
      serviceAccountName: fci-secrets-gen
      secrets:
      - name: {{ .Release.Name }}-db2-secrets
        create: true
        type: generic
        values:
        - name: DB2INST1_PASSWORD
          generator: "fci.password.generator"
      - name: {{ .Release.Name }}-elastic-secrets
        create: true
        type: generic
        values:
        - name: ELASTIC_ADMIN_PASSWORD
          generator: "fci.password.generator"
      - name: {{ .Release.Name }}-wca-secrets
        create: true
        type: generic
        values:
        - name: esadmin_password
          generator: "fci.password.generator"
      - name: {{ .Release.Name }}-mongo-secrets
        create: true
        type: generic
        values:
        - name: mongodb-dsf-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-ees-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-investigation-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-outcome-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-workflow-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-plan-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-article-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-news-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-news-mcd-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-ml-api-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-ml-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-proxy-password
          generator: "fci.password.generator"
        - name: mongodb-eraas-kyc-adapter-password
          generator: "fci.password.generator"
        - name: mongodb-fcai-tls-password
          generator: "fci.password.generator"
        - name: mongodb-fcdd-password
          generator: "fci.password.generator"
        - name: mongodb-iui-password
          generator: "fci.password.generator"
        - name: mongodb-narratives-password
          generator: "fci.password.generator"
        - name: mongodb-password
          generator: "fci.password.generator"
        - name: mongodb-replica-set-key
          generator: "fci.password.generator"
        - name: mongodb-root-password
          generator: "fci.password.generator"
      - name: {{ .Release.Name }}-auth-secrets
        create: true
        type: generic
        values:
        - name: USER_PASSWORD_1
          generator: "fci.password.generator"
        - name: USER_PASSWORD_2
          generator: "fci.password.generator"
        - name: USER_PASSWORD_3
          generator: "fci.password.generator"
        - name: USER_PASSWORD_4
          generator: "fci.password.generator"
        - name: USER_PASSWORD_5
          generator: "fci.password.generator"
        - name: USER_PASSWORD_6
          generator: "fci.password.generator"
        - name: USER_PASSWORD_7
          generator: "fci.password.generator"
        - name: USER_PASSWORD_8
          generator: "fci.password.generator"
        - name: USER_PASSWORD_9
          generator: "fci.password.generator"
        - name: USER_PASSWORD_10
          generator: "fci.password.generator"
        - name: USER_PASSWORD_11
          generator: "fci.password.generator"
        - name: USER_PASSWORD_12
          generator: "fci.password.generator"
        - name: USER_PASSWORD_13
          generator: "fci.password.generator"
        - name: USER_PASSWORD_14
          generator: "fci.password.generator"
        - name: USER_PASSWORD_15
          generator: "fci.password.generator"
        - name: USER_PASSWORD_16
          generator: "fci.password.generator"
        - name: USER_PASSWORD_17
          generator: "fci.password.generator"
        - name: USER_PASSWORD_18
          generator: "fci.password.generator"
        - name: USER_PASSWORD_19
          generator: "fci.password.generator"
        - name: USER_PASSWORD_20
          generator: "fci.password.generator"
        - name: USER_PASSWORD_21
          generator: "fci.password.generator"
        - name: USER_PASSWORD_22
          generator: "fci.password.generator"
        - name: USER_PASSWORD_23
          generator: "fci.password.generator"
        - name: USER_PASSWORD_24
          generator: "fci.password.generator"
        - name: USER_PASSWORD_25
          generator: "fci.password.generator"
      - name: {{ .Release.Name }}-mqm-secrets
        create: true
        type: generic
        values:
        - name: mqm_password
          generator: "fci.password.generator"
      - name: {{ .Release.Name }}-odm-secrets
        create: true
        type: generic
        values:
        - name: odm_eli_password
          generator: "fci.password.generator"
        - name: odm_resadmin_password
          generator: "fci.password.generator"
        - name: odm_resdeploy_password
          generator: "fci.password.generator"
        - name: odm_resmonitor_password
          generator: "fci.password.generator"
        - name: odm_rtsadmin_password
          generator: "fci.password.generator"
        - name: odm_rtsconfig_password
          generator: "fci.password.generator"
        - name: odm_rtsuser1_password
          generator: "fci.password.generator"
        - name: odm_val_password
          generator: "fci.password.generator"
        - name: rms_wasadmin_password
          generator: "fci.password.generator"
      - name: {{ .Release.Name }}-platform-secrets # this will include the suffix in the format of <name>-<suffix>
        create: true
        type: generic
        values:
        - name: FCI_JKS_PASSWORD
          generator: "jks.password.generator"
        - name: FCI_KAFKA_MSG_JKS_ALIASNAME
          generator: "jks.aliasname.generator"
        - name: FCI_KAFKA_MSG_JKS_PASSWORD
          generator: "kafka.p12.password.generator"
        - name: JWT_KEY
          generator: "jwt.password.generator"
        - name: batch_password
          generator: "fci.password.generator"
        - name: com_fci_password
          generator: "fci.password.generator"
        - name: com_spss_password
          generator: "fci.password.generator"
{{- end -}}
