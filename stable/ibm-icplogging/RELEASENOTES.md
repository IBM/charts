# What's new in 1.0.0
* End-to-end TLS support. When enabled, you can choose either Searchguard (using community-edition features) or XPack (with a license purchased separately from Elastic). Refer to the knowledge center for important information on features and limitations.
* Automated index initialization in Kibana.
* Parses JSON-formatted logs from containers.
* Default storage class names for the Elasticsearch data pod.
* Multiplatform image support via Docker. This makes Helm deploys in mixed-platform environments more efficient.
* General improvements, such as better labeling and naming consistency.


# Prerequisites
1. Kubernetes 1.9 or higher, with Tiller 2.7.2 or higher.
1. Persistent volumes for each of the datas, or dynamic provisioning.
1. `amd64` nodes for TLS-enabled Elasticsearch, Logstash and Kibana pods.


# Known issues
1. When TLS is enabled the "Logs" tab for Kubernetes resources will not function properly.
1. When attempting to reach a TLS-enabled Kibana over unsecured HTTP it will redirect the browser to `https://0.0.0.0`. To avoid this, specify `https` when connecting to a TLS-enabled Kibana.


# Version history
| Chart | Date     | Details                           |
| ----- | -------- | --------------------------------- |
| 1.0.0 | May 2018 | First full release                |
