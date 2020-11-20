{{- /*
"dv.sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "dv.sch.chart.config.values" -}}
sch:
  chart:
    appName: "dv"
    labelType: "prefixed"
    components:
      secret:
        name: "secret"
      upgradeBackupPVC:
        name: "bar-pvc"
      enginePVC:
        name: "pvc"
      cachingPVC:
        name: "caching-pvc"
      initVolume:
        name: "init-volume"
      barBackup:
        name: "bar-backup"
      barRestore:
        name: "bar-restore"
      secretGen:
        name: "secret-gen"
      secretDel:
        name: "secret-del"
      connRename:
        name: "conn-rename"
      pvcDel:
        name: "pvc-del"
      pvcGen:
        name: "pvc-gen"
      metastore:
        name: "metastore"
      engine:
        name: "engine"
      utils:
        name: "utils"
      worker:
        name: "worker"
      addInstanceOwner:
        name: "add-instance-owner"
    pods:
      utils:
        name: "dv-utils"
      metastore:
        name: "dv-metastore"
      engine:
        name: "dv-engine"
      worker:
        name: "dv-worker"
    security:
      defaultPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
          runAsUser: 2824 # bigsql user
          fsGroup: 43999
      metastorePodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
          fsGroup: 43999
        serviceAccountName: dv-sa
      utilsPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000322824
          fsGroup: 43999
        serviceAccountName: dv-sa
      commonUtilsJobPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
        serviceAccountName: cpd-editor-sa
      commonUtilsJobContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
      barPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          fsGroup: 43999 # sysdv group
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
        serviceAccountName: dv-bar-sa
      initVolumePodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          fsGroup: 43999 # sysdv group
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
        serviceAccountName: dv-sa
      initVolumeContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: true
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
          capabilities:
            add:
            - AUDIT_WRITE
            - DAC_OVERRIDE
            - FOWNER
            - SETGID
            - SETUID
            drop:
            - ALL
      headPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: {{ .Values.enableHostIPC }}
        securityContext:
          fsGroup: 43999 # sysdv group
          runAsNonRoot: true
        serviceAccountName: dv-sa
      metastoreContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
      serverContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: true
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
          capabilities:
            add:
            - AUDIT_WRITE
            - IPC_OWNER        # Needed for Db2
            - SETGID
            - SETUID
            - CHOWN
            - DAC_OVERRIDE
            - KILL
            - FOWNER
            drop:
            - ALL
      utilsContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: true
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
          capabilities:
            add:
            - AUDIT_WRITE
            - SETGID
            - SETUID
            - CHOWN
            drop:
            - ALL
      workerPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: {{ .Values.enableHostIPC }}
        securityContext:
          fsGroup: 43999 # sysdv group
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
        serviceAccountName: dv-sa
      workerContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: true
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
          capabilities:
            add:
            - AUDIT_WRITE
            - IPC_OWNER        # Needed for Db2
            - SETGID
            - SETUID
            drop:
            - ALL
    metering:
      productName: "IBM Data Virtualization"
      productID: "eb9998dcc5d24e3eb5b6fb488f750fe2"
      productVersion: "1.5.0"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "All"
      productCloudpakRatio: "1:1"
      cloudpakName: "IBM Cloud Pak for Data"
      cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
      cloudpakInstanceId: {{ .Values.zenCloudPakInstanceId }}
{{- end -}}
