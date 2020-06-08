## What's new...

-OpenShift Container Platform 4.3 and 4.4 support
-'Out of the box' configuration now leverages 3 replicas and HA databases for high availability

## Breaking Changes
-OCP 4.3 and 4.4 are the only supported platforms
-No supported migration from IECM 4.0

## Fixes

## Prerequisites

1. Red Hat OpenShift Container Platform 4.3,4.4

2. IBM Cloud Platform Common Services 3.2.7

3. Helm version >=2.9.1

# Documentation
For further instructions go to the [online](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/hub/hub.html) documentation. Also, check the README file provided with the chart.

# Version History

| Chart | Date             | OpenShift Required | Breaking Changes | Details               |
| ----- | ---------------- | ------------------ | ---------------- | --------------------- |
| 4.1.0 | Jun 12, 2020     | 4.3,4.4            | No migration support | - |
| 4.0.0 | Feb 14, 2020     | 4.2                | OCP 4.2, dynamic DB storage | - |

| Chart | Date             | Kubernetes Required | Breaking Changes | Details               |
| ----- | ---------------- | ------------------- | ---------------- | --------------------- |
| 3.2.2 | Nov 22, 2019     | >=1.13.1            | Local DB default | Silent refresh  |
| 3.2.1 | Sep 27, 2019     | >=1.13.1            | None             | New product release   |
