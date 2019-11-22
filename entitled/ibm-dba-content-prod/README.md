# IBM® Digital Business Automation - Content


## Introduction
IBM® Digital Business Automation for Content provides robust, end-to-end solutions for business automation needs within your enterprise. Digital Business Automation for Content delivers essential bundled capabilities as a well integrated collection of micro-services to digitize all aspects of business operations, and can extend the workforce with digital labor to enable businesses to scale.

## Chart Details
* This chart deploys Business Automation Configuration Container (IBACC), which can then be used to deploy the core services of IBM® Digital Business Automation for Content:

	* IBM® FileNet® Content Manager provides enterprise content management to enable secure access, collaboration support, content synchronization and sharing, and mobile support to engage users over all channels and devices. IBM® FileNet® Content Manager consists of IBM® Content Process Engine (CPE), Content Search Service (CSS),Content Management Interoperability Service (CMIS) and IBM Content Navigator (ICN).

* IBM® Digital Business Automation for Content supports the following:  
	* It can install each product into its one namespace or it can install each product on different namespaces by deploying IBM® Digital Business Automation for Content multiple times. IBM® Digital Business Automation for Content can also deploy the product multiple times in the same namespace but with different helm release name. 
	* It provides the ability to enable auto scaling for Content products and change the default resource requirements.
	* After deploying Business Automation Configuration Container,  the IBACC UI can be launched by end user to select all the listed products in readme or any combination of products and proceed with that product installation.

## Prerequisites

- IBM® Cloud Private 3.1.2.
- NFS Server for static Persistence Volumes.
- Image pull secret for pulling pushed images.Follow [link]( https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_install_ibacc.html ) for steps on generating secret.
- Have the following information available. Follow [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_shared_params_platform.html)
  - IBM® Cloud Private console url.
  - Repo name
  - API Server
  - Cluster Context
  - cloudctl.  
  - Follow [link]( https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_cluster/install_cli.html ) for instructions to install.
  - Cluster ID
  - Account name.
- kubectl
  - Follow [link](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) for instructions to install.
- IBM® Business Automation Configuration Container chart requires 1 persistent volume before chart deployment. 
- IBM® Cloud Private Administrator role is required to deploy IBM® Digital Business Automation for Content.

- The following table describes the storage required for IBM® Business Automation Configuration Container and for the product containers.
  - IBM® Business Automation Configuration Container 
    - Follow [link]( https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_preparing_bacc.html) for installation instructions.
    	
      | Persistent Volumes            | Persistent Volume Claims        | Description                     |
      | ---------------------------   | ------------------------------- |  ---------------------------------------------     |
      | `ibacc-cfg-pv`         | `ibacc-cfg-pvc`          | `Configuration files for IBM® Business Automation Configuration Container` | 

    * Use the below resource to create necessary PersistentVolume and PersistentVolumeClaim or it can be created by using the IBM® Cloud Private console:

      ```
      apiVersion: v1
      kind: PersistentVolume
      metadata:
        name: ibacc-cfg-pv
      spec:
        accessModes:
        - ReadWriteMany
        capacity:
          storage: 1Gi
      nfs:
        path: /ibacc/
        server: <NFS Server>
      persistentVolumeReclaimPolicy: Retain
      storageClassName: ibacc-cfg-pv
      ---
      apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: ibacc-cfg-pvc
        namespace: <NAMESPACE>
      spec:
        accessModes:
        - ReadWriteMany
        resources:
          requests:
            storage: 1Gi
        storageClassName: ibacc-cfg-pv
        volumeName: ibacc-cfg-pv
      status:
        accessModes:
        - ReadWriteMany
        capacity:
          storage: 1Gi
      ```

   * On the NFS server create the corresponding folders for the persistentvolumes.
	`
  	mkdir -p /ibacc
	`
   * Modify the folder permissions.
	`
 	 chown -Rf 50001:50000 /ibacc
	`
  - IBM® FileNet® Content Manager
    * Follow [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ecm.html) for details about this product.

    * IBM® Content Platform Engine
    
      | Persistent Volumes            | Persistent Volume Claims        | Description                                        |
      | ---------------------------   | ------------------------------- |  ---------------------------------------------     |
      | `cpe-icp-cfgstore-pv`         | `cpe-icp-cfgstore-pvc`          | `Configuration files for Liberty` 		     |
      | `cpe-icp-logstore-pv`         | `cpe-icp-logstore-pvc`          | `Content Platform Engine & Liberty logs`           |
      | `cpe-icp-filestore-pv`        | `cpe-icp-filestore-pvc`         | `Content storage volume for advanced storage area` |
      | `cpe-icp-icmrulesstore-pv`    | `cpe-icp-icmrulesstore-pvc`     | `Rules for IBM Case Manager`                                    |
      | `cpe-icp-textextstore-pv`     | `cpe-icp-textextstore-pvc`      | `Text extraction volume used by CSS`               |
      | `cpe-icp-bootstrapstore-pv`   | `cpe-icp-bootstrapstore-pvc`    | `Content Platform Engine bootstrap file location`  |
      | `cpe-icp-fnlogstore-pv`       | `cpe-icp-fnlogstore-pvc`        | `FileNet Log directory`                            |
    
    * IBM® Content Search Services
    
      | Persistent Volume	      | Persistent Volume Claims      | Description            		                     |
      | ---------------------------   | ----------------------------- | ---------------------------------------------        |
      | `css-icp-cfgstore-pv`         | `css-icp-cfgstore-pvc`	      | `Configuration files for CSS`                        |
      | `css-icp-logstore-pv`         | `css-icp-logstore-pvc`        | `Data persistence for CSS log files`                 |
      | `css-icp-tempstore-pv`        | `css-icp-tempstore-pvc`       | `Data persistence for CSS temp files`                |
      | `css-icp-indexstore-pv`       | `css-icp-indexstore-pvc`      | `Data persistence for content index data`            |
      | `css-icp-customstore-pv`       | `css-icp-customstore-pvc`    | `Custom Configuration volume for CSS`                |

    * IBM® Content Management Interoperability Services
    
      | Persistent Volumes            | Persistent Volume Claim	      | Description                                                 |
      | ---------------------------   | ----------------------------- | ------------------------------------	                    |
      | `cmis-icp-cfgstore-pv`        | `cmis-icp-cfgstore-pvc`       | `Configuration files for Liberty`                           |
      | `cmis-icp-logstore-pv`        | `cmis-icp-logstore-pvc`       | `Content Management Interoperability Services Liberty logs` |


  - IBM® Content Navigator 
    * Follow [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ban.html) for details about this product.
    
      | Persistent Volume             | Persistent Volume Claim       | Description                                                      |
      | ---------------------------   | ----------------------------- | ---------------------------------------------                    |
      | `icn-icp-cfgstore-pv`         | `icn-icp-cfgstore-pvc`        | `Configuration files for Liberty`                                |
      | `icn-icp-logstore-pv`         | `icn-icp-logstore-pvc`        | `Navigator and Liberty logs`                                     |
      | `icn-icp-pluginstore-pv`      | `icn-icp-pluginstore-pvc`     | `Custom plugins for Navigator`                                   |
      | `icn-icp-vw-cachestore-pv`    | `icn-icp-vw-cachestore-pvc`   | `Daeja VieweONE logs`                                            |
      | `icn-icp-vw-logstore-pv`      | `icn-icp-vw-logstore-pvc`     | `Daeja VieweONE cache`                                           |
      | `icn-icp-asperastore-pv`      | `icn-icp-asperastore-pvc`     | `Aspera upload (It's optional for user who wants to use Aspera)` |

## Resources Required

- Minimum (non HA): 1 node with 8 cores and 32 GB memory.
- Minimum (HA): Follow IBM Cloud Private hardware requirements [link](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/supported_system_config/hardware_reqs.html#reqs_multi), plus 2 more worker nodes with 8 cores (each core with 8GB memory). 
- Recommended: Follow IBM Cloud Private hardware requirements [link](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/supported_system_config/hardware_reqs.html#reqs_multi), plus 2+ worker nodes with 8+ cores (each core with 16GB memory).
- The following table lists the minimum resource requirements. Adjust the requirements depending on your needs and environment.
- IBM Business Automation Workflow (BAW) is deployed outside of ICP Cluster in VM and accessed using Cloud Access Manager (CAM).

|	 | IBACC  	 |	CPE	 | 	CMIS	 | 	CSS	 |   ICN	 |
| -----  | ------------- | ------------- | ------------- | ------------- | ------------- |
| CPU    |  250m         |   250m        |   250m        |   250m        |   250m        | 
| Memory |  256Mi        |   256Mi       |   256Mi       |   256Mi       |   256Mi       |
| Storage |   1Gb        |  6Gb          |   2Gb         |   4Gb         |   5Gb         |
 

## Installing the Chart
- To install the chart follow this [link]( https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_install_ibacc.html) for instructions. 

### Verifying the Chart
To verify the IBM® Business Automation Configuration Container chart has been deployed, you will need to retrieve the proxy address and the node port, then access the IBM® Business Automation Configuration Container url by running the following commands:  
```
kubectl get nodes -l proxy=true -o jsonpath='{.items[0].status.addresses[0].address}' to obtain the proxy ip.  
kubectl get svc -n <NAMESPACE>  to see a list of the services for later use.  
kubectl get -o jsonpath='{.spec.ports[1].nodePort}' services <IBACC-SERVICENAME>  -n <NAMESPACE>
https://<PROXY_IP>:<IBACC_NODE_PORT>/
```

	- To verify the core products after deployment, please use the following instructions:
	- IBM® FileNet® Content Manager

  	   - To verify IBM® Content Process Engine you will need the proxy address and the node port,then access the IBM Content Process Engine url by running the following commands:

		kubectl get nodes -l proxy=true -o jsonpath='{.items[0].status.addresses[0].address}' to obtain the proxy ip.  
		kubectl get svc -n <NAMESPACE> to see a list of the services for later use.  
    		kubectl get -o jsonpath='{.spec.ports[1].nodePort}' services <CPE_SERVICENAME>  -n <NAMESPACE>
    		https://<PROXY_IP><CPE_NODE_PORT>/accea

  	   - To verify IBM® Content Management Interoperability Services you will need the proxy address and the node port , then access the IBM® Content Management Interoperability Services url by running the following commands:

		kubectl get nodes -l proxy=true -o jsonpath='{.items[0].status.addresses[0].address}' to obtain the proxy ip.  
		kubectl get svc -n <NAMESPACE> to see a list of the services for later use.  
    		kubectl get -o jsonpath='{.spec.ports[1].nodePort}' services <CMIS_SERVICENAME>  -n <NAMESPACE>
    		https://<PROXY_IP><CMIS_NODE_PORT>/openfncmis_wlp

           - Verify IBM® Content Search Service by running the following to check the pod status as it is not accessible through a URL.

		kubectl get pods -n <NAMESPACE>

	- IBM® Content Navigator

	- To verify IBM® Content Navigator you will need the proxy address and the node port , then access the IBM® Content Navigator url by running the following commands: 

		kubectl get nodes -l proxy=true -o jsonpath='{.items[0].status.addresses[0].address}' to obtain the proxy ip.  
		kubectl get svc -n <NAMESPACE> to see a list of the services for later use.  
		kubectl get -o jsonpath='{.spec.ports[1].nodePort}' services <BAN_SERVICENAME>  -n <NAMESPACE>
  		https://<PROXY_IP>:<BAN_NODE_PORT>/navigator


## Uninstalling the Chart

To uninstall/delete the `my-dbamc-release` deployment:

$ helm delete my-dbamc-release --purge --tls

This command deletes the IBM® Digital Business Automation for Content - Business Automation Configuration Container helm release and the corresponding container.  Please note that core services for IBM® Digital Business Automation for Content will not be removed as a result of this, only the helm release of the Business Automation Configuration Container.

## Configuration
- Configuration parameters for IBM® Business Automation Configuration Container can be found [here]( https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_ibacc_params.html )
- Configuration parameters for IBM® FileNet® Content Manager can be found [here]( https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_cm_params.html ).
  - Note: The minimum memory request for your deployment should be 1-to-1 of what your minimum JVM heap size for the application.

## Documentation

[IBM® Digital Business Automation for Content](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/welcome/kc_welcome_dba_distrib.html)

## PodSecurityPolicy Requirements

* This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.
* The predefined PodSecurityPolicy name: ibm-restricted-psp has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.
* This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface.
* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

- Custom PodSecurityPolicy definition:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: icp4a-ibacc--psp
spec:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  allowedCapabilities:
  - CHOWN
  - DAC_OVERRIDE
  - SETGID
  - SETUID
  - NET_BIND_SERVICE
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - configMap
  - secret
```
- Custom ClusterRole for the custom PodSecurityPolicy:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: icp4a-ibacc-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - icp4a-ibacc-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```
## Storage
Currently, IBM® Digital Business Automation for Content only supports a NFS storage system.  A NFS storage system needs to be created as a pre-req before deploying IBM® Digital Business Automation for Content chart.  Dynamic storage provisioning is not supported and you will need to create the required PV and PVCs as a prerequisite.  Once the required PV and PVCs are created, you will need to modify the ownership of them.  The new ownership for the folder structure will be set to `50001:50000`. If the ownership are not set properly, you will not be able to deploy the chart successfully. In addition, this README only provides the minimum storage needed to deploy the charts wich is 1GB per PersistentVolume.  If you plan to run a heavy workload on your deployments, you may encounter a data loss or the quality of the service will stop responding.  The storage needed depends on what you are planing to do with the deployments.  

## Limitations
- Currently, IBM® Cloud Private 3.1.2 is supported.
- This chart can only be run on Intel amd64 platforms.
- Dynamic Provisioning is not supported.
