# What's new in 1.0.0
* Support for both secured and unsecured Elasticsearch clusters.
* Improved support for both managed and unmanaged deployments.


# Prerequisites
1. Kubernetes 1.9 or higher, with Tiller 2.7.2 or higher.
1. `amd64` nodes for TLS-enabled Elasticsearch, Logstash and Kibana pods.


# Known issues
1. When attempting to reach a TLS-enabled Kibana over unsecured HTTP it will redirect the browser to `https://0.0.0.0`. To avoid this, specify `https` when connecting to a TLS-enabled Kibana.


# Version history
| Chart | Date     | Details                           |
| ----- | -------- | --------------------------------- |
| 1.0.0 | May 2018 | First full release                |
