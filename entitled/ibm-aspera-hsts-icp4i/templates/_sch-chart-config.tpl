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
      ascpLoadbalancer:
        compName: "ascp-loadbalancer"
      ascpSwarm:
        compName: "ascp-swarm"
        env:
          compName: "ascp-swarm-env"
        member:
          compName: "ascp-swarm-member"
          env:
            compName: "ascp-swarm-member-env"
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
      lifecycle:
        compName: "lifecycle"

    meteringProd:
      productName: "IBM Aspera High-Speed Transfer Server (Chargeable)"
      productID: "e73360a854824b6f9198f9b314e8802b"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productVersion: "3.9.10"
      productCloudpakRatio: "1:2"
      productChargedContainers: "All"
      cloudpakName: "IBM Cloud Pak for Integration"
      cloudpakId: "c8b82d189e7545f0892db9ef2731b90d"

    meteringNonProd:
      productName: "IBM Aspera High-Speed Transfer Server (Non-production) (Chargeable)"
      productID: "e73360a854824b6f9198f9b314e8802b"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productVersion: "3.9.10"
      productCloudpakRatio: "1:1"
      productChargedContainers: "All"
      cloudpakName: "IBM Cloud Pak for Integration"
      cloudpakId: "c8b82d189e7545f0892db9ef2731b90d"

    secretGen:
      suffix: "{{ .Release.Name }}-ibm-aspera-hsts"
      overwriteExisting: false
      secrets:
      - name: token-encryption-key
        create: {{ empty .Values.asperanode.tokenEncryptionKeySecret }}
        type: generic
        values:
        - name: TOKEN_ENCRYPTION_KEY
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
        create: {{ and (empty .Values.ingress.tlsSecret) (empty .Values.tls.issuer) ( not (.Capabilities.APIVersions.Has "route.openshift.io/v1") ) }}
        type: tls
        cn: "{{ .Values.ingress.hostname }}"
      - name: sshd
        create: "{{ empty .Values.sshdKeysSecret }}"
        type: rsa
        privateKeyName: ssh_host_rsa_key
        publicKeyName: ssh_host_rsa_key.pub
        fingerprintName: SSHD_FINGERPRINT
{{- end -}}
