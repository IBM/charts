SET DATABASE=SPARK;

CREATE TABLE IF NOT EXISTS DB_VERSION (version INT PRIMARY KEY NOT NULL);

CREATE TABLE  IF NOT EXISTS SERVICE_PROVIDER  (id STRING PRIMARY KEY NOT NULL, instance_id STRING NOT NULL, api_key STRING, state TEXT, metadata jsonb, parameters jsonb,
serviceInstanceDescription STRING, serviceInstanceDisplayName STRING, serviceInstanceNamespace STRING, transientFields jsonb, zenServiceInstanceInfo jsonb,
creation_date STRING, updation_date STRING, document_type STRING);
    
CREATE TABLE  IF NOT EXISTS HB_USERS  (id SERIAL PRIMARY KEY NOT NULL, uid STRING NOT NULL, sID STRING NOT NULL, role STRING, username STRING, password STRING,
state STRING, creation_date STRING, updation_date STRING);

CREATE TABLE  IF NOT EXISTS INSTANCE_MANAGER  (
    id SERIAL NOT NULL, 
    instance_id TEXT PRIMARY KEY NOT NULL,    
    home_volume jsonb,
    api_key TEXT,
    state TEXT,
    account_id TEXT,
    project_id  TEXT,
    creation_date TEXT,
    updation_date TEXT,
    document_type TEXT,
    namespace TEXT,
    deployment_request_id TEXT,
    dataplane_url TEXT,
    cpu_quota INT,
    memory_quota TEXT,
    avail_cpu_quota INT,
    avail_memory_quota TEXT);

CREATE TABLE IF NOT EXISTS dataplane_manager (id STRING PRIMARY KEY NOT NULL, external_dataplane_url STRING, internal_dataplane_url STRING, state STRING, creation_date TIMESTAMP,
updation_date TIMESTAMP, document_type STRING, msg STRING, tag STRING, name STRING, project_id STRING, nfs jsonb, available_pod_resources jsonb);

CREATE TABLE  IF NOT EXISTS DEPLOY_REQUEST(id STRING PRIMARY KEY NOT NULL,state STRING,document_type STRING,creation_date TIMESTAMP,updation_date TIMESTAMP, data_plane_uri STRING,
deployment_details jsonb);

CREATE TABLE  IF NOT EXISTS DEPLOYMENT(id STRING PRIMARY KEY NOT NULL, uu_id STRING, state STRING,document_type STRING,creation_date TIMESTAMP,updation_date TIMESTAMP, 
deployment_details jsonb, deployment_type STRING, deployment_blueprint jsonb);

CREATE TABLE  IF NOT EXISTS JOB  (
    id SERIAL NOT NULL, 
    job_id TEXT PRIMARY KEY NOT NULL,    
    instance_id TEXT NOT NULL,
    version TEXT,
    eng jsonb,
    app_args jsonb,
    app_resource TEXT,
    main_class TEXT,
    dataplane_uri TEXT,
    external_dataplane_uri TEXT,
    nfs_home_volume jsonb,
    driver_id TEXT,
    environment TEXT,
    job_state TEXT,
    start_time TIMESTAMP,
    finish_time TIMESTAMP,
    killed_time TIMESTAMP,
    failed_time TIMESTAMP,
    environment_name TEXT,
    runtime_registration_params jsonb,
    register_job_enabled BOOLEAN, 
    return_code TEXT,
    mode TEXT,
    user_log_dir TEXT,    
    document_type TEXT,
    state TEXT,
    creation_date TIMESTAMP,
    updation_date TIMESTAMP,
    deployment_request_id TEXT,
    project_id TEXT,
    pvc_name TEXT,
    spark_app_id TEXT,
    user_name TEXT,
    resources_updated BOOLEAN
    );

CREATE TABLE  IF NOT EXISTS KERNEL (id SERIAL NOT NULL, kernel_id STRING PRIMARY KEY NOT NULL, instance_id STRING NOT NULL, name STRING, external_dataplane_uri STRING,
usr_lib_cos jsonb, eng jsonb, jkg_size jsonb, register_kernel_enabled BOOLEAN, env jsonb, nfs_home_volume jsonb, environment STRING, environment_name STRING, 
runtime_registration_params jsonb, decommission_time TIMESTAMP, commission_time TIMESTAMP, deletion_time TIMESTAMP, deployment_time TIMESTAMP, document_type STRING,
state STRING, creation_date TIMESTAMP, updation_date TIMESTAMP, cleanup_deployment_request_id STRING, deployment_request_id  STRING);
