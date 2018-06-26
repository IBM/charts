[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2018 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)


# IBM PowerAI Helm Chart

[IBM PowerAI](https://developer.ibm.com/linuxonpower/deep-learning-powerai/) makes deep learning, machine learning, and AI more accessible and more performant.

## Introduction

This is a chart for IBM PowerAI. IBM PowerAI incorporates some of the most popular deep learning frameworks along with unique IBM augmentations to improve cluster performance and support larger deep learning models. This chart is intended to be deployed in IBM Cloud Private.


## Chart Details

- Deploys a pod with the PowerAI container with all of the supported PowerAI Frameworks.
- Supports persistent storage, allowing you to access your datasets and provide your training application code to the pod.
- Provides control over the command that is run during pod startup.

## Prerequisites

- Kubernetes v1.83 or later with GPU scheduling enabled, and Tiller v2.60 or later
- The application must run on *Power System ppc64le* nodes with *supported GPUs* (see PowerAI V1.5.2 release notes).  
- Helm 2.3.1 and later version
- If you wish to leverage persistent storage for data sets and/or runtime code, you should enable `persistence.enabled=true` and create your persistent volume prior to deploying the chart (unless you use `dynamic provisioning`).  It can be created by using the IBM Cloud private UI or via a yaml file as in the following example:

```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: "powerai-datavolume"
  labels:
    type: local
spec:
  storageClassName: ""
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/powerai/data"

```
## Resources Required

Generally PowerAI leverages GPUs for training and inferencing.  You can control the number of GPUs a given pod has access to using the `resource.gpu` value.  Setting it to 0 will allow deployment on a non-gpu system.


## Limitations

This chart provides some basic building blocks to get started with PowerAI.  It is generally expected (though not required) that the PowerAI docker image and helm chart would be extended for a specific production use case.


## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release --set license=accept stable/ibm-powerai --tls
```

The command deploys ibm-powerai on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls 
```

The command removes all the Kubernetes components associated with the chart and deletes the release. After deleting the chart, you should consider deleting any persistent volume that you created.

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.


```console
$ kubectl delete pvc -l release=my-release
``` 
```console
$ kubectl delete pv <name_of_pv>
``` 

## Configuration
The following table lists the configurable parameters of the `ibm-powerai` chart and their default values.

| Parameter                        | Description                                     | Default                                                    |
| -------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `license`                        | Set `license=accept` to accept the terms of the license | `Not accepted`                                     |
| `image.repository`               | PowerAI image repository.          | `hub.docker.com/ibmcom/powerai`                       |
| `image.tag`                      | Docker Image tag. To get the tag of other images, visit "hub.docker.com/ibmcom/powerai"                                    | `1.5.2-all-ubuntu16.04`                                                        |
| `image.pullPolicy`               | Docker Image pull policy (Options - IfNotPresent, Always, Never)                              | `IfNotPresent`                                             |
| `global.image.secretName`               | Docker Image pull secret, if you are using a private Docker registry | `nil`                                        |
| `service.type`                   | Kubernetes service type for exposing ports (Options - ClusterIP, NodePort, None)       | `nil`                                  |
| `service.port`                   | Kubernetes port number to expose       | `nil`                                  |
| `resources.gpu`          | Number of GPUs on which to run the container. A value of 0 will not allocate a GPU.  | `1`                                                   |
| `persistence.enabled`       | Use a PVC to persist data | `false`                                              |
| `persistence.useDynamicProvisioning`        | Use dynamic provisioning for persistent volume | `false`                                                 |
| `poweraiPVC.name`        | Name of volume claim | `datavolume`                                                 |
| `poweraiPVC.accessMode`        | Volume access mode (Options: ReadWriteOnce, ReadWriteMany, ReadOnlyMany) | `ReadWriteOnce`                                                 |
| `poweraiPVC.existingClaim`        | Data PVC existing claim name | nil (will create a new claim by default)                                                 |
| `poweraiPVC.storageClassName`     | Data PVC Storage class | nil (uses default cluster storage class for dynamic provisioning)                                            |
| `poweraiPVC.size`              | Data PVC size                          | `8Gi`                                        |
| `command`              | Command need to run inside pod. E.G. /usr/bin/python /powerai/data/train.py;                           | `nil` 

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. 
> **Tip**: You can use the default [values.yaml](values.yaml)


The volume is mounted in /powerai/data when `persistence.enabled=true`


## persistence

You can optionally provide a persistent volume to the deployment. This volume can hold data that you wish to process, as well as executables for the command you wish to run. For example, if you had python code that would train a model on a given set of data, this volume would host your python code as well as your data, and you can run the python code by specifying the appropriate command.


- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - persistence.enabled: true
    - persistence.useDynamicProvisioning: true
    - repository.persistence.useDynamicProvisioning: false (default)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart.
  - Set global values to:
    - persistence.enabled: true
    - persistence.useDynamicProvisioning: false (default)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.


- No persistent storage. This mode with use emptyPath for any volumes referenced in the deployment.
  - enable this mode by setting the global values to:
    - persistence.enabled: false
    - persistence.useDynamicProvisioning: false
    - repository.persistence.useDynamicProvisioning: false
