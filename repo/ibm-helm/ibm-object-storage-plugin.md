# IBM Cloud Object Storage Plug-in
This Helm chart installs the IBM Cloud Object Storage plug-in in a Kubernetes cluster. In IBM Cloud Kubernetes Service, the Helm chart is deployed in the `ibm-object-s3fs` namespace of your cluster.

# Supported orchestration platforms

The following table details orchestration platforms suitable for deployment of the IBM Cloud Object Storage Plug-in.

|Orchestration platform|Version|Architecture|
|----------------------|-------|------------|
|Kubernetes|1.21|x86|
|Kubernetes|1.20|x86|
|Kubernetes|1.19|x86|
|Red Hat® OpenShift®|4.7|x86|
|Red Hat OpenShift|4.6|x86|

## Introduction
[IBM Cloud Object Storage](https://cloud.ibm.com/docs/services/cloud-object-storage?topic=cloud-object-storage-about-ibm-cloud-object-storage#about-ibm-cloud-object-storage) is persistent, highly available storage that you can mount to apps that run in a Kubernetes cluster by using the IBM Cloud Object Storage plug-in. The plug-in is a Kubernetes Flex-Volume plug-in that connects Cloud Object Storage buckets to pods in your cluster. Information that is stored with IBM Cloud Object Storage is encrypted in transit and at rest, dispersed across multiple geographic locations, and accessed over HTTP by using a REST API.

------------------------------------------------------------------------------------------------------------------------------
## Chart Details
When you install the IBM Cloud Object Storage plug-in Helm chart, the following Kubernetes resources are deployed into your Kubernetes cluster:
- **IBM Cloud Object Storage driver daemonset**: The daemonset deploys one `ibmcloud-object-storage-driver` pod on every worker node in your cluster. The daemonset contains the Kubernetes flex driver plug-in to communicate with the `kubelet` component in your cluster.
- **IBM Cloud Object Storage plug-in pod**: The pod contains the storage provisioner controllers to work with the Kubernetes controllers.
- **IBM-provided storage classes**: You can use the storage classes to create Cloud Object Storage buckets with a specific configuration.
- **Kubernetes service accounts, RBAC cluster roles and cluster role bindings**: The service accounts and RBAC roles authorize the plug-in to interact with your Kubernetes resources.

## Prerequisites

- **IBM Cloud Kubernetes Service (IKS)**:
  - Create or use an existing standard Kubernetes cluster that you [provisioned with IBM Cloud Kubernetes Service](https://cloud.ibm.com/docs/containers?topic=containers-clusters#clusters_cli).
  - [Install the IBM Cloud CLI, the IBM Cloud Kubernetes Service plug-in, the Kubernetes CLI](https://cloud.ibm.com/docs/containers?topic=containers-cs_cli_install#cs_cli_install).
  - [Log in to your IBM Cloud account. Target the appropriate region and, if applicable, resource group. Set the context for your cluster](https://cloud.ibm.com/docs/containers?topic=containers-cs_cli_install#cs_cli_configure).
  - Helm > v3.2.0 Required. Follow the [instructions](https://cloud.ibm.com/docs/containers?topic=containers-helm#install_v3) to install the Helm client v3 on your local machine. If helm v2 is installed on your local machine or on your cluster, then it is strongly recommended to [migrate from helm v2 to v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#migrate_v3).
    Install using [script](https://helm.sh/docs/intro/install/#from-script)

### SecurityContextConstraints Requirements

- The chart automatically creates following SCC, s3fs-cos-driver-scc, for OpenShift Container Platform (OCP) to provide the required permissions & capabilities to the Driver Pods
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: s3fs-cos-driver-scc
    priority: 0
    defaultAddCapabilities: []
    allowedCapabilities: []
    allowHostDirVolumePlugin: true
    allowHostIPC: false
    allowHostPID: false
    allowHostPorts: false
    allowHostNetwork: true
    allowPrivilegedContainer: false
    allowPrivilegeEscalation: true
    requiredDropCapabilities:
     - KILL
     - MKNOD
     - SETUID
     - SETGID
    readOnlyRootFilesystem: true
    runAsUser:
      type: RunAsAny
    seLinuxContext:
      type: RunAsAny
    fsGroup:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    users:
    - system:serviceaccount:{{template "ibm-object-storage-plugin.namespace" .}}:ibmcloud-object-storage-driver
    groups: []
    volumes:
      - configMap
      - downwardAPI
      - emptyDir
      - hostPath
      - persistentVolumeClaim
      - projected
      - secret
    ```


### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

The custom **PodSecurityPolicy**  can be used to finely control the permissions/capabilities needed to deploy this chart.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: policy/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-object-storage-plugin-psp
    spec:
      allowPrivilegeEscalation: false
      requiredDropCapabilities:
      - ALL
      hostNetwork: true
      volumes:
      - 'hostPath'
      - 'secret'
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: MustRunAs
        ranges:
          - min: 1
            max: 65535
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: MustRunAs
        ranges:
          - min: 1
            max: 65535
    ```
  1. Create a Kubernetes namespace where you want to install the IBM Cloud Object Storage plug-in.
      ```
      kubectl create namespace <namespace_name>
      ```

  2. Create the pod security policy in your cluster.
      ```
      kubectl apply -f podsecuritypolicy.yaml
      ```

  3. Custom ClusterRole for the custom PodSecurityPolicy:

     Create a cluster role for your pod security policy.

     1. Open your preferred editor and add the following configuration.

         ```
         kind: ClusterRole
         apiVersion: rbac.authorization.k8s.io/v1
         metadata:
           name: ibmcloud-object-storage-plugin-psp-user
         rules:
           - apiGroups: ['policy']
             resources: ['podsecuritypolicies']
             verbs:     ['use']
             resourceNames:
             - ibm-object-storage-plugin-psp
         ```
     2. Create the cluster role in your cluster.
         ```
         kubectl apply -f custerrole.yaml
         ```

  4. Create a role binding for your pod security policy to scope this policy to the namespace that you created earlier.
      1. Open your preferred editor and add the following configuration.
         ```
         apiVersion: rbac.authorization.k8s.io/v1
         kind: RoleBinding
         metadata:
             name: ibmcloud-object-storage-plugin-psp-user
             namespace: <namespace>
         roleRef:
             apiGroup: rbac.authorization.k8s.io
             kind: ClusterRole
             name: ibmcloud-object-storage-plugin-psp-user
         subjects:
           - kind: ServiceAccount
             name: ibmcloud-object-storage-plugin
             namespace: <namespace>
           - kind: ServiceAccount
             name: ibmcloud-object-storage-driver
             namespace: <namespace>
         ```

      2. Create the role binding in your cluster.
         ```
         kubectl apply -f clusterrolebinding.yaml
         ```


### Permissions
To install the Helm chart in your cluster, you must have the **Administrator** platform role.

## Resources Required
The IBM Cloud Object Storage plug-in requires the following resources on each worker node to run successfully:
- CPU: 0.2 vCPU
- Memory: 128MB

## Installing the Chart
Install the IBM Cloud Object Storage plug-in with a Helm chart to set up pre-defined storage classes for IBM Cloud Object Storage. You can use these storage classes to create a PVC to provision IBM Cloud Object Storage for your apps.

### Before you begin

1. Complete the prerequisites for your IBM Cloud environment as outlined in the `Prerequisites` section of this `README`.
2. Create a Cloud Object Storage instance that you want to use to store your data.
   - **Option 1:** [Create an IBM Cloud Object Storage service instance in IBM Cloud](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#create_cos_service). The service provides a public and a private service endpoint. In IBM Cloud Kubernetes Service, the private endpoint is used by default. However, you can specify the public service endpoint in your PVC instead. To connect to the private service endpoint, you must be on the IBM network, for example by using a VPN gateway.
   - **Option 2:** Set up a local Cloud Object Storage server in your cluster. For example, [check out the `ibm-minio-objectstore` Helm chart](https://cloud.ibm.com/containers-kubernetes/solutions/helm-charts/ibm-charts/ibm-minio-objectstore).
   - **Option 3:** Create or use an existing Cloud Object Storage instance that you set up with a different cloud provider, such as [Amazon s3](https://docs.aws.amazon.com/AmazonS3/latest/dev/Welcome.html).
3. Retrieve your Cloud Object Storage API endpoint, and the credentials to access your Cloud Object Store. For example, to retrieve this information for an IBM Cloud Object Storage service instance in IBM Cloud (Option 1), see [Retrieve the IBM Cloud Object Storage service credentials](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#service_credentials).
4. Store the credentials to access your Cloud Object Store in a Kubernetes secret.
   1. Encode the Cloud Object Storage credentials to base64 and note all the base64 encoded values.
      ```
      echo -n "<key_value>" | base64
      ```

   2. Create a configuration file for your Kubernetes secret. The credentials might vary depending on the type of Cloud Object Storage instance you use. The following examples show the values that you must provide if you use an IBM Cloud Object Storage service instance in IBM Cloud. You can create the secret, say `secret.yaml` in any namespace that you want.
      Example for Hash-based Message Authentication Code (HMAC) authentication:
      ```
      apiVersion: v1
      kind: Secret
      type: ibm/ibmc-s3fs
      metadata:
        name: <secret_name>
        namespace: <namespace>
      data:
        access-key: <base64_access_key_id>
        secret-key: <base64_secret_access_key>
      ```

      Example for Identity and Access Management (IAM) key authentication:
      ```
      apiVersion: v1
      kind: Secret
      type: ibm/ibmc-s3fs
      metadata:
        name: <secret_name>
        namespace: <namespace>
      data:
        api-key: <base64_apikey>
        service-instance-id: <base64_resource_instance_id>
      ```

   3. Create the Kubernetes secret in your cluster.
      ```
      kubectl apply -f secret.yaml
      ```

### Installing the Chart

* Go to **IBM Cloud Kubernetes Service** for deployment on IKS Cluster

### _IBM Cloud Kubernetes Service_

**Note**: This chart supports only `Helm V3` and will not work with `Helm V2`

1. Verify that `helm v3` is installed on your local machine.

   ```
   helm version --short
   v3.0.2+g19e47ee
   ```

   **Tip:** If helm v2 is installed on your local machine or on your cluster, then first [migrate from helm v2 to v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#migrate_v3).

2. Add the IBM Cloud Helm repository `ibm-helm` to your cluster.

   ```
   helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm
   ```

3. Update the Helm repo to retrieve the latest version of all Helm charts in this repo.

   ```
   helm repo update
   ```

4. Download the Helm chart and unpack the chart in your current directory. Then, navigate to the `ibm-object-storage-plugin` directory.

   ```
   helm fetch --untar ibm-helm/ibm-object-storage-plugin && cd ibm-object-storage-plugin
   ```
5. To limit the IBM Cloud Object Storage plug-in access to Kubernetes secrets, go to **Optional: Limit secret access** ; otherwise, if there is no limitation to be set, continue with next step.

6.  Install the IBM Cloud Object Storage Helm plug-in `ibmc`. The plug-in is used to automatically retrieve your cluster location and to set the Cloud Object Storage s3 API endpoint for your IBM Cloud Object Storage buckets in your storage classes.

       1. Install the `ibmc` Helm plug-in.

          ```
          helm plugin install ./helm-ibmc
          ```
          Example output:

          ```
          Installed plugin: ibmc
          ```
       2. Verify that the `ibmc` plug-in is installed successfully.

          ```
          helm ibmc --help
          ```
7.  Install the IBM Cloud Object Storage plug-in. When you install the plug-in, pre-defined storage classes are added to your cluster.

    **Important note:** The bucket access policy configuration, to configure authorised ips, has been enabled only for VPC-Gen2 clusters. Currently, this feature is not supported on IKS Classic.
    The feature has been enabled by default for VPC-Gen2 clusters in **eu-fr2** region.
    For other regions, to enable bucket access policy, pass the flag `--set bucketAccessPolicy=true` to helm ibmc install command.

    Example: Install chart from helm registry, without any limitation to access specific Kubernetes secrets:

    ```
     helm ibmc install ibm-object-storage-plugin ibm-helm/ibm-object-storage-plugin --set license=true
    ```

    Example: Install chart from local path, with a limitation to access the Cloud Object Storage's secrets only, as described in the `Optional: Limit secret access` section at the bottom:

    ```
    helm ibmc install ibm-object-storage-plugin ./ --set license=true
    ```
    
    Example: Install chart from helm registry, with bucket access policy feature enabled (for regions other than eu-fr2)

    ```
     helm ibmc install ibm-object-storage-plugin ibm-charts/ibm-object-storage-plugin --set license=true --set bucketAccessPolicy=true
    ```
8. Go to **Limit secret access**

### Optional: Limit secret access
Limit the IBM Cloud Object Storage plug-in to access only the Kubernetes secrets that hold your IBM Cloud Object Storage service credentials. By default, the plug-in is authorized to access all Kubernetes secrets in your cluster.
   1. Navigate to the `templates` directory and list available files.
      ```
      cd ./templates && ls
      ```
   2. Open the `provisioner-sa.yaml` file and look for the `ibmcloud-object-storage-secret-reader` ClusterRole definition.
   3. Add the name of the secret that you created earlier to the list of secrets that the plug-in is authorized to access in the `resourceNames` section.
      ```
      kind: ClusterRole
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: ibmcloud-object-storage-secret-reader
      rules:
      - apiGroups: [""]
        resources: ["secrets"]
        resourceNames: ["<secret_name1>","<secret_name2>"]
        verbs: ["get"]
      ```
   4. Save your changes.
   5. Navigate back to the `ibm-object-storage-plugin` directory.
   6. Go back to **Installing the Chart** section and continue with chart installation.

### Verifying the Chart

1. Verify that the IBM Cloud Object Storage plug-in is installed correctly.
   ```
   kubectl get pod -n <namespace> -o wide | grep object
   ```
   Example output:
   ```
   $ kubectl get pods -n ibm-object-s3fs -o wide | grep object
   ibmcloud-object-storage-driver-nss6g              1/1     Running   0          2m7s   10.216.37.8      10.216.37.8    <none>           <none>
   ibmcloud-object-storage-driver-qsnh8              1/1     Running   0          2m7s   10.216.37.14     10.216.37.14   <none>           <none>
   ibmcloud-object-storage-plugin-7644559d65-4b2dr   1/1     Running   0          2m7s   172.30.207.136   10.216.37.14   <none>           <none>
   ```
   The installation is successful when you see one `ibmcloud-object-storage-plugin` pod and one or more `ibmcloud-object-storage-driver` pods. The number of `ibmcloud-object-storage-driver` pods equals the number of worker nodes in your cluster. All pods must be in a `Running` state for the plug-in to function properly. If the pods fail, run `kubectl describe pod -n <namespace> <pod_name>` to find the root cause for the failure.

2. Verify that the storage classes are created successfully. Note that this output varies depending on the type of cluster you use.
   ```
   kubectl get storageclass | grep 'ibmc-s3fs'
   ```
   Example output in IBM Cloud Kubernetes Service:
   ```
   ibmc-s3fs-cold-cross-region            ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-cold-regional                ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-flex-cross-region            ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-flex-perf-cross-region       ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-flex-perf-regional           ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-flex-regional                ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-standard-cross-region        ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-standard-perf-cross-region   ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-standard-perf-regional       ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-standard-regional            ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-vault-cross-region           ibm.io/ibmc-s3fs   8m
   ibmc-s3fs-vault-regional               ibm.io/ibmc-s3fs   8m
   ```

## Removing the Chart
If you do not want to provision and use IBM Cloud Object Storage in your cluster, you can uninstall the Helm chart.

**Note:** Removing the plug-in does not remove existing PVCs, PVs, or data. When you remove the plug-in, all the related pods and daemon sets are removed from your cluster. You cannot provision new IBM Cloud Object Storage for your cluster or use existing PVCs and PVs after you remove the plug-in, unless you configure your app to use the IBM Cloud Object Storage API directly.

* Go to **IBM Cloud Kubernetes Service** for removing chart from IKS Cluster

### IBM Cloud Kubernetes Service

1. Find the installation name of your Helm chart.

     ```
     helm ls --all --all-namespaces | grep ibm-object-storage-plugin
     ```

2. Delete the IBM Cloud Object Storage plug-in by removing the Helm chart. Here, `<helm_chart_namespace>` is the namespace where your chart is deployed.

     ```
     helm delete <helm_chart_name> -n <helm_chart_namespace>
     ```

3. Remove the `ibmc` Helm plug-in.

   1. Remove the plug-in.

      ```
      helm plugin remove ibmc
      ```
   2. Verify that the `ibmc` plug-in is removed.

      ```
      helm plugin list
      ```
      Example output:

      ```
      NAME    VERSION    DESCRIPTION
      ```
      The `ibmc` plug-in is removed successfully if the `ibmc` plug-in is not listed in your CLI output.


### Verify removal of chart

**Verify that the IBM Cloud Object Storage pods are removed.**

   ```
   kubectl get pods -n <namespace> | grep object-storage
   ```
   The removal of the pods is successful if no pods are displayed in your CLI output.

**Verify that the storage classes are removed.**

   ```
   kubectl get storageclasses | grep 'ibmc-s3fs'
   ```
   The removal of the storage classes is successful if no storage classes are displayed in your CLI output.

## Use Custom CA Bundle

**Note:** We need to add service URL and service IP to `/etc/hosts` of each worker node.

1. Get the service cluster IP
2. On each worker node add to /etc/hosts

Example

```
$ kubectl get svc minio-ibm-minio-svc
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
minio-ibm-minio-svc   ClusterIP   172.30.64.110   <none>        9000/TCP   2d6h

```
Add to /etc/hosts

```
<Service Cluster IP>   <service name>.<namespace>.svc.cluster.local
```

```
172.30.64.110  minio-ibm-minio-svc.zen.svc.cluster.local
```

**How to use CA  Bundle with IBM Cloud Object Storage Plug-in**

  Once you have the CA Bundle ready, pass the ca-bundle key in the cos secret with parameter `ca-bundle-crt` along with `access-key` and `secret-key`.

   Sample Secret:

   ```
	apiVersion: v1
	kind: Secret
	type: ibm/ibmc-s3fs
	metadata:
  	  name: test-secret
  	  namespace: <NAMESPACE_NAME>
	data:
  	  access-key: <access key encoded in base64 (when not using IAM OAuth)>
	  secret-key: <secret key encoded in base64 (when not using IAM OAuth)>
	  api-key: <api key encoded in base64 (for IAM OAuth)>
 	  service-instance-id: <service-instance-id encoded in base64 (for IAM OAuth + bucket creation)>
      ca-bundle-crt: < TLS Public cert bundles encoded in base64>
  ```

   Create PVC by providing COS-Service name and COS-Service namespace

   Sample  PVC template:

   ```
   kind: PersistentVolumeClaim
   apiVersion: v1
   metadata:
     name: s3fs-test-pvc
     namespace: <NAMESPACE_NAME>
     annotations:
       volume.beta.kubernetes.io/storage-class: "ibmc-s3fs-standard"
       ibm.io/auto-create-bucket: "true"
       ibm.io/auto-delete-bucket: "false"
       ibm.io/bucket: "<BUCKET_NAME>"
       ibm.io/object-path: ""    # Bucket's sub-directory to be mounted (OPTIONAL)
       ibm.io/region: "us-standard"
       ibm.io/secret-name: "test-secret"
       ibm.io/stat-cache-expire-seconds: ""   # stat-cache-expire time in seconds; default is no expire.
       ibm.io/cos-service: <COS SERVICE NAME>
       ibm.io/cos-service-ns: <NAMESPACE WHERE COS SERVICE IS CREATED>
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 8Gi # fictitious value

  ```
## Installing in an airgap environment using a bastion host

General guidance on installing in airgap environments/ setting up bastion host can be found below. This document provides details of installation via a bastion host, for other setups refer to the general guidance.
[bastion setup](https://github.com/ibm-cloud-architecture/terraform-openshift4-vcd/tree/master/docs#perform-bastion-install)
[IBM Cloud Pak foundational services](https://www.ibm.com/docs/en/cpfs?topic=operator-installing-foundational-services-offline-airgap)

This procedure will mirror required container images from the IBM entitled registry into a RedHat Openshift cluster, then install the product helm chart using those images having configured the cluster to use the images from the mirrored location.

Run the following steps on the bastion host. It must be a Linux host. Windows is not supported using this method.

* Install [cloudctl](https://github.com/IBM/cloud-pak-cli)
```
wget https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz
tar xf cloudctl-linux-amd64.tar.gz
chmod 755 cloudctl-linux-amd64
mv cloudctl-linux-amd64 /usr/local/bin/cloudctl
cloudctl version
```
* Install `oc`
```
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.5/openshift-client-linux.tar.gz
tar xf openshift-client-linux.tar.gz oc
mv oc /usr/local/bin/
oc version
```

* Follow this [link](https://github.com/ibm-cloud-architecture/terraform-openshift4-vcd#high-level-steps-for-setting-up-shared-mirror-registry-for-airgap-install-skip-this-if-you-if-you-have-a-mirror-registry-already-setup-with-the-ocp-images-mirrored ) to setup shared mirror registry for airgap
* Mirroring the images [here](https://docs.openshift.com/container-platform/4.6/installing/installing-mirroring-installation-images.html)

* Login to the Openshift cluster that will host the mirrored images with cluster-admin privileges
```
oc login ...
```
* Confirm whether the container registry is accessible
```
oc get routes -n openshift-image-registry
```
* If `no resources` are found, create a route to provide external access to the registry
```
oc patch configs.imageregistry.operator.openshift.io/cluster \
  --patch '{"spec":{"defaultRoute":true}}' --type=merge
```

## Using the airgap scripts to create image registry and mirror images once bastion host and cluster are ready

References -
https://github.ibm.com/CloudPakOpenContent/cloud-pak-launch-cli
https://github.ibm.com/IBMPrivateCloud/cloud-pak-airgap-cli

1. Follow the instructions as below to create mirror registry and mirror images

    i. download case from cloud-pak repo 
    
    **Note** - change the `ibm-object-storage-plugin-1.1.2.tgz` to the required / latest version.

    ```
    cloudctl case save --case https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-object-storage-plugin-1.1.2.tgz --outputdir ./offline
    ```
    Expected o/p 
    ```
    #  cloudctl case save --case https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-object-storage-plugin-1.1.2.tgz --outputdir ./offline
    Downloading and extracting the CASE ...
    - Success
    Retrieving CASE version ...
    - Success
    Validating the CASE ...
    Validating the signature for the ibm-object-storage-plugin CASE...
    - Success
    Creating inventory ...
    - Success
    Finding inventory items
    - Success
    Resolving inventory items ...
    Parsing inventory items
    - Success
    ```

    ii. navigate to airgap case directory
    
    ```
    cd ./offline
    tar -xvzf ibm-object-storage-plugin-1.1.2.tgz
    cd ibm-object-storage-plugin/inventory/ibmObjectStoragePlugin/files
    ```

    iii. initialize the mirror registry

    ```
    # ./airgap.sh registry service init -u test_user -p simplepassword
    [INFO] Initializing /tmp/docker-registry/data
    [INFO] Initializing /tmp/docker-registry/auth
    [INFO] Initializing /tmp/docker-registry/certs
    [INFO] Creating /tmp/docker-registry/auth/htpasswd
    Adding password for user test_user
    [INFO] Generating self-sign certificate
    Generating RSA private key, 4096 bit long modulus (2 primes)
    .............................................................................++++
    .......................................++++
    e is 65537 (0x010001)
    Generating a RSA private key
    .........................++++
    ...........................................................................................................................................................................................................++++
    writing new private key to '/tmp/docker-registry/certs/server.key'
    -----
    Signature ok
    subject=C = US, ST = New York, L = Armonk, O = IBM Cloud Pak, CN = bastion-vdc-qc-objectairgap
    Getting CA Private Key
    ```

    iv. start the registry service
    ```
    ./airgap.sh registry service start
    [INFO] Container engine: /usr/bin/podman
    [INFO] Starting registry
    Trying to pull docker.io/library/registry:2.6...
    Getting image source signatures
    Copying blob 470e22cd431a done  
    Copying blob 1048a0cdabb0 done  
    Copying blob ba51a3b098e6 done  
    Copying blob 486039affc0a done  
    Copying blob ca5aa9d06321 done  
    Copying config 10b45af23f done  
    Writing manifest to image destination
    Storing signatures
    b9571e1d4230ab05d047f89e5a3dc52dbd53429e01de8dd28e06355810bd9fee
    [INFO] Registry service started at bastion-vdc-qc-objectairgap:5000
    ```
    
    ```
    # podman ps
    CONTAINER ID  IMAGE                              COMMAND               CREATED        STATUS            PORTS                   NAMES
    5e6d48ecf858  docker.io/library/registry:latest  /etc/docker/regis...  46 hours ago   Up 42 hours ago   0.0.0.0:5004->5000/tcp  registry123
    b0d9a54687c6  docker.io/library/registry:2.6     /etc/docker/regis...  6 seconds ago  Up 6 seconds ago  0.0.0.0:5000->5000/tcp  docker-registry
    ```

    **Note** - the mirror registry takes the hostname of the machine on which scripts are sitting as the registry name by default.

    v. create secret to access mirrored registry 

    **Note** - NOTE: Secret name should be same as the registry name created in above step, here it is hostname of the machine.

    ```
    # ./airgap.sh registry secret --create -u test_user -p simplepassword bastion-vdc-qc-objectairgap:5000
    [INFO] Creating registry authencation secret for bastion-vdc-qc-objectairgap:5000
    [INFO] Registry secret created in /root/.airgap/secrets/bastion-vdc-qc-objectairgap:5000.json
    [INFO] Done
    ```

    * list the secrets
    ```
    # ./airgap.sh registry secret --list
    localhost:5000
    july30:5000
    bastion-vdc-qc-objectairgap:5000
    ```

    vi. check the registries available for mirroring images
    
    ```
    ./airgap.sh image mirror --dir ./offline --to-registry bastion-vdc-qc-objectairgap:5000 --show-registries
    
    [INFO] Processing CASE archive directory: ./offline
    [INFO] Copying image CSV file at ./offline/ibm-object-storage-plugin-1.1.2-images.csv to /tmp/airgap_202107304819/ibm-object-storage-plugin-1.1.2-images.csv temporarily
    [INFO] Creating a CSV file of mirrored images at ./offline/bastion-vdc-qc-objectairgap/ibm-object-storage-plugin-1.1.2-images.csv-mirrored-images.csv
    [INFO] Processing image CSV file at /tmp/airgap_202107304819/ibm-object-storage-plugin-1.1.2-images.csv
    [INFO] removing temp /tmp/airgap_202107304819/ibm-object-storage-plugin-1.1.2-images.csv images.csv file
    [INFO] Generating image mapping file /tmp/airgap_image_mapping_1sSB1VeHc
    [INFO] Registries that would be used in this action
    docker.io
    bastion-vdc-qc-objectairgap:5000
    ```

    vii. apply image policy for the registry

    ```
    # ./airgap.sh cluster apply-image-policy  --name case-app --dir ./offline --registry bastion-vdc-qc-objectairgap:5000
    [INFO] Processing CASE archive directory: ./offline
    [INFO] Copying image CSV file at ./offline/ibm-object-storage-plugin-1.1.2-images.csv to /tmp/airgap_202107305412/ibm-object-storage-plugin-1.1.2-images.csv temporarily
    [INFO] Processing image CSV file at /tmp/airgap_202107305412/ibm-object-storage-plugin-1.1.2-images.csv
    [INFO] removing temp /tmp/airgap_202107305412/ibm-object-storage-plugin-1.1.2-images.csv images.csv file
    [INFO] Generating image mapping file /tmp/airgap_image_mapping_ZKNMRt2eF
    [INFO] Generating image content source policy
    ---
    apiVersion: operator.openshift.io/v1alpha1
    kind: ImageContentSourcePolicy
    metadata:
      name: case-app
    spec:
      repositoryDigestMirrors:
      - mirrors:
        - bastion-vdc-qc-objectairgap:5000/ibmcom
        source: docker.io/ibmcom
    ---
    [INFO] Applying image content source policy
    oc apply  -f "/tmp/airgap_image_policy_n6HNHhV20"
    imagecontentsourcepolicy.operator.openshift.io/case-app created
    ```

    viii. update pull secret

    ```
    # ./airgap.sh cluster update-pull-secret --registry bastion-vdc-qc-objectairgap:5000
    [INFO] Retrieving cluster pull secret
    [INFO] Retrieving target registry authentication secret
    [INFO] Merging cluster pull secret
    [INFO] Applying image content source policy
    oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=/tmp/airgap_pull_secret_McKKYaFbZ 
    secret/pull-secret data updated
    ```

    ix. add ca-cert

    ```
    # ./airgap.sh cluster add-ca-cert --registry bastion-vdc-qc-objectairgap:5000
    [INFO] Extracting certificate authority from bastion-vdc-qc-objectairgap:5000 ...
    [INFO] Certificate authority saved to /root/.airgap/certs/bastion-vdc-qc-objectairgap:5000-ca.crt
    [INFO] Creating configmap airgap-trusted-ca
    oc -n openshift-config create configmap airgap-trusted-ca --from-file=bastion-vdc-qc-objectairgap..5000=/root/.airgap/certs/bastion-vdc-qc-objectairgap:5000-ca.crt 
    configmap/airgap-trusted-ca created
    [INFO] Updating cluster image configuration
    E0730 07:57:03.682913   71871 request.go:1001] Unexpected error when reading response body: unexpected EOF
    E0730 07:57:03.683047   71871 request.go:1001] Unexpected error when reading response body: unexpected EOF
    E0730 07:57:03.683085   71871 request.go:1001] Unexpected error when reading response body: unexpected EOF
    image.config.openshift.io/cluster patched
    ```

    x. **Mirror the images**

    ```
    # ./airgap.sh image mirror --dir ./offline --to-registry bastion-vdc-qc-objectairgap:5000
    
    [INFO] Generating auth.json
    [INFO] Processing CASE archive directory: ./offline
    [INFO] Copying image CSV file at ./offline/ibm-object-storage-plugin-1.1.2-images.csv to /tmp/airgap_202107301005/ibm-object-storage-plugin-1.1.2-images.csv temporarily
    [INFO] Updating a CSV file of mirrored images at ./offline/bastion-vdc-qc-objectairgap/ibm-object-storage-plugin-1.1.2-images.csv-mirrored-images.csv
    registry,image_name,tag,digest,mtype,os,arch,variant,insecure,digest_source,image_type,groups
    docker.io,ibmcom/ibmcloud-object-storage-plugin,1.8.30,sha256:4adddd3d619c056ed6fd3dc00864e4b7af140dd731557c2e64bfd6ced4232bbf,IMAGE,linux,amd64,"",0,CASE,"",""
    docker.io,ibmcom/ibmcloud-object-storage-driver,1.8.30,sha256:324787a10da384bb7bb441538eb65846c9df57bfd0e8a37a2f3efaeb423c2bc9,IMAGE,linux,amd64,"",0,CASE,"",""
    [INFO] Processing image CSV file at /tmp/airgap_202107301005/ibm-object-storage-plugin-1.1.2-images.csv
    [INFO] removing temp /tmp/airgap_202107301005/ibm-object-storage-plugin-1.1.2-images.csv images.csv file
    [INFO] Generating image mapping file /tmp/airgap_image_mapping_abdupHqsP
    [INFO] Start mirroring CASE images ...
    [INFO] Found 2 images
    [INFO] Mirroring /tmp/airgap_image_mapping_abdupHqsP
    oc image mirror -a "/root/.airgap/auth.json" -f "/tmp/airgap_image_mapping_abdupHqsP" --filter-by-os '.*' --insecure 
    bastion-vdc-qc-objectairgap:5000/
      ibmcom/ibmcloud-object-storage-driver
        blobs:
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:eaae3e91ee4d2424372eb341d21f0ab6f1374cf1b642c913f461aa6a9ea32fef 179B
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:b21b7ee65320f553d8b2f85d46c69becf24619a68458a611f99503ae07cb3654 1.02KiB
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:33a7230a3dc0471cc792f835b46b0027ba7d293aa1a6d19cf517c89cdf989e66 1.659KiB
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:a4360c9d581f8fbbf5d8908ac0b6d4508f3ac6d6f7a915b1fed827cc82411243 1.7KiB
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:5a141268e47d7782dc9c9696f41152843c28665a4f0526cd5bc30b8958b57a92 7.454KiB
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:298afcd44884d2419d40b2810abab309f99cf7a0cb62f8a447fd34df9e26daf4 11.41KiB
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:c5a0d42ee9349c58d9bb0db4e6726b43b60ca99e5fd51f707269a53d54533677 1.992MiB
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:d46e034e2deb9d48751bc953bcd4ca3a9c8cac17383ef2e1af88af50f6e930d9 14.86MiB
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:300962fbe887a70ceeecaceec70ac4c17e908a66b4c6ef2ee663e3da775ed5cf 18.44MiB
          docker.io/ibmcom/ibmcloud-object-storage-driver sha256:42f70057e3674282915517b75f1045a0e0e82567174d04625632952c06f324c5 37.66MiB
        manifests:
          sha256:324787a10da384bb7bb441538eb65846c9df57bfd0e8a37a2f3efaeb423c2bc9 -> 1.8.30
      ibmcom/ibmcloud-object-storage-plugin
        blobs:
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:63a06520afdb4345c25d3599ccf9dd33b025460ff62dc4096f87e07d25e3fa1e 131B
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:a4360c9d581f8fbbf5d8908ac0b6d4508f3ac6d6f7a915b1fed827cc82411243 1.7KiB
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:e021e11f679528db35c8a1c93745c0423e2dac78866964ba9c218885e8d2f0d2 7.45KiB
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:5602055f0e819ee2b8d3e1bc8e8932a29a33dcf6773bba3ec509d143dc1fc48e 11.59KiB
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:0eab0e9051c92465535f31b7bebc36aa2ea318f1d78a62474ec3eb844eb3e0f9 131.5KiB
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:6a6822b852cea4cef8e717c761a03dec51941994b2d660599a90a812aff205cd 8.049MiB
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:0f167305315b1ecf14288ee8a864e9c35210813edaaf561be9b6055175812be8 19.22MiB
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:ac7f3a77454f00a444a11f7de28328ee48aa7f6f0a1a819550b0de37495c9c7d 24.57MiB
          docker.io/ibmcom/ibmcloud-object-storage-plugin sha256:42f70057e3674282915517b75f1045a0e0e82567174d04625632952c06f324c5 37.66MiB
        manifests:
          sha256:4adddd3d619c056ed6fd3dc00864e4b7af140dd731557c2e64bfd6ced4232bbf -> 1.8.30
      stats: shared=2 unique=15 size=125MiB ratio=0.70
    
    phase 0:
      bastion-vdc-qc-objectairgap:5000 ibmcom/ibmcloud-object-storage-plugin blobs=9 mounts=0 manifests=1 shared=2
    phase 1:
      bastion-vdc-qc-objectairgap:5000 ibmcom/ibmcloud-object-storage-driver blobs=10 mounts=2 manifests=1 shared=2
    
    info: Planning completed in 490ms
    uploading: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-plugin sha256:6a6822b852cea4cef8e717c761a03dec51941994b2d660599a90a812aff205cd 8.049MiB
    uploading: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-plugin sha256:0eab0e9051c92465535f31b7bebc36aa2ea318f1d78a62474ec3eb844eb3e0f9 131.5KiB
    uploading: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-plugin sha256:ac7f3a77454f00a444a11f7de28328ee48aa7f6f0a1a819550b0de37495c9c7d 24.57MiB
    uploading: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-plugin sha256:0f167305315b1ecf14288ee8a864e9c35210813edaaf561be9b6055175812be8 19.22MiB
    uploading: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-plugin sha256:42f70057e3674282915517b75f1045a0e0e82567174d04625632952c06f324c5 37.66MiB
    sha256:4adddd3d619c056ed6fd3dc00864e4b7af140dd731557c2e64bfd6ced4232bbf bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-plugin:1.8.30
    mounted: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-driver sha256:42f70057e3674282915517b75f1045a0e0e82567174d04625632952c06f324c5 37.66MiB
    uploading: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-driver sha256:300962fbe887a70ceeecaceec70ac4c17e908a66b4c6ef2ee663e3da775ed5cf 18.44MiB
    uploading: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-driver sha256:d46e034e2deb9d48751bc953bcd4ca3a9c8cac17383ef2e1af88af50f6e930d9 14.86MiB
    uploading: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-driver sha256:c5a0d42ee9349c58d9bb0db4e6726b43b60ca99e5fd51f707269a53d54533677 1.992MiB
    sha256:324787a10da384bb7bb441538eb65846c9df57bfd0e8a37a2f3efaeb423c2bc9 bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-driver:1.8.30
    info: Mirroring completed in 5.22s (25.07MB/s)
    ```

2. Now the images got mirrored, update the mirrored images in values.yaml of s3fs helm charts and install the charts.

    ```
    cd ./offline/charts/
    tar -xvzf ibm-object-storage-plugin-2.1.2.tgz 
    cd ibm-object-storage-plugin
    ```
    
    * update the publicRegistry in values.yaml with manifests of mirrored images
    
    ```
    pluginImage:
        ibmContainerRegistry: registry1.example.com:5000/ibmcom/ibmcloud-object-storage-plugin@sha256:b5aedc1e095733a799ef10a272b3f97ec4226448d981ac5e4d0512ad25be8333
        publicRegistry: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-plugin@sha256:4adddd3d619c056ed6fd3dc00864e4b7af140dd731557c2e64bfd6ced4232bbf
      driverImage:
        ibmContainerRegistry: icr.io/ibm/ibmcloud-object-storage-driver@sha256:b257da723ec6234128fc5dbeeb4329c030126d392af046740fa3aa7d49a377a9
        publicRegistry: bastion-vdc-qc-objectairgap:5000/ibmcom/ibmcloud-object-storage-driver@sha256:324787a10da384bb7bb441538eb65846c9df57bfd0e8a37a2f3efaeb423c2bc9
    
    ```

3. Install helm charts

```
# helm ibmc install ibm-object-storage-plugin ./ --set license=true
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /opt/terraform/installer/objectairgap/auth/kubeconfig
Helm version: WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /opt/terraform/installer/objectairgap/auth/kubeconfig
v3.6.3+gd506314
Checking cluster type
Fetching WORKER OS details ...
Installing the Helm chart...
PROVIDER: RHOCP
WORKER_OS: redhat
PLATFORM: openshift
KUBE_DRIVER_PATH: /etc/kubernetes
CONFIG_BUCKET_ACCESS_POLICY: false
Chart: ./
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /opt/terraform/installer/objectairgap/auth/kubeconfig
NAME: ibm-object-storage-plugin
LAST DEPLOYED: Fri Jul 30 08:13:10 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing: ibm-object-storage-plugin.   Your release is named: ibm-object-storage-plugin

1. Verify that the storage classes are created successfully:

   $ oc get storageclass | grep 'ibmc-s3fs'

2. Verify that plugin pods are in "Running" state:

   $ oc get pods -n default -o wide | grep object

   The installation is successful when you see one `ibmcloud-object-storage-plugin` pod and one or more `ibmcloud-object-storage-driver` pods.
   The number of `ibmcloud-object-storage-driver` pods equals the number of worker nodes in your cluster. All pods must be in a `Running` state
   for the plug-in to function properly. If the pods fail, run `oc describe pod -n default <pod_name>`
   to find the root cause for the failure.

```

**Sample pvc yaml**

```
# cat pvc.yaml 
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvctest
  namespace: default
  annotations:
    ibm.io/auto-create-bucket: "true"
    ibm.io/auto-delete-bucket: "false"
    ibm.io/bucket: "toricpchangei2"
    #ibm.io/object-path: ""
    ibm.io/secret-name: "secret-default"
    ibm.io/auto_cache: "true"
    ibm.io/tls-cipher-suite: "default"
    ibm.io/endpoint: "https://s3.direct.us.cloud-object-storage.appdomain.cloud"
    ibm.io/region: us-standard
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 8Gi # Enter a fictitious value
  storageClassName: ibmc-s3fs-cos
```

**Sample pod yaml**

```
# cat pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: pod-pvctest
  namespace: default
spec:
  containers:
  - name: s3fs-test-container-two
    image:  bastion-vdc-qc-objectairgap:5004/ibmcom/ibmcloud-object-storage-driver:1.8.31 
    volumeMounts:
    - mountPath: "/mnt/mymount"
      name: s3fs-test-volume
  volumes:
  - name: s3fs-test-volume
    persistentVolumeClaim:
      claimName: pvctest
```


## Configuration
Review the parameters that you can configure during the IBM Cloud Object Storage plug-in installation.

|Parameter|How used|Example|Default value|
|---------|---------------|-------------------|----------|
|`maxUnavailableNodeCount`|The number of worker nodes that can be unavailable during an update of the IBM Cloud Object Storage plug-in. |1|1|
|`image.pluginImage`|The container registry to pull plug-in image from . For RHCOS image will be pulled from `ibmcom` namespace and from `icr.io/ibm/` namespace for IKS.| RHCOS: `ibmcom/ibmcloud-object-storage-plugin`, IKS: `icr.io/ibm/ibmcloud-object-storage-plugin` | RHCOS: `ibmcom/ibmcloud-object-storage-plugin`, IKS: `icr.io/ibm/ibmcloud-object-storage-plugin` |
|`image.driverImage`|The container registry to pull driver image from . For RHCOS image will be pulled from `ibmcom` namespace and from `icr.io/ibm/` namespace for IKS.| RHCOS: `ibmcom/ibmcloud-object-storage-driver`, IKS: `icr.io/ibm/ibmcloud-object-storage-driver` | RHCOS: `ibmcom/ibmcloud-object-storage-driver`, IKS: `icr.io/ibm/ibmcloud-object-storage-driver` |
|`iamEndpoint`|The IBM Cloud Identity and Access Management API endpoint that you want to use. |`https://iam.cloud.ibm.com`|`https://iam.cloud.ibm.com`|
|`cos.endpoint`|The s3 API endpoint for your Cloud Object Storage instance that you want to use. The API endpoint varies depending on the type of Cloud Object Storage that you use. |IBM Cloud Object Storage service: `https://s3.us.cloud-object-storage.appdomain.cloud`, Minio: `http://minio-service.default:9000`|`https://<Endpoint URL>`|
|`cos.storageClass`|The name of the storage class which refers to `Location + Storage Class` / `LocationConstraint` as discussed [here](https://cloud.ibm.com/docs/services/cloud-object-storage/basics/classes.html#locationconstraint) |`standard`| `<StorageClass>`|

## Tips:
- By default, object-storage plugin storageclasses are created with `"AESGCM"` as `tls-cipher-suite` for `Debian` family's operating systems and `"ecdhe_rsa_aes_128_gcm_sha_256"` as `tls-cipher-suite` for `Red Hat` family's operating systems. Cipher suite can be overridden from the PVC using `ibm.io/tls-cipher-suite: "<TLS_CIPHER_SUITE>"` under `annotations` section.

## Limitations
- `runAsUser` and `fsGroup` IDs should be same to provide non-root user access to COS volume mount.
- **Platform support:** This Helm chart is validated to run in:
  - IBM Cloud Kubernetes Service
  - Red Hat OpenShift on IBM Cloud
  - Red Hat Enterprise Linux CoreOS (RHCOS)

## Documentation
Review the following links for further information about IBM Cloud Object Storage.

- [General information about IBM Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage).
- [Create your first persistent volume claim (PVC)](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#add_cos) for your app that points to a bucket in Cloud Object Storage.
- [Use Cloud Object Storage in a Kubernetes stateful set](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#cos_statefulset).

