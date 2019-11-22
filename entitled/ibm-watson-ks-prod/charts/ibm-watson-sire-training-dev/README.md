# ibm-watson-sire-training

## Overview
This chart installs the SIRE training micro-service that is part of the larger Watson Knowledge Studio (WKS) product. The chart is not intended to be installed on its own, but integrated as a sub-chart of the WKS product.
The charts installs:
- SIREG tokenizers/parsers (toggle supported languages via configuration)
- Job queue training framework that allows to queue and schedule jobs on Kubernetes
- TrainFacade micro-service that abstracts away interaction with the training framework and S3 storage.
- Docker image used for training and evaluation of SIRE custom models.

## Data Store Dependencies
The `ibm-watson-sire-training` chart is designed to be integrated as a subchart, and with regard to the required data stores it is **not self-contained**. In particular, it requires:
- access to an existing **PosgreSQL** installation
- access to an existing **S3-compatible storage backend**

These two dependencies are "injected" via the chart configuration, essentially by setting parameters to pass the the endpoints of these existing data stores and by passing the names of existing access secrets.

All data store related configuration is via **global** parameters since the assumption is that the data stores and their configuration is shared with the parent chart and other sub-charts.

Regarding the configuration parameters, the chart tries to prevent imposing any naming conventions on the parent chart. For example, to determine the name of the Kubernetes secret holding the PostgreSQL authentication information, the chart allows to pass in a **custom helper template** function. We use this pattern in multiple places. Passing in a reference to a template instead of fixed values allows to dynamically determine names, e.g. based on deploy parameters such as release names. More details are described in the following two sections.

### S3 compatible storage
#### Access Secret (required)
In order to access the S3 endpoint, the chart requires S3 access information. The name of the **existing** access secret that the chart will be looking for is controlled by the `global.s3.accessSecret.nameTpl` parameter that takes the name of an existing helper template as value.

This existing access secret must contain two fields that hold:
1. S3 access key (field name controlled via `global.s3.accessSecret.fieldAccessKey`)
1. S3 secret access key (field name controlled via `global.s3.accessSecret.fieldSecretKey`)

#### TLS Secret (optional)
If connections to the S3 endpoint should be encrypted (`global.s3.sslEnabled`) and you are using a self-signed certificate, then we require to pass in a root/server certificate that our client should trust.

Control the TLS secret name via parameter `global.s3.tlsSecret.nameTpl` which takes a reference to an existing helper template. Set the parameter `global.s3.tlsSecret.fieldRootCertificate` to control the name of the secret field that holds the root certificate. This is only required if SSL is enabled and the server certificate is self-signed.

### PostgreSQL

#### Authentication Secret (required)
In order to access the PostgreSQL installation, the chart requires authentication information. The name of the **existing** authentication secret that the chart will be looking for is controlled by the `global.postgresql.authSecret.nameTpl` parameter that takes the name of an existing helper template as value.

This existing authentication secret must contain two fields that hold:
1. admin user password (field name controlled via `global.postgresql.authSecret.fieldAdminPassword`)
2. jobq user password (this is a non-admin user created for the jobq component, the field name is controlled via `global.postgresql.authSecret.jobqPassword`

#### TLS Secret (optional)
If connections to the PostgreSQL instance should be encrypted (`global.postgresql.sslEnabled`) and the PostgreSQL client in this chart should verify the PostgreSQL server certificate, we require to pass in a root certificate that our client should trust.

Control the TLS secret name via parameter `global.postgresql.tlsSecret.nameTpl` which takes a reference to an existing helper template. Set the parameter `global.postgresql.tlsSecret.fieldRootCertificate` to control the name of the secret field that holds the root certificate. This will also set the PostgreSQL client's SSL mode to "[*verify-ca*](https://www.postgresql.org/docs/9.6/libpq-ssl.html)".

If SSL is enabled and you do not want the client to verify the server certificate, just leave the `global.postgresql.tlsSecret.fieldRootCertificate` empty (default), the chart will then not look for any TLS secret and the client's SSL mode setting will be "[*require*](https://www.postgresql.org/docs/9.6/libpq-ssl.html)".

## Configuration

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.highAvailabilityMode` | if enabled, deploys >= 2 replicas for each relevant component | `true` |
| `clusterDomain`                      | Cluster domain used by Kubernetes Cluster (the suffix for internal KubeDNS names). | `cluster.local` |
|**S3 access secret (required)**| --- | --- |
| `global.s3.accessSecret.nameTpl` | reference to an existing helper template that renders the name of the S3 access secret | `"sireTraining.s3AccessSecretNameTemplate"` |
| `global.s3.accessSecret.fixedName` | if set, will use this fixed name instead of the above helper template to look for the S3 access secret | not set |
| `global.s3.accessSecret.fieldAccessKey` | field name in the access secret that holds the S3 access key | `"accesskey"` |
| `global.s3.accessSecret.fieldSecretKey` | field name in the access secret that holds the S3 secret access key | `"secretkey"` |
| **S3 endpoint configuration** | --- | --- |
|  `global.s3.sslEnabled` | use https protocol when connecting to the S3 enpoint and encrypt communication | `true` |
| `global.s3.endpointTpl` | reference to an existing helper template that renders the hostname (e.g. kube svc name) of the S3 endpoint | `"sireTraining.s3EndpointTemplate"` |
| `global.s3.bucketTpl` | reference to an existing helper template that renders the S3 bucket name that should be used, the bucket will be created if it does not yet exist | `"sireTraining.s3BucketNameTemplate"` |
| `global.s3.endpointPort` | defines the port that will be used in the default `global.s3.endpointTpl` template to construct the full S3 endpoint url | `9000` |
| `global.s3.endpointFixed` | if set, will use this fixed bucket name instead of the above `global.s3.endpointTpl` template| not set |
| `global.s3.bucketFixed` | if set, will use this fixed bucket name instead of the above `global.s3.bucketTpl` template | not set |
| **S3 TLS secret (optional)** | only relevant if SSL enabled (`global.s3.sslEnabled=true`) and you are using a self-signed certificarte | --- |
| `global.s3.tlsSecret.nameTpl` | reference to an existing helper template that renders the name of the S3 TLS secret | `sireTraining.s3TlsSecretNameTemplate` |
| `global.s3.tlsSecret.fixedName` |  if set, will use this fixed name instead of the above helper template to look for the S3 TLS secret | not set |
| `global.s3.tlsSecret.fieldRootCertificate` | field name in the TLS secret that holds the root certificate in [PEM format](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail), if not set, but SSL enabled, we will encrypt, and assume the server certificate is signed by a trusted authority. The field must be set if you are using a self-signed certificate. | not set |
| **PostgreSQL authentication secret (required)** | --- | --- |
| `global.postgresql.authSecret.nameTpl` | reference to an existing helper template that renders the name of the PostgreSQL authentication secret | `"sireTraining.postgresqlAuthSecretNameTemplate"` |
| `global.postgresql.authSecret.fixedName` |  if set, will use this fixed name instead of the above helper template to look for the PostgreSQL authentication secret | not set |
| `global.postgresql.authSecret.fieldAdminPassword` | field name in the auth secret that holds the admin user password | `"adminPassword"` |
| `global.postgresql.authSecret.jobqPassword` | field name in the auth secret that holds a password that should be used for the jobq user (this user will be newly created in the DB) | `"jobqPassword"` |
| **PostgreSQL endpoint configuration** | --- | --- |
| `global.postgresql.sslEnabled` | use https protocol when connecting to the PostgreSQL enpoint and encrypt communication | true |
| `global.postgresql.hostNameTpl` | reference to an existing helper template that renders the hostname (e.g. kube svc name) of the PostgreSQL endpoint | `"sireTraining.postgresqlHostNameTemplate"` |
| `global.postgresql.fixedHostName` | if set, will use this fixed hostname instead of the above `global.postgresql.hostNameTpl` template | not set |
| `global.postgresql.adminDB` | name of the PostgrSQL admin database | `"postgres"` |
| `global.postgresql.adminUser` | name of the PostgreSQL admin user | `"postgres"` |
| `global.postgresql.port` | defines the port that will be used in the default `global.postgresql.hostNameTpl` template to construct the full PostgreSQL connection string | `5432` |
| **PostgreSQL TLS secret (optional)** | only relevant if SSL enabled (`global.postgresql.sslEnabled=true`) and server certificate verification desired | --- |
| `global.postgresql.tlsSecret.nameTpl` | reference to an existing helper template that renders the name of the PostgreSQL TLS secret | `"sireTraining.postgresqlTlsSecretNameTemplate"` |
| `global.postgresql.tlsSecret.fixedName` |  if set, will use this fixed name instead of the above helper template to look for the PostgreSQL TLS secret | not set |
| `global.postgresql.tlsSecret.fieldRootCertificate` | field name in the TLS secret that holds the root certificate in [PEM format](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail), if not set, but SSL enabled, we will encrypt, but disable server certificate verification, i.e. set [SSL mode](https://www.postgresql.org/docs/9.6/libpq-ssl.html) to `require` instead of `verify-ca` in the PostgreSQL client | not set |

### SIRE Training Parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| `preInstallHookWeightAnchor` | Will use this value as anchor in this chart's pre-install hooks. Allows to control the relative order to hooks in other charts. For example, make sure that any hooks that create the required secrets for this chart run prior (lower weight) then the provided value here. | `10` |
| **Job Queue configuration** | --- | --- |
| `jobq.logLevel` | log level of the job queue component | `"info"` |
| `jobq.tenants.train.quota_cpu_millis` | Maximum amount of milli CPU quota (as defined in the job's CPU requested param `trainJob.cpu_requested`) all running training jobs can consume. If no quota left, jobs will be queued. | `1000` |
| `jobq.tenants.train.quota_memory_megabytes` | Maximum amount of memory in MB all running training jobs can consume. If no quota left, jobs will be queued. | `30000` |
| `jobq.tenants.train.max_queued_and_active_per_user` | Maximum amnount of queued and active training jobs, any additional jobs will be rejected with an error. | `10` |
| `jobq.tenants.train.max_active_per_user` | Maximum amount of training jobs a single user (identified by service instance id) can run in parallel even if enough cpu/mem quota available. | `2` |
| `jobq.tenants.evaluate.quota_cpu_millis` | Maximum amount of milli CPU quota all running evaluate (aka batch apply) jobs can consume. If no quota left, jobs will be queued. | `1000` |
| `jobq.tenants.evaluate.quota_memory_megabytes` | Maximum amount of memory in MB all running evaluate jobs can consume. If no quota left, jobs will be queued. | `30000` |
| `jobq.tenants.evaluate.max_queued_and_active_per_user` | Maximum amnount of queued and active evaluate jobs, any additional jobs will be rejected with an error. | `10` |
| `jobq.tenants.evaluate.max_active_per_user` | Maximum amount of evaluate jobs a single user (identified by service instance id) can run in parallel even if enough cpu/mem quota available. | `2` |
| **Training job configuration** | --- | --- |
| `trainJob.timeout_seconds` | Terminate training jobs that take more time than this timeout value. The time a job may spend in the job queue also counts against this timeout. | `18000` (5 hours) |
| `trainJob.cpu_requested` | The amount of CPU a training job will need to run. We usually define a low requested value and a much higher limit value (5x) since we generally assume worker nodes are under utilized and we generally get as much CPU time scheduled as defined in the limit value. If you adjust this value, make sure to also check the `jobq.tenants.train.quota_cpu_millis` setting.  | `200m` |
| `trainJob.cpu_limit` | The amount of CPU a train job can maximally consume. | `1000m` |
| `trainJob.memory_limit` | The amount of memory a train job can maximally consume. Increase here if you see training jobs failing with out of memory errors. If you adjust this value, make sure to also check the `jobq.tenants.train.quota_memory_megabytes` setting. | `5Gi` |
| **Evaluate (aka batch apply) job configuration** | --- | --- |
| `batchApplyJob.timeout_seconds` | Terminate evaluate jobs that take more time than this timeout value. The time a job may spend in the job queue also counts against this timeout. | `1800` (30 minutes) |
| `batchApplyJob.cpu_requested` | The amount of CPU an evaluate job will need to run. We usually define a low requested value and a much higher limit value (5x) since we generally assume worker nodes are under utilized and we generally get as much CPU time scheduled as defined in the limit value. If you adjust this value, make sure to also check the `jobq.tenants.evaluate.quota_cpu_millis` setting.  | `200m` |
| `batchApplyJob.cpu_limit` | The amount of CPU an evaluate job can maximally consume. | `1000m` |
| `batchApplyJobnJob.memory_limit` | The amount of memory an evaluate job can maximally consume. Increase here if you see evaluation jobs failing with out of memory errors. If you adjust this value, make sure to also check the `jobq.tenants.evaluate.quota_memory_megabytes` setting. | `5Gi` |

### Language configuration
| Parameter | Description | Default |
|-----------|-------------|---------|
| `sireg.languages.en.enabled` | Toggle language support for English | `true` |
| `sireg.languages.es.enabled` | Toggle language support for Spanish | `true` |
| `sireg.languages.ar.enabled` | Toggle language support for Arabic | `false` |
| `sireg.languages.de.enabled` | Toggle language support for German | `false` |
| `sireg.languages.fr.enabled` | Toggle language support for French | `false` |
| `sireg.languages.it.enabled` | Toggle language support for Italian | `false` |
| `sireg.languages.ja.enabled` | Toggle language support for Japanese | `false` |
| `sireg.languages.ko.enabled` | Toggle language support for Korean | `false` |
| `sireg.languages.nl.enabled` | Toggle language support for Dutch | `false` |
| `sireg.languages.pt.enabled` | Toggle language support for Portuguese | `false` |
| `sireg.languages.zh.enabled` | Toggle language support for Chinese (simplified) | `false` |
| `sireg.languages.zht.enabled` | Toggle language support for Chinese (traditional) | `false`|

### Development/Debug Parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.image.pullSecretCsfdev` | reference to an existing image pull secret that will be injected into pods, should not be required in ICP(4D), but helpful during development | not set |
| `global.image.pullPolicy` | defines the image pull policy that will be used in all resources | `IfNotPresent` |
