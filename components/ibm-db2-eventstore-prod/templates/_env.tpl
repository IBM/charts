{{- define "eventstore.environment-variables" }}
- name: USER_HOME_ID
  value: "{{ .Values.dsx.userHomePVC.userId }}"
- name: RELEASE_NAMESPACE
  value: "{{ .Release.Namespace }}"
- name: NAMESPACE
  value: "{{ .Release.Namespace }}"
- name: SERVICENAME
  value: "{{ .Values.servicename }}"
- name: RUNTIME_CONTEXT
  value: "{{ .Values.runtime }}"
- name: MEMBER_COUNT
  value: "{{ .Values.deployment.members }}"
- name: HOSTNETWORK
  value: "{{ .Values.engine.hostNetwork }}"
- name: NODE_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
{{- end }}
