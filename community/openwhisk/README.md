# OpenWhisk
Apache OpenWhisk is an open source, distributed serverless platform that executes functions in response to events at any scale.

## Introduction
This chart is for deploying [Apache OpenWhisk](https://openwhisk.apache.org/) to your Kubernetes cluster.

[Add more] 
* Paragraph overview of the workload
* Include links to external sources for more product info
* Don't say "for ICP" or "Cloud Private" the chart should remain a general chart not directly stating ICP or ICS. 

## Chart Details
[Add more]
* Simple bullet list of what is deployed as the standard config
* General description of the topology of the workload 
* Keep it short and specific with items such as : ingress, services, storage, pods, statefulsets, etc. 

## Prerequisites
* Kubernetes 1.10 - 1.11.*

[Add more]
* PersistentVolume requirements (if persistence.enabled) - PV provisioner support, StorageClass defined, etc. (i.e. PersistentVolume provisioner support in underlying infrastructure with ibmc-file-gold StorageClass defined if persistance.enabled=true)

[Add more]
* Simple bullet list of CPU, MEM, Storage requirements
* Even if the chart only exposes a few resource settings, this section needs to inclusive of all / total resources of all charts and subcharts.

### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator setup a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-anyuid-hostpath-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
        name: ibm-anyuid-hostpath-psp
    annotations:
        kubernetes.io/description: "This policy allows pods to run with 
        any UID and GID and any volume, including the host path.  
        WARNING:  This policy allows hostPath volumes.  
        Use with caution." 
    spec:
        allowPrivilegeEscalation: true
        fsGroup:
            rule: RunAsAny
        requiredDropCapabilities: 
        - MKNOD
        allowedCapabilities:
        - SETPCAP
        - AUDIT_WRITE
        - CHOWN
        - NET_RAW
        - DAC_OVERRIDE
        - FOWNER
        - FSETID
        - KILL
        - SETUID
        - SETGID
        - NET_BIND_SERVICE
        - SYS_CHROOT
        - SETFCAP 
        runAsUser:
            rule: RunAsAny
        seLinux:
            rule: RunAsAny
        supplementalGroups:
            rule: RunAsAny
        volumes:
        - '*'
    ```

## Resources Required
[Add more]
* Describes Minimum System Resources Required

## Initial setup

1. Identify the Kubernetes worker nodes that should be used to execute
user containers.  Do this by labeling each node with
`openwhisk-role=invoker`. If you have a multi-node cluster, for each node <INVOKER_NODE_NAME>
you want to be an invoker, execute
```shell
kubectl label nodes <INVOKER_NODE_NAME> openwhisk-role=invoker
```
For a single node cluster, simply do
```shell
kubectl label nodes --all openwhisk-role=invoker
```

## Installing the Chart

Please ensure that you have reviewed the [prerequisites](#prerequisites) and the [initial setup](#initial-setup) instructions.

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release community/openwhisk --set whisk.ingress.apiHostName=<your ip address>
```

The command deploys OpenWhisk on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

You can use the command ```helm status <release name>``` to get a summary of the various Kubernetes artifacts that make up your OpenWhisk deployment. Once the ```install-packages``` Pod is in the Completed state, your OpenWhisk deployment is ready to be used.

### Verifying the Chart
To verify your deployment was successful! simply run:
```bash
helm test <release name>
```

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete <my-release> --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  

## Configuration
[Values.yaml](./values.yaml) outlines the configuration options that are supported by this chart.

[Please Review]
## Storage
* Define how storage works with the workload
* Dynamic vs PV pre-created
* Considerations if using hostpath, local volume, empty dir
* Loss of data considerations
* Any special quality of service or security needs for storage

## Limitations
* Deployment limitation - you can only deploy one instance of a chart in a single namespace.
* Platform limitation - only supports amd64.

## Documentation
* [OpenWhisk documentation](https://openwhisk.apache.org/documentation.html)

# Disclaimer
Apache OpenWhisk Deployment on Kubernetes is an effort undergoing incubation at The Apache Software Foundation (ASF), sponsored by the Apache Incubator. Incubation is required of all newly accepted projects until a further review indicates that the infrastructure, communications, and decision making process have stabilized in a manner consistent with other successful ASF projects. While incubation status is not necessarily a reflection of the completeness or stability of the code, it does indicate that the project has yet to be fully endorsed by the ASF.

# Support
For questions, hints, and tips for developing in Apache OpenWhisk:

[Join the Dev Mailing List](https://openwhisk.apache.org/community.html#mailing-lists)

[Follow OpenWhisk Media](https://openwhisk.apache.org/community.html#social)
