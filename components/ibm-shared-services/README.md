# ds-cloudpaks
# IBM InfoSphere Information Server DataStage addon Helm Chart

[InfoSphere Information Server](https://www.ibm.com/analytics/us/en/technology/information-server/) provides you with complete information management and governance solutions for analytical insights to create business value through data.

## Introduction

This chart consists of IBM InfoSphere Information Server Enterprise intended to be deployed in production environments.

## Chart Details

This chart will do the following
- It will deploy DataStage addon. Information Server will need to be deployed prior to the deployment of DatsStage addon.

## Prerequisites
- Information Server will need to be deployed prior to the deployment of the DataStage addon.

## Installing the Chart

> **Tip**: List all releases using `helm list`

### Accessing IIS Launchpad

Once the install process is completed and all the pods are up and running, open a compatible browser and enter `http://<external ip>:<node port>/ibm/iis/launchpad`. Login using isadmin/P455w0rd.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
helm delete --purge my-release --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the 0074-datastage chart and their default values.

### Common Parameters

| Parameter                                 | Description                       | Default Value                |
|-------------------------------------------|-----------------------------------|------------------------------|
| release.image.pullPolicy                  | Image Pull Policy                 | IfNotPresent                 |
| release.image.repository                  | Image Repository                  | N/A   |
| release.image.tag                         | Image Tag                         | 11.7.0.1SP1                  |
| persistence.enabled                       | Enable persistence                | true                         |
| persistence.useDynamicProvisioning        | Use Dynamic PV Provisioning       | true                         |

### Containers Parameters


#### Resources Required

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.requests.memory|
|-------------------------------|----------------------|-------------------------|
|**ds-compute**	                |2000m                 |6000Mi                   |

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

- Persistent storage configured for the engine conductor pod is shared by the ds-compute pods.

## Resources Required

## Limitations
