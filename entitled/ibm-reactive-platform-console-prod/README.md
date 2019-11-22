# IBM Reactive Platform Console

The [IBM Reactive Platform Console](https://www.ibm.com/marketplace/reactive-platform) enables you to monitor applications running on IBM Cloud Platform.

## Introduction
The IBM Reactive Platform Console provides visibility for Key Performance Indicators (KPIs), reactive metrics, monitors and alerting, and includes a large selection of ready-to-use dashboards. This Console delivers real value during development, testing, and staging as well as during production. The Console helps you to manage the complexities of distributed applications and focus on building core business value.

## Chart Details
This Helm chart will install the following:
* An IBM Reactive Platform Console user interface using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to display the information generated from the following deployments: 
    * A Prometheus server as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to collect and visualize time series data relating to applications.
    * An Alertmanager as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to route alerts to many different integration points, including Slack, PagerDuty, and others.
    * Grafana as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to enable [predefined dashboards](https://developer.lightbend.com/docs/telemetry/current/visualizations/grafana.html#grafana-dashboards) from Lightbend Telemetry.
    * Kubernetes state metrics as a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to generate and expose cluster-level metrics, see [here](https://developer.lightbend.com/docs/console/current/installation/rbac.html#kubernetes-state-metrics) for more details.


The Console provides out-of-the-box support for any application instrumented to export metrics to Prometheus. [Akka](https://akka.io/), [Lagom](https://www.lagomframework.com/), and [Play](https://www.playframework.com/) applications that include [Lightbend Telemetry](https://developer.lightbend.com/docs/telemetry/current/home.html) (formerly called Cinnamon) provide even deeper insights and can take advantage of pre-built Grafana dashboards. The IBM Reactive Console features include the following:
* Cluster View of running workloads
* Auto monitoring of application health for Akka/Play/Lagom applications
* Preconfigured Grafana dashboard
* Preinstalled Lightbend Telemetry Grafana dashboards

## Prerequisites
* Helm 2.9.1 or later
* Kubernetes 1.12.4 or later
* IBM Cloud Private 3.1.2 or later
* Dedicated IBM Cloud Private Namespace
* If you are using Persistent Volumes, the cluster’s DefaultStorageClass is used and the required storage can be seen in the Resources Required section
* Cluster Administrator access is needed for installation

### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.

The predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the IBM Cloud Private user interface.
From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
Custom PodSecurityPolicy definition:

```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
        name: ibm-reactive-platform-console-prod-psp
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
Custom ClusterRole for the custom PodSecurityPolicy:

```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
        name: ibm-reactive-platform-console-prod-clusterrole
    rules:
    - apiGroups:
        - extensions
        resourceNames:
        - ibm-reactive-platform-console-prod-psp
        resources:
        - podsecuritypolicies
        verbs:
        - use
```
For more information about PodSecurityPolicy definitions, see the [IBM Cloud Private documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/security.html).

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-reactive-platform-console-prod-scc
    readOnlyRootFilesystem: false
    allowedCapabilities:
    - CHOWN
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    - NET_BIND_SERVICE
    seLinux:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    runAsUser:
      type: RunAsAny
    fsGroup:
      rule: RunAsAny
    volumes:
    - configMap
    - secret
    ```

## Resources Required
* Default CPU (total): 900m
* Default RAM (total): 650Mi

If using persistent storage:  
* Default Storage: 

| Parameter                  | Description                                     | Default |
| -----------------------    | ---------------------------------------------   | -------------- |
| `prometheusVolumeSize`     | Size of the Prometheus volume (Used for storing prometheus data and custom monitors) | `256Gi` |
| `alertmanagerVolumeSize`   | Size of the Alertmanager volume (Used for saving [silences](https://prometheus.io/docs/alerting/alertmanager/#silences))  | `256Gi` |
| `esGrafanaVolumeSize `     | Size of the Grafana volume (Used for saving custom dashboards, plugins, and users) | `256Gi` |

## Installing the Chart
Installing the Helm chart deploys a single IBM Reactive Platform Console instance.

This helm chart can only be installed by a user with Cluster Administrator access. This is needed for the chart to create ClusterRole and ClusterRoleBinding resources in order to monitor details of Reactive Platform based applications.

### Pre-Installation Set-Up
1. For this pre-installation set-up you will need to use the Kubernetes command line tool. If you do not have the Kubernetes command line tool set up, see [Accessing your cluster from the kubectl CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/cfc_cli.html) for instructions.
For IBM Cloud Private on OpenShift, you will also need the OpenShift CLI `oc`

1. From the Kubernetes command line tool, create the namespace in which to deploy the service. Use the following command to create the namespace:
    ```
    kubectl create namespace {namespace-name}
    ```
    or using IBM Cloud Private on OpenShift:
    ```
    oc new-project {namespace-name}
    ```
    `{namespace-name}` is the name you wish to use for the namespace
1. The ibm-reactive-platform-console chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation of the chart (as stated in the PodSecurityPolicy Requirements section). To ensure this namespace has the correct PodSecurityPolicy, enter the following command:
    ```
    kubectl -n {namespace-name} create rolebinding ibm-anyuid-clusterrole-rolebinding --clusterrole=ibm-anyuid-clusterrole --group=system:serviceaccounts:{namespace-name}
    ```
    For IBM Cloud Private on OpenShift, you will instead need to bind a security context constraint to the namespace, using the following command
    ```
    oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:{namespace-name}
    ```
1. In order to upload the PPA archive you will need to [Configure authentication for the Docker CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_images/configuring_docker_cli.html)
1. If your image repository requires credentials in order to pull an image, then you will have to create a secret containing those credentials. You can do this using the following command:
    ```
    kubectl -n {namespace-name} create secret docker-registry {secret-name} --docker-server={cluster_CA_domain} --docker-username={your_username} --docker-password={your_password}
    ```
    * Replace `{namespace-name}` with the Docker namespace in which you wish to host the Docker image. This is the namespace you created in Step 1 of the pre-installation set-up.
    * Replace `{secret-name}` with the name of your secret.
    * Replace `{cluster_CA_domain}` with your IBM Cloud Private cluster domain and port number, often referred to as `{icp-url}`.
    * Replace `{your_username}` with your own credentials.
    * If using the internal container registry on OpenShift, replace `{your_password}` with your login token. You can obtain this by running the command `oc whoami -t`. Otherwise, replace this with your credentials.

    You will need to add your {secret-name} to the `values.yaml` file or your customised values override file (see the Installing the Chart through the CLI section for more information).

### Uploading the PPA archive to IBM Cloud Private
To load the file from Passport Advantage into IBM Cloud Private, you must first login to your IBM Cloud Private instance through the cloudctl CLI. As the uploading of the archive loads the images required for the deployment to the private image repository you must also login via the docker login command.


Once logged in, enter the following command in the IBM Cloud Private CLI:
```
    cloudctl catalog load-archive --archive {compressed_file_name} [ --registry {registry} ]
```
* Replace `{compressed_file_name}` with the name of the file that you downloaded from Passport Advantage.
* `--registry` is optional and if left out the images will be uploaded to the registry associated with the default cluster CA domain and the current targeted namespace. Otherwise replace `{registry}` with the repository and namespace you wish to upload the images to.

See the [IBM Cloud Private Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/cli_catalog_commands.html#load-archive) for more information on this command.

Loading the file into IBM Cloud Private adds the images needed into the local IBM Cloud Private image repository and adds the helm chart to IBM Cloud Private's internal Helm repository called `local-charts`. The chart will then be displayed in IBM Cloud Private's catalog enabling installation of the chart through the UI.

### Installing the Chart through the UI
To install the chart through the UI, first search for the helm chart in IBM Cloud Private's catalog by searching for: "ibm-reactive-platform-console". 
Once found, select the configure button to configure all of the values needed for installation of the chart. For a list of the configurable parameters and their default values please see the Configuration section below.
Once all necessary configuration parameters have been set, select "Install" to install the chart.

### Installing the Chart through the CLI
First, run the following command to download the chart from the IBM Cloud Private Cloud Private repository:
```
    wget https://{cluster_CA_domain}:8443/helm-repo/requiredAssets/{chart-archive-file} --no-check-certificate
```
* Replace `{chart-archive-file}` with the name of the downloaded file that contains the Helm chart, e.g. `ibm-reactive-platform-console-1.0.1.tgz`.

Following this, extract the files from the TGZ file by using the following command:
```
    tar -xvzf /path/to/{chart-archive-file}
```
Replace `{chart-archive-file}` with the name of the downloaded file that contains the Helm chart.

Once the TAR file has been extracted, the images need to be uploaded to your private repository.

Then the parameters in the `values.yaml` file need to be configured:
* First, make a copy of the values.yaml file and rename it (e.g. `my-override.yaml`)
* In your copy of the file, remove all but the configuration settings that you want to replace with your own values
* Customise the values you want to replace with your own values. For a list of the configurable parameters and their default values please see the Configuration section below. Ensure that the values
for `imageCredentials.registry` and `imageCredentials.credentials` match those of the private repository you have uploaded the images to.

After this customisation, the chart can be installed from the Helm CLI. Enter the following command from the directory where the chart has been extracted to:
```
    helm install --tls --values {override-file-name} --namespace {namespace-name} --name {my-release} {chart-directory}
```
* Replace `{my-release}` with the name for your release.
* Replace `{override-file-name}` with the path to the file that contains the values that you want to override from the `values.yaml` file provided with the chart package. For example: `ibm-reactive-platform-console/my-override.yaml`
* Replace `{namespace-name}` with the namespace you created for the service.
* Replace `{chart-directory}` with the name of the extracted chart directory.

## Verifying the Chart
See the NOTES.txt file associated with this chart for verification instructions.

## Uninstalling the Chart
To uninstall/delete the `{my-release}` deployment:
```
    helm delete {my-release} --purge --tls
```
The command removes all the Kubernetes components associated with the chart and deletes the release.  
You can find the deployment with ```helm list --all``` and searching for an entry with the chart name "ibm-reactive-platform-console".
If you have used a secret, please note you will need to manually delete it using the following command:
``` 
    kubectl delete secret {secret-name}
```

## Configuration
The following table lists the configurable parameters of the ibm-reactive-platform-console chart and their default values.

| Parameter                  | Description                                     | Default |
| -----------------------    | ---------------------------------------------   | -------------- |
| `imagePullPolicy`          | Docker image pull policy (Always, Never, or IfNotPresent)  | `IfNotPresent` |
| `prometheusDomain`         | Prometheus annotation domain | `prometheus.io` |
| `podUID`                   | Run pods as the given UID except where it is necessary to run as root  | `65534` |
| `imageCredentials.registry`| Image Registry if the images have been uploaded to a different private repository than your IBM Cloud Private instance | `nil` |
| `imageCredentials.credentials`| Image pull secret - If using a registry that requires authentication, the name of the secret containing credentials  | `nil` |
| `createAlertManager`       | Create Alert Manager - Tick to deploy a new Alert Manager. Otherwise modify the `alertManagers` list to use existing Alert Manager(s)  | `true` |
| `alertManagers`            | Comma separated list of alert manager addresses (can be k8s local DNS service names)| `alertmanager:9093` |
| `alertManagerConfigMap`    | Alert manager ConfigMap. Set to the name of a ConfigMap, with a file alertmanager.yml | `alertmanager-default` |
| `exposeServices`           | Service type for exposing Console outside the cluster. If set to anything other than false also set the esConsoleExposePort  | `NodePort` |
| `esConsoleExposePort`      | If Expose Console is set to NodePort or LoadBalancer, the console will be exposed on this port | `30080` |
| `esConsoleURL`             | URL for external access to the console (Optional). e.g. If external access to the console via an ingress is available at http://console.mycorp.com:8080, then set esConsoleURL=http://console.mycorp.com:8080  | `nil` |
| `defaultCPURequest`        | Default resource requests for CPU  per container (0.1) | `100m` |
| `prometheusCPURequest`     | Set to override the default value for the Prometheus container resource requests for CPU | `nil` |
| `defaultMemoryRequest`     | Default resource requests for memory per container | `50Mi` |
| `prometheusMemoryRequest`  | Set to override the default value for the Prometheus container resource requests for memory | `500Mi` |
| `defaultMemoryLimit`       | Default resource limits for memory per container | `50Mi` |
| `prometheusMemoryLimit`    | Set to override the default value for the Prometheus container resource limits for memory | `500Mi` |
| `usePersistentVolumes`     | Select to use persistent volumes, otherwise emptyDir volumes are used  | `false` |
| `prometheusVolumeSize`     | Prometheus volume size - used for storing metrics data  | `256Gi` |
| `alertmanagerVolumeSize`   | Alert Manager volume size - used for storing silences  | `32Gi` |
| `esGrafanaVolumeSize`      | Grafana volume size - used for storing users, custom dashboards, and plugins | `32Gi` |
| `esGrafanaEnvVars`         | Optional Grafana Environment Variables  | `nil` |


## Limitations
* Only amd64 is supported
* The chart must be loaded into the catalog by a Cluster Administrator
* The chart can only be deployed by a Cluster Administrator

## Documentation
Find out more about [IBM Reactive Platform](https://ibm.biz/reactive-platform-docs).
