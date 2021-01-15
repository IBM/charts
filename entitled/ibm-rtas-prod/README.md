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


* [RedHat OpenShift Container Platform](https://docs.openshift.com/container-platform/4.4/release_notes/ocp-4-4-release-notes.html) v4.4 or later (x86_64)
* [OpenShift SDN in _network policy_ mode](https://docs.openshift.com/container-platform/4.4/networking/openshift_sdn/about-openshift-sdn.html) (Optional) The default installation includes NetworkPolicy resources, these will only be acted upon if the SDN is configured appropriately.
* [Dynamic Volume Provisioning](https://docs.openshift.com/container-platform/4.4/storage/dynamic-provisioning.html) supporting accessModes ReadWriteOnce (RWO) and ReadWriteMany (RWX).
* [Jaeger Operator](https://docs.openshift.com/container-platform/4.4/service_mesh/service_mesh_install/installing-ossm.html#ossm-operator-install-jaeger_installing-ossm) (Recommended) If tests should contribute trace information and Jaeger based reports are required.
* [RedHat Service Mesh](https://docs.openshift.com/container-platform/4.4/service_mesh/servicemesh-release-notes.html) v1.1 or later (Optional) If additional service virtualization features are required.

Installed locally:
* [oc cli](https://docs.openshift.com/container-platform/4.4/cli_reference/openshift_cli/getting-started-cli.html)
* [helm cli](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.4/html/cli_tools/helm-cli) v3.3.4 or later.

To install the product you need to be able to login to the OpenShift cluster with sufficient privileges:
```console
oc login -u kubeadmin -p {password} https://api.{openshift-cluster-dns-name}:6443
```
## Red Hat OpenShift SecurityContextConstraints Requirements

The product is compatible with the [`restricted`](https://ibm.biz/cpkspec-scc) SecurityContextConstraint

If you would prefer to use the custom ibm-rtas-restricted SCC, please do the following before installation:

Custom SecurityContextConstraints definition:

  ```bash
  oc create -f - <<EOF
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    name: ibm-rtas-restricted
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegeEscalation: true
  allowPrivilegedContainer: false
  allowedCapabilities: null
  defaultAddCapabilities: null
  fsGroup:
    type: MustRunAs
  groups:
  priority: null
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - KILL
  - MKNOD
  - SETUID
  - SETGID
  runAsUser:
    type: MustRunAsRange
  seLinuxContext:
    type: MustRunAs
  supplementalGroups:
    type: RunAsAny
  users: []
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  EOF
  ```

Configure services to use this SCC.  From the command line, run:

  ```bash
  $ oc adm policy add-scc-to-group ibm-rtas-restricted system:serviceaccounts:test-system
  ```


## Resources Required
The product requires, in addition to resources required by the cluster, a minimum of:
16GiB memory, 8 cpu, 128GiB of persistent storage

Depending on workload considerably more resources could be required.

### Storage
The default storage class should support both the ReadWriteOnce (RWO) and ReadWriteMany (RWX) accessModes.

If the default storage class does not support ReadWriteMany, an alternative class must be specified using the following additional helm value:
```console
  --set global.persistence.rwxStorageClass=ibmc-file-gold
```

The default configuration creates claims that dynamically provision the below persistent volumes.

| Claim                                 | Size     | Access Mode | Content |
| ------------------------------------- |:--------:|:-----------:| ------- |
| data-{my-rtas}-datasets-postgresql-0  | 2Gi      | RWO         | Edits to Datasets |
| data-{my-rtas}-execution-postgresql-0 | 2Gi      | RWO         | Infrastructure details |
| data-{my-rtas}-gateway-postgresql-0   | 2Gi      | RWO         | Project details |
| data-{my-rtas}-rabbitmq-0             | 8Gi      | RWO         | Notifications between services |
| data-{my-rtas}-keycloak-postgresql-0  | 2Gi      | RWO         | Users and resource ownership |
| data-{my-rtas}-results-0              | 8Gi      | RWO         | Reports |
| data-{my-rtas}-results-postgresql-0   | 2Gi      | RWO         | Execution result metadata |
| data-{my-rtas}-rm-postgresql-0        | 2Gi      | RWO         | Source details |
| data-{my-rtas}-tam-0                  | 32Gi     | RWO         | Cloned git repositories |
| data-{my-rtas}-tam-postgresql-0       | 8Gi      | RWO         | Test asset metadata |
| data-{my-rtas}-userlibs-0             | 1Gi      | RWX         | User provided third party libraries and extensions |

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
### Create Namespace
The product requires its own namespace. Create a namespace to install the product into.
```console
oc new-project test-system
```
### Access to binaries
Add the Entitlement Registry to Helm



```console
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm
```
To pull images used by the product, you require an entitlement key. This can be obtained from: https://myibm.ibm.com/products-services/containerlibrary
```console
oc create secret docker-registry cp.icr.io \
  -n test-system \
  --docker-server=cp.icr.io \
  --docker-username=cp \
  --docker-password={entitlement-key} \
  --docker-email=not-required@test
```
### Trust of certificate
Some components of the product solution communicate with the server. This is done using https, verifying that the certificate is signed by a trusted CA. Where default certificates are used, they are typically not signed by a recognized, trusted, CA. To enable this certificate to be trusted we add the signing CA into our trust by placing it in a secret:

* Verify if an additional CA certificate is required. IBM Cloud uses Lets Encrypt meaning it is already trusted
```
curl -sw'%{http_code}' -o/dev/null \
  "https://wildcard.$(oc get -n openshift-ingress-operator ingresscontroller default -ojsonpath='{.status.domain}')"
```
If the result is `503` then no further action is required, however `000` means that a certificate needs adding.

* Get the default CA certificate in PEM format
```
oc get -n openshift-ingress-operator secret router-ca -ojsonpath='{.data.tls\.crt}' | base64 --decode > ca.crt
```
* Validate that this is the CA used to sign the certificate used for ingress
```
curl -sw'%{http_code}' -o/dev/null --cacert ca.crt \
  "https://wildcard.$(oc get -n openshift-ingress-operator ingresscontroller default -ojsonpath='{.status.domain}')"
```

The result should be `503`.



If you see `000` then the certificate configuration has been customized and you need to find the certificate of the signer.

* Add the CA to the secret
```
oc create secret generic -n test-system ingress --from-file=ca.crt=ca.crt
```
### Install the chart
If you are migrating data from a release prior to 10.1, refer to the [additional steps](#migration).

Helm may then be used to install the product. Note: substitute `{my-rtas}` for a Helm [release name](https://helm.sh/docs/intro/using_helm/#three-big-concepts).


Less recently patched versions of OpenShift can give errors, for example: `ValidationError(Route.spec.to): missing required field "weight"` These errors are caused by OpenShift performing [invalid](https://bugzilla.redhat.com/show_bug.cgi?id=1773682) checks. If you can not patch OpenShift, these checks can be disabled appending `--disable-openapi-validation` to the helm command.

```console
helm repo update
helm pull --untar ibm-helm/ibm-rtas-prod --version 3.1012.0

# update the runAsUser and fsGroup to match scc policy
sed -i -e "s/runAsUser: 1001/runAsUser: $(oc get project test-system -oyaml \
  | sed -r -n 's# *openshift.io/sa.scc.uid-range: *([0-9]*)/.*#\1#p')/g;
           s/fsGroup: 1001/fsGroup: $(oc get project test-system -oyaml \
  | sed -r -n 's# *openshift.io/sa.scc.supplemental-groups: *([0-9]*)/.*#\1#p')/g" ibm-rtas-prod/values-openshift.yaml

helm install {my-rtas} ./ibm-rtas-prod -n test-system \
  --set license=true \
  -f ibm-rtas-prod/values-openshift.yaml \
  --set global.ibmRtasIngressDomain=rtas.{openshift-cluster-dns-name} \
  --set global.ibmRtasPasswordAutoGenSeed={my-super-secret} \
  --set global.ibmRtasRegistryPullSecret=cp.icr.io \
  --set global.rationalLicenseKeyServer=@{rlks-ip-address}

rm -fr ibm-rtas-prod
```
* The password seed is used to create default passwords and should be stored securely. It's required again should it be necessary to restore from a backup. Restoring from backup without the original seed is possible when `files/reconcile-secrets.sh` is run following the restore, but all user defined secrets created in the product will be unreadable (unless re-encrypted).

* The _default_ `openshift-cluster-dns-name` referred to above can be found using:
```
oc get --namespace=openshift-ingress-operator ingresscontroller/default -ojsonpath='{.status.domain}'
```

## Migration
When migrating from versions prior to v10.1, before running _helm install_ it is necessary to restore data from a backup file taken from the earlier version.

```console
helm repo update
helm pull --untar ibm-helm/ibm-rtas-prod --version 3.1012.0

sed -i 's/{{ \.Release\.Name }}/{my-rtas}/g' ibm-rtas-prod/files/import-prek8s-backup.yaml

# update the runAsUser to match scc policy
sed -i -e "s/1001/$(oc get project test-system -oyaml \
  | sed -r -n 's# *openshift.io/sa.scc.uid-range: *([0-9]*)/.*#\1#p')/g" ibm-rtas-prod/files/import-prek8s-backup.yaml

oc apply -f ibm-rtas-prod/files/import-prek8s-backup.yaml -n test-system
```
Then follow the instructions found in the log:
```console
oc logs import-prek8s-backup -n test-system
```
Then tidy up the chart in the current directory
```console
rm -fr ibm-rtas-prod
```
## Security Considerations
### Dynamic workload

To scale test asset execution the product creates kubernetes resources dynamically. To review the permissions required to do this consult the execution [role](charts/execution/templates/role.yaml) with its [binding](charts/execution/templates/rolebinding.yaml).

When the resources are created a label is applied so they may be tracked:
```console
oc get all,cm,secret -lexecution-marker -n test-system
```
These resources are deleted 24 hours after the execution completes.

### Trust of additional certificates
The product only trusts certificates signed by recognized CAs. To trust additional CAs, for example your internal corporate CA, you must create a secret containing the additional CAs you wish to trust.

The certificate must be in PEM format and have a `.crt` extension.
```
oc create secret generic -n test-system usercerts --from-file=corp-ca.crt
```
Once created you need to restart pods that mount it for the additional CA to be trusted. Pods that mount this secret can be listed by running:
```
oc get pod -n test-system -o json | jq -r \
  '.items[] | select(.spec.volumes[].secret.secretName == "usercerts") | .metadata.name'
```
They can be forced to restart by deleting them.
```
oc delete pod {my-rtas}-tam-0 -n test-system
```
The log will show the additional CAs if successfully added.
```
oc log {my-rtas}-tam-0 -n test-system -c trust-store
```
Further certificates can be added. Note that getting certificates with openssl without verification makes you vulnerable to man-in-the-middle attacks.
```
openssl s_client -connect cncf.io:443 -servername cncf.io </dev/null \
  | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > cncf.crt

oc patch secret usercerts -n test-system --type=json \
  -p='[{"op":"replace","path":"/data/cncf.crt","value":"'$(base64 -w0 cncf.crt)'"}]'
```
The secret is not included in the normal backup scheme. You should manually backup the secret containing the additional CAs if you consider it valuable.
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
### Namespaces for virtualization
To enable service virtualization via Istio of services that are either:
* Not part of the local service mesh
* Headless services
* Services without backend workloads

A set of Istio enabled namespaces must be provided where messages sent to these services will be intercepted. Where services are not referenced by fully qualified domain name this set is also used to identify services where messages can be intercepted when received. These can be configured during install with this Helm parameter:
```console
  --set execution.istio.namespaces='{namespaceA,namespaceB}' \
```
or alternatively using array index notation
```console
  --set execution.istio.namespaces[0]=namespaceA \
  --set execution.istio.namespaces[1]=namespaceB \
```
## Configuration


The defaults shown are not appropriate on OpenShift clusters. The `values-openshift.yaml` file must be used to make the product compatible.


| Parameter                                        | Description | Default |
|--------------------------------------------------|-------------|---------|
| `global.ibmRtasRegistryPullSecret`                      | The name of the secret used to pull images from the Entitlement Registry | REQUIRED |
| `global.ibmRtasIngressDomain`                 | The web address to expose the product on. For example `192.168.0.100.nip.io` | REQUIRED |
| `global.ibmRtasPasswordAutoGenSeed`           | The seed used to generate secrets | REQUIRED |
| `global.jaegerAgent.enabled`                     | Controls whether execution engines may choose to write traces to Jaeger | false |
| `global.jaegerAgent.internalHostName`            | The name of the service that execution engines write traces to | '' |
| `global.jaegerDashboard.enabled`                 | Controls whether results contain a link to Jaeger traces | false |
| `global.jaegerDashboard.externalURL`             | The base URL for where traces may be opened in a browser | '' |
| `global.persistence.rwxStorageClass`             | For environments that do not provide default StorageClasses that support ReadWriteMany (RWX) accessMode, this value must be set to the name of a suitable StorageClass that has been provisioned to support ReadWriteMany access | |
| `global.prometheusDashboard.enabled`             | Controls whether resource monitoring can query the internal prometheus instance | true |
| `global.prometheusDashboard.internalURL`         | The URL for where the internal prometheus instance can be found | http://{{ .Release.Name }}-prometheus-server |
| `global.prometheusDashboard.podNamespaceLabel`   | The label used to partition metrics by namespace in Prometheus. Check the prometheus-config ConfigMap for `metric_relabel_configs`, use the `target_label`. The value is likely to be `kubernetes_namespace` | namespace |
| `global.rationalLicenseKeyServer`                | Where floating licenses may be fetched to run high load performance tests. For example `@ip-address` | '' |
| `license`                                        | Confirmation that the EULA has been accepted. For example `true` | false |
| `datasets.postgresql.`..                         | Datasets storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `datasets.resources.limits.memory`               | Datasets MAX memory usage | 1Gi |
| `datasets.resources.requests.cpu`                | Datasets requested cpu usage | 150m |
| `datasets.resources.requests.memory`             | Datasets requested memory usage | 400Mi |
| `execution.intercepts.clusterRole.create`        | Create [role](charts/execution/templates/clusterrole-intercepts.yaml) to enable NodePort address resolution when exposing virtual services | true |
| `execution.intercepts.clusterRoleBinding.create` | Create [binding](charts/execution/templates/clusterrolebinding-intercepts.yaml) to enable NodePort address resolution when exposing virtual services | true |
| `execution.istio.clusterRole.create`             | If Istio is enabled, create [role](charts/execution/templates/clusterrole-istio.yaml) to virtualize services via Istio | true |
| `execution.istio.clusterRoleBinding.create`      | If Istio is enabled, create [binding](charts/execution/templates/clusterrolebinding-istio.yaml) to virtualize services to all namespaces | false |
| `execution.istio.enabled`                        | Enable service virtualization via Istio | false |
| `execution.istio.namespaces`                     | The set of namespaces that are considered for service virtualization | |
| `execution.postgresql.`..                        | Execution service storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `execution.resources.limits.memory`              | Execution service MAX memory usage | 1Gi |
| `execution.resources.requests.cpu`               | Execution service requested cpu usage | 150m |
| `execution.resources.requests.memory`            | Execution service requested memory usage | 400Mi |
| `execution.role.create`                          | Create a default role used to run test assets | true |
| `execution.roleBinding.create`                   | Bind the default role used to run test assets to the execution service account | true |
| `existingSecretsStorageKey`                      | Key used the encrypt user defined secrets | from seed |
| `frontend.resources.limits.memory`               | Frontend MAX memory usage | 256Mi |
| `frontend.resources.requests.cpu`                | Frontend requested cpu usage | 50m |
| `frontend.resources.requests.memory`             | Frontend requested memory usage | 100Mi |
| `keycloak.`..                                    | Keycloak configuration. See [chart](https://github.com/codecentric/helm-charts/tree/master/charts/keycloak) | |
| `networkPolicy.enabled`                           | Whether or not to create NetworkPolicy resources | false |
| `networkPolicy.ingress.enabled`                   | Whether or not to create a NetworkPolicy for http ingress | false |
| `networkPolicy.prometheus.enabled`                | Whether or not to create a NetworkPolicy to allow Prometheus metric scraping | false |
| `networkPolicy.prometheus.namespaceLabel`         | Name of label that identifies the namespace in which Prometheus is running | REQUIRED if networkPolicy.prometheus.enabled=true |
| `networkPolicy.prometheus.namespaceValue`         | Value of the label that identifies the namespace in which Prometheus is running | REQUIRED if networkPolicy.prometheus.enabled=true |
| `postgresql.`..                                  | Gateway storage options. See [chart](https://github.com/bitnami/charts/blob/master/bitnami/postgresql) | |
| `rabbitmq.`..                                    | RabbitMQ configuration. See [chart](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq) | |
| `resources.limits.memory`                        | Gateway MAX memory usage | 1Gi |
| `resources.requests.cpu`                         | Gateway requested cpu usage | 150m |
| `resources.requests.memory`                      | Gateway requested memory usage | 400Mi |
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
| `userlibs.persistence.size`                      | Space for third party libraries used to run test assets | 5Gi |
| `userlibs.resources.limits.memory`               | Userlibs MAX memory usage | 64Mi |
| `userlibs.resources.requests.cpu`                | Userlibs requested cpu usage | 0m |
| `userlibs.resources.requests.memory`             | Userlibs requested memory usage | 32Mi |
| ..`.fsGroup`                                     | Where required by the storage provider, the fsGroup value used by pods may be overriden | Per SCC |

## Uninstalling the Chart
Before you remove the product stop the workload that is being run.
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
* `helm rollback` is not currently supported. Move back to a previous release by restoring a backup taken before the upgrade.
* It is not currently possible to edit test assets on the server. This must currently be done in the products that form IBM Rational Test Workbench.
* In each namespace, only one instance of the product can be installed.
* The product replica count configuration enables a maximum of 50 active concurrent users. This configuration can not be changed.
