# IBM Mobile Foundation Helm Chart

## Introduction
IBM Mobile Foundation is an integrated platform that helps you extend your business to mobile devices.

IBM Mobile Foundation Platform includes a comprehensive development environment, mobile-optimized runtime middleware, a private enterprise application store, and an integrated management and analytics console, all backed by various security mechanisms.

For more information: [IBM Mobile Foundation Documentation](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/)


## Chart Details

This chart deploys following Mobile Foundation Components onto Kubernetes based on the selection:

- Server
- Push
- Analytics
- Application Center

> NOTE: This chart can be deployed more than once on the same namespace.

## Prerequisites

1. (Mandatory) In order to create Kubernetes artifacts like Secrets, Persistent Volumes (PV) and Persistent Volume Claims (PVC) on IBM Cloud Private, `kubectl` cli is required. 

	a. Install `kubectl` tooling from the IBM Cloud Private management console, click **Menu > Command Line Tools > Cloud Private CLI**.
	
	b. Expand **Install Kubernetes CLI** to download the installer by using a `curl` command. Copy and run the curl command for your operating system, then continue the installation procedure:
	
	c. Choose the curl command for the applicable operating system. For example, you can run the following command for macOS:
	
	```bash
	curl -kLo <install_file> https://<cluster ip>:<port>/api/cli/kubectl-darwin-amd64
	chmod 755 <path_to_installer>/<install_file>
	sudo mv <path_to_installer>/<install_file> /usr/local/bin/kubectl
	```
	Reference : [Installing the Kubernetes CLI (kubectl)](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/manage_cluster/install_kubectl.html)
	
2. (Mandatory) A pre-configured database is required to store the technical data of the Mobile Foundation Server and Application Center components. 

   You must use one of the below supported DBMS:
   
     1. **IBM DB2** 
     2. **MySQL**
     3. **Oracle**
    
   Follow the below steps, if you are using the **Oracle** or **MySQL** database -
   
      - The JDBC drivers for Oracle and MySQL are not included in the Mobile Foundation installer. Make sure that you have the JDBC driver (For MySQL - use the Connector/J JDBC driver,  For Oracle - use the Oracle thin JDBC driver). Create a Mounted Volume and place the JDBC driver in the location `/nfs/share/dbdrivers`
      - Create a Persistent Volume (PV) by providing the NFS host details and the path where the JDBC driver is stored. Below is a sample `PersistentVolume.yaml`
       
      ```
      cat <<EOF | kubectl apply -f -
      apiVersion: v1
      kind: PersistentVolume
      metadata:
        labels:
          name: mfppvdbdrivers
        name: mfppvdbdrivers
      spec:
        accessModes:
        - ReadWriteMany
        capacity:
          storage: 20Gi
        nfs:
          path: <nfs_path>
          server: <nfs_server>
       EOF
      ```
      > NOTE: Make sure you add the <nfs_server> and <nfs_path> entries in the above yaml. 
      
      - Create a Persistent Volume Claim (PVC) and provide the PVC name in the Helm chart while deploying. Below is a sample `PersistentVolumeClaim.yaml` -  
      ```bash 
      cat <<EOF | kubectl apply -f -
      apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: mfppvc
        namespace: my_namespace
      spec:
        accessModes:
        - ReadWriteMany
        resources:
          requests:
             storage: 20Gi
        selector:
          matchLabels:
            name: mfppvdbdrivers
        volumeName: mfppvdbdrivers
      status:
        accessModes:
        - ReadWriteMany
        capacity:
          storage: 20Gi
      EOF
      ```   
> NOTE: Make sure you add the right namespace in the above yaml.
	
3. (Mandatory) A pre-created **Login Secret** is required for Server, Analytics and Application Center console login. For example:
	
	```bash
	kubectl create secret generic serverlogin --from-literal=MFPF_ADMIN_USER=admin --from-literal=MFPF_ADMIN_PASSWORD=admin
	```

	For Analytics.

	```bash
	kubectl create secret generic analyticslogin --from-literal=MFPF_ANALYTICS_ADMIN_USER=admin --from-literal=MFPF_ANALYTICS_ADMIN_PASSWORD=admin
	```

	For Application Center.

	```bash
	kubectl create secret generic appcenterlogin --from-literal=MFPF_APPCNTR_ADMIN_USER=admin --from-literal=MFPF_APPCNTR_ADMIN_PASSWORD=admin
	```

	> NOTE: If these secrets are not provided, they are created with default username and password of admin/admin during the installation of Mobile Foundation helm chart.

4. (Optional) You can provide your own keystore and truststore to Server, Push, Analytics and Application Center deployment by creating a secret with your own keystore and truststore.

	Pre-create a secret with `keystore.jks` and `truststore.jks` along with keystore and trustore password using the literals KEYSTORE_PASSWORD and TRUSTSTORE_PASSWORD  provide the secret name in the field keystoreSecret of respective component

	Keep the files `keystore.jks`, `truststore.jks` and its passwords as below  

	For example:

	```bash
	kubectl create secret generic server --from-file=./keystore.jks --from-file=./truststore.jks --from-literal=KEYSTORE_PASSWORD=worklight --from-literal=TRUSTSTORE_PASSWORD=worklight
	```

	> NOTE: The names of the files and literals should be the same as mentioned in command above.	Provide this secret name in `keystoresSecretName` input field of respective component to override the default keystores when configuring the helm chart.
	
5. (Optional) To customise the configuration (example: modifying a log trace setting, adding a new jndi property and so on), you will have to create a configmap with the configuration XML file. This allows you to add a new configuration setting or override the existing configurations of the Mobile Foundation components.

    The custom configuration is accessed by the Mobile Foundation components through a configMap (mfpserver-custom-config) which can be created as follows -

	```bash
	kubectl create configmap mfpserver-custom-config --from-file=<configuration file in XML format>
	```
	
    The configmap created using the above command should be provided in the **Custom Server Configuration** in the Helm chart while deploying Mobile Foundation.

    Below is an example of setting the trace log specification to warning (The default setting is info) using mfpserver-custom-config configmap.

    - Sample config XML (logging.xml)

	```bash
    <server>
          <logging maxFiles="5" traceSpecification="com.ibm.mfp.*=debug:*=warning"
          maxFileSize="20" />
    </server>
	```
 
    - Creating configmap and add the same during the helm chart deployment

	```bash
    kubectl create configmap mfpserver-custom-config --from-file=logging.xml
	```

    - Notice the change in the messages.log (of Mobile Foundation components) - ***Property traceSpecification will be set to com.ibm.mfp.=debug:\*=warning.***

6. (Optional) Mobile Foundation components can be configured with hostname based Ingress for external clients to reach them using hostname. The Ingress can be secured by using a TLS private key and certificate. The TLS private key and certificate must be defined in a secret with key names `tls.key` and `tls.crt`. 

	The secret **mf-tls-secret** is created in the same namespace as the Ingress resource by using the following command:

	```bash
	kubectl create secret tls mf-tls-secret --key=/path/to/tls.key --cert=/path/to/tls.crt
	```
	
	The name of the secret is then provided in the field global.ingress.secret

7. (Optional) Mobile Foundation Server is predefined with confidential clients for Admin Service. The credentials for these clients are provided in the `mfpserver.adminClientSecret` and `mfpserver.pushClientSecret` fields. 

	These secrets can be created as follows: 
	
	```bash
	kubectl create secret generic mf-admin-client --from-literal=MFPF_ADMIN_AUTH_CLIENTID=admin --from-literal=MFPF_ADMIN_AUTH_SECRET=admin
	kubectl create secret generic mf-push-client --from-literal=MFPF_PUSH_AUTH_CLIENTID=admin --from-literal=MFPF_PUSH_AUTH_SECRET=admin
	```
	
	If the values for these fields `mfpserver.pushClientSecret` and `mfpserver.adminClientSecret` are not provided during helm chart installation, default client secret`s are created respectively with below credentials as follows:
	  
	  * `admin / nimda` for `mfpserver.adminClientSecret` 
	  * `push / hsup` for `mfpserver.pushClientSecret`
	  
8. For Analytics deployment, one can choose below options for persisting analytics data

	a) To have `Persistent Volume (PV)`  and `Persistent Volume Claim (PVC)` ready and provide PVC name in the helm chart, 
	
	For example: 
	
	Sample `PersistentVolume.yaml`
	
	 ```bash
	apiVersion: v1
	kind: PersistentVolume
	metadata:
	  labels:
	    name: mfvol
	  name: mfvol
	spec:
	  accessModes:
	  - ReadWriteMany
	  capacity:
	    storage: 20Gi
	  nfs:
	    path: <nfs_path>
	    server: <nfs_server>
	 ```
	> NOTE: Make sure you add the <nfs_server> and <nfs_path> entries in the above yaml.

	Sample `PersistentVolumeClaim.yaml`
		
	```bash
	apiVersion: v1
	kind: PersistentVolumeClaim
	metadata:
	  name: mfvolclaim
	  namespace: <namespace>
	spec:
	  accessModes:
	  - ReadWriteMany
	  resources:
	    requests:
	      storage: 20Gi
	  selector:
	    matchLabels:
	      name: mfvol
	  volumeName: mfvol
	status:
	  accessModes:
	  - ReadWriteMany
	  capacity:
	    storage: 20Gi
	```
	
	> NOTE: Make sure you add the right <namespace> in the above yaml.

	b) To choose dynamic provisioning in the chart.

9. (Mandatory) Creating **database secrets** for Server, Push and Application Center.
This section outlines the security mechanisms for controlling access to the database. Create a secret using specified subcommand and provide the created secret name under the database details.

	Run the code snippet below to create a database secret for Mobile Foundation server:

	```bash
	# Create mfpserver secret
	cat <<EOF | kubectl apply -f -
	apiVersion: v1
	data:
	 MFPF_ADMIN_DB_USERNAME: encoded_uname 
	 MFPF_ADMIN_DB_PASSWORD: encoded_password
	 MFPF_RUNTIME_DB_USERNAME: encoded_uname 
	 MFPF_RUNTIME_DB_PASSWORD: encoded_password
	 MFPF_PUSH_DB_USERNAME: encoded_uname
	 MFPF_PUSH_DB_PASSWORD: encoded_password
	kind: Secret
	metadata:
	 name: mfpserver-dbsecret
	type: Opaque
	EOF
	```
	
	Run the below code snippet to create a database secret for Application Center
	
	```bash
	# create appcenter secret
	cat <<EOF | kubectl apply -f -
	apiVersion: v1
	data:
	  MFPF_APPCNTR_DB_USERNAME: encoded_uname
	  MFPF_APPCNTR_DB_PASSWORD: encoded_password
	kind: Secret
	metadata:
	  name: appcenter-dbsecret
	type: Opaque
	EOF
	```

	> NOTE: You may encode the username and password details using the below command - 
	
	```bash
	export $MY_USER_NAME=<myuser>
	export $MY_PASSWORD=<mypassword>
	
	echo -n $MY_USER_NAME | base64
	echo -n $MY_PASSWORD | base64
	```

	This section outlines the security mechanisms for controlling access to the database. Create a secret using specified subcommand and provide the created secret name under the database details.
	
10. (Optional) A separate Database Admin secret can be provided. The user details provided in the Database Admin secret will be used to execute the  DB Initialization tasks, which would in turn create the required Mobile Foundation schema and tables in the database (if it does not exist). Through the Database Admin secret, you can control the DDL operations on your Database instance.

    If the `MFP Server DB Admin Secret` and `MFP Appcenter DB Admin Secret` details are not provided, then the default `Database Secret Name` will be used to perform DB initialization tasks.

    Run the below code snippet to create a `MFP Server DB Admin Secret` for Mobile Foundation server:

      ```bash
      # Create MFP Server Admin DB secret update the same in the Helm chart while deploying Mobile Foundation server component
      cat <<EOF | kubectl apply -f -
      apiVersion: v1
      data:
        MFPF_ADMIN_DB_ADMIN_USERNAME: encoded_uname
        MFPF_ADMIN_DB_ADMIN_PASSWORD: encoded_password
        MFPF_RUNTIME_DB_ADMIN_USERNAME: encoded_uname
        MFPF_RUNTIME_DB_ADMIN_PASSWORD: encoded_password
        MFPF_PUSH_DB_ADMIN_USERNAME: encoded_uname
        MFPF_PUSH_DB_ADMIN_PASSWORD: encoded_password
      kind: Secret
      metadata:
        name: mfpserver-dbadminsecret
      type: Opaque
      EOF
      ```
      
    Run the below code snippet to create a `MFP Appcenter DB Admin Secret` for Mobile Foundation server:      
	
      ```bash
      # Create Appcenter Admin DB secret and update the same in the Helm chart while deploying Mobile Foundation AppCenter   component
      cat <<EOF | kubectl apply -f -
      apiVersion: v1
      data:
        MFPF_APPCNTR_DB_ADMIN_USERNAME: encoded_uname
        MFPF_APPCNTR_DB_ADMIN_PASSWORD: encoded_password
      kind: Secret
      metadata:
      name: appcenter-dbadminsecret
      type: Opaque
      EOF
      ```
	
11. (Optional) Create container **Image Policy** and **Image pull secrets** when the container images are pulled from a registry that is outside the IBM Cloud Private setup's container registry (DockerHub, private docker registry, etc.)
  
	```bash
	# Create image policy
	cat <<EOF | kubectl apply -f -
	apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
	kind: ImagePolicy
	metadata:
	 name: image-policy
	 namespace: <namespace>
	spec:
	 repositories:
	 - name: docker.io/*
	   policy: null
	 - name: <container-image-registry-hostname>/*
	   policy: null
	EOF
	```	
	
	```bash	
	kubectl create secret docker-registry -n <namespace> <container-image-registry-hostname> --docker-username=<docker-registry-username> --docker-password=<docker-registry-password>
	```
	
	> NOTE: text inside < > needs to be updated with right values.
		
### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

	```bash
	apiVersion: extensions/v1beta1
	kind: PodSecurityPolicy
	metadata:
	  name: ibm-mobilefoundation-prod-psp
	  annotations:
	    apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
	    apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default 
	    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
	    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
	spec:
	  requiredDropCapabilities:
	  - ALL
	  volumes:
	  - configMap
	  - emptyDir
	  - projected
	  - secret
	  - downwardAPI
	  - persistentVolumeClaim
	  seLinux:
	    rule: RunAsAny
	  runAsUser:
	    rule: MustRunAsNonRoot
	  supplementalGroups:
	    rule: MustRunAs
	    ranges:
	    - min: 1
	      max: 65535
	  fsGroup:
	    rule: MustRunAs
	    ranges:
	    - min: 1
	      max: 65535
	  allowPrivilegeEscalation: false
	  forbiddenSysctls:
	  - "*"
	```

* Custom ClusterRole for the custom PodSecurityPolicy:

	```bash
	apiVersion: rbac.authorization.k8s.io/v1
	kind: ClusterRole
	metadata:
	  name: ibm-mobilefoundation-prod-psp-clusterrole
	rules:
	- apiGroups:
	  - extensions
	  resourceNames:
	  - ibm-mobilefoundation-prod-psp
	  resources:
	  - podsecuritypolicies
	  verbs:
	  - use
	
	```
> NOTE: It is required to create the PodSecurityPolicy only once, if the PodSecurityPolicy already exists then skip this step.

The cluster admin can either paste the above PSP and ClusterRole definitions into the create resource screen in the UI or run the following two commands:

```bash
kubectl create -f <PSP yaml file>
kubectl create clusterrole ibm-mobilefoundation-prod-psp-clusterrole --verb=use --resource=podsecuritypolicy --resource-name=ibm-mobilefoundation-prod-psp
```

you also need to create the `RoleBinding`:

```bash
kubectl create rolebinding ibm-mobilefoundation-prod-psp-rolebinding --clusterrole=ibm-mobilefoundation-prod-psp-clusterrole --serviceaccount=<namespace>:default --namespace=<namespace>
```

## Resources Required

This chart uses the following resources by default:

| Component | Requested CPU  | Requested Memory | Storage
|---|---|---|---|
| Mobile Foundation Server | **Request/Min:** 1000m CPU, **Limit/Max:** 2000m CPU  | **Request/Min:** 2048 Mi memory,**Limit/Max:** 4096 Mi memory | For database requirements, refer [Prerequisites](#Prerequisites)
| Mobile Foundation Push |  **Request/Min:** 1000m CPU, **Limit/Max:** 2000m CPU | **Request/Min:** 2048 Mi memory, **Limit/Max:** 4096 Mi memory | For database requirements, refer [Prerequisites](#Prerequisites)
| Mobile Foundation Analytics | **Request/Min:** 1000m CPU, **Limit/Max:** 2000m CPU | **Request/Min:** 2048 Mi memory, **Limit/Max:** 4096 Mi memory | A Persistent Volume. Refer [Prerequisites](#Prerequisites) for more information
| Mobile Foundation Application Center | **Request/Min:** 1000m CPU, **Limit/Max:** 2000m CPU | **Request/Min:** 2048 Mi memory, **Limit/Max:** 4096 Mi memory | For database requirements, refer [Prerequisites](#Prerequisites)


## Installing the Chart

From Commandline, you can install the chart with the release name `my-release` as follows:

```bash
helm install --name my-release stable/ibm-mobilefoundation-prod --set <stringArray> --tls
```

`<stringArray>` accepts set of key-values comma separated (For example: key1=val1,key2=val2) used by the Mobile Foundation Server deployed on the Kubernetes cluster. The [configuration](#configuration) section lists the parameters that can be configured during installation.
> **TIP**: See all the resources deployed by the chart using 

```bash
kubectl get all -l release=my-release
```

> Note: The latest Mobile Foundation on ICP package bundles the following supported software - 
> 1. IBM JRE8 SR5 FP37 (8.0.5.37)
> 2. IBM WebSphere Liberty v18.0.0.5

### Uninstalling the Chart

To uninstall/delete the helm release (say `my-release`) execute the following command:

```bash
helm delete my-release --purge --tls
```

This command removes all the Kubernetes components (except any Persistent Volume Claims (PVC)) associated with the chart. This default Kubernetes behavior ensures that the valuable data is not deleted.

## Accessing Mobile Foundation Server

From a web browser, go to the IBM Cloud Private console page and navigate to the helm releases page as follows

1. Click Menu on the Left Top of the Page.
2. Select **Workloads** > **Helm Releases**.
3. Click on the deployed **IBM Mobile Foundation** helm release.
4. Refer the **NOTES** section for the procedure to access the Mobile Foundation Server Operations Console.


## Migrate to IBM Certified Cloud Pak for Mobile Foundation Platform

With [IBM Certified Cloud Pak](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/app_center/cloud_paks_over.html), the Mobile Foundation is now available for deployment as a single helm chart. This replaces the earlier approach of using three different helm charts (viz. ibm-mfpf-server-prod, ibm-mfpf-analytics-prod and ibm-mfpf-appcenter-prod) for deploying the Mobile Foundation components.

Migrating from the old Mobile Foundation components installed as separate helm releases on ICP deployment to the new consolidated single helm chart with IBM Certified Cloud Pak is simple,

1. You may retain all the configuration parameters for Server, Push, Application Center and Analytics.
2. If the Database details are used the same as old deployment, then your new Mobile Foundation deployment (Server, Push and Application Center) will have the same data as that of the old one.
3. Notice the change in the database values to be entered. Access to the database is now controlled through secrets. Refer section-4 under [Prerequisites](#Prerequisites) to create secrets for any credentials (including Console logins, Database accounts, etc).
4. Mobile Foundation Analytics data can be retained by re-using the same Persistence Volume Claim used in the old deployment.


## Reference

[Setting up Mobile Foundation Server on IBM Cloud Private](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/bluemix/mobilefirst-server-on-icp/)
   
## Configuration

### Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| global.arch |  amd64    | amd64 worker node scheduler preference in a hybrid cluster | 3 - Most preferred (Default) |
|      |  ppcle64  | ppc64le worker node scheduler preference in a hybrid cluster | 2 - No preference (Default) |
|      |  s390x    | S390x worker node scheduler preference in a hybrid cluster | 2 - No preference (Default) |
| global.image     | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Default: IfNotPresent |
|      |  pullSecret    | Image pull secret | Required only if images are not hosted on ICP image registry |
| global.ingress | hostname | The external hostname or IP address to be used by external clients | Leave blank to default to the IP address of the cluster proxy node|
|         | secret | TLS secret name| Specifies the name of the secret for the certificate that has to be used in the Ingress definition. The secret has to be pre-created using the relevant certificate and key. Mandatory if SSL/TLS is enabled. Pre-create the secret with Certificate & Key before supplying the name here |
|         | sslPassThrough | Enable SSL passthrough | Specifies is the SSL request should be passed through to the Mobile Foundation service - SSL termination occurs in the Mobile Foundation service. Default: false |
| global.dbinit | enabled | Enable initialization of Server, Push and Application Center databases | Initializes databases and create schemas / tables for Server, Push and Application Center deployment.(Not required for Analytics). Default: true |
|  | repository | Docker image repository for database initialization | Repository of the Mobile Foundation database docker image |
|           | tag          | Docker image tag | See Docker tag description |
| mfpserver | enabled          | Flag to enable Server | true (default) or false |
| mfpserver.image | repository | Docker image repository | Repository of the Mobile Foundation Server docker image |
|           | tag          | Docker image tag | See Docker tag description |
|           | consoleSecret | A pre-created secret for login | Check Prerequisites section|
|  mfpserver.db | host | IP address or hostname of the database where Mobile Foundation Server tables need to be configured. | IBM DB2® (default). |
|                       | port | 	Port where database is setup | |
|                       | secret | A precreated secret which has database credentials| |
|                       | name | Name of the Mobile Foundation Server database | |
|                       | schema | Server db schema to be created. | If the schema already present, it will be used. Otherwise, it will be created. |
|                       | ssl | Database connection type  | Specify if you database connection has to be http or https. Default value is false (http). Make sure that the database port is also configured for the same connection mode |
|                       | driverPvc | Persistent Volume Claim to access the JDBC Database Driver| Specify the name of the persistent volume claim that hosts the JDBC database driver. Required if the database type selected is not DB2 |
|                       | adminCredentialsSecret | MFPServer DB Admin Secret | If you have enabled DB initialization ,then provide the secret to create database tables and schemas for Mobile Foundation components |
| mfpserver | adminClientSecret | Admin client secret | Specify the Client Secret name created. Refer #6 in [Prerequisites](#Prerequisites) |
|  | pushClientSecret | Push client secret | Specify the Client Secret name created. Refer #6 in [Prerequisites](#Prerequisites) |
| mfpserver.replicas |  | The number of instances (pods) of Mobile Foundation Server that need to be created | Positive integer (Default: 3) |
| mfpserver.autoscaling     | enabled | Specifies whether a horizontal pod autoscaler (HPA) is deployed. Note that enabling this field disables the replicas field. | false (default) or true |
|           | minReplicas  | Lower limit for the number of pods that can be set by the autoscaler. | Positive integer (default to 1) |
|           | maxReplicas | Upper limit for the number of pods that can be set by the autoscaler. Cannot be lower than min. | Positive integer (default to 10) |
|           | targetCPUUtilizationPercentage | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods. | Integer between 1 and 100(default to 50) |
| mfpserver.pdb     | enabled | Specifu whether to enable/disable PDB. | true (default) or false |
|           | min  | minimum available pods | Positive integer (default to 1) |
|    mfpserver.customConfiguration |  |  Custom server configuration (Optional)  | Provide server specific additional configuration reference to a pre-created config map |
| mfpserver.jndiConfigurations | mfpfProperties | Mobile Foundation Server JNDI properties to customize deployment | Supply comma separated name value pairs |
| mfpserver | keystoreSecret | Refer the configuration section to pre-create the secret with keystores and their passwords.|
| mfpserver.resources | limits.cpu  | Describes the maximum amount of CPU allowed.  | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|                  | limits.memory | Describes the maximum amount of memory allowed. | Default is 4096Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)|
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value.  | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 2048Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| mfppush | enabled          | Flag to enable Mobile Foundation Push | true (default) or false |
|           | repository   | Docker image repository |Repository of the Mobile Foundation Push docker image |
|           | tag          | Docker image tag | See Docker tag description |
| mfppush.replicas | | The number of instances (pods) of Mobile Foundation Server that need to be created | Positive integer (Default: 3) |
| mfppush.autoscaling     | enabled | Specifies whether a horizontal pod autoscaler (HPA) is deployed. Note that enabling this field disables the replicaCount field. | false (default) or true |
|           | minReplicas  | Lower limit for the number of pods that can be set by the autoscaler. | Positive integer (default to 1) |
|           | maxReplicas | Upper limit for the number of pods that can be set by the autoscaler. Cannot be lower than minReplicas. | Positive integer (default to 10) |
|           | targetCPUUtilizationPercentage | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods. | Integer between 1 and 100(default to 50) |
| mfppush.pdb     | enabled | Specifu whether to enable/disable PDB. | true (default) or false |
|           | min  | minimum available pods | Positive integer (default to 1) |
| mfppush.customConfiguration |  |  Custom configuration (Optional)  | Provide Push specific additional configuration reference to a pre-created config map |
| mfppush.jndiConfigurations | mfpfProperties | Mobile Foundation Server JNDI properties to customize deployment | Supply comma separated name value pairs |
| mfppush | keystoresSecretName | Refer the configuration section to pre-create the secret with keystores and their passwords.|
| mfppush.resources | limits.cpu  | Describes the maximum amount of CPU allowed.  | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|                  | limits.memory | Describes the maximum amount of memory allowed. | Default is 4096Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)|
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value.  | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 2048Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| mfpanalytics | enabled          | Flag to enable analytics | false (default) or true |
| mfpanalytics.image | repository          | Docker image repository | Repository of the Mobile Foundation Operational Analytics docker image |
|           | tag          | Docker image tag | See Docker tag description |
|           | consoleSecret | A pre-created secret for login | Check Prerequisites section|
| mfpanalytics.replicas |  | The number of instances (pods) of Mobile Foundation Operational Analytics that need to be created | Positive integer (Default: 2) |
| mfpanalytics.autoscaling     | enabled | Specifies whether a horizontal pod autoscaler (HPA) is deployed. Note that enabling this field disables the replicaCount field. | false (default) or true |
|           | minReplicas  | Lower limit for the number of pods that can be set by the autoscaler. | Positive integer (default to 1) |
|           | maxReplicas | Upper limit for the number of pods that can be set by the autoscaler. Cannot be lower than minReplicas. | Positive integer (default to 10) |
|           | targetCPUUtilizationPercentage | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods. | Integer between 1 and 100(default to 50) |
|  mfpanalytics.shards|  | Number of Elasticsearch shards for Mobile Foundation Analytics | default to 2|             
|  mfpanalytics.replicasPerShard|  | Number of Elasticsearch replicas to be maintained per each shard for Mobile Foundation Analytics | default to 2|
| mfpanalytics.persistence | enabled         | Use a PersistentVolumeClaim to persist data                        | true |                                                 |
|            |useDynamicProvisioning      | Specify a storageclass or leave empty  | false  |                                                  |
|           |volumeName| Provide an volume name  | data-stor (default) |
|           |claimName| Provide an existing PersistentVolumeClaim  | nil |
|           |storageClassName     | Storage class of backing PersistentVolumeClaim | nil |
|           |size             | Size of data volume      | 20Gi |
| mfpanalytics.pdb     | enabled | Specify whether to enable/disable PDB. | true (default) or false |
|           | min  | minimum available pods | Positive integer (default to 1) |
|    mfpanalytics.customConfiguration |  |  Custom configuration (Optional)  | Provide Analytics specific additional configuration reference to a pre-created config map |
| mfpanalytics.jndiConfigurations | mfpfProperties | Mobile Foundation JNDI properties to be specified to customize operational analytics| Supply comma separated name value pairs  |
| mfpanalytics | keystoreSecret | Refer the configuration section to pre-create the secret with keystores and their passwords.|
| mfpanalytics.resources | limits.cpu  | Describes the maximum amount of CPU allowed.  | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|                  | limits.memory | Describes the maximum amount of memory allowed. | Default is 4096Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)|
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value.  | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 2048Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| mfpappcenter | enabled          | Flag to enable Application Center | false (default) or true |  
| mfpappcenter.image | repository          | Docker image repository | Repository of the Mobile Foundation Application Center docker image |
|           | tag          | Docker image tag | See Docker tag description |
|           | consoleSecret | A pre-created secret for login | Check Prerequisites section|
|  mfpappcenter.db | host | IP address or hostname of the database where Appcenter database needs to be configured	| |
|                       | port | 	Port of the database  | |             
|                       | name | Name of the database to be used | The database has to be precreated.|
|                       | secret | A precreated secret which has database credentials| |
|                       | schema | Application Center database schema to be created. | If the schema already exists, it will be used. If not, one will be created. |
|                       | ssl |Database connection type  | Specify if you database connection has to be http or https. Default value is false (http). Make sure that the database port is also configured for the same connection mode |
|                       | driverPvc | Persistent Volume Claim to access the JDBC Database Driver| Specify the name of the persistent volume claim that hosts the JDBC database driver. Required if the database type selected is not DB2 |
|                       | adminCredentialsSecret | Application Center DB Admin Secret | If you have enabled DB initialization ,then provide the secret to create database tables and schemas for Mobile Foundation components |
| mfpappcenter.autoscaling     | enabled | Specifies whether a horizontal pod autoscaler (HPA) is deployed. Note that enabling this field disables the replicaCount field. | false (default) or true |
|           | minReplicas  | Lower limit for the number of pods that can be set by the autoscaler. | Positive integer (default to 1) |
|           | maxReplicas | Upper limit for the number of pods that can be set by the autoscaler. Cannot be lower than minReplicas. | Positive integer (default to 10) |
|           | targetCPUUtilizationPercentage | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods. | Integer between 1 and 100(default to 50) |
| mfpappcenter.pdb     | enabled | Specifu whether to enable/disable PDB. | true (default) or false |
|           | min  | minimum available pods | Positive integer (default to 1) |
| mfpappcenter.customConfiguration |  |  Custom configuration (Optional)  | Provide Application Center specific additional configuration reference to a pre-created config map |
| mfpappcenter | keystoreSecret | Refer the configuration section to pre-create the secret with keystores and their passwords.|
| mfpappcenter.resources | limits.cpu  | Describes the maximum amount of CPU allowed.  | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|                  | limits.memory | Describes the maximum amount of memory allowed. | Default is 1024Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)|
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value.  | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 1024Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |

## Backup and recovery of MFP Analytics Data

The MFP Analytics Data is available as a part of Kubernetes [PersistentVolume or PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#introduction). You might be using one among the [volume plugins that Kubernetes offers](https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes).

Backup and restore depends on the volume plugins that you use. There are various means/tools through which the volume can be backed up or restored.

Kuberenetes provides [**VolumeSnapshot, VolumeSnapshotContent and Restore options**](https://kubernetes-csi.github.io/docs/snapshot-restore-feature.html#snapshot--restore-feature). You may take a copy of the [volume in the cluster](https://kubernetes.io/docs/concepts/storage/volume-snapshots/#introduction) that has been provisioned by an administrator.

Use the following [example yaml files](https://github.com/kubernetes-csi/external-snapshotter/tree/master/examples/kubernetes) to test the snapshot feature.

You may also leverage other tools to take a backup of the volume and restore the same -

- IBM Cloud Automation Manager (CAM) on ICP
           
	   Leverage the capabilities of CAM and strategies for [Backup/Restore, High Availability (HA) and Disaster Recovery (DR) for CAM instances](https://developer.ibm.com/cloudautomation/2018/05/08/backup-ha-dr/)
	   

- [Portworx](https://portworx.com) on ICP
           
	   Is a storage solution designed for applications deployed as containers or via container orchestrators such as Kubernetes
	   

- Stash by [AppsCode](https://appscode.com/products/kubed/0.9.0/guides/disaster-recovery/stash/)
           
	   Using Stash, you can backup the volumes in Kubernetes 
	   
## Limitations
 
 - N/A
	   
