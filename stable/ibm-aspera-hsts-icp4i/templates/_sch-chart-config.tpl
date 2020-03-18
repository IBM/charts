{{- define "hsts.sch.chart.config.values" }}
sch:
  chart:
    values:
      asperanode:
        masterId: "master"
        clusterId: "cluster"
    test:
      asperanode:
        ping: "test-ping"
        info: "test-info"
    volumes:
      transfer: transfer
      redis: redis
      redisBackup: redis-backup
    components:
      leaderElection: leader-election-lock
      lockDelete: election-lock-delete
      secretGen: secret-gen
      certificate: "certificate"
      aej:
        compName: "aej"
      prometheusEndpoint:
        compName: "prometheus-endpoint"
      stats:
        compName: "stats"
      receiver:
        compName: "receiver"
        env:
          compName: "receiver-env"
      ascpLoadbalancer:
        compName: "ascp-loadbalancer"
      ascpSwarm:
        compName: "ascp-swarm"
        env:
          compName: "ascp-swarm-env"
        member:
          compName: "ascp-swarm-member"
        delete:
          compName: "ascp-swarm-delete"
        prefix: "ascp"
      nodedLoadbalancer:
        compName: "noded-loadbalancer"
      nodedSwarm:
        compName: "noded-swarm"
        env:
          compName: "noded-swarm-env"
        member:
          compName: "noded-swarm-member"
          env:
            compName: "noded-swarm-member-env"
        delete:
          compName: "noded-swarm-delete"
        prefix: "noded"
      httpProxy:
        compName: "http-proxy"
      tcpProxy:
        compName: "tcp-proxy"
      filebeat:
        compName: "filebeat"
      redisBackUp:
        compName: "redis-backup"
      asperanode:
        compName: "asperanode"
        scaler:
          api: "node-api"
        deployment:
          master: "node-master"
          api: "node-api"
        service:
          api: "node-api"
        ingress: "ingress"
        configMap: "node"
        job:
          createAccessKey: "create-access-key-v1"

    meteringProd:
      productName: "IBM Cloud Pak for Integration - Aspera High-Speed Transfer Server (Chargeable)"
      productID: "AsperaHSTS_5737_I89_ICP4I_chargeable"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productVersion: "3.9.5"
      productCloudpakRatio: "1:2"
      productChargedContainers: "All"
      cloudpakName: "IBM Cloud Pak for Integration"
      cloudpakId: "c8b82d189e7545f0892db9ef2731b90d"

    meteringNonProd:
      productName: "IBM Cloud Pak for Integration (non-production) - Aspera High-Speed Transfer Server (Chargeable)"
      productID: "AsperaHSTS_5737_I89_ICP4I_nonProd_chargeable"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productVersion: "3.9.5"
      productCloudpakRatio: "1:1"
      productChargedContainers: "All"
      cloudpakName: "IBM Cloud Pak for Integration"
      cloudpakId: "c8b82d189e7545f0892db9ef2731b90d"

    secretGen:
      suffix: "{{ .Release.Name }}-ibm-aspera-hsts"
      overwriteExisting: false
      secrets:
      - name: access-key
        create: {{ empty .Values.asperanode.accessKeySecret }}
        type: generic
        values:
        - name: ACCESS_KEY_ID
          length: 40
        - name: ACCESS_KEY_SECRET
          length: 40
      - name: node-admin
        create: {{ empty .Values.asperanode.nodeAdminSecret }}
        type: generic
        values:
        - name: NODE_USER
          length: 20
        - name: NODE_PASS
          length: 40
      - name: cert
        create: {{ and (empty .Values.ingress.tlsSecret) (empty .Values.tls.issuer) }}
        type: tls
        cn: "{{ .Values.ingress.hostname }}"
      - name: sshd
        create: {{ empty .Values.sshdKeysSecret }}
        type: rsa
        privateKeyName: ssh_host_rsa_key
        publicKeyName: ssh_host_rsa_key.pub
        fingerprintName: SSHD_FINGERPRINT
{{- end -}}
