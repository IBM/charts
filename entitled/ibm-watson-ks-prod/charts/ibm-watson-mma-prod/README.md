# ibm-watson-mma-prod
This chart contains the custom model management API for IBM Watson's NLU (Natural Language Understanding) service.

## Introduction
MMA is the primary stateful component of the Watson Natural Language Understanding stack.

## Chart Details
This chart creates one pod and an associated service:
* `ibm-watson-mma-prod-model-management-api` - Model management API.

This chart is only intended to be used as a subchart. It is important to note that both MMA and v1 & v2 of MMA are included in this chart and accessible on ports 4000 and 4001, respectively.

<ins>chart status notes</ins>
- MMA v2 is a stub server only (no functionality)
- Secret is directly rendered by Helm (not recommended - should be replaced with an init container or something similar)
- Due to the prior point, not linked to Postgres at creation time; can only be tested if Postgres is already set up in Kubernetes
    - IMPORTANT: when testing, make sure to override the secret values with those matching your current Postgres deployment, otherwise things will fail!

## Prerequisites
> TODO
* Kubernetes Level - indicate if specific APIs must be enabled (i.e. Kubernetes 1.6 with Beta APIs enabled)
* PersistentVolume requirements (if persistence.enabled) - PV provisioner support, StorageClass defined, etc. (i.e. PersistentVolume provisioner support in underlying infrastructure with ibmc-file-gold StorageClass defined if persistance.enabled=true)
* Simple bullet list of CPU, MEM, Storage requirements
* Even if the chart only exposes a few resource settings, this section needs to inclusive of all / total resources of all charts and subcharts.

## Resources Required
> TODO
* Describes Minimum System Resources Required; we need to tune these values for ICP4D.

## Installing the Chart
N/A; this chart should not be released in isolation.

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart
N/A; this chart should not be released in isolation.

## Configuration
The configuration parameters for the Model Management API chart should be set by the Umbrella chart including it. This chart should not exist in isolation.

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.
Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
- ICPv3.1 - Predefined PodSecurityPolicy name: privileged

## Storage
> TODO; this should be updated once Postgres is set up correctly, since we will need to figure out dynamic provisioning first.
* Define how storage works with the workload
* Dynamic vs PV pre-created
* Considerations if using hostpath, local volume, empty dir
* Loss of data considerations
* Any special quality of service or security needs for storage

## Limitations
> TODO
* Deployment limits - can you deploy more than once, can you deploy into different namespace
* List specific limitations such as platforms, security, replica's, scaling, upgrades etc.. - noteworthy limits identified
* List deployment limitations such as : restrictions on deploying more than once or into custom namespaces.
* Not intended to provide chart nuances, but more a state of what is supported and not - key items in simple bullet form.
* Does it work on IBM Container Services, IBM Private Cloud?

## PodSecurityPolicy requirements
> TODO

## Documentation
> TODO
* Can have as many supporting links as necessary for this specific workload however don't overload the consumer with unnecessary information.
* Can be links to special procedures in the knowledge center.
