## Introduction
IBM Rational Test Automation Server brings together test data, test environments, and test runs and reports into a single, web-based browser for testers and non-testers.
IBM Rational Test Automation Server provides the following capabilities:

### Focal Point
IBM Rational Test Automation Server enables test teams to bring together testing from each of the IBM Rational Test Workbench products under a single view. Test teams working to deliver functional, integration, and performance tests benefit from a holistic view of test progress.
### Role-based access and security
Security is a key concern for our clients and therefore, IBM Rational Test Automation Server brings a comprehensive, role-based access control scheme to the server with project owners assigning specific member's key permissions (by using roles), for example managing test data or working with secrets such as passwords.
### Running of tests from the server by using containers
Server-based running of tests is the starting point for IBM Rational Test Automation Server. For members of a project with the appropriate role, IBM Rational Test Automation Server enables direct running of tests from the browser by using containers.
### Connected agents for existing performance agents
Agent owners can connect existing performance agents to the server and add them to a project for running schedules and Accelerated Functional Testing (AFT) Suites on the current infrastructure.
### Project overview statistics
The Overview page for IBM Rational Test Automation Server offers you a quick, simple view on the state of testing for your projects.
### Reporting and the Resource Monitoring Service
IBM Rational Test Automation Server provides the home for capabilities that previously were hosted on Rational Test Control Panel. Reporting and the Resource Monitoring Service are in IBM Rational Test Automation Server and provide a more direct relationship with their related projects. These capabilities also benefit from the project level, role-based access controls.

## Chart Details
* This chart deploys a single instance of IBM Rational Test Automation Server

## Prerequisites

Kubernetes cluster:


* [RedHat OpenShift Container Platform](https://docs.openshift.com/container-platform/4.2/release_notes/ocp-4-2-release-notes.html) v4.2 or later [Kubernetes v1.14]
* [Dynamic Volume Provisioning](https://docs.openshift.com/container-platform/4.2/storage/dynamic-provisioning.html) or manually created Persistent Volumes of an appropriate size already available.
* [Jaeger Operator](https://docs.openshift.com/container-platform/4.2/service_mesh/service_mesh_install/installing-ossm.html#ossm-operator-install-jaeger_installing-ossm) (Recommended) If tests should contribute trace information and Jaeger based reports are required.
* [RedHat Service Mesh](https://docs.openshift.com/container-platform/4.2/service_mesh/servicemesh-release-notes.html) v1.1 or later (Optional) If additional service virtualization features are required.

Installed locally:
* [oc cli](https://docs.openshift.com/container-platform/4.2/cli_reference/openshift_cli/getting-started-cli.html)
* [helm cli](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html/cli_tools/helm-cli) v3.1.3 or later.

To install the product you need to be able to login to the OpenShift cluster with sufficient privileges:
```console
oc login -u kubeadmin -p {password} https://api.{openshift-cluster-dns-name}:6443
```
## Red Hat OpenShift SecurityContextConstraints Requirements
The product is compatible with the [`restricted`](https://ibm.biz/cpkspec-scc) SecurityContextConstraint


## Resources Required
The product requires, in addition to resources required by the cluster, a minimum of:
16GiB memory, 8 cpu, 128GiB of persistent storage

Depending on workload considerably more resources could be required.

### Storage

The default storage class will be used. The storage class must support ReadWriteMany (RWX) so that executions can be performed on all nodes.



The default configuration creates claims that dynamically provision the below persistent volumes.

| Claim                                 | Size     | Access Mode | Content |
| ------------------------------------- |:--------:|:-----------:| ------- |
| data-{my-rtas}-datasets-postgresql-0  | 2Gi      | RWO         | Edits to Datasets |
| data-{my-rtas}-execution-postgresql-0 | 2Gi      | RWO         | Infrastructure details |
| data-{my-rtas}-gateway-postgresql-0   | 2Gi      | RWO         | Project details |
| data-{my-rtas}-kafka-0                | 8Gi      | RWO         | Notifications between services |
| data-{my-rtas}-kafka-zookeeper-0      | 8Gi      | RWO         | Zookeeper state |
| data-{my-rtas}-keycloak-postgresql-0  | 2Gi      | RWO         | Users and resource ownership |
| data-{my-rtas}-results-0              | 8Gi      | RWO         | Reports |
| data-{my-rtas}-results-postgresql-0   | 2Gi      | RWO         | Execution result metadata |
| data-{my-rtas}-rm-postgresql-0        | 2Gi      | RWO         | Source details |
| data-{my-rtas}-tam-0                  | 32Gi     | RWO         | Cloned git repositories |
| data-{my-rtas}-tam-postgresql-0       | 8Gi      | RWO         | Test asset metadata |
| data-{my-rtas}-userlibs-0             | 1Gi      | RWX         | User provided third party libraries |

The pod [`securityContext.fsGroup`](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) can be set for each of these volumes using Helm parameters if your volume provisioner requires it.



Ensure that volumes containing user data can grow when required. Confirm that the storageclass used to install the product (typically the cluster default) has `allowVolumeExpansion: true`

Find the default storageclass name
```console
oc get storageclass
```
Check this storageclass allows expansion
```console
oc get storageclass {name} -oyaml | grep ^allowVolumeExpansion
```
There may be additional configuration required based on the Kubernetes version and storage provider. Therefore the storage provider documentation must be checked for other necessary prerequisites.

## Installing the Chart

The product requires its own namespace. Create a namespace to install the product into.
```console
oc new-project test-system
```
Add the Entitlement Registry to Helm



```console
helm repo add entitled https://raw.githubusercontent.com/IBM/charts/master/repo/entitled
```
To pull images used by the product, you require an API key. This can be obtained from: https://cloud.ibm.com
```console
oc create secret docker-registry cp.icr.io \
  -n test-system \
  --docker-server=cp.icr.io \
  --docker-username=iamapikey \
  --docker-password={api-key} \
  --docker-email=not-required@test
```

If you are migrating data from a previous release refer to the [additional steps](#migration).

Helm may then be used to install the product. Note: substitute `{my-rtas}` for a Helm [release name](https://helm.sh/docs/intro/using_helm/#three-big-concepts).


Less recently patched versions of OpenShift can give errors, for example: `ValidationError(Route.spec.to): missing required field "weight"` These errors are caused by OpenShift performing [invalid](https://bugzilla.redhat.com/show_bug.cgi?id=1773682) checks. If you can not patch OpenShift, these checks can be disabled appending `--disable-openapi-validation` to the helm command.

```console
helm repo update
helm pull --untar entitled/ibm-rtas-prod
# update the runAsUser and fsGroup to match scc policy
sed -i -e "s/runAsUser: 1001/runAsUser: $(oc get project test-system -oyaml \
  | sed -r -n 's# *openshift.io/sa.scc.uid-range: *([0-9]*)/.*#\1#p')/g;
           s/fsGroup: 1001/fsGroup: $(oc get project test-system -oyaml \
  | sed -r -n 's# *openshift.io/sa.scc.supplemental-groups: *([0-9]*)/.*#\1#p')/g" ibm-rtas-prod/values-openshift.yaml

helm install {my-rtas} ./ibm-rtas-prod -n test-system \
  --set license=accept \
  -f ibm-rtas-prod/values-openshift.yaml \
  --set global.ibmRtasIngressDomain=rtas.apps.{openshift-cluster-dns-name} \
  --set global.rationalLicenseKeyServer=@{rlks-ip-address} \
  --set global.ibmRtasPasswordAutoGenSeed={my-super-secret} \
  --set global.ibmRtasRegistryPullSecret=cp.icr.io \
  --set keycloak.keycloak.image.pullSecrets[0]=cp.icr.io

rm -fr ibm-rtas-prod
```
* The RLKS value is required if you intend to run high load performance tests.

* The password seed is used to create all other default passwords and should be stored securely since it's required again should it be necessary to restore from a backup.

## Migration
When migrating from versions prior to v10.1, before running _helm install_ it is necessary to restore data from a backup file taken from the earlier version.


```console
curl -Lo import-prek8s-backup.yaml \
  https://raw.githubusercontent.com/IBM/charts/master/entitled/ibm-rtas-prod/files/import-prek8s-backup.yaml

sed -i 's/{{ \.Release\.Name }}/{my-rtas}/g' ibm-rtas-prod/files/import-prek8s-backup.yaml

# update the runAsUser to match scc policy
sed -i -e "s/1001/$(oc get project test-system -oyaml \
  | sed -r -n 's# *openshift.io/sa.scc.uid-range: *([0-9]*)/.*#\1#p')/g" import-prek8s-backup.yaml

oc apply -f import-prek8s-backup.yaml -n test-system
```
Then follow the instructions found in the log:
```console
oc logs import-prek8s-backup -n test-system
```

## Security Considerations
### Dynamic workload

To scale test asset execution the product creates kubernetes resources dynamically. To review the permissions required to do this consult the execution [role](charts/execution/templates/role.yaml) with its [binding](charts/execution/templates/rolebinding.yaml).

When the resources are created a label is applied to them so they may be tracked:
```console
oc get all,cm,secret -lexecution-marker -n test-system
```
These resources are deleted 24 hours after the execution completes.

### Namespace isolation

The default configuration does not enable service virtualization via Istio. To use this feature it must be configured appropriately and installed by a `cluster-admin`.
#### Multi-tenant clusters
If the cluster IS shared and the product may only virtualize services running in specific namespaces then add this parameter to the Helm install:
```console
  --set execution.istio.enabled=true \
```
Then enable service virtualization in specific namespaces using this command:
```console
oc create rolebinding istio-virtualization-enabled -n {namespace} --clusterrole={my-rtas}-execution-istio-test-system --serviceaccount=test-system:{my-rtas}-execution
```
Note: Uninstalling the chart will not clean up these manually created role bindings.
#### Single-tenant clusters
If the cluster IS NOT shared and the product MAY virtualize any service running in the whole cluster then add these parameters to the Helm install:
```console
  --set execution.istio.enabled=true \
  --set execution.istio.clusterRoleBinding.create=true \
```
## Configuration


The defaults shown are not appropriate on OpenShift clusters. The `values-openshift.yaml` file must be used to make the product compatible.


| Parameter                                        | Description | Default |
|--------------------------------------------------|-------------|---------|
| `global.ibmRtasIngressDomain`                 | The web address to expose the product on. For example `192.168.0.100.nip.io` | REQUIRED |
| `global.ibmRtasPasswordAutoGenSeed`           | The seed used to generate all other passwords | REQUIRED |
| `global.ibmRtasRegistryPullSecret`            | The name of the secret used to pull images from the Entitlement Registry | REQUIRED |
| `global.jaegerAgent.enabled`                     | Controls whether execution engines may choose to write traces to Jaeger | true |
| `global.jaegerAgent.internalHostName`            | The name of the service that execution engines write traces to | jaeger-agent.istio-system |
| `global.jaegerDashboard.enabled`                 | Controls whether results contain a link to Jaeger traces | true |
| `global.jaegerDashboard.externalURL`             | The base URL for where traces may be opened in a browser | https://tracing.{{ .Values.global.ibmRtasIngressDomain }}/jaeger |
| `global.prometheusDashboard.enabled`             | Controls whether resource monitoring can query the internal prometheus instance | true |
| `global.prometheusDashboard.internalURL`         | The URL for where the internal prometheus instance can be found | http://prometheus.istio-system:9090 |
| `global.rationalLicenseKeyServer`                | Where floating licenses may be fetched to run high load performance tests. For example `@ip-address` | '' |
| `license`                                        | Confirmation that the EULA has been accepted. For example `accept` | not_accepted |
| `postgresql.`..                                  | Gateway storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `resources.limits.memory`                        | Gateway MAX memory usage | 1Gi |
| `resources.requests.cpu`                         | Gateway requested cpu usage | 150m |
| `resources.requests.memory`                      | Gateway requested memory usage | 400Mi |
| `datasets.postgresql.`..                         | Datasets storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `datasets.resources.limits.memory`               | Datasets MAX memory usage | 1Gi |
| `datasets.resources.requests.cpu`                | Datasets requested cpu usage | 150m |
| `datasets.resources.requests.memory`             | Datasets requested memory usage | 400Mi |
| `execution.istio.enabled`                        | Enable service virtualization via Istio | false |
| `execution.istio.clusterRole.create`             | If Istio is enabled, create [role](charts/execution/templates/clusterrole-istio.yaml) to virtualize services via Istio | true |
| `execution.istio.clusterRoleBinding.create`      | If Istio is enabled, create [binding](charts/execution/templates/clusterrolebinding-istio.yaml) to virtualize services to all namespaces | false |
| `execution.intercepts.clusterRole.create`        | Create [role](charts/execution/templates/clusterrole-intercepts.yaml) to enable NodePort address resolution when exposing virtual services | true |
| `execution.intercepts.clusterRoleBinding.create` | Create [binding](charts/execution/templates/clusterrolebinding-intercepts.yaml) to enable NodePort address resolution when exposing virtual services | true |
| `execution.postgresql.`..                        | Execution service storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `execution.resources.limits.memory`              | Execution service MAX memory usage | 1Gi |
| `execution.resources.requests.cpu`               | Execution service requested cpu usage | 150m |
| `execution.resources.requests.memory`            | Execution service requested memory usage | 400Mi |
| `execution.role.create`                          | Create a default role used to run test assets | true |
| `execution.roleBinding.create`                   | Bind the default role used to run test assets to the execution service account | true |
| `execution.userlibs.persistence.accessModes[0]`  | Mode required to enable all the execution containers to access third party libraries, needs to be `ReadWriteMany` if you are using a multi-node cluster | ReadWriteOnce |
| `execution.userlibs.persistence.size`            | Space for third party libraries used to run test assets | 5Gi |
| `execution.userlibs.resources.limits.memory`     | Userlibs MAX memory usage | 64Mi |
| `execution.userlibs.resources.requests.cpu`      | Userlibs requested cpu usage | 0m |
| `execution.userlibs.resources.requests.memory`   | Userlibs requested memory usage | 32Mi |
| `frontend.resources.limits.memory`               | Frontend MAX memory usage | 256Mi |
| `frontend.resources.requests.cpu`                | Frontend requested cpu usage | 50m |
| `frontend.resources.requests.memory`             | Frontend requested memory usage | 100Mi |
| `kafka.`..                                       | Kafka configuration. See [chart](https://github.com/bitnami/charts/tree/master/bitnami/kafka) | |
| `keycloak.`..                                    | Keycloak configuration. See [chart](https://github.com/codecentric/helm-charts/tree/master/charts/keycloak) | |
| `results.persistence.size`                       | Space for reports | 24Gi |
| `results.postgresql.`..                          | Results storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `results.resources.limits.memory`                | Results MAX memory usage | 1Gi |
| `results.resources.requests.cpu`                 | Results requested cpu usage | 150m |
| `results.resources.requests.memory`              | Results requested memory usage | 400Mi |
| `rm.postgresql.`..                               | Resource monitoring storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `rm.resources.limits.memory`                     | Resource monitoring MAX memory usage | 1Gi |
| `rm.resources.requests.cpu`                      | Resource monitoring requested cpu usage | 150m |
| `rm.resources.requests.memory`                   | Resource monitoring requested memory usage | 400Mi |
| `tam.persistence.size`                           | Space for cached git repos | 5Gi |
| `tam.postgresql.`..                              | Test asset storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `tam.resources.limits.memory`                    | Test asset MAX memory usage | 1Gi |
| `tam.resources.requests.cpu`                     | Test asset requested cpu usage | 150m |
| `tam.resources.requests.memory`                  | Test asset requested memory usage | 400Mi |
| ..`.fsGroup`                                     | Where required by the storage provider, the fsGroup value used by pods may be overriden | Per SCC |

## Uninstalling the Chart
Before you remove the product you must first stop the workload that is being run.
```console
oc delete all,cm,secret -lexecution-marker -n test-system
```
Then the product can be removed. Note: substitute `{my-rtas}` for the Helm release name used for installation.
```console
helm uninstall {my-rtas} -n test-system
```
The claims and persistent volumes that were created during install will not automatically be deleted. If you re-install the product these objects will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes
```console
oc delete project test-system
```

## Limitations
* It is not currently possible to edit test assets on the server. This must currently be done in the products that form IBM Rational Test Workbench.
* In each namespace, only one instance of the product can be installed.
* The product replica count configuration enables a maximum of 50 active concurrent users. This configuration can not be changed.
