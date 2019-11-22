apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: {{ .Release.Namespace }}
  name: "watson-assistant-chart-role-binding-for-namespace-{{ .Release.Namespace }}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ibm-restricted-clusterrole
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:{{ .Release.Namespace }}
