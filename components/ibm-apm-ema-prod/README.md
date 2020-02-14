# IBM Maximo Equipment Maintenance Assistant On-Premises
IBM Maximo Equipment Maintenance Assistant On-Premises combines asset data and AI to provide insights for problem diagnosis and resolution to help technicians identify the right repair the first time.
## Introduction
IBM Maximo Equipment Maintenance Assistant On-Premises augments your asset maintenance program with machine learning techniques and AI tools. This powerful combination provides asset-intensive industries with capabilities to optimize asset repairs based on prescriptive guidance. AI methods using IBM Watson technology are applied to structured and unstructured data associated with repairs, maintenance, procedures and techniques. This offers enhanced insights and recommend optimum repair methods and procedures. It enables equipment manufacturers to detect failure patterns, ensure optimal first-time fixes, and extend the life of critical assets.

## Chart Details
A chart deploys IBM Maximo Equipment Maintenance Assistant On-Premises instance for production.

It includes the following endpoints:
 - landing page endpoint accessible on `/ema/ui/{instance_id}`
 - auth endpoint accessible on `/ema/ui/{instance_id}/auth`
 - admin console page endpoint accessible on `/ema/ui/{instance_id}/admin`
 - sample app page endpoint accessible on `/ema/ui/{instance_id}/sample-app`
 - studio page endpoint accessible on `/ema/ui/{instance_id}/studio`
 - maximo page endpoint accessible on `/ema/ui/{instance_id}/maximo-integration`
 - user management service endpoints accessible on `/ema/api/v1/user-management`.
 - document management service endpoints accessible on `/ema/api/v1/document-management`.
 - document query service endpoints accessible on `/ema/api/v1/document-query`.
 - usage service endpoints accessible on `/ema/api/v1/usage`.
 - diagnosis service endpoints accessible on `/ema/api/v1/diagnosis`.
 - diagnosis dataloader service endpoints accessible on `/ema/api/v1/dataloader`.

## Prerequisites

1. Red Hat OpenShift version 3.11 is installed.
2. Kubernetes 1.11 or later is installed.
3. Helm 2.9.1 or later is installed.
4. Cluster Admin privilege is only required for preinstall of cluster security policies creation and post delete clean up.
5. The default Docker images for IBM Maximo Equipment Maintenance Assistant On-Premises are loaded to an appropriate Docker Image Repository.
Note: If the archive download from IBM Passport Advantage is loaded to Red Hat OpenShift, the Docker image is automatically loaded to the default Docker registry for Red Hat OpenShift in the namespace which you login.
  
   Docker Images  | Tag | Description |
   --------  | -----|-----|
   ema-admin-console| 1.1.0 | ema admin console |
   ema-api | 1.1.0 | ema service|
   ema-crawler | 1.1.0 | ema crawler|
   ema-diagnosis | 1.1.0 |ema diagnosis service|
   ema-diagnosis-dataloader | 1.1.0 |ema diagnosis dataloader service|
   ema-landing-page|1.1.0|ema landing page|
   ema-auth|1.1.0|ema auth|
   ema-maximo-integration|1.1.0|ema maximo integration|
   ema-sample-app|1.1.0|ema sample app|
   ema-studio|1.1.0|ema studio|
   ema-multi-tenant|1.1.0|ema multi tenant|
   ema-monitor|1.1.0|ema monitor|
   opencontent-common-utils|1.1.2|User problem template management |
Before installing IBM Maximo Equipment Maintenance Assistant On-Premises, you must install and configure helm and kubectl.

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `pak_extensions/pre-install` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom `SecurityContextConstraints` definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
    name: ibm-open-liberty-spring-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowedCapabilities: []
  allowedFlexVolumes: []
  defaultAddCapabilities: []
  fsGroup:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - ALL
  runAsUser:
    type: MustRunAsNonRoot
  seccompProfiles:
  - docker/default
  seLinuxContext:
    type: RunAsAny
  supplementalGroups:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  priority: 0
  ```

* From the command line, you can run the setup scripts included under `pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
  * `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`



### Red Hat OpenShift Project and Installation

This chart requires a `SecurityContextConstraints` to be bound to the target project in OpenShift container platform prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.


#### Creating the required project（namespace）
You need to create and use any new project(namespace) for use like below 
```
oc new-project emans
oc project emans
```
#### Creating the required scc and apply to your project default service account

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `pak_extensions/pre-install` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
* Custom `SecurityContextConstraints` definition:
```
oc create -f - << EOF
allowHostDirVolumePlugin: false
allowHostIPC: true
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities:
- '*'
allowedFlexVolumes: null
apiVersion: v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: emauid provides all features of the restricted SCC but allows users to run with any UID and any GID.
  name: emauid
priority: 10
readOnlyRootFilesystem: false
requiredDropCapabilities: null
runAsUser:
  type: RunAsAny
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
oc adm policy add-scc-to-group emauid system:serviceaccounts:emans
oc adm policy add-scc-to-user emauid system:serviceaccount:emans:default
  ```
#### Create the cluster role binding for your default service account
```
kubectl create clusterrolebinding admin-on-ema --clusterrole=admin --user=system:serviceaccount:emans:default  -n emans
```
#### Create the openshift docker registery pull secret if required 

Verify if you could login to the Red Hat OpenShift docker registry with your account and create pull secrets
```
docker login Docker-registry-URL -u $(oc whoami) -p $(oc whoami -t)
kubectl create secret -n YOUR_NAMESPACE docker-registry openshift-docker-pull --docker-server=DOCKER_REGISTRY_URL --docker-username=DOCKER_REGISTRY_USER --docker-password=DOCKER_REGISTRY_PASSWORD
```


## Resources Required

- System resources, based on default install parameters.
	By default, when you use the Helm Chart to deploy IBM Maximo Equipment Maintenance Assistant On-Premises, you start with the following number of Pods and required resources:  
	
  |Component  | Replica | Request CPU | Limit CPU | Request Memory | Limit Memory
  |--------  | -----| -------------| -------------| -------------| -------------
  |ema-admin-console | 3 | 100m |  1 | 100Mi | 1Gi
  |ema-api | 3 | 200m |  1 | 500Mi | 2Gi
  |ema-auth | 3 | 100m | 1 | 100Mi | 1Gi
  |ema-crawler | 1 | 200m |  1 | 500Mi | 2Gi
  |ema-diagnosis | 3 | 200m |  2 | 500Mi | 2Gi
  |ema-diagnosis-dataloader | 1 | 100m |  1 | 100Mi | 1Gi
  |ema-landing-page| 3 | 100m |  1 | 100Mi | 1Gi
  |ema-maximo-integration| 3 | 100m |  1 | 100Mi | 1Gi
  |ema-sample-app| 3 | 100m |  1 | 100Mi | 1Gi
  |ema-studio| 3 | 100m |  1 | 100Mi | 1Gi
  |ema-multi-tenant| 3 | 100m |  1 | 100Mi | 1Gi
  |ema-monitor| 1 | 200m |  1 | 500Mi | 2Gi
	
   - The CPU resource is measured in Kubernetes _cpu_ units. See Kubernetes documentation for details.
   - Ensure that you have sufficient resources available on your worker nodes to support the IBM Maximo Equipment Maintenance Assistant On-Premises deployment.


## Installing the chart

### Installing the Chart via the Command Line
To install the chart, run the following command:
```bash
$ helm install --name {my-release} -f {my-values.yaml} stable/ibm-apm-ema-prod --tls --timeout 3000
```
-   Replace `{my_release}` with a name for your release.
-   Replace `{my-values.yaml}` with the path to a YAML file that specifies the values that are to be used with the `install` command. Specifying a YAML file is optional.

When it completes, the command displays the current status of the release.

Note: If multiple installs of the chart in a single Red Hat OpenShift environment is required, you must set different Ingress Hostname between installs.

## Post installation
1. Follow the instructions to complete the OIDC registration. The instructions can be displayed after the helm installation completes. The instructions can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: helm status <release> --tls.
2. Validate health of pods by running helm tests:
  helm test {{ .Release.Name }} --tls --cleanup
3. After creating and launching into a service instance, see the [Configuring the solution for IBM Maximo Equipment Maintenance Assistant On-Premises](https://www.ibm.com/support/knowledgecenter/SSZNPQ_1.0.0/com.ibm.ei.doc/welcome.html) topic for getting started.

## Uninstalling the chart

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

The following tables lists the configurable parameters of the IBM Maximo Equipment Maintenance Assistant On-Premises and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `ingress.hostname` | host name to expose Equipment Maintenance Assistant services |    Empty      |
| `ingress.annotations` | decide if need to enable annotations in ingress |    true      |
| `ingress.enabled` | decide if need to enable ingress |    true      |
| `ingress.tlsenabled`        | decide if need to enable tls in ingress    |    true      |
| `global.license` | Users must read the license and set the value to `accepted` | `not accepted` |
| `global.icpDockerRepo`| docker repository for image               |    docker-registry.default.svc:5000/ema/      |
| `global.jksJob.image.repository`| job image repository	               |    docker-registry.default.svc:5000/ema/opencontent-common-utils      |
| `global.jksJob.image.tag`  | job image tag	               |    1.1.2      |
| `service.type` | service type | ClusterIP |
| `service.externalPort` | service external port | 80 |
| `tenantMgmtDB.username` | CouchDB user name for ema tenant management database (e.g. admin) | "" |
| `tenantMgmtDB.password` | CouchDB user password for ema tenant management database (e.g. changeme) | "" |
| `tenantMgmtDB.endpoint` | CouchDB endpoint for ema tenant management database. The endpoint can be the cluster IP (e.g. https://{couchdb-service-name}.{namespace}.svc:5984) or the host exposed using a reencrypting route. | "" |
| `tenantMgmtDB.certificate` | CouchDB certificate for ema tenant management database. Need to provide if CouchDB is self-signed with third-party certificate (except for the kubernetes root CA). | "" |
| `emaAdminConsole.enabled`  | decide if enable ema admin console in chart            |  true    |
| `emaAdminConsole.replicaCount`  | replica count of ema admin console            |  3    |
| `emaAdminConsole.name`  | ema admin console name      |  true    |
| `emaAdminConsole.failureThreshold`  | failure threshold of ema admin console in chart            |  10    |
| `emaAdminConsole.image.repository`  | repository for ema admin console service            |   ema-admin-console    |
| `emaAdminConsole.image.tag`  | tag for ema admin console service            |    1.1.0    |
| `emaAdminConsole.image.pullPolicy`  | image pull policy for ema admin console service      |    Always    |
| `emaApi.enabled`  | decide if enable ema API in chart            |  true    |
| `emaApi.replicaCount`  | replica count of ema API            |  3   |
| `emaApi.name`  | ema API name      |  true    |
| `emaApi.failureThreshold`  | failure threshold of ema API in chart            |  10    |
| `emaApi.image.repository`  | repository for ema API service            |   ema-api    |
| `emaApi.image.tag`  | tag for ema API service            |    1.1.0    |
| `emaApi.image.pullPolicy`  | image pull policy for ema API service      |    Always    |
| `emaCrawler.enabled`  | decide if enable ema crawler in chart            |  true    |
| `emaCrawler.replicaCount`  | replica count of ema crawler            |  3   |
| `emaCrawler.name`  | ema crawler name      |  true    |
| `emaCrawler.failureThreshold`  | failure threshold of ema crawler in chart            |  10    |
| `emaCrawler.image.repository`  | repository for ema crawler service            |   ema-crawler   |
| `emaCrawler.image.tag`  | tag for ema crawler service            |    1.1.0    |
| `emaCrawler.image.pullPolicy`  | image pull policy for ema crawler service      |    Always    |
| `emaDiagnosis.enabled`  | decide if enable ema diagnosis in chart            |  true    |
| `emaDiagnosis.replicaCount`  | replica count of ema diagnosis            |  3    |
| `emaDiagnosis.name`  | ema diagnosis name      |  true    |
| `emaDiagnosis.failureThreshold`  | failure threshold of ema diagnosis in chart            |  10    |
| `emaDiagnosis.image.repository`  | repository for ema diagnosis service            |   ema-diagnosis    |
| `emaDiagnosis.image.tag`  | tag for ema diagnosis service            |    1.1.0    |
| `emaDiagnosis.image.pullPolicy`  | image pull policy for ema diagnosis service      |    Always    |
| `emaDiagnosisDataloader.enabled`  | decide if enable ema diagnosis dataloader in chart            |  true    |
| `emaDiagnosisDataloader.replicaCount`  | replica count of ema diagnosis dataloader            |  3   |
| `emaDiagnosisDataloader.name`  | ema diagnosis dataloader name      |  true    |
| `emaDiagnosisDataloader.failureThreshold`  | failure threshold of ema diagnosis dataloader in chart            |  10    |
| `emaDiagnosisDataloader.image.repository`  | repository for ema diagnosis dataloader service            |   ema-diagnosis-dataloader    |
| `emaDiagnosisDataloader.image.tag`  | tag for ema diagnosis dataloader service            |    1.1.0    |
| `emaDiagnosisDataloader.image.pullPolicy`  | image pull policy for ema diagnosis dataloader service      |    Always    |
| `emaLandingPage.enabled`  | decide if enable ema landing page in chart            |  true    |
| `emaLandingPage.replicaCount`  | replica count of ema landing page            |  3   |
| `emaLandingPage.name`  | ema landing page name      |  true    |
| `emaLandingPage.failureThreshold`  | failure threshold of ema landing page in chart            |  10    |
| `emaLandingPage.image.repository`  | repository for ema landing page service            |   ema-landing-page    |
| `emaLandingPage.image.tag`  | tag for ema landing page service            |    1.1.0    |
| `emaLandingPage.image.pullPolicy`  | image pull policy for ema landing page service      |    Always    |
| `emaAuth.enabled`  | decide if enable ema auth in chart            |  true    |
| `emaAuth.replicaCount`  | replica count of ema auth            |  3   |
| `emaAuth.name`  | ema auth name      |  true    |
| `emaAuth.failureThreshold`  | failure threshold of ema auth in chart            |  10    |
| `emaAuth.image.repository`  | repository for ema auth service            |   ema-auth    |
| `emaAuth.image.tag`  | tag for ema auth service            |    1.1.0    |
| `emaAuth.image.pullPolicy`  | image pull policy for ema auth service      |    Always    |
| `emaMaximoIntegration.enabled`  | decide if enable ema maximo integration in chart            |  true    |
| `emaMaximoIntegration.replicaCount`  | replica count of ema maximo integration            |  3    |
| `emaMaximoIntegration.name`  | ema maximo integration name      |  true    |
| `emaMaximoIntegration.failureThreshold`  | failure threshold of ema maximo integration in chart            |  10    |
| `emaMaximoIntegration.image.repository`  | repository for ema maximo integration service            |   ema-maximo-integration    |
| `emaMaximoIntegration.image.tag`  | tag for ema maximo integration service            |    1.1.0    |
| `emaMaximoIntegration.image.pullPolicy`  | image pull policy for ema maximo integration service      |    Always    |
| `emaSampleApp.enabled`  | decide if enable ema sample app in chart            |  true    |
| `emaSampleApp.replicaCount`  | replica count of ema sample app            |  3   |
| `emaSampleApp.name`  | ema sample app name      |  true    |
| `emaSampleApp.failureThreshold`  | failure threshold of ema sample app in chart            |  10    |
| `emaSampleApp.image.repository`  | repository for ema sample app service            |   ema-sample-app    |
| `emaSampleApp.image.tag`  | tag for ema sample app service            |    1.1.0    |
| `emaSampleApp.image.pullPolicy`  | image pull policy for ema sample app service      |    Always    |
| `emaStudio.enabled`  | decide if enable ema studio in chart            |  true    |
| `emaStudio.replicaCount`  | replica count of ema studio            |  3    |
| `emaStudio.name`  | ema studio name      |  true    |
| `emaStudio.failureThreshold`  | failure threshold of ema studio in chart            |  10    |
| `emaStudio.image.repository`  | repository for ema studio service            |   ema-studio    |
| `emaStudio.image.tag`  | tag for ema studio service            |    1.1.0    |
| `emaStudio.image.pullPolicy`  | image pull policy for ema studio service      |    Always    |
| `emaMultiTenant.enabled`  | decide if enable ema multiTenant in chart            |  true    |
| `emaMultiTenant.replicaCount`  | replica count of ema multiTenant            |  3    |
| `emaMultiTenant.name`  | ema multiTenant name      |  true    |
| `emaMultiTenant.failureThreshold`  | failure threshold of ema multiTenant in chart            |  10    |
| `emaMultiTenant.image.repository`  | repository for ema multiTenant service            |   ema-multi-tennant   |
| `emaMultiTenant.image.tag`  | tag for ema multiTenant service            |    1.1.0    |
| `emaMultiTenant.image.pullPolicy`  | image pull policy for ema multiTenant service      |    Always    |
| `emaMonitor.enabled`  | decide if enable ema monitor in chart            |  true    |
| `emaMonitor.replicaCount`  | replica count of ema monitor            |  1    |
| `emaMonitor.name`  | ema monitor name      |  true    |
| `emaMonitor.failureThreshold`  | failure threshold of ema monitor in chart            |  10    |
| `emaMonitor.image.repository`  | repository for ema monitor service            |   ema-monitor    |
| `emaMonitor.image.tag`  | tag for ema monitor service            |    1.1.0    |
| `emaMonitor.image.pullPolicy`  | image pull policy for ema monitor service      |    Always    |
| `dashboard.enabled`  | decide if enable dashboard in chart            |  true    |
  * ingress hostname is the hostname where the Ingress controller is deployed, by default, it is deployed on proxy or master nodes. Also, user can define their own DNS entry and point to the ip address of proxy/master nodes.
You can specify all configuration values by using the `--set` parameter. For example:

```bash
$ helm install --tls --set ingress.hostname=test.domain.com
```

A subset of the above parameters map to the env variables defined in [IBM Maximo Equipment Maintenance Assistant On-Premises](https://www.ibm.com/support/knowledgecenter/SSZNPQ_1.0.0/com.ibm.ei.doc/welcome.html). For more information please refer to the [IBM Maximo Equipment Maintenance Assistant On-Premises](https://www.ibm.com/support/knowledgecenter/SSZNPQ_1.0.0/com.ibm.ei.doc/welcome.html) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. 

> **Tip**: You can use the default values.yaml

## Limitations
- IBM Maximo Equipment Maintenance Assistant On-Premises can deploy into different namespace and each namespace can deploy only once instance.
- Only the `amd64` architecture is supported.

## Documentation
Find out more about IBM Maximo Equipment Maintenance Assistant On-Premises by reading the [IBM Maximo Equipment Maintenance Assistant On-Premises](https://www.ibm.com/support/knowledgecenter/SSZNPQ_1.0.0/com.ibm.ei.doc/welcome.html).

# Monitoring and logging

OpenShift comes with a Prometheus instance already available. However, this instance has been optimized for instrumentation of the Kubernetes system itself. As a result, to monitor IBM Maximo Equipment Maintenance Assistant On-Premises, cluster admin need to install and configure the separate standalone prometheus server in the same project where you install the IBM Maximo Equipment Maintenance Assistant On-Premises. IBM Maximo Equipment Maintenance Assistant On-Premises provide app and instance level monitoring metrics and export to /metrics by NPM prom client in ema-monitor service so that the standalone prometheus server can pull it after your configuration. You can check the exported metrics details by ema-monitor service https://ema-monitor-service:443/metrics. As ema-monitor service is not exposed as OpenShift container platform route, you can [use Port Forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) feature to 
export to your local port.

Furthemore, depending on your requirement you can deploy the separate Grafana/prometheus instance for the IBM Maximo Equipment Maintenance Assistant On-Premises Monitoring .

### Prometheus installation and configuration.
OpenShift have provided [prometheus templates](https://github.com/openshift/origin/tree/master/examples/prometheus) and [grafana template](https://github.com/openshift/origin/tree/master/examples/grafana) to make Prometheus/Grafana installation on OpenShift relatively pain free.

After you have Prometheus/Grafana installed, configure your prometheus scrape config file to contain the ema-monitor-service metrics.
`Prometheus config to contain the ema-monitor-service part`
```
scrape_configs:
...
  - job_name: 'ema'
    static_configs:
    - targets: ['ema-monitor-service:443']
    scheme: https
    tls_config:
      cert_file: /etc/tls/private/tls.crt
      key_file: /etc/tls/private/tls.key
      insecure_skip_verify: true

```
**Tips**:  
Recommend that you install the standalone Prometheus to the same namespace as IBM Maximo Equipment Maintenance Assistant. Otherwise you need to replace **ema-monitor-service:443** with **ema-monitor-service.<EMA_NAMESPACE>.svc.cluster.local:443** in the above configuration. Use the IBM Maximo Equipment Maintenance Assistant namespace to replace <EMA_NAMESPACE>.

The above certificate (tls.crt, tls.key) is the OpenShift self-signed certificate and created as secrets **prometheus-tls** during prometheus server installation. It is usually mounted to the above path in prometheus oauth proxy container **prom-proxy**. Also, modify the statefulset by **oc edit statefulset prom** and mount it to prometheus container **prometheus** as well.

Also ensure the arguments **-openshift-delegate-urls={"/": {"resource": "namespaces", "verb": "get"}}** is configured to the prometheus oauth proxy container **prom-proxy** and also need to give the prometheus service account **prom** the auto delegation role by **oc adm policy add-cluster-role-to-user system:auth-delegator system:serviceaccount:<EMA_NAMESPACE>:prom** to get the standalone prometheus server worker within OpenShift authentication framework.

You also can add the prometheus to your grafana as a datasource and import the predefined IBM Maximo Equipment Maintenance Assistant dashboard data/ema-grafana-dashboard.json. 
 


### Logging
IBM Maximo Equipment Maintenance Assistant On-Premises sends its logs to the standard output, and thus cluster administrators can deploy the cluster logging to see the IBM Maximo Equipment Maintenance Assistant On-Premises logs. You can import the IBM Maximo Equipment Maintenance Assistant predefined kibana dashboard data/ema-kibana-dashboard.json.

### Hot fix
## Description
Bug fixed:
Fix listing data issue caused by couchdb query return limit to 25 records by default.
API query performance improvement. 
Fix monitor issue related to external api availability prom metric.
Update related helm charts for deployment.
Add error handler in crawler when get tenant failed.
Fix nodejs express default timeout(2min) issue, increase to 10min, configurable

## Instruction
To apply the hotfix for IBM Maximo Equipment Maintenance Assistant On-Premises, you can follow the same steps described in the previous part.

The updated images of hotfix for IBM Maximo Equipment Maintenance Assistant On-Premises are as below.

Docker Images  | Tag | Description |
   --------  | -----|-----|
   ema-api | 1.1.0-hotfix.1 | ema service|
   ema-crawler | 1.1.0-hotfix.1 | ema crawler|
   ema-diagnosis | 1.1.0-hotfix.1 |ema diagnosis service|
   ema-service-provider | 1.1.0-hotfix.1 |ema service provider|
   ema-monitor| 1.1.0-hotfix.1 |ema monitor|
   ema-admin-console| 1.1.0-hotfix.1 | ema admin console |
   ema-diagnosis-dataloader | 1.1.0-hotfix.1 |ema diagnosis dataloader service|
   ema-landing-page|1.1.0-hotfix.1|ema landing page|
   ema-auth|1.1.0-hotfix.1|ema auth|
   ema-maximo-integration|1.1.0-hotfix.1|ema maximo integration|
   ema-sample-app|1.1.0-hotfix.1|ema sample app|
   ema-studio|1.1.0-hotfix.1|ema studio|
   ema-multi-tenant|1.1.0-hotfix.1|ema multi tenant|




