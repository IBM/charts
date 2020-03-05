{{- /*
"sch.config.values" contains the default configuration values used by
the Shared Configurable Helpers.

To override any of these values, modify the templates/_sch-chart-config.tpl file
*/ -}}
{{- define "sch.chart.config.values" -}}
sch:
  securityContext:
    # This is the default user that should be used by charts that create containers
    # This user should also be the one created and used in the dockerfile
    # If an alternate user is required in the dockerfile, the security context user in the container should be changed to reflect this
    # The user in the security context of the chart (level above container) should be left as default as it will be overriden by the containers user
    defaultUser: 65534

  restrictedNamespaces:
    - kube-system
    - kube-public
    - platform
    # - default

  names:
    fullCompName:
      maxLength: 62
      releaseNameTruncLength: 30
      appNameTruncLength: 7
      compNameTruncLength: 25

  chart:

    # This override allows all IBM Event Streams subcharts to be labelled
    #  consistently as part of the same overall application
    appName: "ibm-es"

    productName:
      dev: "IBM Event Streams Community Edition"
      prod: "IBM Event Streams"
      foundation-prod: "IBM Event Streams Foundation Edition"
      icp4i-prod: "IBM Cloud Pak for Integration - Event Streams"

    # Use the old convention for standard Kubernetes labels, as switching
    # to the new labels would break upgrades
    labelType: non-prefixed

    edition: icp4i-prod

    platform: icp

    #
    # Names given to the Kubernetes components that make up Event Streams
    #
    components:

      #
      # Components for defining Roles and Role Bindings
      #
      essential:
        # component label for all the essential release wide resources
        compName: "essential"
        networkPolicyDefault: "default-access"
        preInstallSA:
          name: "pre-install-sa"
        preInstallRole:
          name: "pre-install-role"
        preInstallRoleBinding:
          name: "pre-install-rb"
        postDeleteSA:
          name: "post-delete-sa"
        postDeleteRole:
          name: "post-delete-role"
        postDeleteRoleBinding:
          name: "post-delete-rb"
        secretsDeleterJob:
          name: "secrets-deleter-job"
        certGenJob:
          name: "cert-gen-job"
        certGenDeleterJob:
          name: "cert-gen-deleter-job"
        zonesTopologyJob:
          name: "zones-topology-job"
        zonesTopologyJobConfigMap:
          name: "zones-topology-job-cm"
        zonesTopologyClusterRole:
          name: "zones-topology-clusterrole"
        zonesTopologyClusterRoleBinding:
          name: "zones-topology-crb"
        oauthJobDeleterJob:
          name: "oauth-jobdeleter-job"
        oauthClientDeleterJob:
          name: "oauth-client-deleter-job"
        releaseConfigMap:
          name: "release-cm"
        releaseCreateJob:
          name: "release-cm-creater-job"
        releasePortsPatcherJob:
          name: "release-cm-addport-job"
        releasePatcherJob:
          name: "release-cm-patcher-job"
        releaseDeleteJob:
          name: "release-cm-deleter-job"
        releaseRole:
          name: "release-cm-role"
        releaseRoleBinding:
          name: "release-cm-rolebinding"
        releaseServiceAccount:
          name: "release-cm-sa"
        labelPodsRole:
          name: "pod-labeler-role"
        labelPodsRoleBinding:
          name: "pod-labeler-rolebinding"

      #
      # Components relating to the Kafka cluster
      #
      kafka:
        # component label for all the Kafka-related resources
        compName: "kafka"
        kafkaVersion: "2.3.1"
        kafkaInternalVersion: "2.3"
        networkPolicy: "kafka-access"
        # all of the resources deployed by the Kafka charts
        statefulSet:
          name: "kafka-sts"
        internalHeadless:
          name: "kafka-headless-svc"
        externalHeadless:
          name: "kafka-external-headless-svc"
        metricsConfigMap:
          name: "metrics-cm"
        serviceAccount:
          name: "kafka-sa"
        jmxSecret:
          name: "jmx-secret"
        configMap:
          name: "kafka-cm"
        mproxyConfigMap:
          name: "kafka-mpcm"
        configPath: "/config"
        tlsConfigPath: "/tlsconfig"

      #
      # Components relating to the Kafka metrics proxy
      #
      kafkaMetricsProxy:
        # component label for all the Kafka-related resources
        compName: "metrics-proxy"
        # all of the resources deployed by the kafka metrics proxy component

      #
      # Components relating to the elasticsearch
      #
      elasticSearch:
        # component label for all the Elastic-related resources
        compName: "elastic"
        networkPolicy: "elastic-access"
        # all of the resources deployed by the elastic search component
        service:
          name: "elastic-svc"
        statefulSet:
          name: "elastic-sts"
        serviceAccount:
          name: "elastic-sa"
        configMap:
          name: "elastic-cm"
        tlsConfigPath: "/tlsconfig"

      #
      # Components relating to the index manager
      #
      indexmgr:
        # component label for all the Index-manager-related resources
        compName: "indexmgr"
        networkPolicy: "indexmgr-access"
        # all of the resources deployed by the index manager component
        service:
          name: "indexmgr-svc"
        deployment:
          name: "indexmgr-deploy"
        serviceAccount:
          name: "indexmgr-sa"
        configMap:
          name: "indexmgr-cm"
        tlsConfigPath: "/tlsconfig"

      #
      # Components relating to the collector
      #
      collector:
        # component label for all the collector-related resources
        compName: "collector"
        networkPolicy: "collector-access"
        # all of the resources deployed by the collector component
        service:
          name: "collector-svc"
        deployment:
          name: "collector-deploy"
        serviceAccount:
          name: "collector-sa"
        configMap:
          name: "collector-cm"
        tlsConfigPath: "/tlsconfig"

      #
      # Components relating to the ZooKeeper nodes
      #
      zookeeper:
        # component label for all the ZooKeeper-related resources
        compName: "zookeeper"
        networkPolicy: "zookeeper-access"
        # all of the resources deployed by the ZooKeeper charts
        statefulSet:
          name: "zookeeper-sts"
        internalHeadless:
          name: "zookeeper-headless-svc"
        externalHeadless:
          name: "zookeeper-external-headless-svc"
        configMap:
          name: "zookeeper-cm"
        configPath: "/config"

      #
      # Components relating to the proxy that allows external access to Kafka
      #
      proxy:
        # component label for all the proxy-related resources
        compName: "proxy"
        networkPolicy: "proxy-access"
        brokerPrefix: "brk"
        internalPrefix: "INTERNAL"
        # all of the resources deployed by the proxy charts
        route:
          name: "proxy-route"
        secret:
          name: "proxy-secret"
        service:
          name: "proxy-svc"
        role:
          name: "proxy-role"
        roleBinding:
          name: "proxy-rolebinding"
        controller:
          name: "proxy-deploy"
        configMap:
          name: "proxy-cm"
        serviceAccount:
          name: "proxy-sa"

      #
      # Components relating to the Replicator
      #
      replicator:
        # component label for all the replicator-related resources
        compName: "replicator"
        networkPolicy: "replicator-access"
        # all of the resources deployed by the replicator charts
        service:
          name: "replicator-svc"
        deployment:
          name: "replicator-deploy"
        configMap:
          replicatorConfigMap:
            name: "replicator-cm"
          proxyConfigMap:
            name: "replicator-proxy-cm"
        secretCreatorJob:
          name: "replicator-secret-job"
        secretDeleterJob:
          name: "replicator-secretdelete-job"
        credentialsSecret:
          name: "replicator-secret"
        serviceAccount:
          name: "replicator-sa"
        rest:
          role:
            name: "replicator-rest-role"
          roleBinding:
            name: "replicator-rest-rolebinding"
        configPath: "/config"

      #
      # Components relating to the Admin REST API
      #
      rest:
        # component label for all the REST API-related resources
        compName: "rest"
        networkPolicy: "rest-access"
        # all of the resources deployed by the REST API charts
        service:
          name: "rest-svc"
        deployment:
          name: "rest-deploy"
        configMap:
          name: "rest-cm"
        serviceAccount:
          name: "rest-sa"
        roles:
          name: "rest-role"
        roleBindings:
          name: "rest-rolebinding"
        tlsConfigPath: "/tlsconfig"

      #
      # Components relating to hosting the Admin REST API proxy
      #
      restproxy:
        # component label for all the ui-proxy-related resources
        compName: "restproxy"
        # all of the resources deployed by the rest-proxy charts
        adminRestRoute:
          name: "rest-route"
        clientAuthRoute:
          name: "clientauth-route"
        externalservice:
          name: "rest-proxy-external-svc"
        internalservice:
          name: "rest-proxy-internal-svc"
        deployment:
          name: "rest-proxy-deploy"
        networkPolicy: "rest-proxy-access"
        serviceAccount:
          name: "rest-proxy-sa"
        adminRestPort:
          name: "admin-rest-https"
        clientAuthPort:
          name: "clientauth-rest-https"

      #
      # Components relating to the REST Producer API
      #
      restproducer:
        # component label for all the REST Producer API-related resources
        compName: "restproducer"
        networkPolicy: "rest-producer-access"
        # all of the resources deployed by the REST Producer API charts
        service:
          name: "rest-producer-svc"
        deployment:
          name: "rest-producer-deploy"
        serviceAccount:
          name: "rest-producer-sa"
      #
      # Components relating to hosting the admin UI
      #
      ui:
        # component label for all the UI-related resources
        compName: "ui"
        networkPolicy: "ui-access"
        # all of the resources deployed by the UI charts
        route:
          name: "ui-route"
        service:
          name: "ui-svc"
        openshiftSecureServiceCert:
          name: "ui-service-cert"
        deployment:
          name: "ui-deploy"
        role:
          name: "ui-role"
        roleBinding:
          name: "ui-rolebinding"
        oauth2ClientRegistration:
          name: "ui-oauth2-client-reg"
        oauthSecret:
          name: "oauth-v2-secret"
        serviceAccount:
          name: "ui-sa"
        oauth:
          role:
            name: "oauth-role"
          roleBinding:
            name: "oauth-rolebinding"
          serviceAccount:
            name: "oauth-sa"
          client:
            name: "oauth-registration"

      #
      # Components relating to ICP IAM Security
      #
      security:
        # component label for all the ICP IAM related resources
        compName: "security"
        networkPolicy: "security-access"
        # service label for auto-generation of service ID
        serviceName: "eventstreams"
        # secret that is used to hold the auto-generated service id and api key
        iamSecret:
          name: "iam-secret"
        roleMappings:
          name: "role-mappings"
        roleMappingsConfigMap:
          name: "role-mappings-cm"
        serviceAccount:
          name: "security-sa"
        accesscontroller:
          service:
            name: "access-controller-svc"
          deployment:
            name: "access-controller-deploy"
          serviceAccount:
            name: "access-controller-sa"
        managementIngress:
          dnsName: "icp-management-ingress.kube-system"

      #
      # Components relating to Telemetry
      #
      telemetry:
        # component label for all the Telemetry related resources
        compName: "telemetry"
        networkPolicy: "telemetry-access"
        # name for post-install hook
        job:
          name: "telemetry-hook"
        serviceAccount:
          name: "telemetry-sa"

      #
      # Components relating to the Schema Registry
      #
      schemaregistry:
        # component label for all the Schema Registry resources
        compName: "schemaregistry"
        networkPolicy: "schemaregistry-access"
        # resources deployed by the schemaregistry chart
        statefulSet:
          name: "schemaregistry-sts"
        persistentVolumeClaim:
          name: "schemaregistry-pvc"
        serviceAccount:
          name: "schemaregistry-sa"
        service:
          name: "schemaregistry-svc"
        role:
          name: "schemaregistry-role"
        roleBinding:
          name: "schemaregistry-rolebinding"

      #
      # Components relating to the Grafana Dashboards
      #
      dashboard:
        default: 
          name: "default-dashboard"
        performance:
          name: "performance-dashboard"

      #
      # Components relating to prometheus
      #
      prometheus:
        # component label for all the Schema Registry resources
        compName: "prometheus"
        
      #
      # Components relating to the Helm Tests
      #
      helmTests:
        # component label for all the essential release wide resources
        compName: "test"
        testServicesPod:
          name: "test-services-po"
        serviceAccount:
          name: "test-sa"


{{- end -}}
