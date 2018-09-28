{{- /*
"sch.config.values" contains the default configuration values used by
the Shared Configurable Helpers.

To override any of these values, modify the templates/_sch-chart-config.tpl file
*/ -}}
{{- define "sch.chart.config.values" -}}
sch:
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

    productVersion: 2018.3.0

    # EDITION_START
    edition: dev
    # EDITION_END

    #
    # Names given to the Kubernetes components that make up Event Streams
    #
    components:

      #
      # Components for copying secret from Release Namespace to kube-system
      #
      essential:
        # component label for all the essential release wide resources
        compName: "essential"
        networkPolicy: "access-jobs"
        networkPolicyDefault: "access-default-deny"
        # all of the resources deployed by the secret secretsCopierClusterRole
        preInstallSA:
          name: "pre-install-sa"
        secretCopierClusterRole:
          name: "secret-copy-cr"
        secretCopierClusterRoleBindingReleaseNamespace:
          name: "secret-copy-crb-ns"
        secretCopierClusterRoleBindingKubeSystem:
          name: "secret-copy-crb-sys"
        secretCopierJob:
          name: "secret-copy-job"
        imagePullSecret:
          name: "secret-copy-secret"
        secretsDeleterSA:
          name: "secrets-deleter-sa"
        secretsDeleterClusterRole:
          name: "secrets-deleter-cr"
        secretsDeleterRoleBindingNamespace:
          name: "secrets-deleter-crb-ns"
        secretsDeleterRoleBindingSystem:
          name: "secrets-deleter-crb-sys"
        secretsDeleterJob:
          name: "secrets-deleter-job"
        certGenJob:
          name: "cert-gen-job"


      #
      # Components relating to the Kafka cluster
      #
      kafka:
        # component label for all the Kafka-related resources
        compName: "kafka"
        networkPolicy: "kafka-access"
        # all of the resources deployed by the Kafka charts
        statefulSet:
          name: "kafka-sts"
        headless:
          name: "kafka-headless-svc"
        brokerService:
          name: "kafka-broker-svc"
        metricsConfigMap:
          name: "metrics-cm"
        podManagerRole:
          name: "pod-manager-role"
        podManagerRoleBinding:
          name: "pod-manager-rolebinding"
        serviceAccount:
          name: "kafka-sa"

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
        headless:
          name: "zookeeper-headless-svc"
        fixed:
          name: "zookeeper-fixed-ip-svc"

      #
      # Components relating to the proxy that allows external access to Kafka
      #
      proxy:
        # component label for all the proxy-related resources
        compName: "proxy"
        networkPolicy: "proxy-access"
        # all of the resources deployed by the proxy charts
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
          name: "replicator-cm"
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

      #
      # Components relating to hosting the Admin REST API proxy
      #
      restproxy:
        # component label for all the ui-proxy-related resources
        compName: "restproxy"
        # all of the resources deployed by the rest-proxy charts
        service:
          name: "rest-proxy-svc"

      #
      # Components relating to hosting the admin UI
      #
      ui:
        # component label for all the UI-related resources
        compName: "ui"
        networkPolicy: "ui-access"
        # all of the resources deployed by the UI charts
        service:
          name: "ui-svc"
        deployment:
          name: "ui-deploy"
        role:
          name: "ui-role"
        roleBinding:
          name: "ui-rolebinding"
        oauth2ClientRegistration:
          name: "ui-oauth2-client-reg"
        oauthSecret:
          name: "oauth-secret"
        serviceAccount:
          name: "ui-sa"
      #
      # Components relating to hosting the admin ui-proxy
      #
      uiproxy:
        # component label for all the ui-proxy-related resources
        compName: "uiproxy"

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
        serviceAccount:
            name: "security-sa"
        accesscontroller:
          service:
            name: "access-controller-svc"
          deployment:
            name: "access-controller-deploy"
          serviceAccount:
            name: "access-controller-sa"

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

{{- end -}}
