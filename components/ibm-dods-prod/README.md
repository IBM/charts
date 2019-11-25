# ibm-dods-prod
IBM Decision Optimization for Data Science (DODS) is an add-on to Watson Studio / Cloud Pack for Data that provides
advanced decision capabilities.

## Introduction
This chart is an add-on to Watson Studio / Cloud Pack for Data that provides advanced decision capabilities.

## Chart Details
This chart contains following components:
- dd-init: initialization job on install/uninstall. This setup libraries in user-home PV.
- dd-scenario-api: backend APIs for the decision optimization features
- dd-scenario-ui: user interface of the decision optimization features
- dd-cognitive: backend APIs for the modeling assistant

## Prerequisites
This chart pre-reqs the CP4D, Watson Studio and WML base charts. These chart sets up the PV and brings in essential services like user management, nginx, metastoredb, etc. and actual solve capabilities.

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: `cpd-user-scc` provided by CP4D has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart. This shall be the
case as CP4D installation is a prerequisite.

This predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has also been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

You can also define a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. For example, from the user interface you can copy and paste the following snippets to setup the custom SecurityContextConstraints
- Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-dods-prod-scc
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
Cumulatively the minimum CPU required by all deployments (with 2 replicas each, the default) is 1800m, and
the minimum memory is 3 Gb.

## Installing the Chart

The recommended way to install this chart is using the `cpd` install utility shipped with Cloudpak for Data parent product.
see the [IBM Cloud Pak for Data documentation](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ)

Alternatively, you can install it with helm: to install the chart with the release name `my-release`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release stable/ibm-dods-prod
```

The command deploys <Chart name> on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release. 
If the uninstall command above seems blocked for a long time, it might be because the uninstallation hook
can not run. You may in this case retry it with an additional parameter `--no-hooks` to force deletion.

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `userHomePVC.persistence.existingClaimName` | Existing PVC Name for User Home | `user-home-pvc` |
| `architecture` | Architecture scheduling preferences | `amd64` |
| `serviceAccount` | Service account to run the services | `cpd-viewer-sa` |
| `dockerRegistryPrefix` | Docker registry prefix where our image are stored | `docker-registry.default.svc:5000/zen` |
| `image.pullPolicy` | Default pull policy for images | `IfNotPresent` |
| `ddScenarioApi.replicas` | Number of replicas for the backend APIs service | `1` |
| `ddScenarioApi.resources.limits.cpu` | Maximum cpu for the backend APIs service | `1000m` |
| `ddScenarioApi.resources.limits.cpu` | Maximum memory for the backend APIs service | `1024Mi` |
| `ddScenarioApi.resources.requests.cpu` | Initial cpu request for the backend APIs service | `200m` |
| `ddScenarioApi.resources.requests.cpu` | Initial cpu request for the backend APIs service | `512Mi` |
| `ddScenarioUi.replicas` | Number of replicas for the user interface service | `1` |
| `ddScenarioUi.resources.limits.cpu` | Maximum cpu for the user interface service | `500m` |
| `ddScenarioUi.resources.limits.cpu` | Maximum memory for the user interface service | `1024Mi` |
| `ddScenarioUi.resources.requests.cpu` | Initial cpu request for the user interface service | `200m` |
| `ddScenarioUi.resources.requests.cpu` | Initial cpu request for the user interface service | `512Mi` |
| `ddCognitive.replicas` | Number of replicas for the modeling assistant service | `1` |
| `ddCognitive.resources.limits.cpu` | Maximum cpu for the modeling assistant service | `1000m` |
| `ddCognitive.resources.limits.cpu` | Maximum memory for the modeling assistant service | `2048Mi` |
| `ddCognitive.resources.requests.cpu` | Initial cpu request for the modeling assistant service | `500m` |
| `ddCognitive.resources.requests.cpu` | Initial cpu request for the modeling assistant service | `512Mi` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. 

In most cases, the default values are correct and shall not be changed.

## Storage
The chart stores some info in the pre-existing user-home PV created by CP4D. It does not create or require any other storage.

## Limitations
This chart is not self sufficient. It has dependency on other charts. 

