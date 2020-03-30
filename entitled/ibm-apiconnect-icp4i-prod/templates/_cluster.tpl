{{- define "ibm-apiconnect-cip.apic-cluster-spec" -}}
apiVersion: apic.ibm.com/v1
kind: APIConnectCluster
metadata:
  name: {{ .Release.Name }}-apic-cluster
spec:
  secret-name: {{ .Release.Name }}-apic-cluster
  subsystems:
{{- if .Values.management.enabled }}
  - apiVersion: v1
    kind: apic.ibm.com/ManagementSubsystem
    metadata:
      name: {{ .Values.management.name }}
    spec:
      CloudProperties:
        extra-values-file: /home/apic/extra-values/{{ .Values.management.name }}-extra-values.yaml
        ingress-type:      {{ .Values.global.routingType }}
        mode:              {{ .Values.global.mode }}
        namespace:         {{ .Release.Namespace }}
        registry:          {{ regexReplaceAll "/$" .Values.global.registry "" }}
        {{- if .Values.global.registrySecret }}
        registry-secret:   {{ .Values.global.registrySecret }}
        {{- else }}
        registry-secret: ibm-entitlement-key
        {{- end }}
        storage-class:     {{ .Values.management.storageClass | default .Values.global.storageClass }}
      SubsystemProperties:
        secret-name: {{ .Release.Name }}-apic-cluster-{{ .Values.management.name }}
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
      name: {{ .Values.portal.name }}
    spec:
      CloudProperties:
        extra-values-file: /home/apic/extra-values/{{ .Values.portal.name }}-extra-values.yaml
        ingress-type:      {{ .Values.global.routingType }}
        mode:              {{ .Values.global.mode }}
        namespace:         {{ .Release.Namespace }}
        registry:          {{ regexReplaceAll "/$" .Values.global.registry "" }}
        {{- if .Values.global.registrySecret }}
        registry-secret:   {{ .Values.global.registrySecret }}
        {{- else }}
        registry-secret: ibm-entitlement-key
        {{- end }}
        storage-class:     {{ .Values.portal.storageClass | default .Values.global.storageClass }}
      SubsystemProperties:
        secret-name: {{ .Release.Name }}-apic-cluster-{{ .Values.portal.name }}
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
      name: {{ .Values.analytics.name }}
    spec:
      CloudProperties:
        extra-values-file: /home/apic/extra-values/{{ .Values.analytics.name }}-extra-values.yaml
        ingress-type:      {{ .Values.global.routingType }}
        mode:              {{ .Values.global.mode }}
        namespace:         {{ .Release.Namespace }}
        registry:          {{ regexReplaceAll "/$" .Values.global.registry "" }}
        {{- if .Values.global.registrySecret }}
        registry-secret:   {{ .Values.global.registrySecret }}
        {{- else }}
        registry-secret: ibm-entitlement-key
        {{- end }}
        storage-class:     {{ .Values.analytics.storageClass | default .Values.global.storageClass }}
      SubsystemProperties:
        secret-name: {{ .Release.Name }}-apic-cluster-{{ .Values.analytics.name }}
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
{{- if .Values.gateway.enabled }}
  - apiVersion: v1
    kind: apic.ibm.com/GatewaySubsystem
    metadata:
      name: {{ .Values.gateway.name }}
    spec:
      CloudProperties:
        extra-values-file: /home/apic/extra-values/{{ .Values.gateway.name }}-extra-values.yaml
        ingress-type:      {{ .Values.global.routingType }}
        mode:              {{ .Values.global.mode }}
        namespace:         {{ .Release.Namespace }}
        registry:          ""
        {{- if .Values.global.registrySecret }}
        registry-secret:   {{ .Values.global.registrySecret }}
        {{- else }}
        registry-secret: ibm-entitlement-key
        {{- end }}
        storage-class:     {{ .Values.gateway.storageClass | default .Values.global.storageClass }}
      SubsystemProperties:
        secret-name: {{ .Release.Name }}-apic-cluster-{{ .Values.gateway.name }}
        target: kubernetes
      endpoints:
        api-gateway:     {{ .Values.gateway.apiGatewayEndpoint }}
        apic-gw-service: {{ .Values.gateway.gatewayServiceEndpoint }}
      settings:
        enable-tms:                      {{ .Values.gateway.enableTms }}
        enable-high-performance-peering: {{ eq .Values.gateway.highPerformancePeering true | quote }}
        image-pull-policy:               {{ .Values.gateway.imagePullPolicy }}
        image-repository:                {{ regexReplaceAll "/$" .Values.global.registry "" }}/{{ .Values.gateway.image }}
        image-tag:                       {{ .Values.gateway.imageTag }}
        max-cpu:                         {{ .Values.gateway.maxCpu }}
        max-memory-gb:                   {{ .Values.gateway.maxMemoryGb }}
        replica-count:                   {{ .Values.gateway.replicaCount }}
        tms-peering-storage-size-gb:     {{ .Values.gateway.tmsPeeringStorageSizeGb }}
        v5-compatibility-mode:           {{ .Values.gateway.v5CompatibilityMode }}
        monitor-image-repository:        {{ regexReplaceAll "/$" .Values.global.registry "" }}/{{ .Values.gateway.monitoringImage }}
        monitor-image-tag:               {{ .Values.gateway.monitoringImageTag }}
{{- end }}
{{- if .Values.gateway2.enabled }}
  - apiVersion: v1
    kind: apic.ibm.com/GatewaySubsystem
    metadata:
      name: {{ .Values.gateway2.name }}
    spec:
      CloudProperties:
        extra-values-file: /home/apic/extra-values/{{ .Values.gateway2.name }}-extra-values.yaml
        ingress-type:      {{ .Values.global.routingType }}
        mode:              {{ .Values.global.mode }}
        namespace:         {{ .Release.Namespace }}
        registry:          ""
        {{- if .Values.global.registrySecret }}
        registry-secret:   {{ .Values.global.registrySecret }}
        {{- else }}
        registry-secret: ibm-entitlement-key
        {{- end }}
        storage-class:     {{ .Values.gateway2.storageClass | default .Values.global.storageClass }}
      SubsystemProperties:
        secret-name: {{ .Release.Name }}-apic-cluster-{{ .Values.gateway2.name }}
        target: kubernetes
      endpoints:
        api-gateway:     {{ .Values.gateway2.apiGatewayEndpoint }}
        apic-gw-service: {{ .Values.gateway2.gatewayServiceEndpoint }}
      settings:
        enable-tms:                      {{ .Values.gateway2.enableTms }}
        enable-high-performance-peering: {{ eq .Values.gateway2.highPerformancePeering true | quote }}
        image-pull-policy:               {{ .Values.gateway2.imagePullPolicy }}
        image-repository:                {{ regexReplaceAll "/$" .Values.global.registry "" }}/{{ .Values.gateway2.image }}
        image-tag:                       {{ .Values.gateway2.imageTag }}
        max-cpu:                         {{ .Values.gateway2.maxCpu }}
        max-memory-gb:                   {{ .Values.gateway2.maxMemoryGb }}
        replica-count:                   {{ .Values.gateway2.replicaCount }}
        tms-peering-storage-size-gb:     {{ .Values.gateway2.tmsPeeringStorageSizeGb }}
        v5-compatibility-mode:           {{ .Values.gateway2.v5CompatibilityMode }}
        monitor-image-repository:        {{ regexReplaceAll "/$" .Values.global.registry "" }}/{{ .Values.gateway2.monitoringImage }}
        monitor-image-tag:               {{ .Values.gateway2.monitoringImageTag }}
{{- end }}
{{- end -}}
