# Introduction

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




* [RedHat OpenShift Container Platform](https://docs.openshift.com/container-platform/4.6/release_notes/ocp-4-6-release-notes.html) v4.6 or later (x86_64)
* [OpenShift SDN in _network policy_ mode](https://docs.openshift.com/container-platform/4.6/networking/openshift_sdn/about-openshift-sdn.html) (Optional) The default installation includes NetworkPolicy resources, these will only be acted upon if the SDN is configured appropriately.
* [Dynamic Volume Provisioning](https://docs.openshift.com/container-platform/4.6/storage/dynamic-provisioning.html) supporting accessModes ReadWriteOnce (RWO) and ReadWriteMany (RWX).
* [Jaeger Operator](https://docs.openshift.com/container-platform/4.6/service_mesh/v2x/installing-ossm.html#ossm-install-ossm-operator_installing-ossm) (Recommended) If tests should contribute trace information and Jaeger based reports are required.

Installed locally:

* [oc cli](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html)
* [helm cli](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.6/html/cli_tools/helm-cli) v3.6.2 or later.

To install the product you need to access the cluster with cluster administrator privileges.


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
oc adm policy add-scc-to-group ibm-rtas-restricted system:serviceaccounts:test-system
```




## Service Virtualization Usage

For the product to show Service Virtualization usage metrics, User Workload monitoring must be enabled in the cluster.  You should consult the OpenShift documentation for the version of the platform that you are using for details on how to do this.  For example:

### OpenShift 4.6

**Enabling monitoring for user-defined projects** in:
https://docs.openshift.com/container-platform/4.6/monitoring/enabling-monitoring-for-user-defined-projects.html



## Resources Required

The product requires, in addition to resources required by the cluster, a minimum of:
16GiB memory, 8 cpu, 128GiB of persistent storage

Depending on workload considerably more resources could be required.

### Storage

When providing your own cluster if the default storage class does not support the ReadWriteMany (RWX) accessMode, an alternative class must be specified using the following additional helm value:

```console
  --set global.persistence.rwxStorageClass=ibmc-file-gold
```

The following ReadWriteMany storage implementations have been validated:


* [IBM Cloud File Storage](https://cloud.ibm.com/docs/containers?topic=containers-file_storage)




The default configuration creates claims that dynamically provision the below persistent volumes.

| Claim                                 | Size     | Access Mode | Content |
| ------------------------------------- |:--------:|:-----------:| ------- |
| data-{my-rtas}-postgresql-0           | 26Gi     | RWO         | User data used by services |
| data-{my-rtas}-rabbitmq-0             | 8Gi      | RWO         | Notifications between services |
| data-{my-rtas}-results-0              | 8Gi      | RWO         | Reports |
| data-{my-rtas}-tam-0                  | 32Gi     | RWO         | Cloned git repositories |
| data-{my-rtas}-userlibs-0             | 1Gi      | RWX         | User provided third party libraries and extensions |

The pod [`fsGroup`](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) can be set for these volumes using the Helm `securityContext.fsGroup` value if your volume provisioner requires it.


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

The persistent volumes can be expanded by editing the [claim](https://kubernetes.io/blog/2018/07/12/resizing-persistent-volumes-using-kubernetes/)


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

Some components of the product solution communicate with the server. This is done using HTTPS, verifying that 
the certificate is signed by a trusted CA. Where default certificates are used, they are typically not signed 
by a recognized, trusted, CA.


#### Self Trust

To enable the certificate to be trusted we add the signing CA into a secret so that it can be injected into our trust stores.



* Verify if an additional CA certificate is required. IBM Cloud uses Lets Encrypt meaning it is already trusted

```bash
curl -sw'%{http_code}' -o/dev/null \
  "https://wildcard.$(oc get -n openshift-ingress-operator ingresscontroller default -ojsonpath='{.status.domain}')"
```

If the result is `503` then no further action is required, however `000` means that a certificate needs adding.

* Get the default CA certificate in PEM format

```bash
oc get -n openshift-ingress-operator secret router-ca -ojsonpath='{.data.tls\.crt}' | base64 --decode > ca.crt
```

* Validate that this is the CA used to sign the certificate used for ingress

```bash
curl -sw'%{http_code}' -o/dev/null --cacert ca.crt \
  "https://wildcard.$(oc get -n openshift-ingress-operator ingresscontroller default -ojsonpath='{.status.domain}')"
```

The result should be `503`, if you see `000` then the certificate configuration has been customized and you need to find the certificate of the signer to use in the next step.

* Create the ingress secret to store the CA

```bash
oc create secret generic -n test-system ingress --from-file=ca.crt=ca.crt
```



#### Fetching the CA certificate

To fetch the signing CA certificate so that it can be injected into other product trust stores.

```bash
oc get secret ingress -n test-system -o jsonpath={.data.ca\\.crt} | base64 -d
```

### Install with Helm

If you are upgrading from a previous release, refer to the [additional steps](#upgrade).

Helm may then be used to install the product. Note: substitute `{my-rtas}` for a Helm [release name](https://helm.sh/docs/intro/using_helm/#three-big-concepts).


*NOTE* If you are upgrading, you must specify the same value for `global.persistence.rwxStorageClass` as used in the existing installation.  If you do not know what this is, it can be found by running:

```bash
oc get pvc -n test-system data-{my-rtas}-userlibs-0 \
   -ojsonpath='{.spec.storageClassName}' && echo
```

The value should be used in place of the one shown below.


```console
helm repo update
helm pull --untar ibm-helm/ibm-rtas-prod --version 7.1022.0

# update the runAsUser and fsGroup to match scc policy
sed -i -e "s/runAsUser: 1001/runAsUser: $(oc get project test-system -oyaml \
  | sed -r -n 's# *openshift.io/sa.scc.uid-range: *([0-9]*)/.*#\1#p')/g;
           s/fsGroup: 1001/fsGroup: $(oc get project test-system -oyaml \
  | sed -r -n 's# *openshift.io/sa.scc.supplemental-groups: *([0-9]*)/.*#\1#p')/g" ibm-rtas-prod/values-openshift.yaml

helm install {my-rtas} ./ibm-rtas-prod -n test-system \
  --set license=true \
  -f ibm-rtas-prod/values-openshift.yaml \
  --set global.persistence.rwxStorageClass=ibmc-file-gold \
  --set global.ibmRtasIngressDomain=rtas.{openshift-cluster-dns-name} \
  --set global.ibmRtasCertSecretOptional=false \
  --set global.ibmRtasPasswordAutoGenSeed={my-super-secret} \
  --set global.ibmRtasRegistryPullSecret=cp.icr.io \
  --set global.rationalLicenseKeyServer=@{rlks-ip-address}

rm -fr ibm-rtas-prod
```


* `global.ibmRtasCertSecretOptional=false` should be set only when an `ingress` secret to store the CA was created above.



* The rwxStorageClass is cloud provider dependent, the value provided is only an example.


* The password seed is used to create default passwords and should be stored securely. Its required again to restore from a backup.


* The _default_ `openshift-cluster-dns-name` referred to above can be found using:

```bash
oc get --namespace=openshift-ingress-operator ingresscontroller/default -ojsonpath='{.status.domain}'
```

The default certificate which terminates TLS connections, has a single wildcard. This means that only a single hostname segment
can be prefixed. Therefore using the ingress domain my.server.{openshift-cluster-dns-name} would typically be invalid.


Note: During install a job is used to initialize the PostgresQL database. On successful completion it can optionally be removed

```console
oc delete job {my-rtas}-postgresql-init -n test-system
```



### Installing in an airgap environment using a bastion host

General guidance on installing in airgap environments can be found [here](https://www.ibm.com/docs/en/cpfs?topic=operator-installing-foundational-services-offline-airgap). This document provides details of installation via a bastion host, for other setups refer to the general guidance.

This procedure will mirror required container images from the IBM entitled registry into a RedHat Openshift cluster, then install the product helm chart using those images having configured the cluster to use the images from the mirrored location.

Run the following steps on the bastion host. It must be a Linux host. Windows is not supported using this method.

* Install [cloudctl](https://github.com/IBM/cloud-pak-cli)

```bash
wget https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz
tar xf cloudctl-linux-amd64.tar.gz
chmod 755 cloudctl-linux-amd64
mv cloudctl-linux-amd64 /usr/local/bin/cloudctl
cloudctl version
```

* Install `oc`

```bash
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.6/openshift-client-linux.tar.gz
tar xf openshift-client-linux.tar.gz oc
mv oc /usr/local/bin/
oc version
```

* Login to the Openshift cluster that will host the mirrored images with cluster-admin privileges

```bash
oc login ...
```

* Confirm whether the container registry is accessible

```bash
oc get routes -n openshift-image-registry
```

* If `no resources` are found, create a route to provide external access to the registry

```bash
oc patch configs.imageregistry.operator.openshift.io/cluster \
  --patch '{"spec":{"defaultRoute":true}}' --type=merge
```

* A project named `cp` is required to host the mirrored images

```bash
oc new-project cp
```

* Save the case, which contains scripts to mirror the images

```bash
export CASE_NAME=ibm-rtas-case
export CASE_VERSION=7.1022.0
export CASE_ARCHIVE=${CASE_NAME}-${CASE_VERSION}.tgz
export CASE_REMOTE_PATH=https://github.com/IBM/cloud-pak/raw/master/repo/case/${CASE_ARCHIVE}
export OFFLINEDIR=$HOME/offline

cloudctl case save \
  --case $CASE_REMOTE_PATH \
  --outputdir $OFFLINEDIR
```

* Store credentials to authenticate with the IBM entitled registry. Your key can be found in [container library](https://myibm.ibm.com/products-services/containerlibrary)

```bash
export ENTITLEMENT_KEY=YOUR_KEY_HERE
export CASE_INVENTORY_SETUP=ibmRtasProd

cloudctl case launch \
  --case $OFFLINEDIR/$CASE_ARCHIVE \
  --inventory $CASE_INVENTORY_SETUP \
  --action configure-creds-airgap \
  --args "--registry cp.icr.io --user cp --pass $ENTITLEMENT_KEY"
```

* Store credentials to authenticate with the OpenShift container registry

```bash
LOCAL_DOCKER_REGISTRY=$(oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}')
LOCAL_DOCKER_USER=unused
LOCAL_DOCKER_PASSWORD=$(oc whoami -t)

cloudctl case launch \
  --case $OFFLINEDIR/$CASE_ARCHIVE \
  --inventory $CASE_INVENTORY_SETUP \
  --action configure-creds-airgap \
  --args "--registry $LOCAL_DOCKER_REGISTRY --user $LOCAL_DOCKER_USER --pass $LOCAL_DOCKER_PASSWORD"
```

* Mirror the images from the IBM entitled registry to the OpenShift container registry

```bash
cloudctl case launch \
  --case $OFFLINEDIR/$CASE_ARCHIVE \
  --inventory $CASE_INVENTORY_SETUP \
  --action mirror-images \
  --args "--registry $LOCAL_DOCKER_REGISTRY --inputDir $OFFLINEDIR"
```

* Configure the OpenShift cluster where the product is to be installed with a [global pull secret](https://docs.openshift.com/container-platform/4.6/openshift_images/managing_images/using-image-pull-secrets.html#images-update-global-pull-secret_using-image-pull-secrets) to access the images in the registry and the [mirrored location](https://docs.openshift.com/container-platform/4.6/openshift_images/image-configuration.html#images-configuration-registry-mirror_image-configuration) so that they are not pulled from the IBM entitled registry. WARNING: This operation will result in the cluster rebooting all nodes.

```bash
cloudctl case launch \
  --case $OFFLINEDIR/$CASE_ARCHIVE \
  --inventory $CASE_INVENTORY_SETUP \
  --action configure-cluster-airgap \
  --namespace default \
  --args "--registry $LOCAL_DOCKER_REGISTRY --inputDir $OFFLINEDIR"
```

_Note: the namespace argument is required for legacy reasons, its value can be any namespace that exists_

If your cluster does not use a Machine Config Operator the above step will not update and reboot all nodes. In such cases you should follow [instructions](https://docs.openshift.com/container-platform/4.6/openshift_images/image-configuration.html#images-configuration-registry-mirror_image-configuration) to update `/etc/containers/registries.conf` on all nodes and reboot them.

* Unpack the product helm chart

```bash
tar xf $OFFLINEDIR/charts/ibm-rtas-prod-7.1022.0.tgz
```

* Continue to install the product as normal but since the global pull secret has been created the pull secret is not required `oc create secret docker-registry cp.icr.io`. Naturally this secret should not be referenced in the helm install `--set global.ibmRtasRegistryPullSecret=cp.icr.io \`.



## Upgrade

The method by which an upgrade is performed depends on the version being upgraded.  See the appropriate section below.

### Upgrading from 10.1.3



Follow the installation instructions [above](#installing-the-chart) but use `helm upgrade` rather than `helm install`.


### Upgrading from 10.1, 10.1.1 and 10.1.2

*NOTE* You may only upgrade from a 10.1.x installation. To upgrade from a version prior to this, please first upgrade to 10.1.2.



Uninstall the old version of product. Note: substitute `{my-rtas}` for the Helm release name used at installation.

```bash
helm uninstall {my-rtas} -n test-system
```

Delete the orphaned dynamic workload left in the namespace.

```bash
oc delete all,cm,secret -lexecution-marker -n test-system
```


Install the product as [above](#installing-the-chart)

Use the scripts in the `files` directory of the chart to merge data into the installation.

```bash
migrate.sh create-pvcs -n test-system {my-rtas}
migrate.sh merge-dbs -n test-system {my-rtas}
```


Wait for pods to spin down then back up again.

Confirm that the server has the data that you expect.

You may then remove resources created during the migration using:

```bash
migrate.sh delete-temp-resources -n test-system {my-rtas}
```

## Security Considerations

### Dynamic workload

To scale test asset execution the product creates kubernetes resources dynamically. To review the permissions required to do this consult the execution [role](templates/execution/role.yaml) with its [binding](templates/execution/rolebinding.yaml).

When the resources are created a label is applied so they may be tracked:

```bash
oc get all,cm,secret -lapp.kubernetes.io/managed-by={my-rtas}.test-system -n test-system
```

These resources are deleted 24 hours after the execution completes.

It is possible for users to request executions that exceed the resources available in the cluster. In such cases execution pods can be left Pending or Evicted. To ensure that only the dynamic workload is affected, meaning that critical services are not affected, appropriate priorityClasses need to be used within the cluster so that critical services are given priority by the scheduler.

As general guidance if your cluster has a fixed number of nodes; configure `execution.priorityClassName` with a class that has a [negative](https://kubernetes.io/blog/2019/04/16/pod-priority-and-preemption-in-kubernetes/) priority. This should make the dynamic workload the least important in the cluster thereby protecting critical services. If your cluster autoscales a negative priority can not be used since the autoscaler will not scale the cluster to meet demand from pods with a negative priority. In such cases setting a default priorityClass in the cluster with a high value for critical services is recommended with a different, lower, non-negative class for the dynamic workload using `execution.priorityClassName`. Further information can be found in the configuration section.

### Trust of additional certificates

The product only trusts certificates signed by recognized CAs. To trust additional CAs, for example your internal corporate CA, you must create a secret containing the additional CAs you wish to trust.

The certificate must be in PEM format and have a `.crt` extension.

```bash
oc create secret generic -n test-system usercerts --from-file=corp-ca.crt
```

Once created you need to restart pods that mount it for the additional CA to be trusted. Pods that mount this secret can be listed by running:

```bash
oc get pod -n test-system -o json | jq -r \
  '.items[] | select(.spec.volumes[].secret.secretName == "usercerts") | .metadata.name'
```

They can be forced to restart by deleting them.

```bash
oc delete pod {my-rtas}-tam-0 -n test-system
```

The log will show the additional CAs if successfully added.

```bash
oc logs {my-rtas}-tam-0 -n test-system -c trust-store
```

Further certificates can be added. Note that getting certificates with openssl without verification makes you vulnerable to man-in-the-middle attacks.

```bash
openssl s_client -connect cncf.io:443 -servername cncf.io </dev/null \
  | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > cncf.crt

oc patch secret usercerts -n test-system --type=json \
  -p='[{"op":"replace","path":"/data/cncf.crt","value":"'$(base64 -w0 cncf.crt)'"}]'
```

The secret is not included in the normal backup scheme. You should manually backup the secret containing the additional CAs if you consider it valuable.

### Credential changes

Passwords are generated from the provided seed and stored in secrets when installing the software. These passwords can be changed in bulk by changing the seed used in the helm command, or individually by directly changing the value stored in the secret. However, for the values to become live the `files/reconcile-secrets.sh` script must be run.

User defined secrets used within the software are encrypted. The encryption key is also generated as above and held in a secret. It is not possible to re-encrypt these secrets without the original seed used to encrypt them. To re-encrypt the secrets, follow the steps given when running the `files/reconcile-secrets.sh` script.

When restoring a backup made when different secrets were in use, the same method should be used.



### Passive Encryption

Data should be secured at rest.  It is necessary to ensure that encryption at rest is enabled.  Typically, encryption at rest is required for installation of OpenShift Container Platform.  It is important to implement some form of cluster wide passive encryption.  Please refer to the following document for guidance:

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/security_hardening/index




## Configuration


The defaults shown are not appropriate on OpenShift clusters. The `values-openshift.yaml` file must be used to make the product compatible.


| Parameter                                      | Description | Default |
|------------------------------------------------|-------------|---------|
| `global.ibmRtasCertSecretName`                     | The name of the secret containers use to verify trust of the ingress domain when loopback occurs | ingress |
| `global.ibmRtasCertSecretOptional`                 | If the ingress domain certificate is signed by a globally trusted CA, skip use of the secret | false |
| `global.ibmRtasRegistryPullSecret`                    | The name of the secret used to pull images from the Entitlement Registry. | REQUIRED |
| `global.ibmRtasIngressDomain`               | The web address to expose the product on. For example `192.168.0.100.nip.io` | REQUIRED |
| `global.ibmRtasPasswordAutoGenSeed`         | The seed used to generate secrets. | REQUIRED |
| `global.ibmRtasRegistry`                    | The location of container images to use. See [move-images](files/move-images.sh) | cp.icr.io/cp |
| `global.jaegerAgent.internalHostName`          | The name of the service that execution engines write traces to. | '' |
| `global.jaegerDashboard.externalURL`           | The URL for where traces may be opened in a browser. | '' |
| `global.persistence.rwoStorageClass`           | The storageClass to use if the cluster default is not appropriate | '' |
| `global.persistence.rwxStorageClass`           | For environments that do not provide default StorageClasses that support ReadWriteMany (RWX) accessMode, this value must be set to the name of a suitable StorageClass that has been provisioned to support ReadWriteMany access | REQUIRED |
| `global.prometheusDashboard.internalURL`       | The URL for where the internal prometheus instance can be found. | http://{{ .Release.Name }}-prometheus-server |
| `global.prometheusDashboard.podNamespaceLabel` | The label used to partition metrics by namespace in Prometheus. Check the prometheus-config ConfigMap for `metric_relabel_configs`, use the `target_label`. The value is likely to be `kubernetes_namespace` | namespace |
| `global.rationalLicenseKeyServer`              | Where floating licenses are hosted to entitle use of the product. For example `@ip-address` | '' |
| `clusterDomain`                                | The DNS name of the Kubernetes cluster if the default is overridden. | cluster.local |
| `execution.ingress.hostPattern`                | Pattern used to generate hostnames so that running assets may be accessed via ingress. | '' |
| `execution.intercepts.clusterRole.create`      | When `network.policy` is disabled, NodePorts can be used to enable access to running assets like virtual services | true |
| `execution.priorityClassName`                  | The products dynamic workload pods will have this priorityClass | '' |
| `execution.priorityClassValue`                 | When set a priorityClass named `execution.priorityClassName` is created with the set priority value | |
| `license`                                      | Confirmation that the EULA has been accepted. For example `true` | false |
| `networkPolicy.enabled`                        | Deny other software, installed in the cluster, access to the product. | false |
| `preflight.validateHostPattern`                | When false, no check will be made prior to installation to validate that the pattern used to generate hostnames (e.g. for virtual services) will produce viable names  | true |
| `priorityClassName`                            | The products pods (excluding dynamic workload) will have this priorityClass | '' |
| `priorityClassValue`                           | When set a priorityClass named `priorityClassName` is created with the set priority value | |
| `securityContext.fsGroup`                      | Where required by the storage provider, the fsGroup value used by pods may be overridden | 1001 |

## Uninstalling the Chart

Remove the product. Note: substitute `{my-rtas}` for the Helm release name used at installation.

```bash
helm uninstall {my-rtas} -n test-system
```

Delete the orphaned dynamic workload left in the namespace.

```bash
oc delete all,cm,secret -lapp.kubernetes.io/managed-by={my-rtas}.test-system -n test-system
```

The claims and persistent volumes that contain user data are not automatically be deleted. If you re-install the product these resources will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes

```bash
oc delete project test-system
```

Note: This will hang if the namespace contains workload which has not terminated.

## Limitations

* `helm rollback` is not currently supported. Move back to a previous release by restoring a backup taken before the upgrade.
* `helm upgrade` is not supported when moving from versions before 10.1.3, to 10.1.3 or later. See [Upgrade](#upgrade) for details.
* It is not currently possible to edit test assets on the server. This must be done in the products that form IBM Rational Test Workbench.
* In each namespace, only one instance of the product can be installed.
* The product replica count configuration enables a maximum of 50 active concurrent users. This configuration can not be changed.
