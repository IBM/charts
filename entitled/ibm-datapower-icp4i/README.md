# IBM DataPower Gateway

![IDG Logo](https://avatars1.githubusercontent.com/u/8836442?v=4&s=200)

[IBM® DataPower Gateway](http://www-03.ibm.com/software/products/en/datapower-gateway) is a purpose-built security and integration gateway that addresses the business needs for mobile, API, web, SOA, B2B, and cloud workloads. It is designed to provide a consistent configuration-based approach to security, governance, integration and routing.

[//]: # (Chart Name Start)
## Chart Name
IBM DataPower Gateway Virtual Edition for IBM Cloud Pak for Integration

[//]: # (Chart Name End)

## Introduction
This chart deploys an IBM DataPower Gateway cluster of replicas into a Kubernetes environment. Users should build their applications into the firmware image provided with this chart. This chart contains the concept of patterns. Users with access to the chart can add their own custom patterns. The provided example pattern,  the `restProxy` pattern, configures the DataPower node to act as a reverse proxy, directing client requests to the appropriate backend server.

## Chart Details
Deploys IBM DataPower Gateway Virtual Edition for Production or Nonproduction.
Only works with DataPower version 2018.4.1.10u.

## Prerequisites
WARNING! Not providing an adminUserSecret will result in a default, hardcoded admin password. \
A user with the Operator role is required to install this chart. \
helm and kubectl must be installed and configured on your system.

### Admin Password Secret
It is possible to change the default admin password prior to deployment by creating a password secret and passing that into the `adminUserSecret` value.

In order to replace the default admin credentials, the new credentials should be configured via Secret and `.Values.datapower.adminUserSecret` must be set to the name of the Secret containing the admin user's credentials.

The following are properties which can be used to define the admin user's credentials:
- `password-hashed`: The hashed value (see Linux `man 3 crypt` for format) of the admin user's password. Required if `password` is not defined.
- `password`: The admin user's password. Required if `password-hashed` is not defined; ignored if `password-hashed` is defined.
- `salt`: The salt value used when hashing `password` (see `man 3 crypt`). Optional; ignored when `password-hashed` is defined. (Default: 12345678)
- `method`: The name of the hashing algorithm used to hash `password`. Valid options: md5, sha256. Optional; ignored when `password-hashed` is defined. (Default: md5)

The following examples create Secrets with different values, but result in an admin user with the same credentials (and the same password hash):
-  `kubectl create secret generic admin-credentials --from-literal=password=helloworld --from-literal=salt=12345678 --from-literal=method=md5`
-  `kubectl create secret generic admin-credentials --from-literal=password=helloworld`
-  `kubectl create secret generic admin-credentials --from-literal=password-hashed='$1$12345678$8.nskQfP4gQ8tk5xw6Wa8/'`

These two examples also result in Secrets with different values but identical admin credentials
-  `kubectl create secret generic admin-credentials --from-literal=password=hunter2 --from-literal=salt=NaCl --from-literal=method=sha256`
-  `kubectl create secret generic admin-credentials --from-literal=password-hashed='$5$NaCl$aOrRVimQNvZ2ZLjnAyMvT3WgaUEXoWgwkgyBrhwIg04'`
  Notice that, when setting `password-hashed`, the value must be surrounded by single-quotes

In all of the examples above, `.Values.datapower.adminUserSecret` should be set to 'admin-credentials' for the admin user to be configured.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)

The predefined PodSecurityPolicy name: ibm-anyuid-psp has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the catalog interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy allows pods to run with any UID and GID, but preventing access to the host."
      name: ibm-datapower-psp
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
      - configMap
      - emptyDir
      - projected
      - secret
      - downwardAPI
      - persistentVolumeClaim
      forbiddenSysctls:
      - '*'
    ```

### SecurityContextConstraints Requirements
This chart is designed to work with the `ibm-anyuid-scc` SCC.

* Predefined SecurityContextConstraint: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc)

- Custom SecurityContextConstraints definition:
  ```
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
      kubernetes.io/description: "This policy allows pods to run with
        any UID and GID, but preventing access to the host."
      cloudpak.ibm.com/version: "1.1.0"
    name: ibm-datapower-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowPrivilegeEscalation: true
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
  allowedFlexVolumes: []
  allowedUnsafeSysctls: []
  defaultAddCapabilities: []
  defaultAllowPrivilegeEscalation: true
  forbiddenSysctls:
    - "*"
  fsGroup:
    type: RunAsAny
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - MKNOD
  runAsUser:
    type: RunAsAny
  # This can be customized for your host machine
  seLinuxContext:
    type: RunAsAny
  # seLinuxOptions:
  #   level:
  #   user:
  #   role:
  #   type:
  supplementalGroups:
    type: RunAsAny
  # This can be customized for your host machine
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  # If you want a priority on your SCC -- set for a value more than 0
  # priority:
  ```

## Configuration
There are two approaches to installing DataPower configuration using this chart:
1. Deploy custom application configuration with configmaps
2. Building a DataPower Application Image

### 1. Deploying DataPower Application Configuration with configmaps
#### i. Adding DataPower config
New DataPower configuration can be added into DataPower by using the `datapower.additionalConfig` value. This value takes the form of a list of `domain-config` pairs.
```
datapower:
  additionalConfig:
  - domain: "default"
    config: "default-configmap"
  - domain: "newdomain"
    config: "newdomain-configmap"
```

The `config` parameter must be a configmap created directly from a standard DataPower config file.
```
kubectl create configmap default-configmap --from-file=/path/to/config.cfg
```

A user with sufficient cluster permission needs to create your configmaps before deploying.

#### ii. Adding local files
Local files, such as gatewayscript files, can be added into the DataPower deployment by using the `datapower.additionalLocal` value. This value is a Kubernetes configmap of a tar file that contains all the files you want to add. This tar file must be a well-formed DataPower `local:` directory where files intended for the `default` domain are on the top level and all files intended for a different domain are in a subdirectory named for that domain.

Example tar file contents:
```
$ ls local/*
newdomain/ <default-domain-files>

local/newdomain:
<newdomain files>
```

Example tar file creation:
```
tar czf datapower-local-files.tar.gz local/*
```

Example configmap creation:
```
kubectl create configmap datapower-local-configmap --from-file=datapower-local-files.tar.gz
```

#### iii. Adding certificates
Certificates and other crypto files can be added to the DataPower `cert:` directory by using the `datapower.additionalCerts` value. This value takes the form of a list of `domain-secret` pairs with an optional `certType`.
```
datapower:
  additionalCerts:
  - domain: "default"
    secret: "some-default-cert-secret"
    certType: sharedcert
  - domain: "newdomain"
    secret: "some-newdomain-cert-secret"
    certType: usrcert
```
`certType` is an optional field that determines whether a cert is shared between domains or unique. Set to `sharedcert` for the cert to be shared across domains or `usrcert` to keep it isolated to the specified domain. The default value is `usrcert`.


The secrets are Kubernetes secrets which contain the crypto files you want to use. To create the secret from an existing crypto key-cert pair:
```
kubectl create secret generic my-secret --from-file=/path/to/key.pem --from-file=/path/to/cert.pem
```

### 2. Building a DataPower Application Image
#### i. Creating the DataPower configuration
Before you can build and deploy a DataPower Docker application you must create an export package that contains the DataPower configuration for the DataPower Docker image. You create and export the DataPower configuration outside of ICP4I on a DataPower appliance or virtual DataPower offering.

You can create the DataPower configuration using the DataPower GUI, CLI, or other management interface, which can be importing an existing export package from a secure server and using a deployment policy with deployment policy variables to modify the configuration in the export package during import. The resultant and exported configuration should be the explicit configuration for your DataPower Docker application.

The defined and imported configuration is restricted to features supported by DataPower for Docker. If you create an export package from another DataPower offering with features not supported by DataPower for Docker, these feature will be unavailable.

The easiest way to export and import packages is through the DataPower GUI, but you can use the DataPower `backup` command to do an export.

For complete information about creating the DataPower configuration, see [IBM Knowledge Center: DataPower Gateway](https://www.ibm.com/support/knowledgecenter/SS9H2Y_7.7.0/com.ibm.dp.doc/welcome.html). When within the DataPower documentation, use the search feature to find the information you need.

#### ii. Building a DataPower Docker Application
The first-class approach to build DataPower Gateway as a containerized application is to build and upload a DataPower Docker image to your repository. A DataPower Docker image is the combination of your DataPower configuration artifacts and a version-specific DataPower firmware image. Each DataPower Docker image in your repository is a purpose-built application that you can deploy without any post-deployment activities.


To build your DataPower Docker image, you must develop the application’s configuration. The easiest method is in the Docker containers on your workstation.

1. Download the version-specific DataPower firmware image from the read-only IBM Entitled Registry.

2. Create a clean working directory with the config, local, and certs subdirectories. These subdirectories will be mounted inside the container to extract the application’s configuration.

3. Grant full permission to ensure that everyone can access these subdirectories.
   ```
   chmod -R 777 config local certs
   ```

4. Start the container. The following snippet is the minimum required set of parameters.
   ```
   docker run -it –-name <name> \
   -v $(pwd)/config:/opt/ibm/datapower/drouter/config \
   -v $(pwd)/local:/opt/ibm/datapower/drouter/local \
   -v $(pwd)/certs:/opt/ibm/datapower/root/secure/usrcerts \
   -e DATAPOWER_ACCEPT_LICENSE="true" \
   -e DATAPOWER_INTERACTIVE="true" \
   -p 9090:9090 \
   <tag>
   ```
   Where `<name>` is the name of the container, and `<tag>` is generally in the `<registry-path>:<version>.<build>-<edition>` format.

5. Configure access to the DataPower GUI.
   ```
   # configure terminal
   # web-mgmt
   # admin-state "enabled"
   # exit
   ```

6. Access the DataPower Gateway to import the export package that contains your DataPower configuration.
   - To start a GUI session, enter https://localhost:9090 as the URL in your browser.
   - To start a CLI session, use the `docker attach` command.

7. After you write and test your configuration, save everything to your mounted volumes.
   - In the GUI, click Save Configuration.
   - In the CLI, issue the `write memory` command.

8. Stop the DataPower container, where <name> is the name of the container.
   ```
   docker stop -t 300 <name>
   ```
  
9. Change ownership of files owned by root.
   ```
   chown -R $USER:$USER config local certs
   ```

10. Create the Dockerfile for the DataPower Docker image. The following snippet is the most basic Dockerfile that you should require.
    ```
    FROM <tag>
    COPY config /opt/ibm/datapower/drouter/config
    COPY local /opt/ibm/datapower/drouter/local
    COPY certs /opt/ibm/datapower/root/secure/usrcerts
    USER root
    RUN chown -R drouter:drouter /opt/ibm/datapower/drouter/config \
                                 /opt/ibm/datapower/drouter/local \
                                 /opt/ibm/datapower/root/secure/usrcerts
    RUN set-user drouter
    USER drouter
    ```
    Where `<tag>` is generally in the `<registry-path>:<version>.<build>-<edition>` format.

11. With your Dockerfile, build your DataPower Docker image, where `<my-image>` is the name that differentiates various DataPower Docker images in your repository.
    ```
    docker build . -f Dockerfile -t <my-image>
    ```

12. Use the `docker push` command to upload the DataPower Docker image to your repository.

#### iii. Deploying the DataPower Docker application
When you deploy DataPower capabilities through ICP4I, you can override all parameters set in the DataPower Docker image. While defining the deployment configuration, ensure that you have the correct values for the following parameters.
- Ensure that **Pattern Name** is set to "none".
- Ensure that **DataPower image repository** is set to your repository.
- Ensure that **Image tag override** is set to the name of the DataPower Docker image in your repository.


### Values
The helm chart has the following Values that can be overriden using the Parameters fields prior to deployment.

| Value                                 | Description                                   | Default             |
|---------------------------------------|-----------------------------------------------|---------------------|
| `datapower.replicaCount`              | The replicaCount for the deployment           | 1                   |
| `datapower.image.repository`          | The image to use for this deployment          | datapower-icp4i     |
| `datapower.image.version`             | The image version to deploy                   | 2018.4.1.10u.318372u|
| `datapower.image.license`             | The license type to deploy                    | Production          |
| `datapower.image.tagOverride`         | Tag override for custom images                | N/A                 |
| `datapower.image.pullPolicy`          | Determines when the image should be pulled    | Always              |
| `datapower.image.pullSecret`          | Secret used for pulling images                | N/A                 |
| `datapower.env.workerThreads`         | Number of DataPower worker threads            | 4                   |
| `datapower.resources.limits.cpu`      | Container CPU limit                           | 8                   |
| `datapower.resources.limits.memory`   | Container memory limit                        | 64Gi                |
| `datapower.resources.requests.cpu`    | Container CPU requested                       | 4                   |
| `datapower.resources.requests.memory` | Container Memory requested                    | 8Gi                 |
| `datapower.webGuiManagementState`     | WebGUI Management admin state                 | disabled            |
| `datapower.webGuiManagementPort`      | WebGUI Management port                        | 9090                |
| `datapower.gatewaySshState`           | SSH admin state                               | disabled            |
| `datapower.gatewaySshPort`            | SSH Port                                      | 9022                |
| `datapower.restManagementState`       | REST Management admin state                   | disabled            |
| `datapower.restManagementPort`        | REST Management port                          | 5554                |
| `datapower.xmlManagementState`        | XML Management admin state                    | disabled            |
| `datapower.xmlManagementPort`         | XML Management port                           | 5550                |
| `datapower.snmpState`                 | SNMP admin state                              | enabled             |
| `datapower.snmpPort`                  | SNMP interface port                           | 1161                |
| `datapower.flexpointBundle`           | ILMT Flexpoint Bundle type                    | N/A                 |
| `datapower.additionalConfig`          | List of domain-config pairs                   | N/A                 |
| `datapower.additionalLocal`           | Configmap containing local.tar                | N/A                 |
| `datapower.additionalCerts`           | List of domains-cert pairs                    | N/A                 |
| `health.livenessPort`                 | Listening port for livenessProbe              | 7879                |
| `health.readinessPort`                | Listening port for readinessProbe             | 7878                |
| `service.name`                        | Name to add to service                        | datapower           |
| `patternName`                         | The name of the datapower pattern to load     | none                |
| `restProxy.backendURL`                | The backend URL datapower will proxy          | https://www.ibm.com |
| `restProxy.containerPort`             | The backend URL datapower will proxy          | 8443                |
| `crypto.frontsideSecret`              | Secret containing key and cert data           | N/A                 |
| `dashboard.enabled`                   | Boolean determining if a dashboard is loaded  | enabled             |


The `patternName` specifies the configuration included with the deployment. Pattern-specific options are prefixed by the `patternName` in values.yaml.
The available patterns are:

- `restProxy` : Configures the DataPower Gateway as a proxy for RESTful services, the service is available over HTTP or HTTPS(if crypto parameters are set) at `restProxy.containerPort` and proxies to `restProxy.backendURL`.
- `none` : Does not include any configuration. You may only interact with DataPower by using `kubectl attach`.
> **Tip**: List all releases using `helm list --tls`

[//]: # (Resources Required Start)
## Resources Required
Minimum resources per pod: 4 CPU and 4 GB RAM

[//]: # (Resources Required End)

## Installing the Chart
Install chart via the catalog interface.
Users installing this chart must have at least "edit" permissions for the target namespace.

To deploy with HTTPS you must define `crypto.frontsideSecret`, which is the name of the Kubernetes secret containing data key.pem and cert.pem. These files are in the standard key and cert format. Create this secret prior to deploying. Create secret using `kubectl create secret generic <mycryptosecret> --from-file=key.pem --from-file=cert.pem`. Without `crypto.frontsideSecret` defined, DataPower will use HTTP.

This chart has the capability to load an example Grafana dashboard utilizing Prometheus metrics from the DataPower pod. By enabling .Values.dashboard.enabled, the dashboard will be automatically loaded if the cluster has the requisite monitoring capabilities. When first loaded, a data source may not be selected for each of the Grafana graphs. A user with proper permissions must select the Promethus data source for each graph in the dashboard. Don't worry if this isn't done right away, Prometheus stores the whole time-series so your monitoring data will not be lost if the dashboard is not properly configured.

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart
To uninstall/delete the `my-release` deployment, navigate to Helm Releases and delete there.



[//]: # (Limitations Start)
## Limitations
- None, this chart is available for production.
- No limit on number of deployments.
- No limit on number of deployments per namespace.
- Limited to amd64 architectures.

[//]: # (Limitations End)

## Documentation
See NOTES.txt associated with this chart for verification instructions


> **Tip**: You can use the default [values.yaml](values.yaml)


[View the IBM DataPower Gateway Product Page](https://www.ibm.com/products/datapower-gateway/resources)

[View the IBM DataPower Gateway Documentation](https://www.ibm.com/support/knowledgecenter/SS9H2Y)


_Copyright©  IBM Corporation 2017,2020. All Rights Reserved._

_The IBM DataPower Gateway logo is copyright IBM and is provided for use for the purposes of IBM CloudPak for Integration. You will not use the IBM DataPower Gateway logo in any way that would diminish the IBM or IBM DataPower Gateway image. IBM reserves the right to end your privilege to use the logo at any time in the future at our sole discretion. Any use of the IBM DataPower Gateway logo affirms that you agree to adhere to these conditions._
