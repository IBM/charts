# Installing IBM Maximo Production Optimization On-Premises

## Introduction

IBM® Maximo Production Optimization On-Premises delivers a predictive solution for the manufacturing industries to maximize overall equipment effectiveness (OEE).  

## Chart Details

A chart deploys IBM Maximo Production Optimization On-Premises instance for production.  
This chart is bundled together with an embedded JanusGraph and CouchDB instance.  

## Prerequisites

1. IBM Cloud Private version 3.1+ is installed.
2. Cluster Admin privilege is only required for preinstall of cluster security policies creation and post install of OIDC registration.
3. Before the installation, the storage needs to be set up and available, eg, NFS or GlusterFS, or some other storage infrastructure. In addition, the default or PO dedicated storageclass and the corresponding storage provisioner should have been created and configured correctly. 
4. For CouchDB/JanusGraph/Production Optimization, if an existing PersistentVolumeClaim is specified, CouchDB will use the PersistentVolume provisioned by the supplied PersistentVolumeClaim to store the data. If no existing PersistentVolumeClaim is supplied, a new PersistentVolumeClaim will be created during the installation. When creating the new PersistentVolumeClaim, if an existing storageclass is specified, this storageclass will be used, if no storageclass is supplied, the default storageclass of the Kubernetes cluster will be used. 
5. The default Docker images for IBM Maximo Production Optimization are loaded to an appropriate Docker Image Repository.  
Note: If the archive download from IBM Passport Advantage is loaded to IBM Cloud Private, the Docker image is automatically loaded to the default Docker registry for IBM Cloud Private in the namespace which you login.  

   Docker Images  | Tag | Description |
   --------  | -----|-----|
   janusgraph | v1.0.0 | JanusGraph Runtime |
   couchdb| v1.0.0 | CouchDB |
   graphmgmt | v1.0.0 | graph management service|
   tenantapi | v1.0.0 | Tenant organization administration|
   alertservice | v1.0.0 |Alert data management|
   bs | v1.0.0 |backend scheduling service|
   dashboard|v1.0.0|reporting Dashboard|
   smm|v1.0.0|Semantic model management|
   ts|v1.0.0|Metrics data management|
   up|v1.0.0|User problem template management | 
   doc|v1.0.0|RESTful API document provider|

Before installing IBM Maximo Production Optimization On-Premises on your system, you must install and configure `helm` and `kubectl`.

### Kubernetes secret related

IBM Maximo Production Optimization On-Premises needs two Kubernetes secrets. One secret stores the certificate and private keys used by ingress and Couchdb. The other secret stores the credentials for accessing Couchdb and SSO related.

There are two ways to create the two kubernetes secrets:
1.  Automatically generating the secretes during the installation by
       - Setting "autoSecret" and "autoCert" to "true" in the values.yaml; or
       - Selecting the two separate checkbox for "Generate a new secret which contains the credentials" and "Generate a new SSL self-signed certificate" on the GUI configuration panel.
   
2. Manually creating the secrets by running sample shell scripts and kubectl commands then setting the secrets in values.yaml or on the GUI configuration panel before installation

- Creating the self-signed certificate related Kubernetes secret using the sample yaml file (po-cert.yaml) and sample shell script (create-certificate.sh) in the pak_extension directory under the ibm-cloud-pak directory:
     - pre-install/namespaceAdministration/create_certificate_secret/po-cert.yaml
     - pre-install/namespaceAdministration/create_certificate_secret/create-certificate.sh
     
Please note in below create-certificate.sh that "YOUR-INGRESS-HOSTNAME" should be replaced by the hostname of the ingress planned to deploy, "YOUR-RELEASENAME" in the "COUCHDB_HOSTNAME" should be replaced by the exact release name of the PO planned to install, and "YOUR-RELEASENAME-po-couchdb" is the name of the Counchdb service. 
After the update of create-certificate.sh and po-cert.yaml, run the script to create certificates.

```
#!/bin/bash
INGRESS_HOSTNAME=YOUR-INGRESS-HOSTNAME
COUCHDB_HOSTNAME=YOUR-RELEASENAME-po-couchdb
(printf  "[req]\nreq_extensions = v3_req\ndistinguished_name = req_distinguished_name\n[req_distinguished_name]\n[v3_req]\nsubjectAltName=@alt_names\n[alt_names]\nDNS.1=$INGRESS_HOSTNAME\nDNS.2=$COUCHDB_HOSTNAME\n[SAN]\nsubjectAltName=DNS:$INGRESS_HOSTNAME,DNS:$COUCHDB_HOSTNAME")

openssl req -x509 -nodes -sha256 -subj "/CN=$INGRESS_HOSTNAME" \
  -days 36500 -newkey rsa:2048 -keyout cert.key -out cert.crt \
  -reqexts SAN -extensions SAN \
  -config <(printf  "[req]\nreq_extensions = v3_req\ndistinguished_name = req_distinguished_name\n[req_distinguished_name]\n[v3_req]\nsubjectAltName=@alt_names\n[alt_names]\nDNS.1=$INGRESS_HOSTNAME\nDNS.2=$COUCHDB_HOSTNAME\n[SAN]\nsubjectAltName=DNS:$INGRESS_HOSTNAME,DNS:$COUCHDB_HOSTNAME")
```

Use base64 to encode the content of the certificate and the private key, 

```
cat cert.crt | base64
cat cert.key | base64
```
In below po-cert.yaml, the value of "tls.crt" should be replaced by the output of the above "cat cert.crt | base64" command, the value of "tls.key" should be replaced by the output of the "cat cert.key | base64" command, the "YOUR-RELEASENAME" should be replaced by the exact release name.

```
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
metadata:
  name: YOUR-RELEASENAME-manual-cert
  labels:
    app: po
    chart: ibm-maximo-po-prod
    component: autocert
    heritage: Tiller
    release: YOUR-RELEASENAME
  
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUREakNDQWZhZ0F3SUJBZ0lKQVBHRXlERXFKaHE4TUEwR0NTcUdTSWIzRFFFQkN3VUFNQ014SVRBZkJnTlYKQkFNTUdIQnZMV2xqY0RJdWMzZG5MblZ6YldFdWFXSnRMbU52YlRBZ0Z3MHhPREV5TVRRd05qSXlORE5hR0E4eQpNVEU0TVRFeU1EQTJNakkwTTFvd0l6RWhNQjhHQTFVRUF3d1ljRzh0YVdOd01pNXpkMmN1ZFhOdFlTNXBZbTB1ClkyOXRNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTBYTjBqb09ML01pRGFaWUoKYWcvS3hMNG1odVkrZVVNYitEbXRxdGdGQ0RQN1BqSSs4Yi9lMUhNOGdyeElCeWFuV3ljdXBUdm5oOVBBNmlDaAppa0dzOGdkOSs4S1Yxd0I1REMyb3RjOUJsZGlURkZHdlhOT0lQbG1xYnhraGR1SVFTQ0lxa1ZrQU9wc0RMOTR4CndjOHB5WFJHVUZCcmZ6K3I5ZVozeCtBQjIrNEc4R2tsQ1lhT29Ma2NVUDcrVVlVTUppVVdKMnZ6Umovc1VuR1YKUXloMlo1L3dQLzh3bkRLMndCbFI2WkRjNDI3Qkd6MVhHc09weWdhRFJva3IyUE5GeVRFOEVXNk9EMlZ1cXZMTQoyMk8vbCtjbkROL05JMDJaWWsxbG9ZOVJRNldYOFJPelp0ZStVTjAwTjRIV2txeVdvNUxobldnS2VTVlVmRU05ClNxVUovUUlEQVFBQm8wTXdRVEEvQmdOVkhSRUVPREEyZ2hod2J5MXBZM0F5TG5OM1p5NTFjMjFoTG1saWJTNWoKYjIyQ0duQnZMWEZwWVc1cWRXNHRNVEl4TkMxd2J5MWpiM1ZqYUdSaU1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQgpBUUNxb3Y5Si9CMHNHczdvMkd1dDlLQUw3eXFkcmZoSWl5a2RlYTgwRm9NNy9mSnR5ZWprZnNnNUNxTm4wU0R5CmlEbExabDJtVlNxZ1hiYmhtN1ZSQUo3Z0sva00rNlJFM05CcjMrSmdJdDBBTGdRb09PdFdJRVE4WDJGWnZyT3IKUWV2cE5TNWV3UEpPQTdGYmdHQ3piMStPL2pLTW1naWppc0tPbGNWVG96Ykdxby9LaitQY3NGaXgxakpPNldvdQpuRmVnSXB0c0t0UTYzbUpGa3pVc3JMbDdvRnRxMWkvVmxFWGVMVkNVTUtwLzBLZitJSWJydUF2YUlpSE83bGxoCnk1MVNybGxCU2pyaXl2THV5S1dkREFBVk9tNmd5ZlE5RmN5bGc1dm8zR1dlNUhrNTV2TXVmc1A0N1ExeWtoZEoKYVRMUXNncTVHbU5pUVRUY09mMWVCd01qCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2Z0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktnd2dnU2tBZ0VBQW9JQkFRRFJjM1NPZzR2OHlJTnAKbGdscUQ4ckV2aWFHNWo1NVF4djRPYTJxMkFVSU0vcytNajd4djk3VWN6eUN2RWdISnFkYkp5NmxPK2VIMDhEcQpJS0dLUWF6eUIzMzd3cFhYQUhrTUxhaTF6MEdWMkpNVVVhOWMwNGcrV2FwdkdTRjI0aEJJSWlxUldRQTZtd012CjNqSEJ6eW5KZEVaUVVHdC9QNnYxNW5mSDRBSGI3Z2J3YVNVSmhvNmd1UnhRL3Y1UmhRd21KUlluYS9OR1AreFMKY1pWREtIWm5uL0EvL3pDY01yYkFHVkhwa056amJzRWJQVmNhdzZuS0JvTkdpU3ZZODBYSk1Ud1JibzRQWlc2cQo4c3piWTcrWDV5Y00zODBqVFpsaVRXV2hqMUZEcFpmeEU3Tm0xNzVRM1RRM2dkYVNySmFqa3VHZGFBcDVKVlI4ClF6MUtwUW45QWdNQkFBRUNnZ0VBYS9JRThDMzd4NXZQbm1zbER2UjBuRkVqcWdLZnovODJPd2YrNlQzTDJoNXcKTGUzWFl1QndCeTRjMFlRWDJ4ZWd5T200c0kvZkU3R2Vpd3VtTllzRGh2azFoTHNVWG1wditFYlAzR09rZVlYVQp4M1FSM05Wb01qb2tESDMzTVQzeEJqd1ZsRE02V3ZubytwS1pNam1DWDhEOVBBYzJYNjZCQVlwMTBSMHgyQlkxCngyWnAwQVN6enlvOWtaaE9ja1BHdi80MkVxaDRBdjRQWHlZd2tMdVcrNjNEV3JrYTgyTzNOVU95cUY3ekwyeUkKSFR4YUFXMnZETFg3eWYvdFVYVDRsOU5uVjBsSFozN3UvNTJoMEMrN3BNVkk2UDhYbmw4VlhBeWphQlE2QzE5UwpjSGh0WnNaT2lING9mL3JPOWlRV0VBTTd4WGYwQjZlU3dBUkIzSHRFQVFLQmdRRHdCUk1nU0FRQ0tlS3U1dnpQCndFV1daSi9JaURDYnFsRVJjMDM4Rnh6SjBPL3RTb3N3Z21MOC9HSVFicnZaOVNOcjVhMnBrTFA2TzZvd1RLNFoKcjA4MXA3dUhXMUs3ZUltNWhYU2VkaUczdUpFM0k2eXY5Nmh3ZzlObXl0WHRuWXdSd3VWa3hOR1NyQ0dGMERuUgpHRHlPbVN3RVlCNUJab2g2QWVZUHI0bFdiUUtCZ1FEZlpWeXQ0TThLYnhkVTAvUWRSRmlkb0FOQm5CY0FjMklMCkNXdURhWTd6V3QyZHdYU1FVUjdWbHFSbUlnenpUS1RrMXUvcE9JS0dQdVFVNHRqVkoxSEVIblZaTVc5akl2OXUKMGpUTlpYMGU0U1hQaTRUWVR3RkwxT0dRVTVMdVExQzM1d2paMnp3M2FtMTBjMklhTlVwM2RNNVd6b3A0cklsKwpJbVAwZTNxSDBRS0JnUUNNbVF4cEhvWnFsZ3FabGVtRjhRVlNZY05QZnFlcXFBd3hBckF0K1lQOW5JelBIWm1ICll2bUZaSG8xVWdoc1ZyTFhJNFdsRElUQkVtNVJPTG5MaGV3S2JDVG4xMUVSVER5eEZrSUlDUDhiVmR5S3hqVUUKSnpqZUgvcVgvajF1b1psSlZqZDEzZTA5MCtNWE5iQ0lrWC8zc0RZZW9nZFhIQzdaK1g3QXRYem55UUtCZ1FEVwpweExTa0h6Z1RiWmhiL2ZVVjJPK3NZM3ZjUWc1Q3FWZWJZSzlGcVNnK09LUlB0MjkvZlJlend6UWhrOWpTSFg0CjNQNVJYbGNzbnltUldCZDVXUHFjTTVnV1NBWDdnQmxvWnRzTnNVTDBkT3BiN25lTFVQNngycStTZW50b0xZNVYKNXN6K2FFWUlDVjk2MFpPbUV5YW1lYm42ZHlOZXFJckVoRTcvRDliQXdRS0JnQ0lONmNJQzdLcTB4bG1kYjBSVQpLVk5PMzZsY0phYis3bVQwR3J3ZGtRZWpicC9JUFpESVVEWVJ2MXRSOEZuMlBFQWVjN0NoSXF6Q2w4OXZwYVI3CndnUTBmQmpiZFA3elVFWjh6Zko3WVVtRFp0aFo3aWxkbXdMMEpGblF6NTFFNHR1ZG8rbUJrT0lma2lNWmY1VlkKb1Q4aG1OVnI1aGhSNm1ONzVIUW1ibFpRCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
```
Use cloudctl command to login the ICP, choose the right namespace and run the below command:

```
kubectl create -f po-cert.yaml
```
In addition,  "kubectl get secret | grep manual-cert" can be used to check the result.

- Creating the credential related Kubernetes secret using the sample yaml file (po-credentials.yaml) and sample shell script (create-credential.sh) in the pak_extension directory under the ibm-cloud-pak directory.
    - pre-install/namespaceAdministration/create_certificate_secret/create-credential.sh
    - pre-install/namespaceAdministration/create_certificate_secret/po-credentials.yaml
    
Run the shell script create-credential.sh to create the credential strings after base64 encoding.

```
#!/bin/bash

mkdir -p /tmp/po-secrets
cd /tmp/po-secrets
pwd
ls -lha

export RANDFILE=/tmp/po-secrets/.rnd

echo "create random secret for PO"
pckey=$(openssl rand -base64 64 | tr -d '/\\=\n' | base64 | tr -d '\n')
echo "pckey=$pckey"
couchdbAdminUsername=YWRtaW4=
echo "couchdbAdminUsername=$couchdbAdminUsername"
couchdbAdminPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 | base64)
echo "couchdbAdminPassword=$couchdbAdminPassword"
couchdbCommonUsername=cG91c2Vy
echo "couchdbCommonUsername=$couchdbCommonUsername"
couchdbCommonPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 | base64)
echo "couchdbCommonPassword=$couchdbCommonPassword"
couchdbCookieAuthSecret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 33 | base64)
echo "couchdbCookieAuthSecret=$couchdbCookieAuthSecret"
sso_client_id=$(openssl rand -hex 16 | base64 | tr -d '\n')
echo "sso_client_id=$sso_client_id"
sso_client_secret=$(openssl rand -base64 64 | tr -d '/\\=\n' | base64 | tr -d '\n')
echo "sso_client_secret=$sso_client_secret"
```
In below po-credentials.yaml, update the values of the credential fields according to the output of the above shell script, and make sure the "YOUR-RELEASENAME" has been replaced with the right release name.

```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: YOUR-RELEASENAME-manual-secret
  labels:
    app: po
    chart: ibm-maximo-po-prod
    component: autosecret
    heritage: Tiller
    release: YOUR-RELASENAME
data:
  couchdbAdminPassword: bGgxZTQxaENjSmlCOVh5Vg==
  couchdbAdminUsername: YWRtaW4=
  couchdbCommonPassword: a2dxRDE5RGdJOGxTek44dQ==
  couchdbCommonUsername: cG91c2Vy
  couchdbCookieAuthSecret: eWlUVUFIZkZCbjMxdTBJSjV3YnFxdFZ4dFRjWmxoUTBv
  pckey: U0FpWm1DdWxUMTFRcU1VeGxHSWd1bW5pemtuQm1vdFFKMjJhMXQ3QTFXODJvK0IzMXNlZEErVkZlK0d0R0pBNkpvM25xTXhZYTVoS1RDT2ZSVlJ3
  sso_client_id: YjczZWFiMWY3Y2UxOTI3ODhhMDQ2MDY3Nzk0NmY4NWIK
  sso_client_secret: b3pLMG9oZ000K05rWHVaUERCM21RYXVTTk1YVjk4WjY4SmtNNVRva0lqNmlLZzVETW1sZXVHV0lKM3UyZDE1MVFzeDYzYW5BTmRZNjNzMzFrRGRTMGc=
```
Use cloudctl command to login the ICP, choose the right namespace and run the below command:

```
kubectl create -f po-credentials.yaml
```
In addition,  "kubectl get secret | grep manual-secret" can be used to check the result.

After creating these secrets manually before the installation, make reference to these existing secrets for the installation:
- If values.yaml is being used to complete the installation, it needs to be updated with "autoSecret=false" and "autoCert=false" , also the exact names of the secrets to the "existingSecret" and "existingCert" should be input in the values.yaml. 
- If the GUI installation is being used to complete the installation, "Generate a new secret which contains the credentials" and  "Generate a new SSL self-signed certificate" in the configuration panel should keep unchecked, and the name of the secrets should be input to the "The existing secret name which already contains the credentials" and "The existing secret name which already contains the SSL certificate" fields.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [ibm-restricted-psp](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.
This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the **pak_extension** pre-install directory.

-  **From the user interface**, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-maximo-po-psp
    spec:
	  allowPrivilegeEscalation: false
	  forbiddenSysctls:
	  - '*'
	  fsGroup:
	    ranges:
	    - max: 65535
	      min: 1
	    rule: MustRunAs
	  requiredDropCapabilities:
	  - ALL
	  runAsUser:
	    rule: MustRunAsNonRoot
	  seLinux:
	    rule: RunAsAny
	  supplementalGroups:
	    ranges:
	    - max: 65535
	      min: 1
	    rule: MustRunAs
	  volumes:
	  - configMap
	  - emptyDir
	  - projected
	  - secret
	  - downwardAPI
	  - persistentVolumeClaim
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-maximo-po-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-maximo-po-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
- From the command line, you can run the setup scripts included under pak_extensions
	- As a cluster admin the pre-install instructions are located at:
  		- pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

	- As team admin/operator the namespace scoped instructions are located at:
  		- pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

Note: The PodSecurityPolicy needs to be created only once. If the policy already exists, you can ignore this step.  

## Resources required

- System resources, based on default install parameters.
	By default, when you use the Helm Chart to deploy IBM Maximo Production Optimization, you start with the following number of Pods and required resources:  
	
	Component  | Replica | Request CPU | Limit CPU | Request Memory | Limit Memory
	|--------  | -----| -------------| -------------| -------------| -------------
	|janusgraph | 1 | 500m |  2 | 2048Mi | 4096Mi
	|couchdb | 1 | 500m |  2 | 2048Mi | 4096Mi
	|dashboard | 3 | 50m |  500m | 200Mi | 500Mi
	|alertservice| 3 | 50m |  500m | 200Mi | 500Mi
	|smm| 3 | 50m |  500m | 200Mi | 500Mi
	|ts | 3 | 50m |  500m | 500Mi | 1024Mi
	|graphmgmt | 3 | 50m |  500m | 200Mi | 500Mi
	|tenantapi | 3 | 50m |  500m | 200Mi | 500Mi
	|bs| 3 | 50m |  500m | 200Mi | 500Mi
	|up| 3 | 50m |  500m | 200Mi | 500Mi
	|doc| 3 | 50m |  500m | 200Mi | 500Mi
	
   - The CPU resource is measured in Kuberenetes _cpu_ units. See Kubernetes documentation for details.
   - Ensure that you have sufficient resources available on your worker nodes to support the IBM Maximo Production Optimization deployment.  
   - JanusGraph and CouchDB can only have 1 Replica, please DO NOT scale JanusGraph and CouchDB. For other components, you can scale in and out based on your resource capacity.
- Storage resources(Persistence):
  Use either storage with dynamic provisioning or static provisioning. The underlying directories for the storage should have 766 permissions.
  - JanusGraph will need 50GB of disk space
  - CouchDB will need 100GB of disk space
  - Production Optimization will need 10GB of disk space

## Installing the chart

### Installing the Chart via UI
1. From the IBM Cloud Private dashboard console, open the Catalog.
2. Locate and select the ibm-maximo-po-prod chart.
3. Review the provided instructions and select Configure.
4. Provide a release name and select a namespace.
5. Review and accept the license(s).
6. Using the Configuration table below, provide the required configuration based on requirements specific to your installation. Required fields are displayed with an asterisk.
7. Select the Install button to complete the helm installation.

### Installing the Chart via the Command Line
To install the chart, run the following command:
```bash
$ helm install --tls --name {my-release} -f {my-values.yaml} stable/ibm-maximo-po-prod
```
-   Replace `{my_release}` with a name for your release.
-   Replace `{my-values.yaml}` with the path to a YAML file that specifies the values that are to be used with the `install` command. Specifying a YAML file is optional.

When it completes, the command displays the current status of the release.

Note: If multiple installs of the chart in a single IBM Cloud Private environment is required, please set different Ingress Hostname between installs.

## Post installation
1. Follow the instructions to complete the OIDC registration. The instructions can be displayed after the helm installation completes. The instructions can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: helm status <release> --tls.
2. After creating and launching into a service instance, see the [Configuring the solution for Production Optimization](https://www.ibm.com/support/knowledgecenter/SSEH43_1.0.0/on_prem_kc_welcome.html) topic for getting started.

## Uninstalling the chart
### Uninstalling the Chart via UI:
1. Select the Menu -> Workloads -> Helm Releases
2. Locate the installed helm release and select the actions menu -> Delete
3. Confirm deletion by selecting the Remove button

### Uninstalling the Chart via the Command Line:
To uninstall and delete the `my-release` deployment, run the following command:

```bash
$ helm delete --tls my-release
```

To irrevocably uninstall and delete the `my-release` deployment, run the following command:

```bash
$ helm delete --purge --tls my-release
```

If you omit the `--purge` option, Helm deletes all resources for the deployment but retains the record with the release name. This allows you to roll back the deletion. If you include the `--purge` option, Helm removes all records for the deployment so that the name can be used for another installation.

## Configuration

The following options apply to a IBM Maximo Production Optimization runtime configuration.

| Value                                                   | Description                                              | Default             |
|---------------------------------------------------------|----------------------------------------------------------|---------------------|
| `ingress.hostname` | host name to expose Production Optimization services |    Empty      |
| `adminUser`        | admin user to be allowed to use Production Optimization Dashboard and RESTful API services    |    Empty      |
| `global.masterHost`| virtual IP(cluster_vip) or cluster_lb_address for ICP management service               |    Empty      |
| `global.masterPort`| router_https_port for ICP management service	               |    8443      |
| `global.oidcPort`  | oidc port for ICP management service	               |    8443      |
| `global.replicaCount` | replication count for all Production Optimization services except JanusGraph and CouchDB |    3      |
| `ingress.annotation`  | annotation method for ingress |    Empty      |
| `ingress.tlsenabled`  | enable ingress tls communitcation or not |    true      |
| `global.secretGen.autoSecret`  | automatically generate secret or not, refer the above section "Kubernetes secret related" for details |    true      |
| `global.secretGen.existingSecret`  | specify existing secret if you already have one, refer the above section "Kubernetes secret related" for details |    Empty      |
| `global.secretGen.autoCert`  | automatically generate tls certification file for ingress and CouchDB              |    true      |
| `global.secretGen.existingCert`  | specify existing tls certification file for ingress and CouchDB              |    Empty      |
| `global.supportT.image.repository`  | repository for Utilities image used to config the product              |    up      |
| `global.supportT.image.tag`  | tag for Utilities image used to config the product              |  v1.0.0        |
| `global.sharedPVC.persistence.useDynamicProvisioning`  | useDynamicProvisioning             |     true     |
| `global.sharedPVC.persistence.storageClass`  | storageClass             |     null     |
| `global.sharedPVC.persistence.existingClaimName`  | existingClaimName             |     ''     |
| `global.sharedPVC.persistence.size`  | size for persistent volume             |    10Gi    |
| `global.imagePullPolicy`  | image pull policy for production optimization components except CouchDB and JanusGraph            |    IfNotPresent    |
| `global.imageSecretName`  | image pull secret name            |    Empty    |
| `graphmgmt.image.repository`  | repository for graph management service            |    graphmgmt    |
| `graphmgmt.image.tag`  | tag for graph management service            |    v1.0.0    |
| `graphmgmt.image.resources`  | resources claim for graph management service      |    Empty    |
| `up.image.repository`  | repository for up service            |    up    |
| `up.image.tag`  | tag for up service           |    v1.0.0    |
| `up.image.resources`  | resources claim for up service      |    Empty    |
| `alertservice.image.repository`  | repository for alertservice      |    alertservice    |
| `alertservice.image.tag`  | tag for alertservice            |    v1.0.0    |
| `alertservice.image.resources`  | resources claim for alertservice      |    Empty    |
| `ts.image.repository`  | repository for ts service            |    ts    |
| `ts.image.tag`  | tag for ts service            |    v1.0.0    |
| `ts.image.resources`  | resources claim for ts service      |    Empty    |
| `bs.image.repository`  | repository for bs service            |   bs    |
| `bs.image.tag`  | tag for bs service            |    v1.0.0    |
| `bs.image.resources`  | resources claim for bs service      |    Empty    |
| `tenantapi.image.repository`  | repository for tenantapi service            |    tenantapi    |
| `tenantapi.image.tag`  | tag for tenantapi service            |    v1.0.0    |
| `tenantapi.image.resources`  | resources claim for tenantapi service      |    Empty    |
| `dashboard.image.repository`  | repository for dashboard service            |    dashboard    |
| `dashboard.image.tag`  | tag for dashboard service            |    v1.0.0    |
| `dashboard.image.resources`  | resources claim for dashboard service      |    Empty    |
| `smm.image.repository`  | repository for smm service            |    smm    |
| `smm.image.tag`  | tag for smm service            |    v1.0.0    |
| `smm.image.resources`  | resources claim for smm service      |    Empty    |
| `doc.image.repository`  | repository for document service            |    smm    |
| `doc.image.tag`  | tag for document service            |    v1.0.0    |
| `doc.image.resources`  | resources claim for document service      |    Empty    |
| `janusgraph.image.repository`  | repository for janusgraph service            |    po-janusgraph  |
| `janusgraph.image.tag`  | tag for janusgraph service            |    v1.0.0    |
| `janusgraph.image.pullPolicy`  | image pull policy for janusgraph service      |    IfNotPresent    |
| `janusgraph.persistence.useDynamicProvisioning`  | use useDynamicProvisioning or not for JanusGraph service      |    true    |
| `janusgraph.persistence.existingClaim`  | existing persist volume claim for JanusGraph service      |    nil    |
| `janusgraph.persistence.size`  | size for persist volume used by JanusGraph service      |    50Gi    |
| `janusgraph.persistence.storageClass`  | StorageClass for JanusGraph service      |    Nil    |
| `janusgraph.resources.limits.cpu`  | limited cpu resources for janusgraph service      |    Empty    |
| `janusgraph.resources.limits.memory`  | limited memory resources for janusgraph service      |    Empty    |
| `janusgraph.resources.requests.cpu`  | requests cpu resources for janusgraph service      |    Empty    |
| `janusgraph.resources.requests.memory`  | requests memory resources for janusgraph service      |    Empty    |
| `couchdb.image.repository`  | repository for CouchDB service            |   po-couchdb    |
| `couchdb.image.tag`  | tag for CouchDB service            |    v1.0.0    |
| `couchdb.image.pullPolicy`  | image pull policy for CouchDB service      |    IfNotPresent    |
| `couchdb.persistentVolume.useDynamicProvisioning`  | use useDynamicProvisioning or not to provision pv for CouchDB service      |    true    |
| `couchdb.persistentVolume.existingDataVolumeClaimName`  | existingDataVolumeClaimName for CouchDB service      |    Empty    |
| `couchdb.persistentVolume.size`  | size for CouchDB service      |    100Gi    |
| `couchdb.persistentVolume.storageClass`  | storageClass for CouchDB service      |    null    |
  * ingress hostname is the hostname where the Ingress controller is deployed, by default, it is deployed on proxy or master nodes. Also, user can define their own DNS entry and point to the ip address of proxy/master nodes.
You can specify all configuration values by using the `--set` parameter. For example:

```bash
$ helm install --tls --set ingress.hostname=test.domain.com
```

Alternatively, you can provide a YAML file that specifies the values for the parameters when you install the Helm chart. For example:

```bash
$ helm install -tls --name my-release -f values.yaml stable/ibm-maximo-po-prod
```

If you want to deploy IBM Maximo Production Optimization to a different namespace with your PPA loaded name space, please use the following command to make Docker images' scope to global.
```
for image in $(kubectl get images | tail -n +2 | awk '{ print $1; }'); do kubectl get image $image -o yaml | sed 's/scope: namespace/scope: global/' | kubectl apply -f -; done
```

## Access Environment

1. Access IBM Maximo Production Optimization's Dashboard from browser using the adminUser you set during helm installation phase.
   - https://{ingress.hostname}:{ingress port}/{dashboard path}
     - ingress.hostname is set when you install helm release.
    
2. You can click menu in right corner of dashboard and select "API key" to create or reset your RESTful API Key, then you can start to use the following RESTful API services by adding headers:
```
  -H 'tenantId: GoldenTenant'
  -H 'userId: {adminUser}'
  -H 'apiKey: {apiKey created}
```

3. You can add normal user to your ICP instance by RESTful API. 
For all RESTful API description and try-out, please refer https://{ingress.hostname}:{ingress port}/api/explorer for documenting with swagger.

4. For the following configuration and usage for Production Optimization, please refer [Knowledge center](https://www.ibm.com/support/knowledgecenter/SSEH43_1.0.0/on_prem_kc_welcome.html) document.

| Path                                                   | Description                                              |
|---------------------------------------------------------|----------------------------------------------------------|
| / 						| Dashboard access path                                   	|
| /api/v1/smm			| Semantic Model Managment access path               	|
| /api/v1/ts				| Metrics Data Management access path               	|
| /api/v1/alertsvc		| Alert data Management access path               	|
| /api/v1/up				| User Problem Template and Task Management access path               	|
| /api/explorer		    | RESTful API document access path             	|
| /api/v1/tenantapi		| Organization Administration access path               	|

## Limitations

- Only the `amd64` architecture is supported.
- JanusGraph and CouchDB can only have 1 Replica.
