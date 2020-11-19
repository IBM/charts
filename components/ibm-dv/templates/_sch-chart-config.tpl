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
      enginePVC:
        name: "pvc"
      cachingPVC:
        name: "caching-pvc"
      initVolume:
        name: "init-volume"
      secretGen:
        name: "secret-gen"
      secretDel:
        name: "secret-del"
      metastore:
        name: "metastore"
      engine:
        name: "engine"
      utils:
        name: "utils"
      worker:
        name: "worker"
      bigsql:
        name: "bigsql"
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
      metastorePodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
      utilsPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000322824
          fsGroup: 43999
        serviceAccountName: dv-sa
      secretJobPodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
        serviceAccountName: cpd-editor-sa
      secretJobContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
      initVolumePodSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
        serviceAccountName: dv-sa
      initVolumeContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: true
          runAsNonRoot: true
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
            - IPC_OWNER        # Needed for Db2
      utilsContainerSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: true
          runAsNonRoot: true
          runAsUser: 1000322824 # bigsql user
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
          capabilities:
            add:
            - IPC_OWNER        # Needed for Db2
    metering:
      productName: "IBM Data Virtualization"
      productID: "ICP4D-IBMDataVirtualizationv141_00000"
      productVersion: "1.4.1"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: "All"
      cloudpakName: "IBM Cloud Pak for Data"
      cloudpakId: "eb9998dcc5d24e3eb5b6fb488f750fe2"
      cloudpakVersion: "3.0.1"
{{- end -}}
