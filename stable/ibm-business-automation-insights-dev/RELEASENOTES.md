# Release notes

## What's new...

- Added support of multitenancy and LDAP in Elasticsearch and Kibana. See the release notes of the `ibm-dba-ek` subchart.
- Added support of IBM Business Automation Insights on Red Hat OpenShift on IBM Cloud. The new `flink.initStorageDirectory` parameter allows you to enable initialization of the Flink storage directory. Set this parameter to `true` for IBM Cloud deployments.
- Case activity summaries: A new `user` parameter is available.
- Charts parameters: You can now configure memory and CPU requests, and memory limits, for the Flink job manager and for the administration and setup jobs.

See detailed information at [What's new in 19.0.2](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.bai/topics/con_whats_new_1902.html).

## Breaking Changes

See the `Breaking Changes` section in the release notes of the `ibm-dba-ek` subchart.

## Documentation

See README.md

## Fixes

None.

## Prerequisites

* A Kubernetes cluster, version 1.11 or later
* Tiller 2.9.1 or later
* A persistent Storage
* At least 3 amd64 Kubernetes nodes
* Elasticsearch resource needs are entirely based on your environment. For helpful information to plan the necessary resources, read the [capacity planning guide](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_metrics/capacity_planning.html).
* Apache Kafka. For the supported versions, see https://www.ibm.com/software/reports/compatibility/clarity/softwareReqsForProduct.html.



## Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ----- | ---- | ---- | ---- | ---- |
| 3.2.0 | October 2019 | >=1.11.0 | bai-flink-dev:19.0.2, bai-flink-zookeeper-dev:19.0.2, bai-init-dev:19.0.2, bai-setup-dev:19.0.2, bai-ingestion-dev:19.0.2, bai-bpmn-dev:19.0.2, bai-bawadv-dev:19.0.2, bai-icm-dev:19.0.2, bai-odm-dev:19.0.2, bai-content-dev:19.0.2, bai-admin-dev:19.0.2, bai-elasticsearch-dev:19.0.2, bai-kibana-dev:19.0.2 | See the Breaking Changes section in the release notes of the `ibm-dba-ek` subchart  | Elasticsearch and Kibana support. LDAP authentication and authorization. New parameter in Case activity summaries. New chart parameters to configure CPU and memory limits.
| 3.1.0 | June 2019 | >=1.11.0 | bai-flink-dev:19.0.1, bai-flink-zookeeper-dev:19.0.1, bai-init-dev:19.0.1, bai-setup-dev:19.0.1, bai-ingestion-dev:19.0.1, bai-bpmn-dev:19.0.1, bai-bawadv-dev:19.0.1, bai-icm-dev:19.0.1, bai-odm-dev:19.0.1, bai-content-dev:19.0.1, bai-admin-dev:19.0.1, bai-elasticsearch-dev:19.0.1, bai-kibana-dev:19.0.1 | Change to `baiSecret`  | Add IBM Content Platform Engine event processing, Support role based access using Open Distro for Elaticsearch, No longer uses `nginx`
| 3.0.0 | Mar 2019 | >=1.9.1 | bai-flink-dev:18.0.2, bai-flink-zookeeper-dev:18.0.2, bai-alpine-dev:18.0.2, bai-setup-dev:18.0.2,, bai-bpmn-dev:18.0.2, bai-icm-dev:18.0.2, bai-odm-dev:18.0.2, bai-admin-dev:18.0.2, bai-elasticsearch-dev:18.0.2, bai-kibana-dev:18.0.2, nginx-dev:1.15.2 |    | Add ODM support, Remove Ingress |
| 2.0.0 | Dec 2018 | >=1.9.1 | bai-flink-dev:18.0.1, bai-flink-zookeeper-dev:18.0.1, bai-alpine-dev:18.0.1, bai-setup-dev:18.0.1, bai-ingestion-dev:18.0.1, bai-bpmn-dev:18.0.1, bai-icm-dev:18.0.1, bai-admin-dev:18.0.1, bai-admin-dev:18.0.1, elasticsearch-oss-dev:6.3.1, kibana-oss-dev:6.3.1, nginx-dev:1.15.2 |    | Bug Fixes |

