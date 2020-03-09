{{- define "ports.sch.chart.config.values" -}}
sch:
  config:
    ports:
      # ports used by kafka
      kafka:
        # inter-broker communication, plain text kafka to kafka
        internalKafka: 9092
        internalKafkaIntercept: 8092
        # external applications connect to kafka via this port - security
        externalSecure: 9093
        externalProxySecure: 8093
        # used by Event Streams 'system' components which are always using SSL such as the rest admin service
        internalEventStreamsSecure: 9094
        internalEventStreamsSecureIntercept: 8084
        # used by Event Streams 'system' components which have configurable SSL through a proxy such as the replicator
        internalLoopback: 9095
        internalLoopbackIntercept: 8085
        # Port opened by the kafka-healthcheck container
        healthcheck: 7070
        # Port opened by the kafka-metrics-reporter container
        metrics: 8081
        #Port for JMX connections
        jmx: 9999

      #ports used for security
      security:
        # Secure endpoint for console
        icpSSL: 8443
        # Access controller endpoint
        accessController: 8443
        # ICP Platform Identity Provider
        platformIdentityProvider: 4300


      # ports used by zookeeper
      zookeeper:
        # Incoming client connections
        client: 2181
        clientInternal: 1181
        # Used for connections between ZooKeeper nodes
        server: 2888
        serverInternal: 1888
        # Used by ZooKeeper nodes for connections to the leader
        election: 3888
        electionInternal: 4888

      prometheus:
        # Incomming prometheus connections to scrape metrics
        collector: 8080
        collectorKafka: 8081

      kubernetes:
        # Access to the kubernetes API
        api: 8001

      indexmgr:
        # metrics sent from kafka pod by metrics proxy
        metrics: 8080
        metricsInternal: 8081
        # api for rest server to call
        api: 9080
        apiInternal: 9081

      collector:
        # metrics sent from kafka pod by metrics proxy
        prometheus: 8888
        api: 7888
        apiInternal: 6888

      replicator:
        # Port number for the Kafka Connect REST API on individual replicator pod to properly re-route the external traffic
        api: 8083
        # kafka connect
        connect: 9999

      rest:
        # Port number that the Service uses to expose the REST API in the cluster
        server: 9443
        # Port number that the proxy container will listen on, used for liveness and readiness checks
        health: 9443
        # Port number that the proxy container will listen on, this will be wired to a randomly generated node port
        proxy: 32000

      restproxy:
        # Port number that the Service uses to securely expose the REST proxy externally
        external: 32000
        # Port number that the Service uses to expose the REST proxy internally
        internal: 9443
        # Port number that the proxy container will listen on, used for liveness checks
        health: 32010

      clientauthproxy:
        # Port number that the Service uses to securely expose the clientauth proxy externally
        external: 32001

      restproducer:
        # Port number that the Service uses to expose the REST Producer API in the cluster
        server: 8080

      codegen:
        # port for code generation
        server: 3000

      proxy:
        # health and liveness endpoint
        health: 8080
        # alternative health and liveness endpoint when the default one is in use
        altHealth : 8090
        # This is a placeholder service, since a service requires at least 1 port.
        placeholder: 80

      ui:
        # Port number that the Service uses to expose the UI web server within the cluster
        webserver: 3000
        # health and liveness endpoint
        health: 8080

      schemaregistry:
        server: 3000
        javaServer: 3080

      elasticsearch:
        # rest api endpoint
        api: 9200
        apiInternal: 8200
        # publishing (inter-node communication)
        publishing: 9300
        publishingInternal: 8300

      #well known, standard ports e.g. 80, 443
      wellknown:
        dns: 53

      # port used to access ICP4I platform services
      icp4iplatformservices:
        server: 3000
{{- end -}}
