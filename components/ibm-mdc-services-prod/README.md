# IBM InfoSphere MDM Master Data Connect

[IBM InfoSphere Master Data Management](https://www.ibm.com/analytics/master-data-management) is a comprehensive method to define and manage an organization’s critical data. It provides a single, trusted view of data across the enterprise, agile self-service access, analytical graph-based exploration, governance and a user-friendly dashboard.
Master data management solutions from IBM establish a single, trusted, 360-degree view of data and enable users to deliver better business insights through self-service analytics.

Master Data Connect is a highly scaleable operational cache for IBM Master Data Management.

## Introduction
The IBM Master Data Connect service for IBM Cloud Pak for Data helps you to capitalize on the benefits that master data brings to business applications. It uses a RESTful API to provide geographically distributed users with fast, scalable, and concurrent access to your organization's most trusted master data from IBM InfoSphere MDM.

## Details
Master Data Connect can be deployed on IBM Cloud Pak for Data and a cache of IBM MDM data can be created using IBM MDM Publisher.

## Chart Details

This chart deploys Master Data Connect which is an operational cache for IBM Master Data Management. For more information about Master Data Management see the [product documentation](https://www.ibm.com/support/knowledgecenter/SSWSR9).

This service is not available by default. An administrator must install this service on the IBM® Cloud Pak for Data platform.


## Prerequisites
- IBM Cloud Pak for Data will need to be deployed prior to the deployment of the Master Data Connect service add-on.
- Kubernetes 1.15.0 or later is required
- Openshift 3.11/Openshift 4.3
- Shared Storage (Portworx or NFS)
- 3 Worker Nodes (Minimum 8 Cores/32 GB)

### PodSecurityPolicy Requirements
* Cluster administrator role is not required for installation.

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.
We are not using any new scc (SecurityContextConstraints) and service accounts

* Custom SecurityContextConstraints definition:

```
securityContext:
     allowPrivilegeEscalation: false
     capabilities:
      drop:
      - ALL
     privileged: false
     readOnlyRootFilesystem: false
     runAsNonRoot: true

```


## Installing the Chart

To install the chart with the release name `ibm_mdc_services`:

```bash
$  helm install ibm-mdc-services-prod --name=mdc --tls
```

The command deploys ibm-mdc-services-prod on the openshift cluster in the default configuration.

> **Tip**: List all releases using `helm list`

## SecurityContextConstraints Requirements
- This chart uses scc cpd-user-scc and here is the link to it [`cpd-user-scc`](https://ibm.biz/cpkspec-scc)

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
helm delete --purge my-release --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Some components are not deleted and need to be manually removed for a clean re-install. See help documentation.

## Configuration

The following tables lists the configurable parameters of the 0074-MDC chart and their default values.

### Common Parameters

| Parameter                                 | Description                       | Default Value                |
|-------------------------------------------|-----------------------------------|------------------------------|
| release.image.pullPolicy                  | Image Pull Policy                 | IfNotPresent                 |
| release.image.repository                  | Image Repository                  | N/A   |
| release.image.tag                         | Image Tag                         | 11.6                 |
| persistence.enabled                       | Enable persistence                | true                         |
| persistence.useDynamicProvisioning        | Use Dynamic PV Provisioning       | true                         |


## Resources Required

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.requests.memory|
|-------------------------------|----------------------|-------------------------|
|**cassandra**	                |2000m                 |6000Mi                   |
|**elastic search**	                |2000m                 |6000Mi                   |
|**couchdb**	                |2000m                 |6000Mi                   |
|**aspera**	                |2000m                 |6000Mi                   |
|**mdc-core**	                |2000m                 |6000Mi                   |

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

Local Volumes are not portable which means you will loose data volume if you loose that Kubernetes Node.

To prevent that, you may use shared storage like portworx or NFS.

## Limitations
- Chart can only run on amd64 architecture type
- Minimum CPU requirement is 8 cpu

## Documentation

See the [product documentation](https://www.ibm.com/support/knowledgecenter/SSWSR9).
