CREATE TABLE IF NOT EXISTS DB_VERSION (version INT PRIMARY KEY NOT NULL);

CREATE TABLE  IF NOT EXISTS SERVICE_PROVIDER  (id TEXT PRIMARY KEY NOT NULL, instance_id TEXT NOT NULL, api_key TEXT, state TEXT, metadata jsonb, parameters jsonb,
serviceInstanceDescription TEXT, serviceInstanceDisplayName TEXT, serviceInstanceNamespace TEXT, transientFields jsonb, zenServiceInstanceInfo jsonb, space_id TEXT, job_def_id TEXT, creation_date TEXT, updation_date TEXT, document_type TEXT);

CREATE TABLE  IF NOT EXISTS HB_USERS  (id SERIAL PRIMARY KEY NOT NULL, uid TEXT NOT NULL, sID TEXT NOT NULL, role TEXT, username TEXT, password TEXT,
state TEXT, creation_date TEXT, updation_date TEXT);

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
    avail_memory_quota TEXT,
    context_type TEXT,
    context_id TEXT,
    job_def_id VARCHAR (512),
    spark_confs jsonb);

CREATE TABLE IF NOT EXISTS dataplane_manager (id TEXT PRIMARY KEY NOT NULL, external_dataplane_url TEXT, internal_dataplane_url TEXT, state TEXT, creation_date TIMESTAMP,
updation_date TIMESTAMP, document_type TEXT, msg TEXT, tag TEXT, name TEXT, project_id TEXT, nfs jsonb, available_pod_resources jsonb, additional_details jsonb);

CREATE TABLE  IF NOT EXISTS DEPLOY_REQUEST(id TEXT PRIMARY KEY NOT NULL,runtime_id TEXT,state TEXT,document_type TEXT,creation_date TIMESTAMP,updation_date TIMESTAMP, data_plane_uri TEXT,
deployment_details jsonb);

CREATE TABLE  IF NOT EXISTS DEPLOYMENT(id TEXT PRIMARY KEY NOT NULL, uu_id TEXT, state TEXT,document_type TEXT,creation_date TIMESTAMP,updation_date TIMESTAMP,
deployment_details jsonb, deployer_type TEXT, deployment_blueprint jsonb, deployment_type TEXT);

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
    resources_updated BOOLEAN,
    context_type TEXT,
    context_id TEXT,
    job_def_id TEXT,
    job_run_id TEXT
    );

CREATE TABLE  IF NOT EXISTS KERNEL (id SERIAL NOT NULL, kernel_id TEXT PRIMARY KEY NOT NULL, instance_id TEXT NOT NULL, name TEXT, external_dataplane_uri TEXT,
usr_lib_cos jsonb, eng jsonb, jkg_size jsonb, register_kernel_enabled BOOLEAN, env jsonb, nfs_home_volume jsonb, environment TEXT, environment_name TEXT,
runtime_registration_params jsonb, decommission_time TIMESTAMP, commission_time TIMESTAMP, deletion_time TIMESTAMP, deployment_time TIMESTAMP, document_type TEXT,
state TEXT, creation_date TIMESTAMP, updation_date TIMESTAMP, cleanup_deployment_request_id TEXT, deployment_request_id  TEXT);
