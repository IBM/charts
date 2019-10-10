# Release notes

## What's new...

- Added support of LDAP authentication and authorization for Elasticsearch and Kibana.
- Added support of Kibana multitenancy.

## Breaking Changes

To restore Elasticsearch data snapshots, follow this new procedure: [Restoring Open Distro security indexes](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.bai/topics/tsk_bai_es_restore_odistro_sec_indexes.html).

## Documentation

See README.md

## Fixes

None

## Prerequisites

* A Kubernetes cluster, version 1.11.0 or later
* Tiller 2.9.1 or later
* A persistent Storage
* amd64 Kubernetes nodes

## Version History


| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ----- | ---- | ---- | ---- | ---- |
| 3.2.0 | October 2019 | >=1.11.0 | bai-init-dev:19.0.1, bai-elasticsearch-dev:19.0.1, bai-kibana-dev:19.0.1 | To restore the Elasticsearch data snapshots, you must follow a new documented procedure. | Added support of LDAP authentication and authorization for Elasticsearch and Kibana. Added support of Kibana multitenancy.
| 3.1.0 | June 2019 | >=1.11.0 | bai-init-dev:19.0.1, bai-elasticsearch-dev:19.0.1, bai-kibana-dev:19.0.1 | Change to the user registry  | Support role-based access by using the Open Distro for Elaticsearch security plug-in. No longer uses `nginx`.
| 3.0.0 | Mar 2019 | >=1.9.1 | bai-alpine-dev:18.0.2, bai-elasticsearch-dev:18.0.2, bai-kibana-dev:18.0.2, nginx-dev:1.15.2 |    | Remove Ingress, master pods require persistent volumes |
| 2.0.0 | Dec 2018 | >=1.9.1 | bai-alpine-dev:18.0.1, elasticsearch-oss:6.3.1, kibana-oss:6.3.1, nginx-dev:1.15.2 |    | Bug Fixes |

