# IBM Cloud Object Storage Plug-in
This Helm chart installs the IBM Cloud Object Storage plug-in in a Kubernetes cluster. In IBM Cloud Kubernetes Service, the Helm chart is deployed to the `kube-system` namespace of your cluster.

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
  - Follow the [instructions](https://cloud.ibm.com/docs/containers?topic=containers-helm#install_v3) to install the Helm client v3 on your local machine. If helm v2 is installed on your local machine or on your cluster, then it is strongly recommended to [migrate from helm v2 to v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#migrate_v3).

- **IBM Cloud Private (ICP)**:
  - Create or use an existing [IBM Cloud Private cluster](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/installing/install.html).
  - Install the [IBM Cloud Private CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/install_cli.html) and the [Kubernetes CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/install_kubectl.html).
  - [Log in to your cluster](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/manage_cluster/cli_commands.html#login).
  - Install the [Helm CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/app_center/create_helm_cli.html) on your local machine.
  - For airgap/offline scenario, set the global scope for uploaded images "ibmcloud-object-storage-plugin" and "ibmcloud-object-storage-driver"


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
    readOnlyRootFilesystem: false
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
   - **Option 1:** [Create an IBM Cloud Object Storage service instance in IBM Cloud](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#create_cos_service). The service provides a public and a private service endpoint. In IBM Cloud Kubernetes Service, the private endpoint is used by default. However, you can specify the public service endpoint in your PVC instead. In IBM Cloud Private, you must have outbound connectivity for your cluster to access the public service endpoint. To connect to the private service endpoint, you must be on the IBM network, for example by using a VPN gateway.
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
* Go to **IBM Cloud Private** for deployment on ICP Cluster

### _IBM Cloud Kubernetes Service_

**Note**: This chart supports only `Helm V3` and will not work with `Helm V2`

1. Verify that `helm v3` is installed on your local machine.

   ```
   helm version --short
   v3.0.2+g19e47ee
   ```

   **Tip:** If helm v2 is installed on your local machine or on your cluster, then first [migrate from helm v2 to v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#migrate_v3).

2. Add the IBM Cloud Helm repository `ibm-charts` to your cluster.

   ```
   helm repo add ibm-charts https://icr.io/helm/ibm-charts
   ```

3. Update the Helm repo to retrieve the latest version of all Helm charts in this repo.

   ```
   helm repo update
   ```

4. Download the Helm chart and unpack the chart in your current directory. Then, navigate to the `ibm-object-storage-plugin` directory.

   ```
   helm fetch --untar ibm-charts/ibm-object-storage-plugin && cd ibm-object-storage-plugin
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

    Example: Install chart from helm registry, without any limitation to access specific Kubernetes secrets:

    ```
     helm ibmc install ibm-object-storage-plugin ibm-charts/ibm-object-storage-plugin --set license=true
    ```

    Example: Install chart from local path, with a limitation to access the Cloud Object Storage's secrets only, as described in the `Optional: Limit secret access` section at the bottom:

    ```
    helm ibmc install ibm-object-storage-plugin ./ --set license=true
    ```
    
8. Go to **Limit secret access**


### _IBM Cloud Private_

**Note**: This chart supports only `Helm V3` and will not work with `Helm V2`

1. Verify that `helm v3` is installed on your local machine.

   **Tip:** If helm v2 is installed on your local machine or on your cluster, then first [migrate from helm v2 to v3](https://cloud.ibm.com/docs/containers?topic=containers-helm#migrate_v3).

2. Log on to IBM Cloud Private cluster

   ```
   cloudctl login -a https://<Master Node IP>:8443 --skip-ssl-validation
   ```

3. Add the internal IBM Cloud Private Helm repository called `mgmt-charts`.

   ```
   helm repo add mgmt-charts https://<Master Node IP>:8443/mgmt-repo/charts --ca-file $HELM_HOME/ca.pem --cert-file $HELM_HOME/cert.pem --key-file $HELM_HOME/key.pem
   "mgmt-charts" has been added to your repositories

   ```

4. List the repositories.

   ```
   # helm repo list
   NAME           URL                                             
   stable         https://kubernetes-charts.storage.googleapis.com
   local          http://127.0.0.1:8879/charts                    
   mgmt-charts    https://<Master Node IP>:8443/mgmt-repo/charts  
   ```
5. Download the Helm chart and unpack the chart in your current directory. Then, navigate to the ibm-object-storage-plugin directory.

   ```
   helm fetch --untar mgmt-charts/ibm-object-storage-plugin && cd ibm-object-storage-plugin
   ```

6. To limit the IBM Cloud Object Storage plug-in access to Kubernetes secrets, go to **Optional: Limit secret access** ; otherwise, if there is no limitation to be set, continue with next step.

7. Replace `<s3_endpoint>` with the Cloud Object Storage s3 endpoint that you want to use. For [AWS S3](https://docs.aws.amazon.com/general/latest/gr/rande.html) endpoints provide `Region` for `<storageclass_name>` and in case of [IBM COS](https://cloud.ibm.com/docs/services/cloud-object-storage/basics/classes.html#locationconstraint) endpoints provide `Locationconstraint`. `<namespace>` is custom namespace or the predefined namespace.

     Example: Install with ibm-privileged-psp pod security policy:

     ```
     helm install ibm-object-storage-plugin ./ [--namespace <namespace>] --set license=true --set cos.endpoint=https://<s3_endpoint> --set cos.storageClass=<storageclass_name> --tls
     ```

     Example: Install with custom pod security policy:

     ```
     helm install ibm-object-storage-plugin ./ [--namespace <namespace>] --set license=true --set useCustomPSP=true --set cos.endpoint=https://<s3_endpoint> --set cos.storageClass=<storageclass_name> --tls
     ```

     Note the `useCustomPSP` flag passed to the command.

     Also add `--set workerOS=redhat` in above commands if worker node's OS is `Red Hat`. To check worker node's OS, run `kubectl get nodes -o jsonpath='{ .items[0].status.nodeInfo.osImage }{"\n"}'`

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
   ibmcloud-object-storage-driver-9n8g8                              1/1       Running   0          2m
   ibmcloud-object-storage-plugin-7c774d484b-pcnnx                   1/1       Running   0          2m
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
* Go to **IBM Cloud Private** for removing chart from ICP Cluster

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


### IBM Cloud Private

1. Find the installation name of your Helm chart.

     ```
     helm ls --all --all-namespaces --tls | grep ibm-object-storage-plugin
     ```

2.   Delete the IBM Cloud Object Storage plug-in by removing the Helm chart.

     ```
     helm delete <helm_chart_name> -n <helm_chart_namespace> --tls
     ```


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

## Configuration
Review the parameters that you can configure for IBM Cloud Private during the IBM Cloud Object Storage plug-in installation.

|Parameter|How used|Example|Default value|
|---------|---------------|-------------------|----------|
|`maxUnavailableNodeCount`|The number of worker nodes that can be unavailable during an update of the IBM Cloud Object Storage plug-in. |1|1|
|`image.pluginImage`|The container registry to pull plug-in image from . For ICP image will be pulled from `ibmcom` namespace and from `registry.bluemix.net/ibm/` namespace for IKS.| ICP: `ibmcom/ibmcloud-object-storage-plugin`, IKS: `registry.bluemix.net/ibm/ibmcloud-object-storage-plugin` | ICP: `ibmcom/ibmcloud-object-storage-plugin`, IKS: `registry.bluemix.net/ibm/ibmcloud-object-storage-plugin` |
|`image.driverImage`|The container registry to pull driver image from . For ICP image will be pulled from `ibmcom` namespace and from `registry.bluemix.net/ibm/` namespace for IKS.| ICP: `ibmcom/ibmcloud-object-storage-driver`, IKS: `registry.bluemix.net/ibm/ibmcloud-object-storage-driver` | ICP: `ibmcom/ibmcloud-object-storage-driver`, IKS: `registry.bluemix.net/ibm/ibmcloud-object-storage-driver` |
|`iamEndpoint`|The IBM Cloud Identity and Access Management API endpoint that you want to use. |`https://iam.bluemix.net`|`https://iam.bluemix.net`|
|`cos.endpoint`|The s3 API endpoint for your Cloud Object Storage instance that you want to use. The API endpoint varies depending on the type of Cloud Object Storage that you use. |IBM Cloud Object Storage service: `https://s3.us.cloud-object-storage.appdomain.cloud`, Minio: `http://minio-service.default:9000`|`https://<Endpoint URL>`|
|`cos.storageClass`|The name of the storage class which refers to `Location + Storage Class` / `LocationConstraint` as discussed [here](https://cloud.ibm.com/docs/services/cloud-object-storage/basics/classes.html#locationconstraint) |`standard`| `<StorageClass>`|

## Tips:
- By default, object-storage plugin storageclasses are created with `"AESGCM"` as `tls-cipher-suite` for `Debian` family's operating systems and `"ecdhe_rsa_aes_128_gcm_sha_256"` as `tls-cipher-suite` for `Red Hat` family's operating systems. Cipher suite can be overridden from the PVC using `ibm.io/tls-cipher-suite: "<TLS_CIPHER_SUITE>"` under `annotations` section.

## Limitations
- `runAsUser` and `fsGroup` IDs should be same to provide non-root user access to COS volume mount.
- **Platform support:** This Helm chart is validated to run in:
  - IBM Cloud Kubernetes Service
  - IBM Cloud Private with local Cloud Object Storage

## Documentation
Review the following links for further information about IBM Cloud Object Storage.

- [General information about IBM Cloud Object Storage](https://cloud.ibm.com/docs/services/cloud-object-storage?topic=cloud-object-storage-about-ibm-cloud-object-storage#about-ibm-cloud-object-storage).
- [Create your first persistent volume claim (PVC)](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#add_cos) for your app that points to a bucket in Cloud Object Storage.
- [Use Cloud Object Storage in a Kubernetes stateful set](https://cloud.ibm.com/docs/containers?topic=containers-object_storage#cos_statefulset).

