############
## Shared ##
############
slot_prefix: ''
cloud_environment: 'pprd'
# Specifies the suffix used by the cluster for KubeDNS (default value used by k8s is cluster (dot) local)
clusterDomain: "{{ .Values.clusterDomain }}"
# :kubernetes_cluster_name: cluster name used by Armada (public) or icp-wa (private)
# - options:
#   "devwat-us-south-mzr-cruiser17", "stgwat-us-south-mzr-cruiser6",
#   "prdwat-us-south-mzr-cruiser6", "preprd-us-east-mzr-cr4"
#   "prodwat-syd04-cruiser3", "prdwat-ap-north-mzr-cruiser1", "prdwat-seo01-cr1"
#   "prdwat-eu-gb-mzr-cruiser3", "prdwat-eu-de-mzr-cruiser3"
#   "dedcm-fra02-cruiser1", "dedcm-par01-cruiser1",  "prdwat-wdc06-cruiser1"
#   "icp-wa"
kubernetes_cluster_name: "icp-wa"
ll_registry: "etcd:/etc/secrets/etcd/etcd_connection"
ll_discovery: "etcd:/etc/secrets/etcd/etcd_connection"
litelinks:
  registerExternal: False
slot:
  create_objectore_entries: "true"
  use_tas: "true"
  reaper_interval_secs: "20"
  app_start_min_interval: "0.5"
  train_cpu_millis: "100,1000"
  training_memory_mb: ''
  # One can hardly find worse decision
  # * the code inside the operator interprets 'double{ .Release.Namespace }' and `double{ .Release.Name }} in the components/etcd.py the %%% means new line (why not to have multiline input ???)
  # {% raw %} is there for ansible to present proceesing the double { by jinja templating engine in ansible
  # and needs to be wrapped inside double { "{% raw }}...." } if in helm template to prevent HELM chart (that install the operator) to process the `double{` insice the value
  training_env_vars: "{{ "{% raw %}ICP_ENVIRONMENT=true@@@KUBEDNS_SUFFIX=-headless.{{ .Release.Namespace }}:50443@@@KUBEDNS_PREFIX=dns:///{{ .Release.Name }}-@@@CERTIFICATES_IMPORT_LIST=/etc/secrets/cos/ca.crt:cos-minio@@@SIREG_CERT_PATH=/opt/bluegoat/service/dynconfig/sireg_certificate@@@WORDEMBEDDING_MODE=CLU@@@CLU_EMBEDDING_SERVICE_ADDRESS=dns:///{{ .Release.Name }}-clu-embedding-service.{{ .Release.Namespace }}{% endraw %}" }}"
# global.autoscaling.enabled - Specifies whether Horizontal Pod Autoscalers should be created for the Watson Assistant deployments.
autoscaling:
  enabled: true
# global.pdb.enabled - Specifies whether pdb should be created for the Watson Assistant deployments.
pdb:
  enabled: true
# global.apiV2.enabled - Enables V2 API in the Watson Assistant. It adds new microservices if enabled.
apiV2:
  enabled: true
# Options are soft, hard or disabled.
podAntiAffinity: "soft"

############
## Images ##
############

# The default values that are injested into all WA images (using yaml techniques).
# These values appies in case in the crd cluster.imageRepository is empty (as it will be used during development)
container_images_defaults:
  registry: cp.icr.io
  namespace: cp/watson-assistant

container_images:
  analytics:
    name: analytics
    tag: 1.0.3.202009171543-81-g0406359-wa-icp-1.5.0
  conan_tools:
    name: conan-tools
    tag: 20201118-0229
  tas:
    name: clu-serving
    tag: 20201123-142748-15-31e1eb-wa_icp_1.5.0-icp-92c2215
  sireg:
    name: sireg
    tag: wdc-20181119-cf4a181a-84-master-ea98066c-165
  model-loader-de-tok-20160801:
    name: sireg-model-ubi
    tag: de-tok-20160801-20201119-132042
  model-loader-ja-tok-20160902:
    name: sireg-model-ubi
    tag: ja-tok-20160902-20201119-132042
  model-loader-ko-tok-20181109:
    name: sireg-model-ubi
    tag: ko-tok-20181109-20201119-132042
  store:
    name: store
    tag: "20201123-162822-a6cecf"
  store_litelinks_grpc:
    name: litelinks-grpc
    tag: "20201118-141552-fe0a53"
  dialog:
    name: dialog
    tag: "20201124-0428-08ec41fd-wa-icp-1.5.0-2"
  skill_search:
    name: skill-search
    tag: "20201119-030637-dc9f12-wa-icp-1.5.0-4"
  slad:
    name: clu-training
    tag: "20201123-142748-15-31e1eb-wa_icp_1.5.0-icp"
  spellchecker_mm:
    name: spellcheck-server-image
    tag: wa-icp-1.5.0-20201206-4-3c92c7
  model_mesh:
    name: model-mesh
    tag: main-20201111-5
  model_mesh_tfsa:
    name: model-mesh-tfsa
    tag: main-20201111-7
  model_mesh_tfserving:
  model_mesh_tfserving:
    name: tensorflow-serving
    tag: 1.15.0-reconfig-poll-ubi-20201112-5
  model_mesh_upload:
    name: tensorflow-model-upload
    tag: 20201115-89-b2e0e5
  sync_resources:
    name: sync-resources
    tag: wa-icp-1.5.0-20201206-6-b3982e
  store_sync:
    name: store-sync
    tag: "20201118-141449-1f7298"
  integrations:
    name: servicedesk-integration
    tag: 20201124-093740-99fb8d4d-ci_wa_icp_1.5.0
  recommends_engine:
    name: improve-recommendations-engine-x86_64
    tag: 1.2.15-20201116195914
  recommends_api:
    name: recommends-rest-x86_64
    tag: 1.2.15-20201116184700
  nlu:
    name: clu-controller
    tag: 20201118-113126-2-a13238
  master:
    name: training-master
    tag: 20201118-112433-2-19ef62
  ed_openentities_serving:
    name: openentities-serving
    tag: 20201118-112756-2-d9ae13-wa_icp_1.5.0
  ed_objectstore_py4j_bridge:
    name: objectstore-py4j-bridge
    tag: 20201118-113542-2-05f692
  clu_embedding_service:
    name: clu-embedding-service
    tag: 20201207-13-f0727c-wa_icp_1.5.0-icp
  system-entities:
    name: system-entities
    tag: 20201110-085016-f6b002
  ui:
    name: ui
    tag: 20201203-151719-1bacc9290
  dvt:
    name: dvt-bdd-ubi
    tag: 20201208-072201-f998d4-CP4D_1.5

# Images that are not directly used by this operator (and provided by WA team).
#   They are passed to other (datastore) operators using CRD
#   The main distinction is that they do not live in stg.icr.io/cp/watson-assistant namespace
external_images:
  cloudpakopenElasticsearch:
    registry: cp.icr.io
    namespace: "cp"
    name: opencontent-elasticsearch-6.8.13
    tag: 1.1.185
  cloudpakopenElasticsearchPlugin:
    registry: cp.icr.io
    namespace: "cp"
    name: opencontent-elasticsearch-base-plugins-6.8.13
    tag: 1.1.185
  opencontentEtcd3:
    registry: cp.icr.io
    namespace: "cp"
    name: opencontent-etcd-3
    tag: 2.1.0
  postgres-db:
    registry: cp.icr.io
    namespace: "cp/cpd"
    name: edb-postgresql-12
    tag: ubi8-amd64
  postgres-ha:
    registry: cp.icr.io
    namespace: "cp/cpd"
    name: edb-stolon
    tag: v1-ubi8-amd64
  minio:
    registry: cp.icr.io
    namespace: "cp"
    name: opencontent-minio
    tag: 1.1.5
  minio-client:
    registry: cp.icr.io
    namespace: "cp"
    name: opencontent-minio-client
    tag: 1.0.5
  minio-creds:
    registry: cp.icr.io
    namespace: "cp"
    name: opencontent-icp-cert-gen-1
    tag: 1.1.9

##############
## Replicas ##
##############

# Replicas for each t-shirt size
# NOTE: sireg allows per-model replication overrides in each model's config
#   by setting replicas directly there
replicas:
  small:
    store: 1
    master: 1
    dialog: 1
    tfmm: 1
    ui: 1
    recommends: 1
    spellchecker-mm: 1
    tas: 1
    store-sync: 1
    clu-embedding: 1
    kafka: 1
    system-entities: 1
    nlu: 1
    analytics: 1
    ed: 1
    integrations: 1
    skill-search: 1
    sireg: 1
  medium:
    store: 2
    master: 2
    dialog: 2
    tfmm: 2
    ui: 2
    recommends: 2
    spellchecker-mm: 2
    tas: 2
    store-sync: 2
    clu-embedding: 2
    kafka: 2
    system-entities: 2
    nlu: 2
    analytics: 2
    ed: 2
    integrations: 2
    skill-search: 2
    sireg: 2
  large:
    store: 3
    master: 2
    dialog: 3
    tfmm: 3
    ui: 3
    recommends: 2
    spellchecker-mm: 3
    tas: 3
    store-sync: 2
    clu-embedding: 3
    kafka: 3
    system-entities: 3
    nlu: 3
    analytics: 3
    ed: 3
    integrations: 3
    skill-search: 3
    sireg: 3

#############
## Private ##
#############

private:
  metering:
    productId: "2eb0774c8a3841f09b7b75c9fb1fbdd7"
    productName: "IBM Watson Assistant for IBM Cloud Pak for Data"
    productChargedContainers: "All"
    productMetric: "VIRTUAL_PROCESSOR_CORE"
    cloudpakId: "2eb0774c8a3841f09b7b75c9fb1fbdd7"
    cloudpakName: "IBM Watson Assistant for IBM Cloud Pak for Data"
  proxy_hostname: ""
  master_hostname: "10.26.5.101" # TODO: Hardcoded for now should eventually be overridden in the CR


## Components ##############################################################

###########################
## Event Streams / kafka ##
###########################
kafka:
  metrics:
    expose: True
    path: '/metrics'
  kafka:
    resources:
      limits:
        cpu: 1
        memory: "2Gi"
      requests:
        cpu: 1
        memory: "2Gi"
  zookeeper:
    resources:
      limits:
        cpu: 1
        memory: "1Gi"
      requests:
        cpu: 1
        memory: "1Gi"
  entityOperator:
    resources:
      limits:
        cpu: 1
        memory: "1Gi"
      requests:
        cpu: 1
        memory: "1Gi"

##############
## Postgres ##
##############
postgres:
  clusterSize: 3
  customAnnotations:
    maker: omh
    operator_vendor: edb
  customLabels: {}
  database:
    resources:
      requests:
        cpu: "50m"
        memory: "1Gi"
      limits:
        cpu: "1000m"
        memory: "1Gi"
    #storageClass:        "" # If specified sets the storage class name for EDB postgres instances.  If not specified default to CR spec.postgres.storageClassName, resp. spec.cluster.storageClassName (the most general one)
    #archiveStorageClass: "" # If specified sets the storage class name for archive storage of postgres.  If not specified default to CR spec.postgres.storageClassName, resp. spec.cluster.storageClassName (the most general one)
    #walStorageClass:     "" # IF specified sets the storage class name used by edb operator for storing WAL archives.  If not specified default to CR spec.postgres.storageClassName, resp. spec.cluster.storageClassName (the most general one)
  databasePort: 5432
  serviceAccount: "edb-operator"
  noRedwoodCompat: true
  postgresType: "PG"
  postgresVersion: 12
  primaryConfig:
    max_connections: "100"
  useStub: false


###########
## Store ##
###########
store:
  store_db_schema_schema_version: ""
  enable_metrics: "true"
  enable_elastic_search: True # Specifies if workspace search / aka store-sync feature is used

  # Since we are reusing secret from store-sync the config is not used.
  #workspaceSearch:
  #    datastoreName: store # Name of the Elastic Searcd datastore that is used for workspace-search feature

  activity_tracker:
    enabled: False
    log_directory: "/var/log/at"
  session_store:
    provisioned: True
    icd_provisioned: False
  ENABLE_ATHENA: "true"
  ENABLE_CACHE: "true"
  enable_stable_export: "true"
  analytics:
    message_logging:
      litelinks: "false" # ANALYTICS_ENABLED_FOR_V1_MESSAGE_LOGGING
      kafka: "true" # KAFKA_ENABLED_FOR_V1_MESSAGE_LOGGING
    rest:
      features:
        v1_log_get: "true" # ANALYTICS_REST_SERVICE_ENABLED_FOR_V1_LOG_GET
        v2_assistant_log_post: "true" # ANALYTICS_REST_SERVICE_ENABLED_FOR_V2_ASSISTANT_LOG_POST
        v1_workspace_log_get: "true" # ANALYTICS_REST_SERVICE_ENABLED_FOR_V1_WORKSPACE_LOG_GET
        v1_workspace_log_post: "true" # ANALYTICS_REST_SERVICE_ENABLED_FOR_V1_WORKSPACE_LOG_POST
        v1_report: "true" # ANALYTICS_REST_SERVICE_ENABLED_FOR_V1_REPORT
        user_data: "true" # ANALYTICS_REST_SERVICE_ENABLED_FOR_USER_DATA
      validation_disabled:
        v1_log_get: "true" # ANALYTICS_REST_SERVICE_DISABLE_VALIDATION_FOR_V1_LOG_GET
        v1_workspace_log_post: "true" # ANALYTICS_REST_SERVICE_DISABLE_VALIDATION_FOR_V1_WORKSPACE_LOG_POST
        v2_log_get: "true" # ANALYTICS_REST_SERVICE_DISABLE_VALIDATION_FOR_V2_LOG_GET
        v1_workspace_log_get: "true" # ANALYTICS_REST_SERVICE_DISABLE_VALIDATION_FOR_V1_WORKSPACE_LOG_GET
        v1_report: "true" # ANALYTICS_REST_SERVICE_DISABLE_VALIDATION_FOR_V1_REPORT
        user_data: "true" # ANALYTICS_REST_SERVICE_DISABLE_VALIDATION_FOR_USER_DATA
      timeout: 10000 # ANALYTICS_REST_TIMEOUT
      keepAlive:
        enabled: "false" # ANALYTICS_REST_SERVICE_DO_KEEP_ALIVE
        timeout: 10000  # ANALYTICS_REST_SERVICE_KEEP_ALIVE_TIMEOUT_MS
    endpoint:
      # service: { .Release.Name }-analytics   ANALYTICS_REST_SERVICE_NAME
      port: 8080      # ANALYTICS_REST_SERVICE_PORT
      port_name: rest  # ANALYTICS_REST_SERVICE_PORT_NAME
      cert:
        #secret_name: { .Release.Name }-analytic-litelinks
        secret_key: litelinks_ssl_cert.pem
        #hostname: { .Release.Name }-analytic # ANALYTICS_REST_CERT_HOST
  enable_cap: False
  enable_dialog_litelinks_vault: True
  enable_analytics_litelinks_vault: False # Should no longer be required with analytics_rest
  enable_nlu_litelinks_vault: True
  kafka:
    enabled: True
    auto_create_topic: "true"
    partitions: "4"
    topic_message_log: ""
  postgres:
    provisioned: True
    db_pool_size: "10"
  redis:
    provisioned: False
  elastic:
    skip_cert_check: "true"
  rate_limited: "false"
  enable_training_queue: "true"
  uv_threadpool_size: "64"
  fuzzy_match_languages: "en,es,fr,it,pt-br,de,cs,ja,ar,ko,nl"
  new_system_entities_languages: '["en","es","pt-br","fr","it","ja","de","ko","ar","nl","zh-tw","zh-cn","cs"]'
  spellcheck_languages: '["en","fr"]'
  supported_integrations: '["chat"]'
  bluemix:
    enable_segment: False
  identifier_keys:
    tooling: '''["a064c34f-73f7-4ddf-8e24-d963879af26c"]'''
    unmetered: '''[""]'''
    internal: '''["4b1894c0-5380-4fca-b81d-394aee22b180", "icp-helm-health-testing", "77bbbe25-c718-478c-a50e-05707cff20cf"]'''
    unlimited: '''["388096f4-6d85-4949-b1b2-263b67d17f8f", "bf0cdfa4-ed1d-443f-b1d2-a789530c006d"]'''
  enter_purgatory_on_exit: 'false'
  massage_env_vars: 'true'
  integrations:
    enable_v2: "true"
  resources:
    requests:
      cpu: "600m"
      memory: "1.5Gi"
    limits:
      cpu: "4"
      memory: "1.5Gi"
  autoscaling:
    enabled: True
    max_replicas: 10
    target_cpu_utilization_percentage: 100
  extra_var:
    ENABLE_ICP: "true"
    ENABLE_RECOMMENDS_DELETE: "false"
    ENABLE_SERVICE_DESK_CACHE_NOTIFY: "true"
    ENABLE_SNAPSHOT_MODEL_COPY: "true"
    ENABLE_V1_LATEST_API_VERSION: "true"
    ENABLE_V2_LATEST_API_VERSION: "true"
    IBM_WATSON_LITELINKS_BLOCKING_CALLS_ANALYTICS_ENABLED: "false"
    IBM_WATSON_LITELINKS_BLOCKING_CALLS_VOYAGER_ENABLED: "true"
    LATEST_API_VERSION: "2020-09-24"
    SEGMENT_EVENT_NAME: "API Call"
    STOP_AGENT_DEFINITION_API_PROXY: "true"
    STOP_AGENT_INSTANCE_API_PROXY: "true"
    STOP_SNAPSHOT_API_PROXY: "true"
    STOP_TEMPLATE_API_PROXY: "true"
    STOP_V2_MESSAGE_PROXY: "true"
    STOP_WORKER_DEFINITION_API_PROXY: "true"
    SYNC_BODY_LIMIT: "50mb"
  containers:
    litelinks_grpc:
      name: "litelinks-grpc"
      enabled: True
      env:
        host: "localhost"
        port: 9110
        max_inbound_message_size_bytes: "52428800"
        grpc_core_thread_count: "20"
        grpc_max_thread_count: "50"
        grpc_thread_keepalive_minutes: "30"
        retry_initialisation: "true"
        truststore_path: "/app/truststore.jks"
        use_failing_instances: "false"
        readiness_service_test_timeout_in_ms: "10000"
        readiness_check_interval_in_ms: "30000"
        readiness_check_delay_in_ms: "10000"
        readiness_do_logging_on_success: "false"
        readiness_affected_by_clu_service_availabilty: "false"
        readiness_affected_by_dialog_service_availabilty: "false"
        readiness_affected_by_analytics_service_availabilty: "false"
      resources:
        requests_cpu: .25
        requests_memory: "1.5Gi"
        limits_cpu: 2
        limits_memory: "1.5Gi"
  backup:
    # To disable the cronjob, set suspend to True
    suspend: False
    # Here you can change the schedule of the backups
    # For example, 0 23 * * * equates to 11pm everyday
    # see https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/
    schedule: "0 23 * * *"
    access_mode: ReadWriteOnce
    size: 1Gi
    # Specify how many jobs to keep and dumps stored in PVC to keep
    history:
      jobs:
        success: 30
        failed: 10
      #Sunday=0, Monday=1, Tuesday=2 etc.
      files:
        weekly_backup_day: 0
        #The number of backups to keep taken on weekly_backup_day
        keep_weekly: 4
        #The number of backups to keep that were taken on all the other days of the week
        keep_daily: 6



############
## Dialog ##
############

dialog:
  metrics:
    expose: True
    path: '/metrics'
  event_streams:
    enabled: False
    suggestion_event_topic: ''
    log_skill_deleted_events_to_kafka: False
  service:
    type: 'ClusterIP'
  redis:
    mode: 'provided'
  haproxy:
    use_redis: False
  update_strategy:
    maxUnavailable: 0
    maxSurge: '35%'
  logs_storage: 'emptyDir'
  autolearn:
    enabled: False
    ssl: False
  litelinks:
    pem_ssl_cert_enabled: True
  run_as: 'JAR'
  l2_cache_mode: 'redis'
  url_fetcher:
    host: ''
  autoscaling:
    enabled: True
    max_replicas: 10
    target_cpu_utilization_percentage: 100
  extra_var:
    ELEVATE_PLAN_FOR_ALL: 'true'
    REDIS_CACHE_EXPIRY: '60'
    BLOCKED_CALLOUT_IPS: '[]'
    MAX_DELTA_MEMORY_SIZE_BYTES: '5242880'

#################
## SkillSearch ##
#################

skill_search:
  service:
    type: 'ClusterIP'
  update_strategy:
    maxUnavailable: 0
    maxSurge: 4
  autoscaling:
    enabled: True
    max_replicas: 10
    target_cpu_utilization_percentage: 100
  env_vars:
    SKILLS_ENABLED: 'SEARCH'
    MAX_THREADS: '20'
    DISCOVERY_CONFIDENCE_THRESHOLD_DEFAULT: '0.0'
    DISCOVERY_PASSAGES_MAX_PER_DOCUMENT: '3'
    DISCOVERY_PASSAGES_CHARACTERS: '325'
    DISCOVERY_PASSAGES_FIND_ANSWERS: 'false'
    DISCOVERY_PASSAGES_MAX_ANSWERS_PER_PASSAGE: '1'
    DISCOVERY_DEDUPLICATE_FIELDS: ''

#########
## CLU ##
#########

clu:
  training_logs_storage: 'none'
  config_secret_name: 'wa-clu-config-secret'
  cos_secret_name: 'wa-tls-ssl-minio'
  objectstore:
    primary:
      type: 'ibm'
      softlayer: 'TBD:blah'
      ibm: 'TBD:blah'
    #fallback:
    #  type: 'ibm'
    #  softlayer: 'TBD:blah'
    #  ibm: 'TBD:blah'
  mongodb:
    icd_provisioned: False #TODO default value?
  master:
    version: '1'
    logs:
      storage: 'emptyDir' #TODO what's the default value here?
    service:
      type: 'ClusterIP'
    autoscaling:
      enabled: True
      max_replicas: 10
      target_cpu_utilization_percentage: 100
    litelinks:
      service_name: 'DELETE:tas_ll_master'
      name: 'DELETE:tas_ll_master_2'
      vault:
        enabled: True #TODO what is the default value
      ssl:
        cert: 'TBD:master-cert'
        private_key: 'TBD:master-pk'
    secret:
      name: 'TBD:master-sec'
    probes:
      readiness:
        initial_delay_seconds: 120
      liveliness:
        initial_delay_seconds: 120
    pagerduty:
      api_key: ''
      url: ''
    config:
      train:
        namespace: '' #TODO currently for ICP session.namespace is used
        use_kubernetes: 'true' #IMPORTANT that this not have capital T
        docker:
          trust_all_docker_registry_certificates:  'true'
      reaper_interval_secs: '20'
      app_start_min_interval: '0.5'
      max_heap_size: '256m'

  tas:
    litelinks:
      name: 'TODO_tas_litelinks_name'
    secret:
      name: 'TODO_tas_litelinks_secret'
    scaleup_rpm_threshold: 850
    autoscaling:
      enabled: True
      max_replicas: 10
      target_cpu_utilization_percentage: 90

  nlu:
    version: '20200830-003213-228-9d65fd'
    logs:
      storage: 'emptyDir' #TODO what's the default value here?
    service:
      type: 'ClusterIP'
    autoscaling:
      enabled: True
      max_replicas: 10
      target_cpu_utilization_percentage: 100
    litelinks:
      register_external: False #TODO what;s the default value
      service_name: 'TODO_litelinks_service_name'
      name: 'TODO_litelinks_name'
      vault:
        enabled: True #TODO what is the default value
      ssl:
        cert: 'TODO_litelinks_ssl_cert'
        private_key: 'TODO_litelinks_ssl_key'
    probes:
      readiness:
        initial_delay_seconds: 120
      liveliness:
        initial_delay_seconds: 120

  tfmm:
    litelinks_name: "" # Defaults to "{ slot_name }-tf-mm" if not specified
    progress_deadline_seconds: 1200 # the model upload step took around 15 min in stage environment, putting the deadline as 20 minutes (20 * 60 = 1200 seconds)
    statsd_enabled: true   # configures if the statsd container should be a part of the pod
    enabled: true
    secret_name: "" # If empty defaults to `clu-config-secret` and the global secret is used, otherwise slot+component specific secret is created and used.
    service:
      type: ClusterIP # The type of service to create. The value ClusterIP can be overridden by litelinks.registerExternal options. Possible values are ClusterIP, NodePort, LoadBalancer
    litelinks:
      registerExternal: false # Specifies if the LL should register (in ETCD/ZK) the external NodeIP:Port - inter-cluster communication
    autoscaling:
      enabled: True
      max_replicas: 10
      target_cpu_utilization_percentage: 90
    probes:
      readiness:
        initial_delay_seconds: 120
      liveliness:
        initial_delay_seconds: 120
    tf_mm_tensorflow_serving_version: '1.15.0-reconfig-poll-ubi-20200504-8'
    # Component configurations
    components:
      modelmesh_runtime:
        resources:
          requests:
            cpu: .3
            memory: 1536Mi
          limits:
            cpu: 5
            memory: 1536Mi
        env:
          heap_size: 1024m
      tensorflow_serving_adapter:
        resources:
          requests:
            cpu: .1
            memory: 768Mi
          limits:
            cpu: 2.0
            memory: 768Mi
      tensorflow_serving:
        resources:
          requests:
            cpu: .5
            memory: 6144Mi
          limits:
            cpu: 7.5
            memory: 6144Mi
    init:
      resources:
        requests:
          cpu: 100m
          memory: 256Mi
        limits:
          cpu: 200m
          memory: 256Mi

  ed:
    service:
      type: ClusterIP # The type of service to create. The value ClusterIP can be overridden by litelinks.registerExternal options. Possible values are ClusterIP, NodePort, LoadBalancer
    autoscaling:
      enabled: True
      max_replicas: 10
      target_cpu_utilization_percentage: 100
    # Component configurations
    components:
      mm_runtime:
        env:
          heap_size: "800m"
        image:
          pullPolicy: ''
        resources:
          requests:
            cpu:    "150m"
            memory: "1Gi"
          limits:
            cpu:    "4"
            memory: "1Gi"
        probes:
          readiness:
            initialDelaySeconds: 20
          liveness:
            initialDelaySeconds: 30
      ed_mm:
        total_capacity: '512'     # in MB. Have to be in synch with container memory requests/limits (limits should by default be 512 MB higer)
        image:
          pullPolicy: ''
        env:
          wordembedding_mode: CLU
        resources:
          requests:
            cpu:    "500m"
            memory: "1Gi"
          limits:
            cpu:    "4"
            memory: "1Gi"
      ob_py4j:
        image:
          pullPolicy: ''
        resources:
          requests:
            cpu:    "20m"
            memory: "1Gi"
          limits:
            cpu:    "4"
            memory: "1Gi"
        probes:
          readiness:
            initialDelaySeconds: 20
          liveness:
            initialDelaySeconds: 30

  clu_embedding_service:
    service_name: "clu-embedding-service"
    deployment_name: "clu-embedding-service"
    image:
      pullPolicy: IfNotPresent
    resources:
      limits:
        cpu: "4"
        memory: "3Gi"
      requests:
        cpu: "500m"
        memory: "3Gi"
    probes:
      livenessProbe:
        failureThreshold: 3
        initialDelaySeconds: 120
        periodSeconds: 120
        successThreshold: 1
        timeoutSeconds: 60
      readinessProbe:
        failureThreshold: 3
        initialDelaySeconds: 120
        periodSeconds: 120
        successThreshold: 1
        timeoutSeconds: 60
    topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: "failure-domain.beta.kubernetes.io/zone"
        whenUnsatisfiable: ScheduleAnyway # Not to block pod recreation in case complete zone is out.
        # labelSelector: created automatically
    podDisruptionBudget:
      maxUnavailable: 1
    autoscaling:
      enabled: True
      max_replicas: 10
      target_cpu_utilization_percentage: 100


#########
## TAS ##
#########

tas:
  system_entities:
    tokenized_languages: "ja,ko,zh"
    replace_legacy_sys_entities_languages: "en,de,pt,fr,es,it,nl,cs,ja,ko,ar,zh-cn,zh-tw"
    disable_system_entities_legacy_mode: "true"
    disable_sireg_sys_entities: "true"
  CUSTOM_JVM_ARGS: "-Dtas.static_heap_overhead_mbytes=1024"
  HEAP_SIZE: "4000m"
  resources:
    requests:
      cpu: "400m"
      memory: "5Gi"
    limits:
      cpu: "4"
      memory: "5Gi"

####################
## EntitiesDistro ##
####################

###########
## tf-mm ##
###########

###########
## SireG ##
###########

sireg:
  enable_custom_certificates: True
  autoscaling:
    enabled: True
    max_replicas: 10
    target_cpu_utilization_percentage: 100

  models:
    ar-tok:
      model_name: ar-tok
      model_version: 20160801
      model_id: ar-tok-20160801
      model_path: ar-tok/ar_tokenizer_1
      ddinf_file: models/libACE_models/ar_tokenizer.ddinf
      memory_limit: 1300Mi
      max_worker_mem_growth_factor: 1.25
      max_worker_mem_mb: 380
      image_version: 2016
    de-tok:
      model_name: de-tok
      model_version: 20160801
      model_id: de-tok-20160801
      model_path: de-tok/de_tokenizer_1
      ddinf_file: models/libACE_models/de_tokenizer.ddinf
      memory_limit: 1350Mi
      max_worker_mem_growth_factor: 1.25
      max_worker_mem_mb: 400
      image_version: 2016
    en-sysent:
      model_name: en-sysent
      model_version: 20160801
      model_id: en-sysent-20160801
      model_path: en-sysent/en_us_sysent_2
      ddinf_file: en_system_entities.ddinf
      memory_limit: 16000Mi
      num_workers: 2
      requests_cpu: 2500m
      image_version: 2016
    es-tok:
      model_name: es-tok
      model_version: 20160801
      model_id: es-tok-20160801
      model_path: es-tok/es_tokenizer_1
      ddinf_file: models/libACE_models/es_tokenizer.ddinf
      memory_limit: 500Mi
      max_worker_mem_growth_factor: 1.3
      max_worker_mem_mb: 145
      image_version: 2016
    fr-tok:
      model_name: fr-tok
      model_version: 20160801
      model_id: fr-tok-20160801
      model_path: fr-tok/fr_tokenizer_1
      ddinf_file: models/libACE_models/fr_tokenizer.ddinf
      memory_limit: 500Mi
      max_worker_mem_growth_factor: 1.3
      max_worker_mem_mb: 145
      image_version: 2016
    it-tok-20170222:
      model_name: it-tok
      model_version: 20170222
      model_id: it-tok-20170222
      model_path: it-tok/it_tokenizer_2
      ddinf_file: models/libACE_models/sire.ddinf
      memory_limit: 500Mi
      max_worker_mem_growth_factor: 1.3
      max_worker_mem_mb: 145
      image_version: 2016
    it-tok:
      model_name: it-tok
      model_version: 20160801
      model_id: it-tok-20160801
      model_path: it-tok/it-tokenizer_1
      ddinf_file: models/libACE_models/it_tokenizer.ddinf
      memory_limit: 500Mi
      max_worker_mem_growth_factor: 1.4
      max_worker_mem_mb: 145
      image_version: 2016
    ja-tok-20160902:
      model_name: ja-tok
      model_version: 20160902
      model_id: ja-tok-20160902
      model_path: ja-tok/ja_tokenizer_20160902.tar.gz
      ddinf_file: models/libACE_models/sire.ddinf
      memory_limit: 1700Mi
      max_worker_mem_growth_factor: 1.8
      max_worker_mem_mb: 500
      image_version: 2016
    ja-tok:
      model_name: ja-tok
      model_version: 20160801
      model_id: ja-tok-20160801
      model_path: ja-tok/ja_tokenizer_1
      ddinf_file: models/libACE_models/ja_seg.ddinf
      memory_limit: 4000Mi
      max_worker_mem_growth_factor: 2.3
      max_worker_mem_mb: 1850
      num_workers: 2
      requests_cpu: 1000m
      image_version: 2016
    ko-tok-20170804:
      model_name: ko-tok
      model_version: 20170804
      model_id: ko-tok-20170804
      model_path: ko-tok/ko-kr-2017-08-04.tgz
      ddinf_file: models/libACE_models/sire.ddinf
      memory_limit: 1500Mi
      max_worker_mem_growth_factor: 2
      max_worker_mem_mb: 653
      num_workers: 2
      image_version: 2016
    ko-tok-20170920:
      model_name: ko-tok
      model_version: 20170920
      model_id: ko-tok-20170920
      model_path: ko-tok/ko-kr-2017-09-20.tgz
      ddinf_file: models/libACE_models/sire.ddinf
      memory_limit: 2050Mi
      num_workers: 2
      max_worker_mem_growth_factor: 3
      max_worker_mem_mb: 981
      image_version: 2016
    ko-tok-20181109:
      model_name: ko-tok
      model_version: 20181109
      model_id: ko-tok-20181109
      model_path: ko-tok/ko-kr-2018-11-09.tgz
      ddinf_file: ko-kr_tokenizer_20181109-01/sire.ddinf
      memory_limit: 4000Mi
      num_workers: 2
      max_worker_mem_growth_factor: 4
      max_worker_mem_mb: 1700
      image_version: 2018
    ko-tok:
      model_name: ko-tok
      model_version: 20160801
      model_id: ko-tok-20160801
      model_path: ko-tok/ko_tokenizer_1
      ddinf_file: models/libACE_models/ko_tokenizer.ddinf
      memory_limit: 1000Mi
      max_worker_mem_growth_factor: 3.2
      max_worker_mem_mb: 300
      image_version: 2016
    nl-tok:
      model_name: nl-tok
      model_version: 20160801
      model_id: nl-tok-20160801
      model_path: nl-tok/nl_tokenizer_1
      ddinf_file: models/libACE_models/nl_tokenizer.ddinf
      memory_limit: 1500Mi
      max_worker_mem_growth_factor: 1.25
      max_worker_mem_mb: 450
      image_version: 2016
    pt-tok:
      model_name: pt-tok
      model_version: 20160801
      model_id: pt-tok-20160801
      model_path: pt-tok/pt_tokenizer_1
      ddinf_file: models/libACE_models/pt_tokenizer.ddinf
      memory_limit: 500Mi
      max_worker_mem_growth_factor: 1.3
      max_worker_mem_mb: 145
      image_version: 2016
    zhcn-tok:
      model_name: zhcn-tok
      model_version: 20160801
      model_id: zhcn-tok-20160801
      model_path: zhcn-tok/zhcn_tokenizer_1
      ddinf_file: models/libACE_models/zhcn_tokenizer.ddinf
      memory_limit: 7800Mi
      max_worker_mem_growth_factor: 1.5
      max_worker_mem_mb: 3800
      num_workers: 2
      image_version: 2016
    zhtw-tok:
      model_name: zhtw-tok
      model_version: 20171130
      model_id: zhtw-tok-20171130
      model_path: zhtw-tok/zhtw_tokenizer_20171130.tar.gz
      ddinf_file: zh-tw_wks_tokenizer_20171130-01/sire.ddinf
      memory_limit: 1000Mi
      image_version: 2016

#################
## Gateway     ##
#################
gateway:
  addon_name: "gw-addon"
  instance_name: "gw-instance"
  port: 5000
  operator:
    version: "v1.0.3"
  ##################
  ## Addon in CPD ##
  ##################
  # The fields below control the images, links and version that gets displayed in the CPD UI
  addon:
    # label is used as identifier and in the path /watson/{label} -> /watson/assistant
    label: "assistant"
    display_name: "Watson Assistant"
    short_description: "Give your customers fast, straightforward, and accurate answers to their questions, across any application, device, or platform."
    long_description: "Use the Watson Assistant service to design an engaging conversation for your virtual assistant to follow as it interacts with your customers. As you identify the common and unique needs of your customers, the service uses industry-leading machine learning technologies to build a custom AI model for you. The model understands customer requests and maps them to the appropriate solutions. Your assistant can even connect to the customer engagement resources you already use to deliver a unified, problem-solving experience."
    deploy_docs: "https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/cpd/svc/watson/assistant-install.html"
    product_docs: "https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/cpd/svc/watson/assistant.html"
    api_reference_docs: "https://cloud.ibm.com/apidocs/assistant/assistant-data-v2"
    getting_started_docs: "https://cloud.ibm.com/docs/assistant-data"
    max_instances: 30
    product_images: 3
    version: "1.5.0"
    instance_id: ""
    resource_group_id: "ba4ab788-68a9-492b-87da-9179cb1e6541"
    account_id: "02a92df0-657c-43c9-94fc-2280450b1e0b"
    plan_id: "cec95e99-75b8-4e2f-a176-8687f31597fd"
    show_user_management: true
    show_credentials: true

################
## Spellcheck ##
################

spellcheck:
  supported_languages:
    - en
    - fr
  autoscaling:
    enabled: True
    max_replicas: 10
    target_cpu_utilization_percentage: 100



################
## Recommends ##
################

recommends:
  is_clu_embedding_enabled: true
  is_log_message_enabled: false
  is_clustering_enabled: false
  is_metrics_enabled: false
  is_content_enabled: false
  cache:
    enabled: "true"          # whether to use caching for servicing requests
    store: "redis"           # the cache store. redis, elastic
    clustering_ttl: "604800" # TTL for intent clustering results in seconds, default 1 week
    retries_on_error: "3"    # The number of retry attempts if an error is encountered running a redis command
    delay_before_retry: "2"  # Time, in seconds, to delay subsequent retry attempts after an error

  pager_duty:
    enabled: "false"                         # default is pager duty notifications are disabled
    endpoint: "https://events.pagerduty.com" # default PD endpoint available to all public env, may need overriding in dedicated
    service_key: ""                          # service key to use, should be set per environment

  components:
    engine:
      EntityRecommendation:
        word_embeddings_mode: "clu"
        max_neighbor_lookups: 100
      IntentConflictRecommendation: {}
      Logging: {}
      language_config:
        en:
          word_embeddings:
            - "clu"
          ontologies: []
          models:
            - "Logistic"
          combos:
            - "clu"
          meta_model:
            "clu-Logistic": 1
            "random": 0
        es:
          word_embeddings:
            - "clu"
          ontologies: []
          models:
            - "Logistic"
          combos:
            - "clu"
          meta_model:
            "clu-Logistic": 1
            "random": 0
        fr:
          word_embeddings:
            - "clu"
          ontologies: []
          models:
            - "Logistic"
          combos:
            - "clu"
          meta_model:
            "clu-Logistic": 1
            "random": 0
        ja:
          word_embeddings:
            - "clu"
          ontologies: []
          models:
            - "Logistic"
          combos:
            - "clu"
          meta_model:
            "clu-Logistic": 1
            "random": 0
    api:
      logging_level: "info"              # Logging level for api component: info, debug, trace
      migration_ro_mode: false           # Disables APIs which perform write operations to data sources
      intent_recommendations:            # clustering aka intent recommendations
        enabled: false                   # Enabled by default everywhere except ICP
        version: "v2"                    # Version of clustering to use, leave empty to use default
        cluster_min_size: "2"            # Threshold for minimum number of examples in each cluster
        min_assistant_logs: "200"        # Minimum number of assistant logs to use for clustering
        enable_dlaas_job_cleanup: false  # Enables a background script to cleanup completed dlaas jobs at random intervals through the day
        data_migration:                  # Migration settings for moving from v1 (CAT) to v2 clustering
          enabled: false                 # Should migration be attempted at startup
          delta_enabled: false           # Should delta migration be attempted at startup, assumed that full migration has already run
          region: ""                     # The data center region, used for making store calls for data
      # max allowable concurrent requests, per recommendation type, in flight to backend engines per replica
      # set to 0 for no limits
      rate_limits:
        intent_cluster: "0"
        intent_conflict: "3"
        entity_synonym: "0"

###########
## UI    ##
###########
ui:
  #################
  ## K8s config  ##
  #################
  autoscaling:
    enabled: True
    max_replicas: 10
    target_cpu_utilization_percentage: 100
  service:
    type: "ClusterIP"
    port: 8443
  readinessProbe:
    initialDelaySeconds: 10
    periodDelaySeconds: 5
    timeoutDelaySeconds: 5
  livenessProbe:
    initialDelaySeconds: 20
    periodDelaySeconds: 5
    timeoutDelaySeconds: 5
  update_strategy:
    maxUnavailable: 0
    maxSurge: 1

  #################
  ## Datastores  ##
  #################
  redis:
    mode: 'provided'
    tls_config: 'icd'
    icd_provisioned: true
  haproxy:
    use_redis: False

  ############################
  ## ENVIRONMENT VARIABLES  ##
  ############################
  host_slot: "1"
  #TODO: where do secrets live?
  cookie_secret: SQi5EsIbI9ZX71PSWS77 # cookieSecret - an alhanum string used to encrypt context of cookies in tooling
  session_secret: icpSessionSecret
  crypto_key: crypto123ForICP
  #ingress:
  #  path: "/assistant/RELEASENAME" #TODO: what should RELEASENAME be?
  bluemix:
    service_name: "conversation"
    service_plan_names: ""
    regions:            "{}"
    service_guids:      "{}"
    service_plan_guids: "{}"
    plan_hosts: ""
    app_mgmt_enable: ""
  discovery_api_version: "2018-12-03"
  api_minor_version: "2018-07-10"
  account_billing_url: ""
  resource:
    controller_regions:  '[\"us-south\"]'
    catalog_service_name: 'assistant'
    catalog_service_plan_names: '["standard"]'
    catalog_service_id: ''
    catalog_service_plan_ids: ''
  use_resource_controller: "true"
  use_cloud_foundry: "false"
  use_environment_resource_catalog: "false"
  prefer_env_store_url: "false"
  auth_provider: "jwt"
  authorization_url: ""
  iam:
    endpoint: ""
  feature_rules: '{}'
  cors_whitelist: '[]'
  segment_config: ''
  optimizely_config: ''
  integrations_oauth_redirect_hostname: ''
  web_experience_config: '{}'
  web_chat_url: ''
  cloud_logout_url: "/auth/doLogout"
  plus_trial_length: ''
  deploy_env: "dev"
  use_environment_bluemix_regions: "true"
  session_timeout: "86400"
  node_env: "production"
  appscan_verification_code: "" # Provide a verificationcode to allow AppScan on Cloud (ASoC) to scan an environment
  discovery:
    bluemix_endpoints:
  new_relic:
    enabled: false
    app_name: "" # assistant-ui_<[dev|stg|prod]_datacenter> e.g. assistant-ui_dev_us-south
  activity_check:
    enable: true
    interval: "60000" #This is the max interval in which they tooling will poll the for whether the token has expired
  features:
    enable-premium-features: true
    integrations: true
    facebook-integration: false
    intercom-integration: false
    slack-integration:    false
    webchat-integration:  true
    zendesk-integration:  false
    system-entities-v2: false
    clusters: false
    intent-recommendations: false
    response-types-slots: true
    icp: true
    cloud-logout: true
    iam-adoption: false
    suggestion-text-policy: true
    twilio-text-integration: false
    voice-telephony-integration: false
    new-integration-panel: true
    search-skill-result-count: true
    web-experience: true
    web-experience-homescreen: true
    web-experience-new-suggestions: true
  languages:
    ar:
      value: "ar"
      label: "ARABIC"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
    en:
      value: "en"
      label: "ENGLISH_US"
      off-topic: "2017-02-03"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
      open-entities: true
      synonym-recommendations: "" # gets set in ui.py based on whether recommends is enabled
      spell-check: true
      spell-check-default: true
    de:
      value: "de"
      label: "GERMAN"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
    es:
      value: "es"
      label: "SPANISH"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
      synonym-recommendations: "" # gets set in ui.py based on whether recommends is enabled
    fr:
      value: "fr"
      label: "FRENCH"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
      open-entities: true
      synonym-recommendations: "" # gets set in ui.py based on whether recommends is enabled
      spell-check: true
    it:
      value: "it"
      label: "ITALIAN"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
    ja:
      value: "ja"
      label: "JAPANESE"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
      synonym-recommendations: "" # gets set in ui.py based on whether recommends is enabled
    ko:
      value: "ko"
      label: "KOREAN"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
    pt-br:
      value: "pt-br"
      label: "BRAZILIAN_PORTUGUESE"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
    cs:
      value: "cs"
      label: "CZECH"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
    nl:
      value: "nl"
      label: "DUTCH"
      off-topic: "2017-04-21"
      fuzzy-match: true
      search: true
      system-entities-v2-default: true
    zh-tw:
      value: "zh-tw"
      label: "CHINESE_TRADITIONAL"
      off-topic: "2017-04-21"
      search: true
      system-entities-v2-default: true
    zh-cn:
      value: "zh-cn"
      label: "CHINESE_SIMPLIFIED"
      off-topic: "2017-04-21"
      search: true
      system-entities-v2-default: true

###########
## Redis ##
###########

redis:
  verification:
    enabled: true
  # Resource overrides take the following form:
  # pod (member, sentinel)
  # -> container (db, mgmt, proxy, proxylog)
  #   -> resource_type (requests, limits)
  #     -> resource (cpu, memory)
  #       -> resource_value
  resources: {}

 #  cr:
 #    spec:
 #      version: 5.0.9 # This is the value specified in the code. You are able to override if the default is not correct
##########
## Etcd ##
##########

etcd:
  tls: True
  # Because of the limitation of the ETCD operator all the values has to be of type string, i.e., in quotes (especially the numeric ones)
  resources:
    limits:
      cpu: "4"
      memory: "256Mi"
    requests:
      cpu: "15m"
      memory: "256Mi"

###########
## MinIO ##
###########

minio:
  resources:
    limits:
      cpu: 4
      memory: 1Gi
    requests:
      memory: 1Gi
      cpu: 75m

###################
## ElasticSearch ##
###################
elastic:
  version: "6.8.0"
  requests:
    memory: "4Gi"
    cpu: 1
  limits:
    memory: "4Gi"
    cpu: 2

################
## Store-Sync ##
################

store_sync:

  elastic_search:
    datastoreName: store

  elastics_search_enabled: true

  selective_shipping: "true"
  throttle_lock_in_mins: 10
  sync_lock_in_mins: 10
  deferred_thread_sleep_duration_in_mins: 4
  standard_worker_count: 2
  priority_worker_count: 2
  deferred_worker_count: 1
  elastic_max_batch_size: 5000
  elastic_read_timeout: 20000
  elastic_conn_timeout: 5000
  db_pool_size: 2

  update_strategy:
    maxUnavailable: "20%"
    maxSurge: "35%"

crDefaults:
  datastores:
    elasticSearch:
    - name: analytics
      eck:
        version: "6.8.0"
        storage:
          storageSize: 40Gi
        resources:
          requests:
            memory: "4Gi"
            cpu: 1
          limits:
            memory: "4Gi"
            cpu: 2
        settings:
          autoCreateIndex: False
        #Note that this will not work on airgap clusters
        specSkeleton:
          nodeSets:
          - name: default
            podTemplate:
              spec:
                initContainers:
                - name: install-plugins
                  command:
                  - sh
                  - -c
                  - |
                      bin/elasticsearch-plugin install --batch analysis-icu
                      bin/elasticsearch-plugin install --batch analysis-kuromoji
                      bin/elasticsearch-plugin install --batch analysis-nori
                      bin/elasticsearch-plugin install --batch analysis-phonetic
                      bin/elasticsearch-plugin install --batch analysis-smartcn
                      bin/elasticsearch-plugin install --batch analysis-stempel
                      bin/elasticsearch-plugin install --batch analysis-ukrainian
      cloudpakopenElasticSearch:
        version: "6.8.0"
        storage:
          storageSize: 40Gi
        settings:
          autoCreateIndex: False
    - name: store
      eck:
        version: "6.8.0"
        storage:
          storageSize: 10Gi
        resources:
          requests:
            memory: "4Gi"
            cpu: 1
          limits:
            memory: "4Gi"
            cpu: 2
        settings:
          autoCreateIndex: False
      cloudpakopenElasticSearch:
        version: "6.8.0"
        storage:
          storageSize: 10Gi
        settings:
          autoCreateIndex: False


###############
## Analytics ##
###############
analytics:
  # If the operator should create the CR for analytics or not.
  create: True
  # Default values for CR of the WatsonAssistantAnalytics
  cr:
    skeleton:
      elasticSearch:
        datastoreName: analytics
        autoDeletion:  # Configure if oldest logs should be removed from ElasticSearch if the ElasticSeach is filled in (even before standard expiration time)
          enabled: "true" # auto_deletion_enabled
          threshold: 75 # auto_deletion_disk_used_percent: In percent, how much should be ES filled in. Env variable:
      crossInstanceQueryScope:
        enabled: "false"  # enable_cross_instance_query_scope: If enabled permits to analyze logs from different service instances.
      reports:
        defaultVersion: "v2" # report_default_version - specifies the default Elastic search (schema) version used by report call. Value can be overriden be options.version parameter in content of the REST reports request.
  autoscaling:
    enabled: True
    max_replicas: 10
    target_cpu_utilization_percentage: 100

#####################
## System Entities ##
#####################
system_entities:
  resources:
    requests:
      cpu: "400m"
      memory: "2Gi"
    limits:
      cpu: "4"
      memory: "2Gi"
  autoscaling:
    enabled: True
    max_replicas: 10
    target_cpu_utilization_percentage: 90
  java_opts: "-Xmx1500m"
  concatenate_alternatives: "true"
  compute_legacy_end_dates: "true"
  prune_overlapping_entities: "true"
  use_preview_suffix_for_entities: "false"

#########
## DVT ##
#########
dvt:
  test_tags: "@accuracy,@authorwksp,@checkLangs,@dialogErrors,@dialogV1,@dialogV1errors,@dialogs,@entities,@folders,@fuzzy,@generic,@intents,@newse,@openentities,@patterns,@prebuilt,@slots,@spellcheck,@v2authorskillcp4d,@v2authorwksp,@v2skillrefcp4d,@v2snapshots,@workspaces"
  requests:
    memory: "1Gi"
    cpu: 10m
  limits:
    memory: "1536Mi"
    cpu: 1

network_policy:
  enabled: true
