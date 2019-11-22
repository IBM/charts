[![IBM Spectrum Computing](https://github.com/IBMSpectrumComputing/lsf-hybrid-cloud/blob/master/Spectrum_icon.png)](https://www.ibm.com/support/knowledgecenter/SSWRJV/product_welcome_spectrum_lsf.html)

# IBM Spectrum Computing

**NOTICE: This Technical Preview will expire Oct 31st, 2019**

## Introduction
IBM Spectrum Computing delivers three key capabilities:
* Effectively manages highly variable demands in workloads within a finite supply of resources
* Provides improved service levels for different consumers and workloads in a shared multitenant environment
* Optimizes the usage of expensive resources such as general-purpose graphics processing units (GPGPUs) to help ensure that they are allocated the most important work

### Overview
IBM Spectrum Computing builds on IBM Spectrum Computing's rich heritage in workload management and orchestration in demanding high performance computing and enterprise environments. With this strong foundation, IBM Spectrum Computing brings a wide range of workload management capabilities that include:
* Multilevel priority queues and preemption
* Fairshare among projects and namespaces
* Resource reservation
* Dynamic load-balancing
* Topology-aware scheduling
* Capabilty to schedule GPU jobs with consideration for CPU or GPU topology
* Parallel and elastic jobs
* Time-windows
* Time-based configuration
* Advanced reservation
* Workflows

### Improved workload prioritization and management
IBM Spectrum Computing adds robust workload orchestration and prioritization capabilities to IBM Cloud Private environments. IBM Cloud Private is an application platform for developing and managing on-premises, containerized applications. It is an integrated environment for managing containers that includes the container orchestrator Kubernetes, a private image repository, a management console, and monitoring frameworks.
While the Kubernetes scheduler in IBM Cloud Private employs a basic “first come, first served" method for processing workloads, IBM Spectrum Computing enables organizations to effectively prioritize and manage workloads based on business priorities and objectives. 

### Key capabilities of IBM Spectrum Computing
**Workload Orchestration**  
Kubernetes provides effective orchestration of workloads as long as there is capacity. In the public cloud, the environment can usually be enlarged to help ensure that there is always capacity in response to workload demands. However, in an on-premises deployment of IBM Cloud Private, resources are ultimately finite. For workloads that dynamically create Kubernetes pods (such as Jenkins, Jupyter Hub, Apache Spark, Tensorflow, ETL, and so on), the default "first come, first served" orchestration policy is not sufficient to help ensure that important business workloads process first or get resources before less important workloads. IBM Spectrum Computing prioritizes access to the resources for key business processes and lower priority workloads are queued until resources can be made available.

**Service Level Management**  
In a multitenant environment where there is competition for resources, workloads (users, user groups, projects, and namespaces) can be assigned to different service levels that help ensure the right workload gets access to the right resource at the right time. This function prioritizes workloads and allocates a minimum number of resources for each service class. In addition to service levels, workloads can also be subject to prioritization and multilevel fairshare policies, which maintain correct prioritization of workloads within the same Service Level Agreement (SLA). 

**Resource Optimization**
Environments are rarely homogeneous. There might be some servers with additional memory or some might have GPGPUs or additional capabilities. Running workloads on these servers that do not require those capabilities can block or delay workloads that do require additional functions. IBM Spectrum Computing provides multiple polices such as multilevel fairshare and service level management, enabling the optimization of resources based on business policy rather than by users competing for resources.


## Chart Details
Only one instance of this chart should be deployed.  It should be deployed by the Cluster Administrator. 
The following items are created when this chart is deployed:
* A daemon set on all worker nodes
* A management pod running on one of the management nodes
* A persistent volume claim

## Prerequisites
* Deployment of the chart requires at least two machines: one manager and one worker.
* A persistent volume for state storage.

## PodSecurityPolicy Requirements
The pods created by deploying the chart should use at a minimum the [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) PodSecurityPolicy.
Capabilites KILL, SETUID, and SETGID are necessary to become users and manage workload.  The SYS_ADMIN capability is needed to allow mode switching of GPUs.  Detection and control of the GPU also requires the pod to have access to /dev on the worker node.  This requires privileged containers.  Privileged containers are enabled by setting the **gpu.nvidiapath** chart value.  If set it is assumed that GPUs are available, and the agent pods will switch to privileged.  If you do not have GPUs do not set this value.  Using the Nvidia docker runtime will have the same effect without needing to set **gpu.nvidiapath**.

A more restrictive policy is given below.
Custom PodSecurityPolicy definition:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy allows pods to run with any
      UID and GID, and run some ioctl commands.
      Use with caution."
  name: ibm-spectrum-computing-psp
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - MKNOD
  - NET_RAW
  - SYS_CHROOT
  - SETFCAP
  - AUDIT_WRITE
  - FOWNER
  - FSETID
  allowedCapabilities:
  - KILL
  - SETUID
  - SETGID
  - CHOWN
  - SETPCAP
  - NET_BIND_SERVICE
  - DAC_OVERRIDE
  - SYS_ADMIN
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - '*'
  hostIPC: false
  hostNetwork: false
  hostPID: false
  hostPorts:
  - max: 65535
    min: 0
```

## Resources Required
* 1 GB free on the management nodes
* 1 core on the management nodes
* 512 MB free on worker nodes
* 200m cores on the worker nodes

## Installing the Chart
The chart can be installed either through the GUI or Helm CLI.  To deploy using the CLI log in as 
the cluster administrator and run the following:
```bash
cloudctl login --skip-ssl-validation -u admin
```
** Note the API endpoint from above.  It will be used later. **
```bash 
cloudctl catalog load-archive --archive ibm-spectrum-computing-1.1.0.tgz
export HELM_HOME=~/.helm
helm repo add local-charts {API Endpoint from above}/helm-repo/charts --ca-file $HELM_HOME/ca.pem --cert-file $HELM_HOME/cert.pem --key-file $HELM_HOME/key.pem
helm install --tls --name hpac local-charts/ibm-spectrum-computing-prod
```
**NOTE: You may need to run "helm init" to initialize helm.**

This will deploy the chart and name the deployment "hpac".

A persistent volume is required to hold the configuration and job information.  This needs to be
created before deploying the chart.

### Verify the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

### Uninstalling the Chart
The chart can be uninstalled by running:
```bash
helm delete --purge --tls {Name of deployment}
```

## Configuration
The following tables lists the configurable parameters of the chart and their default values.

| Parameter                    | Description                                     | Default                 |
| --------------------------   | ---------------------------------------------   | ----------------------- |
| `manager.image`              | The image for the management pod                | `lsf-master`            |
| `manager.tag`                | The image tag to use for the management pod     | `10.1.0.7m31`             |
| `manager.imagePullPolicy`    | The image pull policy for the management image  | `Always`                |
| `manager.cpu`                | The amount of CPU to allocate to the manager    | `1000m`                  |
| `manager.memory`             | The amount of RAM to allocate to the manager    | `1Gi`                   |
| `compute.image`              | The image for the worker pod                    | `lsf-comp`              |
| `compute.tag`                | The image tag to use for the worker pod         | `10.1.0.7m31`             |
| `compute.imagePullPolicy`    | The image pull policy for the worker image      | `Always`                |
| `compute.excludeHostLabel`   | Worker nodes with this label will be excluded   | `excludelsf`            |
| `pvc.useDynamicProvisioning` | When true try to create storage automatically   | `false`                 |
| `pvc.storageClassName`       | Storage class to use for dynamic storage        | `""`                    |
| `pvc.existingClaimName`      | When defined use this Persistent Volume Claim   | `""`                    |
| `pvc.selector.label`         | The selector label for the PV                   | `lsfvol`                |
| `pvc.selector.value`         | The selector label value for the PV             | `lsfvol`                |
| `pvc.size`                   | The minim8um size of volume to use              | `5Gi`                   |
| `pvc.fsGroup`                | The GID to use for the fsGroup for the PVC      | `495`                   |
| `pvc.supplementalGroups`     | The GID to use in addition for the PVC          | `495`                   |
| `gpu.nvidiapath`             | For non nvidia-docker runtimes.  Kublets nvidia-driver path | `""`        |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

## Storage
Persistent storage will be needed in production environments where job loss is not acceptable.  A Persistent Volume (PV) should be created before deploying the chart.  Consult the storage configuration documentation to setup the PV.
The sample definition below is for a NFS based persistent volume.
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mylsfvol
  labels:
    lsfvol: "lsfvol"
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: "Recycle"
  nfs:
    # FIXME: Use your NFS servers IP and export
    server: 10.1.1.1
    path: "/export/stuff"
```
Save the definition and replace the **server** and **path** values to match your NFS server.  Note the labels.  These are used to make sure that this volume is used with the chart deployment.  The configuration files are located in this volume.

## Limitations
This chart supports IBM Cloud Private 3.1.x and later.

In this configuration IBM Spectrum LSF has been packaged for deployment as a helm chart.  
The container images used have been packaged to make deployment and evaluation as simple as possible.  
Those containers are not integrated with the site specific user authentication system such as NIS/LDAP/Kerberos etc.  
To use user specific policies use the tools below to import users and groups.

Nvidia Docker is needed for GPU support.  The containers are built without GPU libraries, so Nvidia Docker is needed to provide access to the GPU utilities and libraries. 

This chart deploys a daemonset on all of the available worker nodes, as such provides no manual scaling of the of the deployment.  

No encryption of the data at rest or in motion is provided by this chart.  It is up to the administrator to configure storage encryption and IPSEC to secure the data.


# Job Scheduler Spec Reference and Examples
This section outlines how to use the new capabilites.

Additional examples and the most current pod specification annotations are available [here.](https://github.com/IBMSpectrumComputing/lsf-kubernetes)
Questions can be posted but do not post any confidential information.

More information on the LSF job submission options and configuration can be found [here](https://www.ibm.com/support/knowledgecenter/SSWRJV_10.1.0/lsf_welcome/lsf_kc_cluster_ops.html).

## Job Scheduler Spec Reference
Deploying the chart enables job control extensions for the pods.  The table below lists the pod spec fields that are available:

| Pod Spec Field                  | Description                            | LSF job submission option |
| ------------------------------- | ------------------------------------   | ----------------- |
| `*metadata.name`                | A name to assign to the job            | `Job Name (-J)`  |
| `++lsf.ibm.com/project`         | A project name to assign to job        | `Project Name (-P)`  |
| `++lsf.ibm.com/application`     | An application profile to use          | `Application Profile (-app)`|
| `++lsf.ibm.com/gpu`             | The GPU requirements for the job       | `GPU requirement (-gpu)`  |
| `++lsf.ibm.com/queue`           | The name of the job queue to run the job in | `Queue (-q)`   |
| `++lsf.ibm.com/jobGroup`        | The job group to put the job in        | `Job Group (-g)`  |
| `++lsf.ibm.com/fairshareGroup`  | The fairshare group to use to share resources between jobs | `Fairshare Group (-G)`  |
| `++lsf.ibm.com/user`            | The user to run applications as, and for accounting  | `Job submission user`  |
| `++lsf.ibm.com/reservation`     | Reserve the resources prior to running job | `Advanced Reservation (-U)`  |
| `++lsf.ibm.com/serviceClass`    | The jobs service class                 | `Service Class (-sla)`  |
| `spec.containers[].resources.requests.memory` | The amount of memory to reserve for the job | `Memory Reservation (-R "rusage[mem=...]")` |
| `*spec.schedulerName`           | Set to "lsf"                           | N/A |

**NOTE:  * - in pod specification section:  spec.template, ++ - in pod specification section:  spec.template.metadata.annotations**

These capabilities are accessed by modifying the pod specifications for jobs.  Below are some samples of how to configure jobs to access the new capabilites.

### Job Scheduler Example 1 
This example uses the new scheduler for the placement of the workload.  The placement request will be routed to the LSF scheduler for queuing and placement.  

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: myjob-k8s-115
spec:
  template:
    metadata:
      name: myjob-001
    spec:
      schedulerName: lsf        # This directs scheduling to the LSF Scheduler
      containers:
      - name: ubuntutest
        image: ubuntu
        command: ["sleep", "60"]
        resources:
          requests:
            memory: 5Gi
      restartPolicy: Never
```
Here we have just told Kubernetes to use **lsf** as the job scheduler.  The LSF job scheduler can 
then apply it's policies to choose when and where the job will run.

### Job Scheduler Example 2
Additional parameters can be added to the pod yaml file to control the job.  The example below adds 
some additional annotations for controlling the job.  The **lsf.ibm.com/queue: "normal"** tells the scheduler to use the **normal** queue.  By default there are four queues available:
* priority - This is for high priority jobs
* nornal - This is for normal jobs
* idle - These are for jobs that can only run if there are idle resources
* night - These are for jobs that are only allowed to run at night

Additional queues can be added by modifing the **lsb.queues** configMap.

The **lsf.ibm.com/fairshareGroup: "gold"** tells the scheduler which fairshare group this job belongs to.  By default the following groups have been configured:
* gold
* silver
* bronze

These groups allow the user to modify how the resources are shared.  Some groups may have a higher allocation of resources, and can use a better fairshareGroup.
 
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: myjob-001
spec:
  template:
    metadata:
      name: myjob-001
      # The following annotations provide additional scheduling
      # information to better place the pods on the worker nodes
      # NOTE:  Some of these require additional configuration to work
      annotations:
        lsf.ibm.com/project: "big-project-1000"
        lsf.ibm.com/queue: "normal"
        lsf.ibm.com/jobGroup: "/my-group"
        lsf.ibm.com/fairshareGroup: "gold"
    spec:
      # This directs scheduling to the LSF Scheduler
      schedulerName: lsf
      containers:
      - name: ubuntutest
        image: ubuntu
        command: ["sleep", "60"]
      restartPolicy: Never
```
In the example above the annotations provide the LSF scheduler more information about the job and how it should be run.  

### Important Example About Pod Users 
Users that submit a job through Kubernetes typically are trusted to run services 
and workloads as other users.  For example, the pod specifications allow the pod to run as other users e.g.
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: myjob-uid1003-0002
spec:
  template:
    metadata:
      name: myjob-uid1003-0002
    spec:
      schedulerName: lsf
      containers:
      - name: ubuntutest
        image: ubuntu
        command: ["id"]
      restartPolicy: Never
      securityContext:
        runAsUser: 1003
        fsGroup: 100
        runAsGroup: 1001
```
In the above example the pod would run as UID 1003, and produce the following output:
```sh
uid=1003(billy) gid=0(root) groups=0(root),1001(users)
``` 
**Note the GID and groups.**  
Care should be taken to limit who can create pods.

## Parallel Jobs
The chart includes a new Custom Resource Definition (CRD) for parallel jobs.  This simplifies the creation of parallel jobs in kubernetes.  The ParallelJob CRD describes the resource requirements for parallel jobs with multiple tasks on K8s.
The ParallelJob controller daemon is responsible to create seperate Pods for each task described
in the ParallelJob CRD. 

The CRD supports both job-level and task-level scheduling terms which can satisfy common scheduling 
needs over all of the Pods in the same job or individual need for each Pod. At the same time, one
can also specify all of the Pod Spec policies for the Pod defined in the ParallelJob CRD.

### Job level terms

ParallelJob CRD supports the following job-level terms to describe the resource requirements apply for 
all of the Pods in the same parallel job.

* spec.description: the human readable description words attached to the parallel job
* spec.resizable: the valid values are "true" or "false", which determines whether the Pods in the parallel job should be co-scheduling together. Specifically, a resizable job can be started with a few Pods got enough resources, while a non-resizable job must get enough resources for all of the Pods before starting any Pods.
* spec.headerTask: typical parallel jobs (e.g. Spark, MPI, Distributed Tensorflow) run a "driver" task to co-ordinate or work as a centeral sync point for the left tasks. This term can be used to specify the name of such "driver" task in a parallel job. It will make sure the header task can be scheduled and started before or at the same time with other non-header tasks.
* spec.placement: this term supports multiple sub-terms which can satisfy various task distribution policies, such as co-allocating multiple tasks on the same host or zone, or evenly distribute the same number of tasks across allocated hosts. This term can be defined in both job-level and task-group level.

Currently, this term supports the following placement policies. The example defines a "same" policy in job-evel to enforce all of the tasks belong to the parallel job co-allocated to the nodes in the same zone. 

```
sameTerm: node | rack | zone
spanTerms:
- topologyKey: node
  taskTile: #tasks_per_topology 
```
To use the topology keys, you must define the following host based resources in your LSF configuration files. Examples are as follows.

lsf.shared:

```
Begin Resource
RESOURCENAME  TYPE    INTERVAL INCREASING  DESCRIPTION
...
kube_name     String  ()       ()          (Kubernetes node name)
rack_name     String  ()       ()          (Kubernetes node rack name)
zone_name     String  ()       ()          (Kubernetes node zone name)    
End Resource
```

lsf.cluster:
```
Begin   Host
HOSTNAME    model  type  server  RESOURCES
...
ICPHost01  !      !     1       (kube_name=172.29.14.7 rack_name=blade1 zone_name=Florida)
End Host
```

* spec.priority: this term is used to specify job priority number which can rank the parallel job with other jobs submitted by the same user. The default maximum number can be supported by LSF is 100.    

### Task level terms

The tasks are grouped by the common resource requirements of replicas. 

* spec.taskGroups[].spec.replica: this term defines the number of tasks in current task group
* spec.taskGroups[].spec.placement: this term shares the same syntax with the one defined at job level. 
The second task group in the example defines an alternative "span" like placement policy, which can either put 4 replicas across two nodes or on the same node.
* spec.taskGroups[].spec.template.spec: the Pod Spec shares the same syntax supported by your K8s cluster. For example, you can specify the nodeSelector to fiter node lables during scheduling.

### LSF specific annotations

The annotations defined at job-level can support job control extensions with prefix of "lsf.ibm.com/" listed in [here](#Job-Scheduler-Spec-Reference). The resource requirements conflict of the following extensions are described as follows.

* lsf.ibm.com/gpu: Number of GPUs to be requested on each host (-gpu). This term will be ignored when the Pod explicitly request nvidia.com/gpu resource in ParallelJob CRD.
* lsf.ibm.com/minCurrent: Not supported by ParallelJob CRD. All of replicas must get allocation at the same time for non-resizable job. For resizable job, once header task got allocation, the job can be started no matter whether other tasks can get allocation at
the same time.

## Submit ParallelJob CRD

The following example submission script describes a parallel job which have two replicas (tasks) in total.

```
$ cat example.yaml
apiVersion: ibm.com/v1alpha1
kind: ParallelJob
metadata:
  name: double-tasks-parallel
  namespace: default
  labels:
    lable1: example2
spec:
  name: double-tasks-parallel
  description: This is a parallel job with two tasks to be running on the same node.
  headerTask: group0
  priority: 100
  schedulerName: lsf
  taskGroups:
  - metadata:
      name: group0
    spec:
      placement:
        sameTerm: node
        spanTerms:
        - topologyKey: node
          taskTile: 2
      replica: 2
      template:
        spec:
          containers:
          - args:
            image: ubuntu
            command: ["sleep", "30"]
            name: task1
            resources:
              limits:
                cpu: 1
              requests:
                cpu: 1
                memory: 200Mi
          restartPolicy: Never
```

Sample jobs may also be found on GitHub: https://github.com/IBMSpectrumComputing/lsf-kubernetes


### Monitor ParallelJob CRD

Use the following command to monitor the status of a parallel job submitted using ParallelJob CRD. It will give the Job Status together with the counters of its Pods in various Pod phases as Task Status.

When the Job is in Pending status, the command shows the Job Pending Reason of corrosponding LSF control job.

```
> kubectl describe pj
Name:         parallel-job
Namespace:    default
Annotations:  <none>
API Version:  ibm.com/v1alpha1
Kind:         ParallelJob
...
...
Status:
  Job Pending Reason:  "New job is waiting for scheduling;"
  Job Status:          Pending
  Task Status:
    Unknown:    0
    Failed:     0
    Pending:    5
    Running:    0
    Succeeded:  0
```

The LSF control job ID is attached as a Pod label named lsf.ibm.com/jobId on each Pod. Several special Pod labels are attached to record the information of its parallel job belongs to.

```
> kubectl describe po
Name:               double-tasks-parallel-kflb9
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               <none>
Labels:             controller-uid=de751862-9114-11e9-864a-3440b5c56250
                    lsf.ibm.com/jobId=2762
                    parallelJob.name=double-tasks-parallel
                    parallelJob.taskGroup.index=1
                    parallelJob.taskGroup.name=group1
Annotations:        lsf.ibm.com/pendingReason: "New job is waiting for scheduling;"
...
...
```

## Host Maintenance
It may be necessary to remove a machine from operation, perhaps to apply patches to the Operating System.
To do this it is necessary to stop the machine from accepting any new workload.  This is done by running:
```sh
kubectl drain --ignore-daemonsets {Name of Node}
```
If you check the node status it will look something like:
```sh
10.10.10.12   Ready,SchedulingDisabled   worker                            5d1h   v1.12.4+icp-ee
```
The **SchedulingDisabled** status indicates that the scheduler will ignore this host.

Once the maintenance is complete the machine can be returned to use by running:
```sh
kubectl uncordon {Name of Node}
```
The **SchedulingDisabled** status will be removed from the machine and pods will be scheduled on it.


## Backups
Configuration and state information is stored in the persistent volume claim.  
Backups of that data should be performed periodically.  The state information 
can become stale very fast as users work is submitted and finished.  Some
job state data will be lost for jobs submitted between the last backup and 
current time.

> A reliable filesystem is critical to minimize job state loss.

Dynamic provisioning of the persistent volume is discouraged because of the difficulty
in locating the correct resource to backup.  Pre-creating a persistent volume claim,
or labeling a persistent volume, for the deployment to use provides the easiest 
way to locates the storage to backup. 

Restoring from a backup will require restarting the manager processes.  Use the procedure
below to reconfigure the entire cluster after restoring files.
1. Locate the master pod by looking for **ibm-spectrum-computing-prod-master** in the list of pods e.g.
```
$ kubectl get pods |grep ibm-spectrum-computing-prod-master
lsf-ibm-spectrum-computing-prod-master-56b55d6dc8-84gcj   1/1     Running   0          3d19h
```

2. Connect to the management pod e.g.
```
$ kubectl exec -ti lsf-ibm-spectrum-computing-prod-master-56b55d6dc8-84gcj bash
```

3. Run the command to re-read the configuration files
```
LSF POD [root@lsfmaster /]# cd /opt/ibm/lsfsuite/lsf/conf 
LSF POD [root@lsfmaster /opt/ibm/lsfsuite/lsf/conf]# ./trigger-reconfig.sh
```

4. Wait for a minute and try some commands to see if the cluster is functioning okay e.g.
```
LSF POD [root@lsfmaster /]# lsid
IBM Spectrum LSF Standard Edition 10.1.0.0, Apr 18 2019
Copyright International Business Machines Corp. 1992, 2016.
US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

My cluster name is myCluster
My master name is lsfmaster
```
 > Command should report the software versions and manager hostname.

```
LSF POD [root@lsfmaster /]# bhosts
HOST_NAME          STATUS       JL/U    MAX  NJOBS    RUN  SSUSP  USUSP    RSV
lsfmaster          closed          -      0      0      0      0      0      0
worker-10-10-10-10 ok              -      -      0      0      0      0      0
worker-10-10-10-11 ok              -      -      0      0      0      0      0
worker-10-10-10-12 ok              -      -      0      0      0      0      0
```
 > Host status should be **ok**, except for the lsfmaster, which will be **closed**.

```
LSF POD [root@lsfmaster /]# bqueues
QUEUE_NAME      PRIO STATUS          MAX JL/U JL/P JL/H NJOBS  PEND   RUN  SUSP
priority         43  Open:Active       -    -    -    -     0     0     0     0
normal           30  Open:Active       -    -    -    -     0     0     0     0
idle             20  Open:Active       -    -    -    -     0     0     0     0
night             1  Open:Inact        -    -    -    -     0     0     0     0
```
 > Queues should be open.


## Changing the Schedulers Configuration
The scheduler stores policy configuration in the persistent volume claim used by the manager pod.  
Additional configuration for the queues and fairshareGroups is stored in configMaps.
The default configuration can be changed, and information about the file formats is available [here.](https://www.ibm.com/support/knowledgecenter/SSWRJV_10.1.0/lsf_welcome/lsf_kc_cluster_ops.html)

What follows is an overview of how to change both the configuration stored in the persistent volume claim, and the configMaps.

### Changing Configuration Files
Changing the scheduler configuration requires:
* Connecting to the manager pod
* Changing the configuration file(s)
* Reconfiguring the scheduler

To connect the the manager pod use the following proceedure:
1. Locate the master pod by looking for **ibm-spectrum-computing-prod-master** in the list of pods e.g.
```
$ kubectl get pods --namespace {Namespace used to deploy chart} |grep ibm-spectrum-computing-prod-master
lsf-ibm-spectrum-computing-prod-master-56b55d6dc8-84gcj   1/1     Running   0          3d19h
```

2. Connect to the management pod e.g.
```
$ kubectl exec -ti lsf-ibm-spectrum-computing-prod-master-56b55d6dc8-84gcj bash
```

The configuration files are located in: `/opt/ibm/lsfsuite/lsf/conf`

The directory has the following files in it:
```
 conf/cshrc.lsf
 conf/profile.lsf
 conf/hosts
 conf/lsf.conf
 conf/lsf.cluster.myCluster
 conf/lsf.shared
 conf/lsf.task
 conf/lsbatch/myCluster/configdir/lsb.users     <-- This is exposed as a configmap
 conf/lsbatch/myCluster/configdir/lsb.nqsmaps
 conf/lsbatch/myCluster/configdir/lsb.reasons
 conf/lsbatch/myCluster/configdir/lsb.hosts
 conf/lsbatch/myCluster/configdir/lsb.serviceclasses
 conf/lsbatch/myCluster/configdir/lsb.resources
 conf/lsbatch/myCluster/configdir/lsb.modules
 conf/lsbatch/myCluster/configdir/lsb.threshold
 conf/lsbatch/myCluster/configdir/lsb.applications
 conf/lsbatch/myCluster/configdir/lsb.globalpolicies
 conf/lsbatch/myCluster/configdir/lsb.params
 conf/lsbatch/myCluster/configdir/lsb.queues    <-- This is exposed as a configmap
```

**NOTE:  Do not directly edit the configmap files, otherwise you will loose your changes.**

Find the file you want to change and modify it.

After changing the configuration files(s) it is necessary to trigger the scheduler to re-read the configuration.  This will not affect running or pending workload.  From within the management pod do the following:

1. Run the command to reconfigure the base
```
LSF POD [root@lsfmaster /]# lsadmin reconfig

Checking configuration files ...

No errors found.

Restart only the master candidate hosts? [y/n] y
Restart LIM on <lsfmaster> ...... done

```
To reconfigure the base on all nodes use:
```
LSF POD [root@lsfmaster /]# lsadmin reconfig all
```

2. Run the command to re-read the schduler configuration.
```
LSF POD [root@lsfmaster /]# badmin mbdrestart

Checking configuration files ...

There are warning errors.

Do you want to see detailed messages? [y/n] y
Apr 22 13:14:49 2019 22437 4 10.1 orderQueueGroups(): File /opt/ibm/lsfsuite/lsf/conf/lsbatch/myCluster/configdir/lsb.queues: Priority value <20> of queue <night> falls in the range of priorities defined for the queues that use the same cross-queue fairshare/absolute priority scheduling policy. The priority value of queue <night> has been set to 1
---------------------------------------------------------
No fatal errors found.
Warning: Some configuration parameters may be incorrect.
         They are either ignored or replaced by default values.

Do you want to restart MBD? [y/n]
```

Here we see there is an error.  The initial configuration will not have errors, but it is instructive to see what they might look like.

3. If errors are seen, correct them, and retry the command to check that
the errors have been corrected.


### Changing the ConfigMap Files
Two configuration files are exposed as configMaps.  They are:
* **lsb.users** - This contains the users and user groups for configuring fairshare
* **lsb.queues** - This contains the queue definitions

They can be edited in the GUI, or using the following commands:
```bash
$ kubectl get configmap
```
This will list all the config maps.  Look for ones containing the string `ibm-spectrum-computing-prod`.
```bash
$ kubectl edit configmap lsf-ibm-spectrum-computing-prod-queues
```
** NOTE: You will see additional metadata associated with the configmap.  Do not change this. **  

Changes to the configMaps will be automatically applied to the cluster.  Errors in the
configMaps will cause the scheduler to revert to a default configuration.  To check
for errors use the proceedure in the above section to test for errors, but remember that
changes to the **lsb.users** and **lsb.queues** have to be done by editing the configmap.


### Adding Users and Groups
The scheduling policies can be applied to existing users and groups, however the scheduler pod has no knowledge of them.
For these policies to function it is necessary to provide the usernames, UIDs, and GIDs typically 
found in /etc/passwd and /etc/group files.  

The **add-users-groups.sh** sample script is provided to import both users and groups (e.g. LDAP/NIS, etc).  
This must be run from the physical hosts operating system that also has access to the persistent volume.  For example,
```bash
$ cd {Location of PV mount}
$ cd lsf/conf
$ add-users-groups.sh
```
This script will call **getent** to gather all the users and group information and will generate 
two files:
* passwd.append
* group.append

The manager container upon detecting these files will import the passwd and group information.  Once this
is done, the fairshare policies for users can be configured.


## Copyright and trademark information
© Copyright IBM Corporation 2019
U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
IBM®, the IBM logo and ibm.com® are trademarks of International Business Machines Corp., registered in many jurisdictions worldwide. Other product and service names might be trademarks of IBM or other companies. A current list of IBM trademarks is available on the Web at "Copyright and trademark information" at [www.ibm.com/legal/copytrade.shtml](https://www.ibm.com/legal/copytrade.shtml).

