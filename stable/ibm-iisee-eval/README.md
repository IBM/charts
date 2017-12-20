# IBM InfoSphere Information Server for Evaluation v11.7 Helm Chart

[InfoSphere Information Server](https://www.ibm.com/analytics/us/en/technology/information-server/) provides you with complete information management and governance solutions for analytical insights to create business value through data. 

## Introduction

This chart consists of IBM InfoSphere Information Server for Evaluation v11.7 intended to be deployed in IBM Cloud Private non-production environments for evaluation purpose. 

## Prerequisites

- Chart should be installed by reviewing and accepting the license terms and conditions.
- Chart uses Persistent Volumes. Dynamic provisioning of Persistent Volumes is enabled by default. The cluster should be set up with Dynamic Provisioning (e.g. GlusterFS). See [persistence](#persistence) section.


## Deploying IIS Evaluation 

To deploy IIS Evaluation using ICp UI, please do the following steps:
- Click Configure button
- Fill in release name
- Fill in namespace
- Accept the license agreement
- Click on Install button

You can deploy manually by executing the helm CLI:

```bash
$ helm install --name my-release --set license=accept stable/ibm-iisee-eval
```

The command deploys ibm-iisee-eval on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Accessing IIS Launchpad 

Once the install process is completed and all the pods are up and running, open a compatible browser and enter `http://<external ip>:<node port>/ibm/iis/launchpad`. Login using isadmin/P455w0rd.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. 

## Configuration

The following tables lists the configurable parameters of the ibm-iisee-eval chart and their default values.

### Common Parameters

| Parameter                                 | Description                       | Default Value                |
|-------------------------------------------|-----------------------------------|------------------------------|
| release.image.pullPolicy                  | Image Pull Policy                 | IfNotPresent                 |
| release.image.repository                  | Image Repository                  | na.cumulusrepo.com/iigicp   |
| release.image.tag                         | Image Tag                         | 11.7                        |
| persistence.enabled                       | Enable persistence                | true                         |
| persistence.useDynamicProvisioning        | Use Dynamic PV Provisioning       | true                         |

### Containers Parameters


#### Resources Parameters

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.requests.memory|
|-------------------------------|----------------------|-------------------------|
|**iisService**		        |2000m                 |6000Mi                   |

#### Port Parameters

| Parameter                           | Description                                      | Default Value                |
|-------------------------------------|--------------------------------------------------|------------------------------|
| haproxy.service.httpsNodePort       | The haproxy port for IIS launchpad               | 32443                        |
| iisService.service.nodePort         | The external port for IIS launchpad              | 32501                        |
| shop4infoApp.service.httpsNodePort  | The external port for IIS enterprise search      | 30443                        |

#### Storage Parameters

| Prefix/Suffix                         | volumeClaim.size          | volumeClaim.storageClassName | volumeClaim.existingClaimName|
|---------------------------------------|---------------------------|------------------------------|------------------------------|
|cassandra                              | 5Gi                       | `nil`                        |  `nil`                       |
|zookeeper                              | 5Gi                       | `nil`                        |  `nil`                       |
|kafka                                  | 5Gi                       | `nil`                        |  `nil`                       |
|elasticsearch                          | 5Gi                       | `nil`                        |  `nil`                       |
|logstash                               | 5Gi                       | `nil`                        |  `nil`                       |
|solr                                   | 5Gi                       | `nil`                        |  `nil`                       |
|iisService                             | 1Mi                       | `nil`                        |  `nil`                       |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: true (default)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.

- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: false (non-default)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.    

The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) volume. The volume is created using dynamic volume provisioning. If the PersistentVolumeClaim should not be managed by the chart, define `persistence.existingClaim`.

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --set persistence.existingClaim=PVC_NAME
```

