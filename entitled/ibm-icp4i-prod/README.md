# IBM Cloud Pak for Integration Navigator

## Introduction
Every enterprise in today's markets must offer robust digital products and services, often
requiring integration of complex capabilities and systems to deliver one coherent whole. IBM Cloud
Pak for Integration offers a simplified solution to this integration challenge, allowing the
enterprise to modernize its processes while positioning itself for future innovation. Once
installed, IBM Cloud Pak for Integration eases monitoring, maintenance and upgrades, helping the
enterprise stay ahead of the innovation curve.

IBM Cloud Pak for Integration (ICP4I) brings together proven, best-in-class capabilities to deliver a
streamlined forward-looking modern integration solution, available as a single high value purchase
at lower cost. This new product unifies disparate tools into one solution that integrates both
modern and traditional products. IBM Cloud Pak for Integration simplifies purchasing, deployment,
management and maintenance. The following components are integrated in IBM Cloud Pak for Integration:
* ICP4I Navigator, a simple integrated user interface spanning components
* Cloud Private, providing a Kubernetes-based foundation
* API Connect, implementing managed APIs
* App Connect Enterprise, providing integration workflows
* MQ, for robust guaranteed transport
* EventStreams, for event handling based on Kafka
* Aspera client, for large file transfers
* Datapower, for a purpose-built security and integration gateway

The initial installation procedure establishes a base Cloud framework.  Once you have logged in
to the base framework, the ICP4I Navigator then allows seamless access to any other components
you have running, without requiring any further logins.  You can then create instances of the other
components you need to implemented solutions.

## Chart Details
This is a Helm chart for the IBM Cloud Pak for Integration Navigator. It provides a UI to allow users to deploy new instances of the ICP4I components, and allows navigation between them in a simple, consistent manner.

## Prerequisites
* Red Hat OpenShift version 3.11.
* IBM Cloud Private fix pack 3.2.0.1907.
* A user with cluster administrator role is required to install the chart.

### Red Hat OpenShift SecurityContextConstraints Requirements	
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.	

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      annotations:
        kubernetes.io/description: "This policy grants access to all privileged 
          host features and allows a pod to run with any 
          UID and GID and any volume.
          WARNING:  This policy is the least restrictive and 
          should only be used for cluster administration.
          Use with caution."
        cloudpak.ibm.com/version: "1.1.0"
      name: ibm-icp4i-prod-scc
    allowHostDirVolumePlugin: true
    allowHostIPC: true
    allowHostNetwork: true
    allowHostPID: true
    allowHostPorts: true
    allowPrivilegedContainer: true
    allowPrivilegeEscalation: true
    allowedCapabilities: 
    - '*'
    allowedFlexVolumes: []
    allowedUnsafeSysctls: 
    - '*'
    defaultAddCapabilities: []
    defaultAllowPrivilegeEscalation: true
    forbiddenSysctls: []
    fsGroup:
      type: RunAsAny
    readOnlyRootFilesystem: false
    requiredDropCapabilities: []
    runAsUser:
      type: RunAsAny
    seccompProfiles:
    - '*'
    seLinuxContext:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    volumes:
    - '*'
    priority: 0
    ```

- From the command line, you can run the setup scripts included under `pak_extensions`. As a cluster admin the pre-install instructions are located at:
  - `pre-install/clusterAdministration/createSecurityPrereqs.sh`

## Resources Required
This chart has the following resource requirements by default:

| Resource | CPU | Memory |
| --- | --- | --- |
| Jobs | `0.25` | `265Mi` |
| Navigator | `0.25` | `265Mi` |
| Services | `0.25` | `265Mi` |

## Installing the Chart

**Only one dashboard can be installed per namespace.**

**Important:** If you are using a private Docker registry (including an ICP Docker registry), an [image pull secret](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/manage_images/imagepullsecret.html) needs to be created before installing the chart. Supply the name of the secret as the value for `image.pullSecret`.

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release stable/ibm-icp4i-prod
```

The command deploys `ibm-icp4i-prod` on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Setting vm.max_map_count on nodes

Some capabilities within the Cloud Pak for Integration require the `vm.max_map_count` sysctl setting on worker
nodes to be at least 1048576. This can be done manually using the command:

```
sudo sysctl -w vm.max_map_count=1048576
sudo su -c 'echo "vm.max_map_count = 1048576" >> /etc/sysctl.conf'
```

This chart includes a mechanism to automatically set the `vm.max_map_count` sysctl setting on all worker nodes
that is enabled by default. This uses a kubernetes daemonset running privileged containers to alter the setting
on each node, it requires cluster admin permissions to install and will apply the `ibm-privileged-scc` SCC to
the daemonset. It will only increase the `vm.max_map_count` sysctl setting to 1048576; it will never decrease
the setting.

To disable this mechanism use the `sysctlDaemon` value. You must then change the setting manually.

### Custom TLS certificates

To provide a custom TLS certificate, create a secret of the TLS type in the target namespace and specify
that secret name in the `tls.secret` configuration value.

Use kubectl to create the secret:

```
kubectl create secret tls <name> --key <key_file> --cert <cert_file>
```

To use a self-signed certificate, select the `tls.generate` configuration value. If the `tls.generate` value is
`true`, the named secret will be overwritten if it already exists.

If you do not enable generation or specify a secret, ICP4I will not start until the secret is created.

For more information, see https://kubernetes.github.io/ingress-nginx/user-guide/tls/

### Verifying the Chart

See the instructions after the helm installation completes for chart verification. The instructions can also be viewed by running the command: `helm status my-release --tls`.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the navigator chart and their default values.

| Parameter                              | Description                                     | Default                      |
| ---------------------------------------| ------------------------------------------------| -----------------------------|
| `replicaCount`                         | Number of deployment replicas                   | `3`                          |
| `image.navigator`                      | ICP4I Navigator docker image                    | `icip-navigator`             |
| `image.configurator`                   | ICP4I Configurator docker image                 | `icip-configurator`          |
| `image.services`                       | ICP4I Services docker image                     | `icip-services`              |
| `image.pullPolicy`                     | Image pull policy                               | `IfNotPresent`               |
| `image.pullSecret`                     | Image pull secret                               | `nil`                        |
| `image.tag`                            | ICP4I image tag                                 | `2.1.1`                      |
| `sysctlDaemon`                         | Update vm.max_map_count on worker nodes         | `true`                       |
| `resources.jobs.requests.cpu`          | Jobs CPU resource requests                      | `0.25`                       |
| `resources.jobs.requests.memory`       | Jobs memory resource requests                   | `256Mi`                      |
| `resources.jobs.limits.cpu`            | Jobs CPU resource limits                        | `1`                          |
| `resources.jobs.limits.memory`         | Jobs memory resource limits                     | `512Mi`                      |
| `resources.navigator.requests.cpu`     | Navigator CPU resource requests                 | `0.25`                       |
| `resources.navigator.requests.memory`  | Navigator memory resource requests              | `256Mi`                      |
| `resources.navigator.limits.cpu`       | Navigator CPU resource limits                   | `1`                          |
| `resources.navigator.limits.memory`    | Navigator memory resource limits                | `512Mi`                      |
| `resources.services.requests.cpu`      | Services CPU resource requests                  | `0.25`                       |
| `resources.services.requests.memory`   | Services memory resource requests               | `256Mi`                      |
| `resources.services.limits.cpu`        | Services CPU resource limits                    | `1`                          |
| `resources.services.limits.memory`     | Services memory resource limits                 | `512Mi`                      |
| `tls.generate`                         | Whether to generate SSL certificates            | `true`                       |
| `tls.hostname`                         | Hostname of the ingress proxy to be configured  | `mycluster.icp`              |
| `tls.secret`                           | TLS secret name                                 | `icip-navigator-tls-secret`  |
| `tls.ingresspath`                      | Path used by the ingress for the service        | `integration`                |
| `arch`                                 | Architecture scheduling preference              | `amd64`                      |
| `productionDeployment`                 | Will this release be used in production         | `true`                       |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Storage
No storage is required for the ICP4I Navigator.

## Limitations
* Chart can only run on amd64 architecture type.

## Documentation
[IBM Cloud Pak for Integration Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSGT7J/welcome.html)

_Copyright IBM Corporation 2019. All Rights Reserved._
