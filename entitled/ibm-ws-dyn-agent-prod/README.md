# IBM Workload Automation Agent - Helm Chart


## Introduction
This chart helps you install and configure IBM Workload Automation Agent.
IBM Workload Automation Agent is a fully-featured version of the **Dynamic Agent** component of IBM Workload Automation. 
To install and configure IBM Workload Automation Agent, see also [Installing IBM Workload Automation Agent](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.4.0/com.ibm.tivoli.itws.doc_9.4/distr/src_pi/awspiinstallingoncloud.htm).
 

## Chart Details
The following is deployed as the standard configuration:
 * Headless service: `agent_release_name`-server
 * StatefulSet: `agent_release_name` 
 * Persistent Volume Claim (only if persistence.enabled:true): `agent_release_name`-data  

where `agent_release_name` is the custom release name (see the [Installing the Chart](#installing the chart) section).

The workload is composed of a StatefulSet including a single image container for the IBM Workload Automation Agent.

## Prerequisites
*  Kubernetes 1.10 with Beta APIs enabled.
*  If dynamic provisioning is not being used, Persistent Volume must be re-created and setup with labels that can be used to refine the Kubernetes PVC bind process.
*  If dynamic provisioning is being used, specify a storageClass per Persistent Volume provisioner to support dynamic volume provisioning
*  A default storageClass is setup during the cluster installation or created prior to the deployment by the Kubernetes administrator.


## Resources Required
 Minimum system resources required:
* CPU 1
* MEM 200Mi
* Storage requirements 2Gi

## Installing the Chart

To install the chart with the release name of your choice  `agent_release_name`, run:

```bash
$ helm install --tls --name agent_release_name stable/ibm-ws-dyn-agent-prod
```

The command deploys the `ibm-ws-dyn-agent-prod` chart on the Kubernetes cluster in the default configuration. The [Configuration](#configuration) section lists the parameters that can be configured during installation.


> **Tip**: List all releases using `helm list --tls` 

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions


## Upgrading the Chart

To upgrade the release `agent_release_name` to a new version of the chart, run: 

```bash
$ helm upgrade --tls agent_release_name stable/ibm-ws-dyn-agent-prod
```

Before you perform the upgrade of a chart, if you have jobs that are currently running, the related processes must be stopped manually or you must wait until the jobs are complete.


### Uninstalling the Chart

To uninstall/delete the `ibm-ws-dyn-agent-prod`  deployment, run:

```bash
$ helm delete --tls agent_release_name --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes:

```bash
$ kubectl delete pvc -l release=agent_release_name
```

## Configuration

The following table lists the configurable parameters of the  chart and their default values.

| Parameter                                     |        Description                                                        |              Default               |
| --------------------------------------------  | ------------------------------------------------------------------------  |----------------------------------- |
| `replicaCount`                                | Number of deployment replicas                                             | `1`                                |
| `image.repository`                            | IBM Workload Automation Agent image repository                            | `ibm-workload-scheduler-agent-dynamic` |
| `image.pullPolicy`                            | Image pull policy                                                         | `Always`                           |
| `image.tag`                                   | IBM Workload Automation Agent image tag                                   | `9.4.0.04`                         |
| `license`                                     | To accept the license agreement                                           | `use accept to accept the license` |
| `agent.name`                                  | Agent display name                                                        | `WA_AGENT`                         |
| `agent.dynamic.server.mdmhostname`            | Hostname of the master domain server                                      | `WAMDM`                            |
| `agent.dynamic.server.port`                   | Port of the master domain server                                          | `31116`                            |
| `agent.dynamic.server.bkmhostname`            | Host name of the backup master domain manager                             | `nil`                              |
| `agent.dynamic.pools`                         | The static workstation pools with which you want to register this agent(*)| `nil`                              |
| `useCustomizedCert`                           | To specify if the agent must use customized certificates to connect to    | `false`                            |
|                                               | the master domain manager (**)                                            |                                    | 
| `resources.limits.memory`                     | Memory resource limits                                                    | `200Mi`                            |
| `resources.limits.cpu`                        | CPU resource limits                                                       | `1`                                |
| `persistence.enabled`                         | To use persistent volume                                                  | `true`                             |
| `persistence.useDynamicProvisioning`          | To use storage classes to dynamically create Persistent Volumes           | `true`                             |
| `persistence.dataPVC.name`                    | Suffix for the names of Persistent Volume Claim                           | `data`                             |
| `persistence.dataPVC.storageClassName`        | Name of the Storage Class to use                                          | `nil`                              |
| `persistence.dataPVC.selector.label`          | Volume label to bind                                                      | `nil`                              |
| `persistence.dataPVC.selector.value`          | Volume label value to bind                                                | `nil`                              |
| `persistence.dataPVC.size`                    | Size of Persistent Volume                                                 | `2Gi`                              |

(*) Note: for details about static workstation pools, see: 
[Workstation](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.4.0/com.ibm.tivoli.itws.doc_9.4/distr/src_ref/awsrgworkstationconcept.htm).

(**) Note: if you set `useCustomizedCert:true`, you must create a secret containing the customized files:

 * TWSClientKeyStore.kdb 
 * TWSClientKeyStore.sth
  
 that will replace the Agent default ones. For detailed instructions, see the [Secrets](#secrets) section.
  
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install --tls`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example:
```bash
$ helm install --tls --name agent_release_name stable/ibm-ws-dyn-agent-prod --set LICENSE=accept
```
> **Tip**: You can use the default values.yaml

## Secrets
If you want to use custom Agent certificates, set `useCustomizedCert:true` and use kubectl to create the following secret in the same namespace where you want  to deploy the chart:   

```bash
$ kubectl create secret generic agent_release_name-secret --from-file=TWSClientKeyStore.kdb --from-file=TWSClientKeyStore.sth --namespace=chart_namespace
```

where TWSClientKeyStore.kdb and TWSClientKeyStore.sth are the Agent keystore and stash file containing your customized certificates.
For details about custom certificates, see the [online](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.4.0/com.ibm.tivoli.itws.doc_9.4/distr/src_ad/awsadsslddmda.htm) documentation.

See an example where `agent_release_name` = myname: 

```bash
$ kubectl create secret generic myname-secret --from-file=TWSClientKeyStore.kdb --from-file=TWSClientKeyStore.sth --namespace=default
```

## Storage
To make persistent all the stdlist logs, job archives and the JobTableDir, the Persistent Volume you specify is mounted in the container folder   
`/home/wauser/TWA/TWS/stdlist   `

The Pod is based on a StatefulSet. This to guarantee that each Persistent Volume is mounted in the same Pod when it is scaled up or down.  

Only for test purposes, you can configure the chart in a way not to use persistence.

You can pre-create Persistent Volumes to be bound to the StatefulSet using Label or StorageClass. Anyway, we suggest to use persistence with dynamic provisioning. In this case you must have defined your own Dynamic Persistence Provider.

The Helm chart is written so that it can support several different **storage** **use cases**:

 **1. Persistent storage using kubernetes dynamic provisioning.** 
 
  It uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which overrides the default.
  Set global values to:
 
  *   `persistence.enabled:true (default)` 
  *   `persistence.useDynamicProvisioning:true(default)`
  
   Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.    
 
 **2. Persistent storage using a predefined PersistentVolume setup prior to the deployment of this chart**
 
  Set global values to:
 *  `persistence.enabled:true` 
 *  `persistence.useDynamicProvisioning:false`
 
  Let the Kubernetes binding process select a pre-existing volume based on the accessMode and size. Use selector labels to refine the binding process.

 **3. No persistent storage**. 
 
  All storage is within the container and will be lost when pod terminates. 
  Enable this mode by setting the global values to:
*  `persistence.enabled:false` 
*  `persistence.useDynamicProvisioning:false` 


## Limitations
*  Limited to amd64 platforms  

## Documentation
 For a description of IBM Workload Automation Agent functionality, see the  [online](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.4.0/com.ibm.tivoli.itws.doc_9.4/twa_landing.html) documentation.
