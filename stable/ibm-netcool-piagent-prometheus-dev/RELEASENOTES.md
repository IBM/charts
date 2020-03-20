# Release Notes for IBM Operations Analytics - Predictive Insights Mediation Pack for Prometheus - Deprecated

These are the Release Notes for IBM Operations Analytics - Predictive Insights Mediation Pack for Prometheus. This is the first version of the mediation pack.

## What's new

- This chart is now deprecated

## Breaking Changes

- Not supported on openshift

## Documentation 

https://www.ibm.com/support/knowledgecenter/SSJQQ3_1.3.6/com.ibm.scapi.doc/kc_welcome-scapi.html

## Fixes

- minor metadata fixes

## Prerequisites

- Install IBM Operations Analytics - Predictive Insights. For more information, see [Installing](https://www.ibm.com/support/knowledgecenter/SSJQQ3_1.3.6/com.ibm.scapi.doc/install_guide/c_tsaa_install_guide.html).

- Install the Kubernetes command line interface (CLI). For more information, see [Accessing your cluster by using the kubectl CLI](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.2/manage_cluster/cfc_cli.html).

- Ensure that Prometheus is connected with Single Socket Layer (SSL) in your Kubernetes environment and gather the information that is required for configuring the Helm chart.

## Version History

| Chart | Date | ICP Required | Image(s) Supported | Details |
| ----- | ---- | ------------ | ------------------ | ------- | 
| 0.2.1 | March 10, 2020| >=2.1.0.1 | netcool-piagent-prometheus:1.0 | deprecating|
| 0.2.0 | June 7, 2018| >=2.1.0.1 | netcool-piagent-prometheus:1.0 | refactoring & Change to PI resource names|
| 0.1.0 | May 18, 2018| >=2.1.0.1 | netcool-piagent-prometheus:1.0 | Initial Release |
