# ibm-watson-aiops-prod
​
## Introduction

[IBM Watson™ AIOps](https://www.ibm.com/products/watson-aiops) combines structured and unstructured data from applications and infrastructure components of your IT landscape. It applies AI to that data to discover anomalies and correlate them to discover impact across components and to localize faults This is used to  guide IT operations teams to understand the nature and impact of issues as they emerge and to guide inform short term remedies and permanent resolutions.
​

## Chart Details
​
This chart creates several pods, deployments, services, and secrets to create the Watson AIOps offering.
​
#### Pods:
​
AIOps
​
* `addon-*` : Pods for integrating with CloudPak for Data UI.
* `alert-localization-*` : Pods for localizing alerts in a topology.
* `chatops-orchestrator-*` : Pods for managing the ChatOps sessions.
* `chatops-slack-integrator-*` : Pods for integrating with Slack.
* `controller-*` : Pods for managing the Watson AIOps's configuration.
* `event-grouping-*` : Pods for grouping of anomalies and events into stories.
* `gw-deployment-*` : Pods for integrating with CloudPak for Data.
* `log-anomaly-detector-*` : Pods for detecting anomalies in logs.
* `mock-server-*` : Pods for simulating connections, when running DVTs.
* `model-train-console-*` : The model train console is pre-configured with all the training resources needed, for an administrator to train the AI models
* `persistence-*` : Pods for managing the persistence of relational data.
* `similar-incidents-service-*` : Pods for identifying similar incidents, as well as extracting the next best actions.
* `topology-*` : Pods for defining a topology, and for interacting with the NetCool ASM product.
​
Sub-Charts
* `ibm-dlaas-*` : Pods for the model training orchestration.
* `ibm-elasticsearch-*` : Pods for the Elastic Search data store.
* `ibm-flink-job-manager-*` : Pods for managing the Apache Flink jobs.
* `ibm-flink-task-manager-*` : Pods for data ingestion and pre-processing for logs, alerts and events.
* `ibm-minio-*` : Pods for the Minio data store.
* `postgres-*` : Pods for the PostGres data store.
​
#### Deployments:
​
AIOps
* `addon` : Deployment for integrating with CloudPak for Data UI.
* `alert-localization` : Deployment for localizing alerts in a topology.
* `chatops-orchestrator` : Deployment for managing the ChatOps sessions.
* `chatops-slack-integrator` : Deployment for integrating with Slack.
* `controller` : Deployment for managing the Watson AIOps's configuration.
* `event-grouping` : Deployment for grouping of anomalies and events into stories.
* `gw-deployment` : Deployment for integrating with CloudPak for Data.
* `log-anomaly-detector` : Deployment for detecting anomalies in logs.
* `mock-server` : Deployment for simulating connections, when running DVTs.
* `model-train-console` : The model train console is pre-configured with all the training resources needed, for an administrator to train the AI models
* `persistence` : Deployment for managing the persistence of relational data.
* `similar-incidents-service` : Deployment for identifying similar incidents, as well as extracting the next best actions.
* `topology` : Deployment for defining a topology, and for interacting with the NetCool ASM product.

Sub-Charts

* `ibm-dlaas-*` : Deployment for the model training orchestration.
* `ibm-flink-job-manager` : Deployment for managing the Apache Flink jobs.
* `ibm-flink-task-manager` : Deployment for data ingestion and pre-processing for logs, alerts and events.
* `postgres-*` : Deployment for the PostGres data store.
​
#### Services:
​
AIOps
* `addon` : Service for integrating with CloudPak for Data UI.
* `alert-localization` : Service for localizing alerts in a topology.
* `chatops-orchestrator` : Service for managing the ChatOps sessions.
* `chatops-slack-integrator` : Service for integrating with Slack.
* `controller` : Service for managing the Watson AIOps's configuration.
* `event-grouping` : Service for grouping of anomalies and events into stories.
* `gateway-svc` : Service for integrating with CloudPak for Data.
* `log-anomaly-detector` : Service for detecting anomalies in logs.
* `mock-server` : Service for simulating connections, when running DVTs.
* `persistence` : Service for managing the persistence of relational data.
* `similar-incidents-service` : Service for identifying similar incidents, as well as extracting the next best actions.
* `topology` : Service for defining a topology, and for interacting with the NetCool ASM product.

Sub-Charts
* `ibm-dlaas-*`: Services for the model training orchestration.
* `ibm-elasticsearch-*` : Services for the Elastic Search data store.
* `ibm-flink-job-manager` : Service for managing the Apache Flink jobs.
* `ibm-minio-*` : Services for the Minio data store.
* `postgres-*` : Services for the PostGres data store.
​
#### Secrets:
​
* `aio-tls` : AIOps TLS secret
* `aio-truststores` : AIOps TLS trust store
* `flink-config-secret` : Credentials for connecting to Flink
* `ibm-dlaas-lcm-tls` : TLS information for Model Training
* `ibm-dlaas-postgres-credentials` : Credentials for connecting to PostGres 
* `ibm-dlaas-ratelimiter-tls` : TLS information for Model Training
* `ibm-dlaas-trainer-tls` : TLS information for Model Training
* `ibm-elasticsearch-cert` : TLS information for connecting to PostGres
* `ibm-elasticsearch-secret` : Credentials for connecting to Elastic
* `ibm-minio-access-secret` : Credentials for connecting to Minio 
* `kafka` : Credentials for connecting to Strimzi Kafka 
* `kafka-certificate` : TLS information for connecting to Strimzi Kafka 
* `mock-server-auth-secret` : Credentials for connecting to the Mock Server
* `postgres-auth-secret` : Credentials for connecting to PostGres
* `postgres-tls-secret` : TLS information for connecting to PostGres
* `gw-tls` : TLS information for connecting to Gateway
​
​
## Prerequisites
[IBM Watson™ AIOps](https://www.ibm.com/products/watson-aiops) requires the following resources before installing:
​
- IBM® Cloud Pak for Data version 3.0.1
- Red Hat® OpenShift® version 4.3
- Portworx
- Strimzi
- S3FS (Post Install)


This is documented in more detail in the [IBM Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/svc-aiops/aiops-prereqs.html).


## Red Hat OpenShift SecurityContextConstraints Requirements
​
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster-scoped as well as namespace-scoped pre- and post-actions that need to be taken.
​
The predefined SecurityContextConstraints name: [`restricted`](https://ibm.biz/cpkspec-scc), has been verified for this chart with one exception. S3FS requires adding `flexVolume` to the `volumes` section. This is detailed in the following custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart.
​
  - From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
    - Custom SecurityContextConstraints definition:
      ```
      apiVersion: security.openshift.io/v1
      kind: SecurityContextConstraints
      metadata:
        name: ibm-watson-zeno-scc
      priority: null
      allowHostDirVolumePlugin: false
      allowHostIPC: false
      allowHostNetwork: false
      allowHostPID: false
      allowHostPorts: false
      allowPrivilegeEscalation: true
      allowPrivilegedContainer: false
      allowedCapabilities: null
      apiVersion: security.openshift.io/v1
      defaultAddCapabilities: null
      fsGroup:
        type: MustRunAs
      groups:
      - system:authenticated
      readOnlyRootFilesystem: false
      requiredDropCapabilities:
      - KILL
      - MKNOD
      - SETUID
      - SETGID
      runAsUser:
        type: MustRunAsRange
      seLinuxContext:
        type: MustRunAs
      supplementalGroups:
        type: RunAsAny
      users:
      - system:serviceaccount:zeno
      volumes:
      - configMap
      - downwardAPI
      - emptyDir
      - hostPath
      - persistentVolumeClaim
      - projected
      - secret
      - flexVolume
      ```
​
## Resources Required
​
The resources required depend on the size of the training datasets as well as the operational data volumes expected during runtime that get used in applying our AI models.  

This is documented in more detail in the [IBM Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/svc-aiops/aiops-prereqs.html).
​
## Installing the Chart

[IBM Watson™ AIOps](https://www.ibm.com/products/watson-aiops) is intended to be installed using the CloudPak for Data Command Line Interface (CLI).  This will configure and install this helm chart.  It is not intended to be run standalone.

This is documented in more detail in the [IBM Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/svc-aiops/aiops-install.html).
​
​
### Uninstalling the Chart

​[IBM Watson™ AIOps](https://www.ibm.com/products/watson-aiops) can be uninstalled using the CloudPak for Data Command Line Interface (CLI).  This will uninstall the previously deployed helm chart and any associated resources.  It is not intended to be run standalone.

This is documented in more detail in the [IBM Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/svc-aiops/aiops-uninstall.html).
​


## Configuration
​[IBM Watson™ AIOps](https://www.ibm.com/products/watson-aiops) is configured using the CloudPak for Data UI.

This is documented in more detail in the [IBM Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/svc-aiops/aiops-admin-ovr.html).


## Limitations
​
The limitations for [IBM Watson™ AIOps](https://www.ibm.com/products/watson-aiops) are documented in the [IBM Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/svc-aiops).
​
​
## Documentation
[IBM Watson™ AIOps](https://www.ibm.com/products/watson-aiops) is documented in more detail in the [IBM Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/svc-aiops).
​
