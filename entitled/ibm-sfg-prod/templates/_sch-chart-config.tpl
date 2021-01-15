# (C) Copyright 2019-2020 Syncsort Incorporated. All rights reserved.

{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "b2bi.sch.chart.config.values" -}}
sch:
  chart:
    appName: "sfg"
    components:
      asiServer:
        name: "asi-server"
      acServer:
        name: "ac-server"
      apiServer:
        name: "api-server"
      asiService:
        name: "asi-svc"
      acService:
        name: "ac-svc"
      apiService:
        name: "api-svc"
      asiFrontendService:
        name: "asi-frontend-svc"
      acFrontendService:
        name: "ac-frontend-svc"
      asiBackendService:
        name: "asi-backend-svc"
      acBackendService:
        name: "ac-backend-svc"
      apiFrontendService:
        name: "api-frontend-svc"
      headlessService:
        name: "cluster-svc"
      configmap:
        name: "config"
      propertyConfigmap:
        name: "config-property"		
      dummyPropertyConfigmap:
        name: "config-dummy-property"
      passphraseSecret:
        name: "passphrase-secret"
      dbSecret:
        name: "db-secret"
      jmsSecret:
        name: "jms-secret"
      libertySecret:
        name: "liberty-secret"
      pullSecret:
        name: "pull-secret"
      asiAutoscaler:
        name: "asi-autoscaler"
      acAutoscaler:
        name: "ac-autoscaler"
      ingress:
        name: "ingress"
      asiInternalRoute:
        name: "asi-internal-route"
      asiExternalRoute:
        name: "asi-external-route"
      acInternalRoute:
        name: "ac-internal-route"
      acExternalRoute:
        name: "ac-external-route"
      apiInternalRoute:
        name: "api-internal-route"
      dbSetup:
        name: "db-setup"
      podSecurityPolicy:
        name: "psp"
      kubePodSecurityPolicy:
        name: "psp-ks"
      clusterRole:
        name: "psp"
      kubeClusterRole:
        name: "psp-ks"
      roleBinding:
        name: "psp"
      kubeRoleBinding:
        name: "psp-ks"
      securityContextConstraints:
        name: "scc"
      securityContextClusterRole:
        name: "scc"
      securityClusterRoleBinding:
        name: "scc"
      podServiceAccount:
        name: "psa"
      podClusterRole:
        name: "pcr"
      podRoleBinding:
        name: "prb"
      asipodDisruptionBudget:
        name: "asipdb"
      apipodDisruptionBudget:
        name: "apipdb"
      monitoringDashboard:
        name: "grafana-dashboard"
      acpodDisruptionBudget:
        name: "acpdb"
      cleanupJob:
        name: "post-delete-cleanup-job"
      cleanupServiceAccount:
        name: "cleanup-sa"
      cleanupRole:
        name: "cleanup-role"
      cleanupRoleBinding:
        name: "cleanup-rb"
      extPurge:
        name: "ext-purge"
      upgradeCleanupJob:
        name: "pre-upgrade-cleanup-job"
    labelType: "prefixed"
    metering:
      productID: {{ template "b2bi.metering.productId" . }}
      productName: {{ template "b2bi.metering.productName" . }}
      productVersion: {{ template "b2bi.metering.productVersion" . }}
      productMetric: {{ template "b2bi.metering.productMetric" . }}
    nonMetering:
      nonChargeableProductMetric: "FREE"
    podSecurityContext:
      runAsNonRoot: true
      supplementalGroups: {{ .Values.security.supplementalGroups }}
      fsGroup: {{ .Values.security.fsGroup }}
      runAsUser: {{ .Values.security.runAsUser }}
    containerSecurityContext:
      privileged: false
      runAsUser: {{ .Values.security.runAsUser }}
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
{{- end -}}
