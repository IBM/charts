# Helm Chart for IBM UrbanCode Velocity (ibm-ucv-prod)

## Introduction
[IBM UrbanCode Velocity](https://www.ibm.com/cloud/urbancode/velocity) is a DevOps and value stream management tool to help you understand your DevOps practices, implement changes, review change impact, and automate release processes.

## Chart Details
This chart deploys a single instance of IBM UrbanCode Velocity.
  * 8 backend microservices
  * 3 frontend microservices
  * Single AMQP (Advanced Message Queuing Protocol) StatefulSet
  * NGINX for inter-service routing
  * Exposed externally via Ingress
  * [Argo](https://github.com/argoproj/argo) workflows for on-demand pod creation to run integrations

## Prerequisites

1. Kubernetes 1.9; Tiller 2.9.1
2. MongoDB Database - may be running in your cluster or outside of it. Need to provide the mongo connection string for a user with database create permissions.
3. Permissions: The installing user needs Cluster Admin privileges in order to install the Argo framework.
4. Configuration scripts (see below)

### Configuration Scripts

The scripts below are for [ibm_cloud_pak](https://github.com/IBM/charts/tree/master/stable/ibm-ucv-prod/ibm_cloud_pak/pak_extensions/)

- common
  - Scripts to check existence of security policy/context
- post-delete
  - clusterAdministration
    - deleteSecurityClusterPrereqs.sh
  - namespaceAdministration
    - deleteSecurityNamespacePrereqs.sh
- post-install
  - namespaceAdministration
    - deleteSecretGenerationJobs.sh
- pre-install
  - clusterAdministration
    - createSecurityClusterPrereqs.sh
  - namespaceAdministration
    - createSecurityNamespacePrereqs.sh
    - createImagePolicyNamespacePrereqs.sh

### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `PodSecurityPolicy` named [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the Cluster Console user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-ucv-prod-psp
    spec:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      allowedCapabilities:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      volumes:
      - configMap
      - secret
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-ucv-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-ucv-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
- From the command line, you can run the setup scripts included under pak_extensions

  As a cluster admin the pre-install instructions are located at:
    - `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
    - `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`
    - `pre-install/namespaceAdministration/createImagePolicyNamespacePrereqs.sh`

### SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-ucv-prod-scc
    readOnlyRootFilesystem: false
    allowedCapabilities:
    - CHOWN
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    - NET_BIND_SERVICE
    seLinux:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    runAsUser:
      type: RunAsAny
    fsGroup:
      rule: RunAsAny
    volumes:
    - configMap
    - secret
    ```
- From the command line, you can run the setup scripts included under pak_extensions

  As a cluster admin the pre-install instructions are located at:
    - `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`
    - `pre-install/clusterAdministration/createArgoClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
    - `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`
    - `pre-install/namespaceAdministration/createImagePolicyNamespacePrereqs.sh`

## Resources Required
The minimal system resources required:
  * CPU: 8 vCPU (virtual CPUs)
  * Memory: 12 GB
  * Storage: 20 GB

## Installing the Chart
To install the chart with the release name `my-release`:
```bash
helm install my-release --set license=accept --set access.key=$ACCESS_KEY --set url.domain=localhost ibm-ucv-prod
```
The above command sets license, access key and domain name parameters. Other parameters may also be required. If parameters aren't specifed with the --set flag, their values will default to the values specified in the values.yaml file.

The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

* Generally teams have subsections for:
   * Verifying the Chart
   * Uninstalling the Chart

### Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: `helm status my-release`.

### Uninstalling the Chart
To uninstall/delete the `my-release` deployment:
```bash
helm delete my-release
```

### Cleanup any pre-reqs that were created
If cleanup scripts were included in the pak_extensions/post-delete directory; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration
The helm chart has the following values. They can be overwritten using the `--set key=value[,key=value]` argument to `helm install`.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `license` | Enter 'accept' to indicate that you accept all terms and conditions of the End User License Agreement (EULA). | `true` |
| `access.key` | The access key obtained with the sign up or purchase of UrbanCode Velocity. This key is required to start Velocity and contains information such as the Velocity Edition and Trial vs Permanent. | `invalid-key` |
| `url.protocol` | The protocol of the Velocity URL. Only `https` is supported. | `https` |
| `url.domain` | The domain name users will access Velocity at. This is usually the ingress host name or the hostname of your kubernetes master node. If you have any reverse proxy in front of your kubernetes cluster, use that. | `localhost` |
| `url.port` | The port users will use to access the app. If you have any reverse proxy in front of your kubernetes cluster, use that. | `32443` |
| `rabbitmq.url` | The URL that services will use to authenticate against RabbitMQ. Should be of form `amqp://<rabbit-username>:<rabbit-password>@<rabbit-service-name/URL>:<rabbit-port>/<optional-v_host>`. The username and password should match what is entered below. | `amqp://rabbit:carrot@velocity-rabbitmq:5672/` | # pragma: whitelist secret
| `rabbitmq.nodePort` | The port that RabbitMQ will be exposed outside the cluster on. This will be used by external tools that rely on RabbitMQ to communicate with Velocity such as Jenkins. | `31672` |
| `rabbitmq.managerPort` | The port that the RabbitMQ administrative console will run on. This is not exposed outside of the cluster. | `15672` |
| `rabbitmq.erlangCookie` | The cookie used by RabbitMQ and services to determine whether they are allowed to communicate with each other. | `128ad9b8-3d9f-11e8-b467-0ed5f89f718c` |
| `loglevel` | The loggin level for all services to use. Possible values are `ALL` > `DEBUG` > `INFO` > `WARN` > `ERROR` > `FATAL` > `OFF`. | `ALL` |
| `ingress.enable` | Set to true if you want ingress rules set up, otherwise set to false. If you are using NodePort or an ingress of your own, then set to false. | `true` |
| `ingress.path` | The path that ingress will serve Velocity on. | `/` |
| `secrets.rabbit` | The name of the Kubernetes Secret to store sensetive RabbitMQ information. Will be created dynamically if it does not exist. | `velocity-rabbitmq` |
| `secrets.tls` | The name of the Kubernetes Secret containing TLS certificate information. Will be created dynamically if it does not exist. | `velocity-tls` |
| `secrets.tokens` | The name of the Kubernetes Secret to store sensetive Velocity tokens. Will be created dynamically if it does not exist. | `velocity-tokens` |
| `secrets.database` | The name of the Kubernetes Secret to store sensetive MongoDB information. Will be created dynamically if it does not exist. | `velocity-database` |

> **Tip**: You can use the default values.yaml

## Storage
There are no permanent storage solutions required.

## Limitations
  * Only supported on `amd64` architecture.

## Identity and Access Management

### User Authentication and Authorization Strategy

The UrbanCode Velocity authentication strategy includes browser cookies and user access key for API usage. Authorization resolves tenant permissions according to roles and teams.

### Integrations

UrbanCode Velocity supports LDAP and header based SSO integrations. LDAP roles are supported and roles passed via SSO header.

### Administration and Management

User authentication and authorization is intended to be managed from the UI. Management through the API is also possible.

### Audit

User audit records can be found in the "audit_log" collection in the "security" database.

## Backup and Recovery

UrbanCode Velocity can be fully backed-up as a restore point by capturing the following:

1. Database: This should be a single MongoDB instance containing multiple MongoDB databases per service.
2. Environmental variables (secrets): these may affect, for instance - encryption, access, and operation.

It is risky, if not impossible, to prescribe a one-size fits all database and/or environment variable (secret) management strategy. Refer to industry and company specific best practices per use case. Common approaches to database backup include the backup of persistent volumes and/or MongoDB's built-in tooling. Environmental variables and secrets should be treated like passwords - lightweight and easily backed-up by simple copying; nevertheless, they are critical and sensitive. Refer to appropriate best practices for your situation.

The following is a simple back-up and restore example:

1. Backup the Database (Refer to MongoDB documentation for details [https://docs.mongodb.com/manual/tutorial/backup-and-restore-tools/](https://docs.mongodb.com/manual/tutorial/backup-and-restore-tools/))
    1. Run MongoDB's `mongodump` command against UrbanCode Velocity's MongoDB instance (this command can executed against a remote instance). For example:

        `mongodump --host=mongoInstanceAddress --port=27017 --out=/opt/backup/velocity-2020-7-4`

    2. Move (archive) the dump file to a secure location.
    3. To restore a dump file run `mongorestore`.

        >NOTE: `mongorestore` by default only adds and does not remove database data. To entirely restore a database to a restore point, either delete all databases before running, or run with the `--drop` flag. For example:

        `mongorestore --host mongoInstanceAddress --port 27017 --drop /backup/dump`

2. Backup and restore environmental variables (secrets)
    1. Copy all deployment secrets to a secure location.
    2. To restore values, copy them back into production as needed.

## Scaling Services

Some services can be scaled with performance improvements, others cannot. See the list of services below for a summary as of urbanCode Velocity 2.0.0:

**Service Containers**

The following services can be scaled with expected performance improvements:
- multi-app-pipeline-api
- release-events-api
- reporting-consumer
- security-api

The following services should not be scaled, but might be scaled in future releases of Velocity:
- application-api
- continuous-release-consumer
- continuous-release-poller

The following services are not expected to provide performance gains, and therefore are not recommended for scaling.
- release-events-ui
- continuous-release-ui
- reporting-ui
- rcl-web-client

**Non-service containers**

Do not scale the rabbit container:
- rabbitnode1

Scaling of velocity router is not typical and probably not helpful.
- velocity-router

## Multiple Instances

For multiple instances of UrbanCode Velocity within the same cluster, use a separate namespace for each instance. Determine which ports will be used for each instance, then install accordingly. In particular, NodePorts do not respect namespaces, so you will need to select unique ports for your instances of rabbit (rabbitmq.nodePort).

## Rolling Back Services

To rollback to a previous version of UrbanCode Velocity you will need a database dump created from the MongoDB Database before the upgrade. For instance, if you are upgrading from 1.5.5 to 2.0.0, creating a database dump before the upgrade will allow you to rollback to 1.5.5 if there are problems with 2.0.0. It is recommended to always create a MongoDB Database dump before upgrading UrbanCode Velocity. Please see the [Backup and Recovery](#backup-and-recovery) section for more information on how to execute the `mongodump` command.

**Warning - You will lose any data added/modified after the database dump was created.**

1. First, you will need to uninstall your current Velocity Helm Release. Follow the instructions in the [Uninstalling the Chart](#uninstalling-the-chart) section.
    - To confirm deletion of your Velocity release you can run `helm list`.
2. Next, you will need to restore your MongoDB database using the database dump that you created before upgrading Velocity.
    - The easiest way to do this is using the `mongorestore` command. You may again refer to the [Backup and Recovery](#backup-and-recovery) section for help with this command. It is very important that you specify the `--drop` flag when running this command (`mongorestore --host mongoInstanceAddress --port 27017 --drop /backup/dump`). Without the `--drop` flag you will have duplicate data in your database.
3. Once your database has been restored to its previous state, you can now recreate the Velocity Helm release. Please see the [Installing the Chart](#installing-the-chart) section for help.
    - When you reinstall Velocity, make sure that you specify the version that you are rolling back to using the `--version` flag.
    - For instance, if you are rolling back to UrbanCode Velocity version 1.5.5:<br/>
    `helm install my-release --set license=accept --set access.key=$ACCESS_KEY --set url.domain=localhost --version=1.5.5 ibm-ucv-prod`

## Other Documentation

To learn more about UrbanCode Velocity, read our knowledge center documentation and checkout the [urbancode.com](https://www.urbancode.com) website.

**Knowledge Center**: https://www.ibm.com/support/knowledgecenter/SSCKX6
**Videos, Blogs, and more**: https://www.urbancode.com/resources/?search=&product_filter%5B%5D=811