# Name

IBM Data Replication

# Introduction

## Summary

Move and synchronize data between heterogenous data stores in near real time with minimal impact.

You can develop optimal solutions that improve operational efficiency by combining data science capabilities, machine-learning techniques, model management, and deployment.

## Features

Features and benefits
With the IBM Data Replication service, you can replicate data changes across heterogenous data sources without impacting the performance of your systems of record. Data Replication can replicate data in the following environments:

- From on-premises data system to cloud data systems
- From one cloud data system to another cloud data system

**Improve business insight**

With Data Replication, you can move data in near real time to the environment where you perform analytics or event processing, which enables you to quickly react to changes and critical business events.
Ensure business continuity
Use Data Replication to synchronize data stores to support continuous operations in the event of planned and unplanned outages.

## Prerequisites

This add-on pre-reqs Cloud Pack for Data, and Common Core Services.

For information on prerequisites see [Planning installation] (https://www.ibm.com/docs/en/software-hub/5.3.x?topic=services-data-replication)

### Resources Required

For information on resources required see [System requirements for services] (https://www.ibm.com/docs/en/software-hub/5.3.x?topic=services-data-replication)

This service does not install a PodDisruptionBudget.

## PodSecurityPolicy Requirements

None.

## SecurityContextConstraints Requirements

This uses the Openshift built-in policy: `restricted` (default SCC)

Custom SecurityContextConstraints definition:

```
...
```

# Installing the Chart

The recommended way to install this product is using the cpd-cli utility shipped with Cloudpak for Data.

For information on installation and configuration see [Data Replication installation](https://www.ibm.com/docs/en/software-hub/5.3.x?topic=services-data-replication)

## Chart Details

For information on installation and configuration see [Data Replication installation](https://www.ibm.com/docs/en/software-hub/5.3.x?topic=services-data-replication)

## Configuration

For information on installation and configuration see [Data Replication installation](https://www.ibm.com/docs/en/software-hub/5.3.x?topic=services-data-replication)

## Storage

This add-on allocates block storage for each service instance pod.

## Limitations

* Platforms supported: RedHat OpenShift on Linux x86_64
* Only one ReplicationService can be installed per namespace. Multiple ReplicationServiceInstances can be added to horizontally scale the workload.

## Documentation

For more information about IBM Data Replication, see [Data Replication](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.3.x?topic=new-data-replication) 
