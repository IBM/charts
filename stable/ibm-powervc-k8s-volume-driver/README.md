# IBM PowerVC FlexVolume Driver
&nbsp;

![IDG Logo](https://raw.githubusercontent.com/IBM/charts/master/logo/powervc-logo-01.png)
![IDG Logo](https://raw.githubusercontent.com/IBM/charts/master/logo/powervc-logo-02.png)

[IBM® PowerVC](https://www.ibm.com/systems/power/software/virtualization-management/) Virtualization Center is an advanced virtualization and cloud management offering, built on OpenStack, that provides simplified virtualization management and cloud deployments for IBM AIX®, IBM i and Linux virtual machines (VMs) running on IBM Power Systems.

PowerVC can be used as the cloud provider that is hosting the virtual machines for the IBM Cloud Private master and worker nodes. This volume driver can also be used to provision storage volumes and mount storage for containers.

## Introduction

This chart installs the volume driver that communicates with PowerVC to provision persistent volumes in Kubernetes and attach those volumes to worker nodes for mounting containers.

Once the chart is installed, you may use any storage class that uses the *__ibm/powervc-k8s-volume-provisioner__* provisioner in the persistent volume claim to provision and attach volumes.  The pre-defined storage class, *__ibm-powervc-k8s-volume-default__*, is created as part of this chart installation. It is set as the default storage class unless you specify otherwise. The default storage class is used in persistent volume claims if no storage class is specified.

You can specify the *__type__* parameter in the storage class to specify which volume type (called the 'storage template' in PowerVC) to use when provisioning volumes. This volume type allows you to choose which storage backend and pool to use, along with other volume options. When installing the chart, you can specify the volume type to use in the pre-defined storage class. If the volume type is not specified at either point, no volume type is used.

## Chart Details

This chart will create the following Kubernetes resources:

  - __ibm-powervc-k8s-volume-provisioner__ - [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) deploys a container that runs the external storage provisioner on the master node
  - __ibm-powervc-k8s-volume-flex__ - [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) responsible for configuring the FlexVolume driver on each of the master and worker nodes
  - __ibm-powervc-config__ - [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) containing the PowerVC configuration information specified on the Helm chart installation
  - __ibm-powervc-k8s-volume-default__ - [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) defining the pre-defined default storage class to be used in persistent volume claims

## Prerequisites

- IBM Cloud Private 2.1.0.2 or later (or Kubernetes 1.9.1 or later)
- PowerVC 1.4.1 or later (PowerVC 1.4.0 may be used if using Fibre Channel attached storage)
- Before installing the chart you must create a [secret](https://kubernetes.io/docs/concepts/configuration/secret/) object that contains a PowerVC administrator username and password. This can be done in two ways:
    1. Create a Secret object through the **IBM Cloud Private management console**:
        1. Click Secrets in the left navigation pane.
        2. Click Create Secret.
        3. On the General tab: 
            - Enter the secret name. It is recommended to follow a naming convention as **ibm-powervc-&lt;my-secret&gt;**. Ex. ibm-powervc-credentials
            - Choose the namespace where the chart is to be installed.
            - Select **Opaque** for Type.
        4. On the Data tab:
            - Add these two secret keys, **OS_USERNAME** and **OS_PASSWORD**. Create these names exactly as shown.
            - Use your favorite base64 encoding tool to encode the secret data and paste it into the value. Ensure that there are no newlines in the value being encoded. For example, if you use the Linux base64 command, you must use the “echo -n” option to avoid having newlines added.
        5. Click Create.
        6. Use this secret name during the configuration step of the chart installation.

    2. Create a Secret object through the **kubectl CLI**:
        1. Create a secret.yaml file as shown in the example below, with the PowerVC administrator username and password. Use your favorite base64 encoding tool to encode the secret data fields. Ensure that there are no newlines in the value being encoded. For example, if you use the Linux base64 command, you must use the “echo -n” option to avoid having newlines added.
           ```yaml
           kind: Secret
           name: ibm-powervc-credentials
           type: Opaque
           data:
               OS_USERNAME: cm9vdA==
               OS_PASSWORD: cGFzc3cwcmQxMjM=
           ```
        2. Use the Kubernetes kubectl CLI tool to add the secrets defined in the secret.yaml file to the namespace where the chart is to be installed. Example: ```kubectl apply -f secrets.yaml -n <namespace>```
        3. Delete or shred the secret.yaml file once it has been added.
        4. Use this secret name during the configuration step of the chart installation.

- Flex volume directory mounted in the controller manager container

The controller manager container on the master node needs to have access to the flex volume driver directory to pick up the PowerVC FlexVolume driver.  Prior to the IBM Cloud Private 2.1.0.3 release, the flex volume directory was not mounted by default.  Verify that the following lines are in the *__/etc/cfc/pods/master.json__* file and if not, add these lines to the file.
```console
    "containers":[
       ...
        "name": "controller-manager",
        ...
        "volumeMounts": [
          ...
          {
            "name": "flexvolume-dir",
            "mountPath": "/usr/libexec/kubernetes/kubelet-plugins/volume/exec"
          }
          ...
    "volumes": [
      ...
      {
        "name": "flexvolume-dir",
        "hostPath": {
          "path": "/usr/libexec/kubernetes/kubelet-plugins/volume/exec",
          "type": "DirectoryOrCreate"
        }
      }
```
## PodSecurityPolicy Requirements

This chart requires a [PodSecurityPolicy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [**ibm-anyuid-hostpath-psp**](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```console
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: <ibm-powervc-psp>
spec:
  privileged: false
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  hostPID: false
  hostIPC: false
  hostNetwork: false
  requiredDropCapabilities:
  - ALL
  allowedCapabilities: []
  defaultAddCapabilities: []
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - flexVolume
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

## Resources Required

There are no artificially set minimum or maximum required resources defined for any resource in this Helm chart.  The resource usage will vary based on how many concurrent volumes are being provisioned and attached, but during steady state there should be minimal CPU usage and less than 50 MB used by the volume provisioner.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release -f <powervc-config.yaml> ibm-powervc-k8s-volume-driver
```
Where `<powervc-config.yaml>` is a yaml file that contains the required parameters described below.

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters for the PowerVC management server and their default values.  Unless you have changed these values, they can be found in /opt/ibm/powervc/powervcrc on the PowerVC mamagement system.

| Parameter               | Description                                             | Default                          |
|-------------------------|---------------------------------------------------------|----------------------------------|
| `openstack.ipOrHostname`| IP address or host name of the PowerVC management server.| N/A (required)                  |
| `openstack.credSecretName`| Name of the pre-created Secret object that contains the PowerVC admin username and password. | N/A (required) |
| `openstack.certData`    | The contents of the PowerVC certificate in PEM format   | (optional - insecure if not set) |
| `openstack.projectName` | The PowerVC project; the specified user must be an admin| ibm-default                      |
| `openstack.domainName`  | The domain for the PowerVC admin user                   | Default                          |
| `driver.flexPluginDir`  | Directory specified by --flex-volume-plugin-dir         | .../kubelet-plugins/volume/exec/ |
| `driver.volumeType`     | Volume type to use in the default storage class         | (optional)                       |
| `driver.dfltStgClass`   | Whether to make this driver the default storage class   | true                             |
| `image.provisionerRepo` | Name and location of the provisioner docker repository  | ibmcom/power-openstack-k8s-volume-provisioner|
| `image.provisionerTag`  | Tag or label for the provisioner docker image           | 1.0.0                            |
| `image.flexVolumeRepo`  | Name and location of the flexvolume docker repository   | ibmcom/power-openstack-k8s-volume-flex|
| `image.flexVolumeTag`   | Tag or label for the flexvolume docker image            | 1.0.0                            |
| `image.provisionerPull` | Pull policy for the provisioner docker image            | IfNotPresent                     |
| `image.flexVolumePull`  | Pull policy for the flexvolume docker image             | IfNotPresent                     |

## Limitations

- This Helm chart will only install on ppc64le worker nodes and ppc64le and x86_64 master nodes.
- A node can have only one installation of this Helm chart. Any subsequent install attempts will fail.
- This Helm chart creates a storage class. Therefore, to install this Helm chart, the user needs authorization to create storage classes.
- The persistent volumes cannot be resized by using powervc-k8s-volume-provisioner.  Volumes must be resized manually through PowerVC to be expanded.
- This Helm chart does not support worker nodes that were deployed through PowerVC using a DHCP network. The IP address listed in PowerVC for the worker node VM must match the IP address used in Kubernetes for the worker node.
