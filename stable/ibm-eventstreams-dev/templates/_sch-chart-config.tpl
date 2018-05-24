{{- /*
"sch.config.values" contains the default configuration values used by
the Shared Configurable Helpers.

To override any of these values, modify the templates/_sch-chart-config.tpl file
*/ -}}
{{- define "sch.chart.config.values" -}}
sch:
  names:
    fullCompName:
      maxLength: 92
      releaseNameTruncLength: 36
      appNameTruncLength: 17
      compNameTruncLength: 39

  chart:
    # This override allows all IBM Event Streams subcharts to be labelled
    #  consistently as part of the same overall application
    appName: "ibm-eventstreams"

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
        # all of the resources deployed by the secret secretsCopierClusterRole
        secretCopierSA:
          name: "secret-copy-sa"
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
          name: "secretsdeleter-sa"
        secretsDeleterClusterRole:
          name: "secretsdeleter-cr"
        secretsDeleterRoleBindingNamespace:
          name: "secretsdeleter-crb-ns"
        secretsDeleterRoleBindingSystem:
          name: "secretsdeleter-crb-sys"
        secretsDeleterJob:
          name: "secretsdeleter-job"


      #
      # Components relating to the Kafka cluster
      #
      kafka:
        # component label for all the Kafka-related resources
        compName: "kafka"
        # all of the resources deployed by the Kafka charts
        statefulSet:
          name: "kafka-sts"
        headless:
          name: "kafka-headless-svc"
        brokerService:
          name: "kafka-broker-svc"
        configMap:
          name: "kafka-cm"
        podManagerRole:
          name: "pod-manager-role"
        podManagerRoleBinding:
          name: "pod-manager-rolebinding"
        serviceAccount:
          name: "kafka-service-account"


      #
      # Components relating to the ZooKeeper nodes
      #
      zookeeper:
        # component label for all the ZooKeeper-related resources
        compName: "zookeeper"
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
          name: "proxy-controller-deploy"
        configMap:
          name: "proxy-cm"
        clusterrole:
          name: "proxy-clusterrole"
        clusterroleBinding:
          name: "proxy-clusterrolebinding"

      #
      # Components relating to the Admin REST API
      #
      rest:
        # component label for all the REST API-related resources
        compName: "rest"
        # all of the resources deployed by the REST API charts
        service:
          name: "rest-svc"
        deployment:
          name: "rest-deploy"

      #
      # Components relating to hosting the Admin REST API proxy
      #
      restproxy:
        # component label for all the ui-proxy-related resources
        compName: "restproxy"
        # all of the resources deployed by the rest-proxy charts
        service:
          name: "rest-proxy-svc"
        configMap:
          name: "rest-proxy-cm"

      #
      # Components relating to hosting the admin UI
      #
      ui:
        # component label for all the UI-related resources
        compName: "ui"
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
          name: "ui-oauth2-client-registration"
        oauthSecret:
          name: "oauth-secret"

      #
      # Components relating to hosting the admin ui-proxy
      #
      uiproxy:
        # component label for all the ui-proxy-related resources
        compName: "uiproxy"
        # all of the resources deployed by the ui-proxy charts
        service:
          name: "admin-ui-proxy-svc"
        configMap:
          name: "ui-proxy-cm"



    # Images saved here in Source Control should be Master Images
    # DOCKER_IMAGE_TAGS_START
    images:
      kafkaTag: 2018-05-21-14.33.23-26ab2b84fa4a89fd50ba7fe4e899a3371fa0aff5
      metricsReporterTag: 2018-05-17-20.03.37-d2917ebc332813573c59e61fab3d708855d172ad
      zookeeperTag: 2018-05-17-20.19.48-0e3629c9a1664a69d250e32ae06221e85e2ce3b2
      proxyTag: 2018-05-21-14.20.25-ffbc3a4b0567a01c539ed159752b31d23888ecdc
      uiTag: 2018-05-24-14.55.28-fd7603f975ed14ea4755b63281aeb0340082cb53
      restTag: 2018-05-21-10.34.14-771d576b9bf47a5258fb75445f7c13e2e60b8cfe
      oauthTag: 2018-05-24-14.15.58-ceecba4b212262b7fd6afa1a05ff05c267529e1c
      codegenTag: 2018-05-23-17.07.37-41f0f7c4d62ecab07a495c6599243f4b79e18d49
    # DOCKER_IMAGE_TAGS_END


    metering:
      productName: IBM Event Streams
      productID: IBMEventStreamsTechPreview
      productVersion: 0.0.1
{{- end -}}
