# Microclimate

## Introduction

Microclimate is an end to end development environment that lets you rapidly create, edit, and deploy applications.

This chart can be used to install Microclimate into a Kubernetes environment.

Visit the [Microclimate landing page](https://microclimate-dev2ops.github.io/) to learn more, or visit our [Slack channel](https://ibm-cloud-tech.slack.com/messages/C8RS7HBHV/) to ask any Microclimate questions you might have.

For more information about what's new in the latest chart, see [Release notes](https://github.com/IBM/charts/blob/master/stable/ibm-microclimate/RELEASENOTES.md).

## Chart details
Installing the chart will:

- Create the specified target namespace for deployments created by using Microclimate's pipelines
- Deploy Microclimate
- Deploy Jenkins, used by Microclimate's pipelines
- Create services for Microclimate and Jenkins
- Create Ingress points for Microclimate
- Create an optional Jenkins Ingress
- Create Persistent Volume Claims if they aren't provided. For more information, see **Configuration**.
- Create service accounts, roles, and bindings if service account names are specified (advised for installations into a non-default namespace)

## Prerequisites
- IBM Cloud Private version 3.1. Older versions of IBM Cloud Private are supported by chart versions v1.5.0 and earlier only. Version support information can be found in the release notes of each chart release.
- An IBM Cloud Private cluster with worker nodes that have x86-64 or ppc64le architecture.
- Ensure [socat](http://www.dest-unreach.org/socat/doc/README) is available on all worker nodes in your cluster. Microclimate uses Helm internally and both the Helm Tiller and client require socat for port forwarding.
- Download the IBM Cloud Private CLI, cloudctl, from your cluster at the `https://<your-cluster-ip>:8443/console/tools/cli` URL.
- Before you install Microclimate, decide whether you want to deploy to the IBM Cloud Kubernetes Service. If you want to deploy to the IBM Cloud Kubernetes Service, when you install Microclimate, specify a Docker registry location on the `jenkins.Pipeline.Registry.URL` property. Both Microclimate and the IBM Cloud Kubernetes Service need to access this registry.

### Pod Security Policies
Microclimate requires a `PodSecurityPolicy` to be bound to the target namespace prior to installation.

The predefined `PodSecurityPolicy`, `ibm-anyuid-hostpath-psp`, is verified for this chart. If your target namespace does not already have this policy applied, Microclimate applies the policy during the installation. For details about the `PodSecurityPolicy` and the `ClusterRole` that is applied, see the following code.

The following code shows the predefined `PodSecurityPolicy`, `ibm-anyuid-hostpath-psp`:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy allows pods to run with
      any UID and GID and any volume, including the host path.  
      WARNING:  This policy allows hostPath volumes.  
      Use with caution."
  name: ibm-anyuid-hostpath-psp
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

The following code shows the custom `ClusterRole` for the predefined `PodSecurityPolicy`, `ibm-anyuid-hostpath-psp`:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
  name: ibm-anyuid-hostpath-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-anyuid-hostpath-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

## Resources Required

The Microclimate containers have the following resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit             |
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------    |
| theia                      | 350Mi                 | 1Gi                   | 30m                   | 500m                  |
| file-watcher               | 128Mi                 | 2Gi                   | 100m                  | 300m                  |
| portal                     | 128Mi                 | 2Gi                   | 100m                  | 500m                  |
| beacon                     | 128Mi                 | 2Gi                   | 100m                  | 500m                  |
| loadrunner                 | 128Mi                 | 2Gi                   | 100m                  | 1000m                 |
| devops                     | 128Mi                 | 2Gi                   | 100m                  | 1000m                 |
| jenkins - Master           | 1500Mi                | -                     | 200m                  | -                     |
| jenkins - Agent            | 600Mi                 | -                     | 200m                  | -                     |

For details about how to configure these values, see **Configuration**.

## Installing the Chart

**IMPORTANT**

Microclimate must be installed into a namespace other than `default`.

For Microclimate to function correctly, you must:

- Prepare for a non-default namespace installation
- Create a namespace for the Microclimate pipeline
- Create a new ClusterImagePolicy
- Create the Microclimate registry secret
- Create the Microclimate pipeline secret in the `microclimate-pipeline-deployments` namespace
- Create a secret so Microclimate can securely use Helm
- Set the Ingress domain name
- Ensure Microclimate is configured correctly to use persistent storage

These steps are detailed below and should be completed in order.

*NOTE:* A number of these instructions require the name of your cluster Certificate Authentication (CA) domain which by default is set to `mycluster.icp`. This might have been set to a different name by your cluster administrator when installing IBM Cloud Private and so you should contact your cluster administrator to confirm this. If this value has been changed, use the actual value instead of `mycluster.icp` where necessary.

#### Prepare for a non-default namespace installation

Create a non-default namespace with the following command. Make sure that your namespace name follows the [Kubernetes resource naming conventions](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names).

`kubectl create namespace <target namespace for Microclimate>`

Set the HELM_HOME environment variable to a folder of choice on your system; it is recommended to use `~/.helm`.

Configure your Kubectl and Helm clients to use the target namespace by logging in to your cluster with `cloudctl`. This ensures all resources created in the upcoming steps are created in the target namespace:

```
cloudctl login -a https://<your-cluster-ip>:8443 -n <target-namespace> --skip-ssl-validation
```

#### Create a namespace for the Microclimate pipeline

The Microclimate pipeline needs a namespace to deploy applications into. Create the namespace with the following command:

`kubectl create namespace microclimate-pipeline-deployments`

This is the default target namespace used by the Microclimate pipeline for deployments. If you want to specify a different namespace, you must set the `jenkins.Pipeline.TargetNamespace` chart value to match the name of the desired namespace when installing the Microclimate chart.

#### Determine your `cluster_ca_domain`

The following steps require the `cluster_ca_domain` certificate authority (CA) domain. During IBM Cloud Private installation, this CA domain was set in the config.yaml file. If you did not specify a CA domain name, `mycluster.icp` is the default value.

You can look it up with the following command:
```
$ kubectl get configmap oauth-client-map -n services -o yaml | grep 'CLUSTER_CA_DOMAIN:' | sed 's/^.*: //'
<cluster_ca_domain>.icp
```

#### Create a new ClusterImagePolicy

Microclimate pipelines pull images from repositories other than `docker.io/ibmcom`. To use Microclimate pipelines, you must ensure you have a cluster image policy that permits images to be pulled from these repositories.

A new cluster image policy can be created with the necessary image repositories by saving the template below into a `mycip.yaml` file and using `kubectl create -f mycip.yaml`:

```
apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
kind: ClusterImagePolicy
metadata:
  name: microclimate-cluster-image-policy
spec:
  repositories:
  - name: <cluster_ca_domain>:8500/*
  - name: docker.io/maven:*
  - name: docker.io/jenkins/*
  - name: docker.io/docker:*
```

Alternatively, you can add the above repositories to an existing cluster image policy by using the `kubectl edit clusterimagepolicy <policy-name>` command, and then adding the above repositories into the repositories of the given cluster image policy.

#### Create the Microclimate registry secret

This secret is used by both Microclimate and Microclimate's pipelines. It allows images to be pushed and pulled from the private registry on your Kubernetes cluster.

Use the following code to create a Docker registry secret:

```
kubectl create secret docker-registry microclimate-registry-secret \
  --docker-server=<cluster_ca_domain>:8500 \
  --docker-username=<account-username> \
  --docker-password=<account-password> \
  --docker-email=<account-email>
```

Verify that the secret was created successfully and exists in the target namespace for Microclimate before you continue. This secret does not need to be patched to a service account because the Microclimate installation manages this step.

#### Create a secret so Microclimate can securely use Helm

Microclimate pipelines deploy applications by using the Tiller at `kube-system`. Establish secure communication with this Tiller and configure it by creating a Kubernetes secret that contains the required certificate files.

The `cloudctl login ...` command listed in the **Prepare for a non-default namespace installation** step downloads the `cert.pem`, `ca.pem`, and `key.pem` files in the `$HELM_HOME` directory. Confirm that these files have been created:

`ls -l $HELM_HOME`

You should see the certificate files listed with recent timestamps. Otherwise, ensure `$HELM_HOME` is set correctly and run the `cloudctl login...` command again.

To create the secret with the certificate files, enter the following command:
```
kubectl create secret generic microclimate-helm-secret --from-file=cert.pem=$HELM_HOME/cert.pem --from-file=ca.pem=$HELM_HOME/ca.pem --from-file=key.pem=$HELM_HOME/key.pem
```

The name of the secret that you have created is printed by the Microclimate pipeline when you run a Jenkins job against your project. With this secret present, your deployed applications appear as a Helm release alongside any others that were deployed from `kube-system`.

**Note:** You need to ensure that the certificate and the secret remain valid.

#### Create the Microclimate pipeline secret in the microclimate-pipeline-deployments namespace

Microclimate needs a second secret to allow the pipeline to deploy applications into the `microclimate-pipeline-deployments` namespace created previously. You can create this with the following and the name *must* be `microclimate-pipeline-secret`:

```
kubectl create secret docker-registry microclimate-pipeline-secret \
  --docker-server=<cluster_ca_domain>:8500 \
  --docker-username=<account-username> \
  --docker-password=<account-password> \
  --docker-email=<account-email> \
  --namespace=microclimate-pipeline-deployments
```

The key difference here is the usage of `--namespace microclimate-pipeline-deployments`.  This is for the service account that sits in this particular namespace. Pods in this namespace pull images from the IBM Cloud Private image registry. The secret name here is arbitrary so long as the service account is patched to use it.

You now need to patch the default service account in this namespace to use the secret.

First, check if the default service account has `imagePullSecrets` associated with it already:
```
kubectl describe serviceaccount default --namespace microclimate-pipeline-deployments
```
If it does not contain any other secrets, patch the service account by using the following command:
```
kubectl patch serviceaccount default --namespace microclimate-pipeline-deployments -p "{\"imagePullSecrets\": [{\"name\": \"microclimate-pipeline-secret\"}]}"
```

If it does contain other secrets, patch the service account using this command instead:
```
kubectl patch sa default -n microclimate-pipeline-deployments --type=json -p="[{\"op\":\"add\",\"path\":\"/imagePullSecrets/0\",\"value\":{\"name\": \"microclimate-pipeline-secret\"}}]"
```

#### Set the Ingress domain name

Access to Microclimate and Jenkins is provided by way of two Kubernetes Ingresses. Both of these require that the `global.ingressDomain` parameter is set. This value represents a unique sub-domain that is used to route to the Microclimate and Jenkins user interfaces. It should resolve to the IP address of your cluster's proxy node. This could, for example, be `example.com`. When a domain name is not available, the service `nip.io` can be used to provide a resolution based on an IP address. For example, `<IP>.nip.io` where `<IP>` would be replaced with the IP address of your cluster's proxy node.

By default, the Microclimate Ingress is set to https://microclimate.[`global.ingressDomain`]. The `microclimate` host name might be changed by setting `global.microclimateHost`. Similarly, `global.jenkinsHost` might be overridden from its default value of 'jenkins'.

For example, if `global.ingressDomain` were set to `10.10.10.10.nip.io`, the Microclimate Ingress would by default be available at `https://microclimate.10.10.10.10.nip.io` and the Jenkins Ingress at `https://jenkins.10.10.10.10.nip.io`.

In IBM Cloud Private 3.1.1, you can use the following command to retrieve the proxy address from your cluster info:

`kubectl get configmaps ibmcloud-cluster-info -n kube-public -o jsonpath='{.data.proxy_address}'`

In IBM Cloud Private 3.1, cluster configurations get the correct IP address in different ways. Find the proxy node for a cluster with the following command:

`kubectl get nodes -l proxy=true`

If the name of this node is an IP address, you can test that this IP is usable as an ingress domain by navigating to `https://<proxy-ip>`. If you receive a `default backend - 404` error, then this IP is externally accessible and should be used as the `global.ingressDomain` value. If you cannot reach this address, copy the IP address that you use to access the IBM Cloud Private dashboard. Use the copied address to set the `global.ingressDomain` value.

If the name of your proxy node is a string instead of an IP address, the proxy node exposes an external IP address. Use this external IP address for the `global.ingressDomain` value:

`kubectl get nodes -l proxy=true -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'`

#### Ensure Microclimate is configured correctly to use persistent storage

When installing the chart, you must ensure sufficient persistent storage is provided to the Microclimate installation. For more information, see **Configuration**.

## Installing from the command line

When the above prerequisities are satisfied and you are confident each resource has been created in the target namespace, you can proceed with the installation process.

Before installing the chart, you must add the IBM charts repo to your Helm repositories:

`helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/`

You can then install the chart using the ingressDomain and service account name:  

`helm install --name microclimate --namespace <target namespace> --set global.rbac.serviceAccountName=micro-sa,jenkins.rbac.serviceAccountName=pipeline-sa,global.ingressDomain=<icp-proxy>.nip.io ibm-charts/ibm-microclimate --tls`.

This command deploys Microclimate on the Kubernetes cluster in the default configuration. For more information, see **Set the Ingress domain name**.

For more information about additional parameters that can be configured during installation, see **Configuration**.

## Verifying the Chart
You can verify the chart by accessing the Microclimate Portal, use your IBM Cloud Private credentials to log in.

When the Helm install has completed successfully, the Microclimate Portal can be accessed by way of the Microclimate ingress hostname. This can be found by passing the name of your Microclimate release into the following command:

`kubectl get ingress -l release=<release_name>`

If you are using Helm to install Microclimate, you can access the Microclimate Portal by using the URL printed at the end of the installation.

Use the following command to view all resources created by this chart, replacing `x.y.z` with the version number of the installed chart, for example `1.0.0`:

`kubectl get all -l chart=ibm-microclimate-x.y.z`

## Uninstalling the Chart

To uninstall or delete the `microclimate` release:

```bash
helm delete --purge microclimate --tls
```

The command removes all the Kubernetes resources that are associated with the chart and deletes the release.

## Configuration

#### Persistent Storage

Microclimate requires two persistent volumes to function correctly: one for storing project workspaces and one for the Jenkins pipeline. The persistent volume used for project workspaces is shared by all users of the Microclimate instance and must be defined with an access mode of ReadWriteMany (RWX). The volume for Jenkins should be ReadWriteOnce (RWO). The default size of the persistent volume claim for the project workspaces is 8Gi. Configure this size with the `persistence.size` option to scale with the number of users and the number and size of the projects they are expected to create or import into Microclimate. As a rough guide, a generated Java project is approximately 128Mi, a generated Swift project is approximately 100Mi, and a generated Node.js project is approximately 1Mi. Therefore, the default size of 8Gi allows space for approximately 64 Java projects.

The Jenkins pipeline requires an 8GB persistent volume, which currently is not configurable.

Both Microclimate and Jenkins can use existing Persistent Volume Claims, which should follow these guidelines for storage size. These names can be passed into the `persistence.existingClaimName` and `jenkins.Persistence.ExistingClaim` chart values.

If you want to use Dynamic Provisioning, or you want Microclimate to create its own `PersistentVolumeClaim`, these values must be left blank.

Dynamic Provisioning is enabled by default, `persistence.useDynamicProvisioning`, and uses the default storage class set up in your cluster. A different storage class can be used by editing the `persistence.storageClassName` option for Microclimate and the `jenkins.Persistence.StorageClass` option for Jenkins in the configuration.

Microclimate attempts to create its own persistent volume claim by using the `persistence.storageClassName` and `persistence.size` options if Dynamic Provisioning is not enabled and if PVCs are not provided by name.

**Warning:** Microclimate stores any projects that are created by users in whichever Persistent Volume to which it gets mounted. Uninstalling Microclimate might cause data to be lost if the `PersistentVolume` and `PersistentVolumeClaim` are not configured correctly. To avoid losing data, we recommend that you have the correct Reclaim Policy set in a provided `PersistentVolumeClaim` or, if you are using Dynamic Provisioning, in the provided `StorageClass`. The same practice should be applied to the Jenkins persistent volume.

**Warning:** Avoid using hostPath persistent volumes. A hostPath volume sets up a file system on a single node of a cluster. The portal, file-watcher, and editor pods need access to the same file system, and these pods can start on different nodes. If the pods start on different nodes, pods that are started on one node are unable to access the hostPath volume that is created on a different node.

For more information about creating Persistent Storage and enabling Dynamic Provisioning, see [Cluster Storage](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/manage_cluster/cluster_storage.html),
[Working with storage](https://www.ibm.com/developerworks/community/blogs/fe25b4ef-ea6a-4d86-a629-6f87ccf4649e/entry/Working_with_storage), and
[Dynamic Provisioning](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/storage_class_all.html).

#### Configuring Microclimate
Microclimate provides a number of configuration options to customise its installation. The following list describes the configurable parameters.

If you are installing by using the Helm CLI then values can be set by using one or more `--set` arguments when doing `helm install`. For example, to configure persistent storage options, you can use the following command:

`helm install --name microclimate --set persistence.useDynamicProvisioning=false,persistence.size=16Gi,<any additional options> ibm-charts/ibm-microclimate --tls`

#### Deploying to the IBM Cloud Kubernetes Service

If you want to deploy applications to the IBM Cloud Kubernetes Service by way of the Microclimate pipeline, when you install Microclimate, specify a Docker registry location on the `jenkins.Pipeline.Registry.URL` property. For more information about deploying into the IBM Cloud Kubernetes Service, see [Configuring Microclimate to deploy applications to the IBM Cloud Kubernetes Service](https://microclimate-dev2ops.github.io/configiks).

#### Additional Pull Secrets

If you want to specify more registry secrets for Microclimate to use, `global.additionalImagePullSecrets` can be set when installing the chart to use a YAML array of ImagePullSecrets. For example, you can include the following registry secrets if you are installing using the IBM Cloud Private catalog:

```
- artifactory
- myregistry
- dockerhub
```

If using the command line instead, the options can be specified as follows:
```
--set global.additionalImagePullSecrets[0]=<secret>,global.additionalImagePullSecrets[1]=<secret2>
```

#### Git configuration

You can use Microclimate with your own source code management system, for example, your own hosted GitLab that might be using self-signed certificates.

Microclimate uses a Git client in two ways, for the Portal component when importing a project, and for Microclimate pipelines when checking out source code to build, push, and potentially deploy. You can specify an extra Git option that you want to use, for example, `--global http.sslVerify false` which accepts self-signed certificates when Microclimate uses Git.

If using the command line, the option can be specified as follows:
```
--set global.gitOption="--global http.sslVerify false"
```

#### Configuration parameters

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `global.ingressDomain`     | Domain for both Microlimate Ingress points      | **MUST BE SET BY USER**     |
| `theia.repository`         | Image repository for theia                      | `ibmcom/microclimate-theia` |
| `theia.tag`                | Tag for theia image                             | `latest` |
| `filewatcher.repository`   | Image repository for file-watcher               | `ibmcom/microclimate-file-watcher` |
| `filewatcher.tag`          | Tag for file-watcher image                      | `latest` |
| `portal.repository`        | Image repository for portal                     | `ibmcom/microclimate-portal` |
| `portal.tag`               | Tag for portal image                            | `latest`|
| `beacon.repository`        | Image repository for beacon                     | `ibmcom/microclimate-beacon` |
| `beacon.tag`               | Tag for beacon image                            | `latest`|
| `imagePullPolicy`          | Image pull policy used for all images           | `Always`    |
| `persistence.existingClaimName`        | Name of an existing PVC to be used with Microclimate - should be left blank if you use Dynamic Provisioning or if you want Microclimate to make it's own PVC     | `""` |
| `persistence.useDynamicProvisioning`      | Use dynamic provisioning | `true` |
| `persistence.size`         | Storage size allowed for Microclimate workspace   | `8Gi` |
| `persistence.storageClassName`        | Storage class name for Microclimate workspace     | `""` |
| `jenkins.Persistence.StorageClass`    | Storage class name for Microclimate workspace | `""` |
| `jenkins.Persistence.ExistingClaim`    | Name of an existing PVC to be used for Jenkins - should be left blank if you use Dynamic Provisioning or if you want Microclimate to make it's own PVC | `""` |
| `jenkins.rbac.serviceAccountName`    | Name of a existing service account to create for Jenkins and the DevOps component to use | `"default"` |
| `global.microclimateHost`  | Host name used for Ingress for Microclimate     | `microclimate` |
| `global.jenkinsHost`       | Host name used for Ingress for Jenkins          | `jenkins` |
| `global.helm.tlsSecretName`    | Name of the Kubernetes secret to be used by the Microclimate pipeline: must be provided in order to use Tiller securely | `""` |
| `global.rbac.serviceAccountName`    | Name of a service account to create for Microclimate's Portal and File Watcher components to use | `"default"` |
| `global.gitOption`    | An extra Git configuration option to be used for Microclimate | `""` |
| `global.applyPodSecurityPolicy`    | Automatically apply the ibm-anyuid-hostpath-psp policy to the namespace Microclimate is installed into | `true` |
| `global.useSecurityContexts`     | Use security contexts for the Portal and Atrium pods | `true` |
| `global.helmHost`     | Hostname and port of the Helm tiller, if using its NodePort configuration. | `""` |

Jenkins also has a number of other configurable options not listed here. These can be viewed in the chart's `values.yaml` file or in your cluster's dashboard page for this chart.

#### Resource requests and limits

Each Microclimate container has a set of default requests and limits for CPU and memory usage. These are set at recommended values but should be configured to suit the needs of your cluster.

Resource requests and limits can also be configured for each of the Microclimate containers by using the options in the following table, for example, `theia.resources.request.cpu`:

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `<containerName>.resources.requests.cpu`          | CPU Request size for a given container      | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.limits.cpu`            | CPU Limit size for a given container        | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.requests.memory`       | Memory Request size for a given container   | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.limits.memory`         | Memory Limit size for a given container     | View the [Resources Required](#ResourcesRequired) section for default values  |

#### Replacing TLS certificates

The default installation of Microclimate on an IBM Cloud Private cluster configures a secure TLS endpoint through Ingress for both the Microclimate and Jenkins user interfaces.  If customization of the certificates used to secure these TLS endpoints is required, follow this procedure.

These commands can be run from any host that has a kubectl client with access to the IBM Cloud Private cluster that is the target of the changes.

1. Generate or acquire a new certificate for Microclimate

  Substituting your own TLS certificate for encrypting Microclimate communications requires a certificate and key file. If you are not using an existing certificate, a new certificate needs to be generated. The following command creates a new certificate for this purpose:

  `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=microclimate.myhost.com"`

  Note: Replace `microclimate.myhost.com` with your unique Microclimate ingress endpoint.

2. Replace the Microclimate TLS certificate

  The next step is to take the certificate acquired in step 1 and replace the existing certificate being used for Microclimate TLS communications. The default installation of Microclimate creates a Kubernetes secret named `microclimate-mc-tls-secret` which contains this certificate. Use the following command to replace that secret with your new certificate:

  `kubectl create secret tls microclimate-mc-tls-secret  --key tls.key --cert tls.crt --dry-run  -o yaml | kubectl replace --force -f -`

3. Generate or acquire a new certificate for Microclimate Jenkins

  Substituting your own TLS certificate for encrypting Microclimate Jenkins communications requires a certificate and key file.  If you are not using an existing certificate, a new certificate needs to be generated. The following command creates a suitable new certificate for this purpose:

  `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=jenkins.myhost.com"`

  Note: Replace `jenkins.myhost.com` with your unique Microclimate Jenkins ingress endpoint.

4. Replace the Microclimate Jenkins TLS certificate

  The last step is to take the certificate acquired in step 3 and replace the existing certificate being used for Microclimate Jenkins TLS communications. The default installation of Microclimate creates a Kubernetes secret named `microclimate-tls-secret` which contains this certificate. Use the following command to replace that secret with your new certificate:

  `kubectl create secret tls microclimate-tls-secret  --key tls.key --cert tls.crt --dry-run  -o yaml | kubectl replace --force -f -`

#### Updating your installation with a new registry URL

To ensure that you install the chart with the correct pipeline registry URL, perform a release upgrade to your current Microclimate installation.

- Enter the following commands into the Helm CLI, substituting your correct value in place of the `<mycluster.icp:8500>` and `<ns2>` variables:
  - `helm repo add ibm-charts-public https://raw.githubusercontent.com/IBM/charts/master/repo/stable`
  - `helm upgrade microclimate --set jenkins.Pipeline.Registry.Url=<mycluster.icp:8500> --namespace <ns2> ibm-charts-public/ibm-microclimate --reuse-values --tls`
- After you upgrade the chart with the correct registry URL, the `microclimate-ibm-microclimate-<xxx-xxx>` portal pod, the `microclimate-ibm-microclimate-devops-<xxx-xxx>` DevOps pod, and the `microclimate-jenkins-<xxx-xxx>` Jenkins pod are restarted.
- You can check your registry URL value in the Jenkins UI. Navigate to `Jenkins`>`Manage Jenkins`>`Configure System`>`Global properties`>`Environment variables`. Then, find the `Name: REGISTRY` and `Value: mycluster.icp:8500/ns2` to see the environment variable setting. If you change the value in the Jenkins UI, the change does not persist after you restart IBM Cloud Private.
- When the portal pod is running, log in to the Microclimate portal UI, and the file-watcher, editor, and loadrunner pods are restarted.
- Run the `kubectl get pods` command to view the status of the pods after the upgrade.
  ```
  NAME                                                              READY     STATUS    RESTARTS   AGE
  microclimate-ibm-microclimate-8d88fbd9c-w7967                     1/1       Running   0          3m
  microclimate-ibm-microclimate-admin-editor-7784cf8d67-wrzbr       2/2       Running   0          48s
  microclimate-ibm-microclimate-admin-filewatcher-79ff787b4766pw7   1/1       Running   0          49s
  microclimate-ibm-microclimate-admin-loadrunner-5c587d99cd-w2fn7   1/1       Running   0          48s
  microclimate-ibm-microclimate-atrium-5799d5cdc8-2szls             1/1       Running   0          18m
  microclimate-ibm-microclimate-devops-55d6c67f49-tgncz             1/1       Running   0          3m
  microclimate-jenkins-b6fd6d5b8-dz2q9                              1/1       Running   0          3m
  ```

## PodSecurityPolicy Requirements

We bundle the role binding for the `ibm-anyuid-hostpath-psp` as part of the chart, so these are installed alongside Microclimate without requiring user intervention.

## Limitations

- Only one installation of Microclimate per cluster is supported.

- This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart.

- An IBM Cloud Private Administrator role is required to install into a non-default namespace. This is because two service accounts will be created if you specify the `global.rbac.serviceAccountName` and `jenkins.rbac.serviceAccountName` properties when installing the chart, which are used to allow Microclimate pods to function correctly in a non-default namespace.

For other known issues and limitations, see the [product documentation](https://microclimate-dev2ops.github.io/troubleshooting#doc).

## Documentation

The Microclimate [landing page](https://microclimate-dev2ops.github.io) provides additional learning resources and documentation.
