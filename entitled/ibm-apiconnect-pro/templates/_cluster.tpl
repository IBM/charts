{{- define "ibm-apiconnect-pro.apic-cluster-spec" -}}
spec:
  secret-name: {{ .Release.Name }}-apic-cluster
  subsystems:
{{- if .Values.management.enabled }}
  - apiVersion: v1
    kind: apic.ibm.com/ManagementSubsystem
    metadata:
      name: management
    spec:
      CloudProperties:
        extra-values-file: /home/apic/extra-values/management-extra-values.yaml
        ingress-type:      {{ .Values.global.routingType }}
        mode:              {{ .Values.global.mode }}
        namespace:         {{ .Values.management.namespace | default .Release.Namespace }}
        registry:          {{ regexReplaceAll "/$" .Values.global.registry "" }}
        registry-secret:   {{ .Values.global.registrySecret }}
        storage-class:     {{ .Values.management.storageClass | default .Values.global.storageClass }}
      SubsystemProperties:
        secret-name: {{ .Release.Name }}-apic-cluster-management
        target: kubernetes
      endpoints:
        api-manager-ui: {{ .Values.management.apiManagerUiEndpoint }}
        cloud-admin-ui: {{ .Values.management.cloudAdminUiEndpoint }}
        consumer-api:   {{ .Values.management.consumerApiEndpoint }}
        platform-api:   {{ .Values.management.platformApiEndpoint }}
      settings:
        cassandra-backup-auth-pass:      {{ .Values.cassandraBackup.cassandraBackupAuthPass }}
        cassandra-backup-auth-user:      {{ .Values.cassandraBackup.cassandraBackupAuthUser }}
        cassandra-backup-host:           {{ .Values.cassandraBackup.cassandraBackupHost }}
        cassandra-backup-path:           {{ .Values.cassandraBackup.cassandraBackupPath }}
        cassandra-backup-port:           {{ .Values.cassandraBackup.cassandraBackupPort }}
        cassandra-backup-protocol:       {{ .Values.cassandraBackup.cassandraBackupProtocol }}
        cassandra-backup-schedule:       {{ .Values.cassandraBackup.cassandraBackupSchedule }}
        cassandra-cluster-size:          {{ .Values.cassandra.cassandraClusterSize }}
        cassandra-max-memory-gb:         {{ .Values.cassandra.cassandraMaxMemoryGb }}
        cassandra-postmortems-auth-pass: {{ .Values.cassandraPostmortems.cassandraPostmortemsAuthPass }}
        cassandra-postmortems-auth-user: {{ .Values.cassandraPostmortems.cassandraPostmortemsAuthUser }}
        cassandra-postmortems-host:      {{ .Values.cassandraPostmortems.cassandraPostmortemsHost }}
        cassandra-postmortems-path:      {{ .Values.cassandraPostmortems.cassandraPostmortemsPath }}
        cassandra-postmortems-port:      {{ .Values.cassandraPostmortems.cassandraPostmortemsPort }}
        cassandra-postmortems-schedule:  {{ .Values.cassandraPostmortems.cassandraPostmortemsSchedule }}
        cassandra-volume-size-gb:        {{ .Values.cassandra.cassandraVolumeSizeGb }}
        create-crd:                      {{ .Values.global.createCrds }}
        external-cassandra-host:
{{- end }}
{{- if .Values.portal.enabled }}
  - apiVersion: v1
    kind: apic.ibm.com/PortalSubsystem
    metadata:
      name: portal
    spec:
      CloudProperties:
        extra-values-file: /home/apic/extra-values/portal-extra-values.yaml
        ingress-type:      {{ .Values.global.routingType }}
        mode:              {{ .Values.global.mode }}
        namespace:         {{ .Values.portal.namespace | default .Release.Namespace }}
        registry:          {{ regexReplaceAll "/$" .Values.global.registry "" }}
        registry-secret:   {{ .Values.global.registrySecret }}
        storage-class:     {{ .Values.portal.storageClass | default .Values.global.storageClass }}
      SubsystemProperties:
        secret-name: {{ .Release.Name }}-apic-cluster-portal
        target: kubernetes
      endpoints:
        portal-admin: {{ .Values.portal.portalDirectorEndpoint }}
        portal-www:   {{ .Values.portal.portalWebEndpoint }}
      settings:
        admin-storage-size-gb:   {{ .Values.portal.adminStorageSizeGb }}   
        backup-storage-size-gb:  {{ .Values.portal.backupStorageSizeGb }}   
        db-logs-storage-size-gb: {{ .Values.portal.dbLogsStorageSizeGb }}   
        db-storage-size-gb:      {{ .Values.portal.dbStorageSizeGb }}  
        site-backup-auth-pass:   {{ .Values.portalBackup.siteBackupAuthPass }}
        site-backup-auth-user:   {{ .Values.portalBackup.siteBackupAuthUser }}
        site-backup-host:        {{ .Values.portalBackup.siteBackupHost }}
        site-backup-path:        {{ .Values.portalBackup.siteBackupPath }}
        site-backup-port:        {{ .Values.portalBackup.siteBackupPort }}
        site-backup-protocol:    {{ .Values.portalBackup.siteBackupProtocol }}
        site-backup-schedule:    {{ .Values.portalBackup.siteBackupSchedule }}
        www-storage-size-gb:     {{ .Values.portal.wwwStorageSizeGb }}
{{- end }}
{{- if .Values.analytics.enabled }}
  - apiVersion: v1
    kind: apic.ibm.com/AnalyticsSubsystem
    metadata:
      name: analytics
    spec:
      CloudProperties:
        extra-values-file: /home/apic/extra-values/analytics-extra-values.yaml
        ingress-type:      {{ .Values.global.routingType }}
        mode:              {{ .Values.global.mode }}
        namespace:         {{ .Values.analytics.namespace | default .Release.Namespace }}
        registry:          {{ regexReplaceAll "/$" .Values.global.registry "" }}
        registry-secret:   {{ .Values.global.registrySecret }}
        storage-class:     {{ .Values.analytics.storageClass | default .Values.global.storageClass }}
      SubsystemProperties:
        secret-name: {{ .Release.Name }}-apic-cluster-analytics
        target: kubernetes
      endpoints:
        analytics-client: {{ .Values.analytics.analyticsClientEndpoint }}
        analytics-ingestion: {{ .Values.analytics.analyticsIngestionEndpoint }}
      settings:
        coordinating-max-memory-gb: {{ .Values.analytics.coordinatingMaxMemoryGb }}
        data-max-memory-gb:         {{ .Values.analytics.dataMaxMemoryGb }}
        data-storage-size-gb:       {{ .Values.analytics.dataStorageSizeGb }}
        enable-message-queue:       {{ .Values.analytics.enableMessageQueue }}
        es-storage-class:           {{ .Values.analytics.esStorageClass }}
        master-max-memory-gb:       {{ .Values.analytics.masterMaxMemoryGb }}
        master-storage-size-gb:     {{ .Values.analytics.masterStorageSizeGb }}
        mq-storage-class:           {{ .Values.analytics.mqStorageClass }}
{{- end }}
{{- end -}}
