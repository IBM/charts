{{- define "ibm-wex-prod.sch.chart.config.values" -}}
sch:
  chart:
    appName: "{{ .Values.global.appName }}"

    components:
      wex:
        # name: wex
        configmap:
          name: configmap
          label:
            component: wex-configmap
        data:
          pvc:
            name: data
        config:
          name: config
          service:
            headlessName: config-headless
          label:
            component: wex-config
            runHeadlessService: wex-config-headless-svc
            runPdb: wex-config-pdb
            runService: wex-config-svc
            runStatefulset: wex-config-pod
        database:
          name: database
          label:
            component: wex-database
            runPdb: wex-database-pdb
            runService: wex-database-svc
            runStatefulset: wex-database-pod
        discovery:
          name: discovery
          label:
            component: wex-discovery
            runPdb: wex-discovery-pdb
            runService: wex-discovery-svc
            runStatefulset: wex-discovery-pod
        gateway:
          name: gateway
          label:
            component: wex-gateway
            runPdb: wex-gateway-pdb
            runService: wex-gateway-svc
            runStatefulset: wex-gateway-pod
        hdp:
          # name: hdp
          nn:
            name: hdp-nn
            service:
              headlessName: hdp-nn-headless
          rm:
            name: hdp-rm
            service:
              headlessName: hdp-rm-headless
          worker:
            name: hdp-worker
          label:
            component: wex-hdp
            runNnPdb: wex-hdp-nn-pdb
            runNnHeadlessService: wex-hdp-nn-svc-headless
            runNnService: wex-hdp-nn-svc
            runNnStatefulset: wex-hdp-nn-pod
            runRmPdb: wex-hdp-rm-pdb
            runRmHeadlessService: wex-hdp-rm-svc-headless
            runRmService: wex-hdp-rm-svc
            runRmStatefulset: wex-hdp-rm-pod
            runWorkerPdb: wex-hdp-worker-pdb
            runWorkerService: wex-hdp-worker-svc
            runWorkerStatefulset: wex-hdp-worker-pod
        ingestion:
          name: ingestion
          service:
            headlessName: ingestion-headless
          pvc:
            name: userdata
          label:
            component: wex-ingestion
            runHeadlessService: wex-ingestion-headless-svc
            runPdb: wex-ingestion-pdb
            runPvc: wex-ingestion-pvc
            runStatefulset: wex-ingestion-pod
        networkPolicy:
          gateway:
            name: networkpolicy-gw
          internal:
            name: networkpolicy-internal
          label:
            component: wex-networkpolicy
            runGw: wex-networkpolicy-gw
            runInternal: wex-networkpolicy-internal
        nlp:
          name: nlp
          label:
            component: wex-nlp
            runPdb: wex-nlp-pdb
            runService: wex-nlp-svc
            runStatefulset: wex-nlp-pod
        orchestrator:
          name: orchestrator
          label:
            component: wex-orchestrator
            runPdb: wex-orchestrator-pdb
            runService: wex-orchestrator-svc
            runStatefulset: wex-orchestrator-pod
            runPvc: wex-orchestrator-pvc
        ui:
          name: ui
          label:
            component: wex-ui
            runService: wex-ui-svc
        wksml:
          name: wksml
          label:
            component: wex-wksml
            runPdb: wex-wksml-pdb
            runService: wex-wksml-svc
            runStatefulset: wex-wksml-pod
        test:
          hdp:
            name: test-hdp
            label:
              component: wex-test-hdp
          resource:
            name: test-resource
            label:
              component: wex-test-resource

    metering:
      productName: "IBM Watson Explorer Deep Analytics Edition"
      productID: "6504aa0655a8434fbeb170b5c8d29c2b"
      productVersion: "12.0.3.1"

    specSecurityContext:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 60001

    podSecurityContext:
      securityContext:
        runAsNonRoot: true
        runAsUser: 60001
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: true
        capabilities:
          drop:
          - ALL
          add:
          - CHOWN
          - AUDIT_WRITE
          - DAC_OVERRIDE
          - FOWNER
          - SETGID
          - SETUID
          - NET_BIND_SERVICE
          - SYS_CHROOT

  names:
    fullName:
      maxLength: 156
      releaseNameTruncLength: 78
      appNameTruncLength: 78
    fullCompName:
      maxLength: 234
      releaseNameTruncLength: 78
      appNameTruncLength: 78
      compNameTruncLength: 78
    statefulSetName:
      maxLength: 234
      releaseNameTruncLength: 78
      appNameTruncLength: 78
      compNameTruncLength: 78
    volumeClaimTemplateName:
      maxLength: 253
      possiblePrefix: "glusterfs-dynamic-"
      claimNameTruncLength: 235
    persistentVolumeClaimName:
      maxLength: 252
      possiblePrefix: "glusterfs-dynamic-"
      releaseNameTruncLength: 78
      appNameTruncLength: 78
      claimNameTruncLength: 78

{{- end -}}
