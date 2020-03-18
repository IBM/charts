# Aspera High-Speed Transfer Server

## Introduction

The IBM Aspera High-Speed Transfer Server (HSTS) is a versatile software application that allows an unlimited number of concurrent users to transfer files of any size at top speed using an Aspera client. Server administrators enjoy a powerful set of management features, including the ability to monitor and control the transfer queue in real time, adjust bandwidth targets on the fly, and configure granular access-control settings.

## Chart Details

This chart installs an HSTS cluster with the following resources:

Deployments

* Aspera Node Master (1 pod)
* Aspera Node API (3 pods by default)
* Aspera Event Journal (1 pod)
* Aspera ascp Loadbalancer (1 pod)
* Aspera Node Loadbalancer (1 pod)
* Aspera Loadbalancer (1 pod)
* Aspera Stats (1 pod)
* Aspera ascp Swarm (1 pod)
* Aspera Node Swarm (1 pod)
* Aspera TCP Proxy (1 pod)
* Redis Server (3 pods)
* Redis Sentinel (3 pods)

Services

* Aspera TCP Proxy
* Aspera Node API
* Aspera Loadbalancer
* Aspera Stats
* Aspera Swarm
* Aspera Event Journal
* Redis HA

## Prerequisites

* An existing Kafka deployment.
* An Aspera Proxy Server installation configured for reverse proxy, external to the Kubernetes cluster.
* The PersistentVolumeClaim provided for transfer storage (**asperanode.volume.existingClaimName**) must have access mode **RWX**.
* Role-based access control (RBAC) must be configured before you deploy Aspera HSTS. See PodSecurityPolicy Requirements and Additional RBAC Requirements below.
* Three Secret objects must be created before you install this chart:
  * Node administrator secret (**nodeAdminSecret**) - Contains the username (**NODE_USER**) and password (**NODE_PASS**) for the node user that will be created during the installation.
  * Access key secret (**accessKeySecret**) - Contains the access key ID (**ACCESS_KEY_ID**) and secret (**ACCESS_KEY_SECRET**) for the access key that will be created during the installation. This access key with have its storage set to the volume mount path.
  * Aspera server secret (**serverSecret**) - Contains the Aspera license (**ASPERA_LICENSE**) and token encryption key (**TOKEN_ENCRYPTION_KEY**) that will be used for all asperanoded containers.

### Required Services

Kafka is required as part of an Aspera HSTS installation. At this time, Kafka is not deployed as part of this chart and will need to be provisioned separately.

It is recommended to use IBM Event Streams as the Kafka backend for production deployments.

### Aspera Reverse Proxy

In order to facilitate transfers originating from outside the Kubernetes cluster, an Aspera Proxy Server instance is required, and must be configured as a reverse proxy (_rproxy_). The intent is for external traffic to be directed at this rproxy instance, which in turn routes the traffic to the corresponding Aspera services inside the Kubernetes cluster (exposed via a NodePort).

You must have the following on hand before you deploy this chart:

* The address of the Aspera reverse proxy instance.
* [Optional] The public SSH key that is created as part of the Aspera reverse proxy installation. The public key(s) are provided via the **receiver.authorizedKeys** value.

After you deploy this chart, you must update the **aspera.conf** of the rproxy with the corresponding NodePort that exposes the TCP proxy service. To view the TCP service:

  ```bash
    $ kubectl get svc -l release=RELEASENAME,component=tcp-proxy
  NAME                       TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)           AGE
  RELEASENAME-aspera-hsts-tcp-proxy   LoadBalancer   10.0.0.54    <pending>     33001:32171/TCP   6d
  ```

Example rproxy **aspera.conf** for a TCP proxy service exposed via NodePort **32171** on a Kubernetes node (**10.24.34.16**):

  ```xml
  <?xml version='1.0' encoding='UTF-8'?>
  <CONF version="2">
      <server>
          <rproxy>
              <enabled>true</enabled>
              <rules>
                  <rule>
                      <udp_port_reuse>false</udp_port_reuse>
                      <squash_user>xfer</squash_user>
                      <keyfile>/opt/aspera/proxy/etc/ssh_keys/id_rsa</keyfile>
                      <host>10.24.34.16:32171</host>
                  </rule>
              </rules>
          </rproxy>
      </server>
  </CONF>
  ```

### Node Labels

In order to ensure high availability, the Aspera Swarm services will attempt to create a configurable number of pods on each node in the Kubernetes cluster.

The nodes on which the receiver pods are running can be restricted via the **nodeLabels** values.

For example, the following would restrict pods to nodes with the `node-role.kubernetes.io/worker=true` label.

```yaml
ascpSwarm:
  config:
    nodeLabels:
      node-role.kubernetes.io/worker: "true"

nodedSwarm:
  config:
    nodeLabels:
      node-role.kubernetes.io/worker: "true"
```

### Aspera License

Only a single Aspera license file is used as part of this chart deployment. In the event that multiple Aspera licenses are available, you are only required to provide one license via a secret.

At this time, only on-premises licenses are supported.

### Storage Permissions

If using an existing PersistentVolumeClaim, it is required that the `persistence.fsGroup` (default `1001`) has read and write permissions.

There are two options to ensure proper permissions:

1) Set `persistence.fsGroup` value to be the existing group id
2) Update the permissions of the existing directory

To update the permissions, mount the volume temporarily or access the host machine. The permissions can be updated with the following commands (using `fsGroup` as `1001` and `/aspera` as the example PVC root):

```bash
chown -R :1001 /aspera
chmod -R ug+rw /aspera
chmod o-t /aspera
```

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement, there may be cluster-scoped as well as namespace-scoped actions that you must do before and after installation.

The predefined PodSecurityPolicy name [`ibm-anyuid-hostaccess-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy that can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the **pak_extension** pre-install directory:

* **From the user interface**, you can copy and paste the following snippets to enable the custom PodSecurityPolicy:
  * Custom PodSecurityPolicy definition:

    ```yaml
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-aspera-hsts-icp4i-psp
    spec:
      privileged: false
      hostNetwork: false
      hostPorts:
        - min: 34001
          max: 34101
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

  * Custom ClusterRole for the custom PodSecurityPolicy:

    ```yaml
    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: ibm-aspera-hsts-icp4i-psp-clusterrole
    rules:
    - apiGroups: ['policy']
      resources: ['podsecuritypolicies']
      verbs:     ['use']
      resourceNames:
      - ibm-aspera-hsts-icp4i-psp
    ```

* **From the command line**, you can run the setup scripts included under **pak_extensions**.

  As a cluster admin, the pre-installation instructions are located at:
  **pre-install/clusterAdministration/createSecurityClusterPrereqs.sh**

  As team admin/operator, the namespace-scoped instructions are located at:
  **pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh**

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-hostaccess-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

* From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  * Custom SecurityContextConstraints definition:

    ```yaml
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-aspera-hsts-icp4i-scc
    readOnlyRootFilesystem: false
    allowedCapabilities: []
    allowHostPorts: true
    seLinuxContext:
      type: RunAsAny
    supplementalGroups:
      type: MustRunAs
      ranges:
      - max: 65535
        min: 1
    runAsUser:
      type: MustRunAsNonRoot
    fsGroup:
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
    ```

* **From the command line**, you can run the setup scripts included under **pak_extensions**.

  As a cluster admin, the pre-installation instructions are located at:
  **pre-install/clusterAdministration/createSecurityClusterPrereqs.sh**

  As team admin/operator, the namespace-scoped instructions are located at:
  **pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh**

### Additional RBAC Requirements

The following RBAC resources are also required before you deploy the chart. The above included scripts (**createSecurityClusterPrereqs.sh** and **createSecurityNamespacePrereqs.sh**) will create these:

#### Cluster Admin

* ClusterRole

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-aspera-hsts-icp4i-clusterrole
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```

#### Namespace User

Substitute `{{ NAMESPACE }}` with the namespace the chart will be deployed in.

* ClusterRoleBinding

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ibm-aspera-hsts-icp4i-crb
subjects:
- kind: ServiceAccount
  name: ibm-aspera-hsts-icp4i
  namespace: "{{ NAMESPACE }}"
roleRef:
  kind: ClusterRole
  name: ibm-aspera-hsts-icp4i-clusterrole
  apiGroup: rbac.authorization.k8s.io

```

* Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ibm-aspera-hsts-icp4i-role
rules:
- apiGroups: [""]
  resources: ["pods", "configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: [secrets"]
  verbs: ["get", "list", "watch"]
```

* RoleBinding

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ibm-aspera-hsts-icp4i-psp-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ibm-aspera-hsts-icp4i-psp-clusterrole
subjects:
- kind: Group
  name: system:serviceaccounts:{{ NAMESPACE }}
  apiGroup: rbac.authorization.k8s.io

```

* RoleBinding

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ibm-aspera-hsts-icp4i-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ibm-aspera-hsts-icp4i-role
subjects:
- kind: ServiceAccount
  name: ibm-aspera-hsts-icp4i
  namespace: "{{ NAMESPACE }}"
```

* ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
imagePullSecrets:
  - name: sa-{{ NAMESPACE }}
metadata:
  name: ibm-aspera-hsts-icp4i
  namespace: "{{ NAMESPACE }}"

```

* Secret Generation Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ibm-sch-secret-gen
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["list", "create", "delete"]
```

* Secret Generation RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ibm-sch-secret-gen
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ibm-sch-secret-gen
subjects:
- kind: ServiceAccount
  name: ibm-sch-secret-gen
  namespace: "{{ NAMESPACE }}"
```

* Secret Generation ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ibm-sch-secret-gen
  namespace: "{{ NAMESPACE }}"
```


## Resources Required

The following tables describe the default usage and limits per pod.

### Memory

|Pod|Memory Requested|Memory Limit
|--|--|-
| Redis Server | 100Mi | 5Gi |
| Redis Sentinel | 5Mi | 100Mi |
| Aspera Event Journal | 10Mi | 200Mi |
| Aspera HSTS HTTP Loadbalancer | 50Mi | 150Mi |
| Aspera HSTS ascp Loadbalancer | 50Mi | 150Mi |
| Aspera HSTS ascp Swarm | 200Mi | 200Mi |
| Aspera HSTS Node Swarm | 200Mi | 200Mi |
| Aspera HSTS Stats | 100Mi | 200Mi |
| Aspera HSTS TCP Proxy | 20Mi | 200Mi |
| Aspera HSTS HTTP Proxy | 100Mi | 200Mi |
| Aspera HSTS ascp Transfer | 50Mi | 700Mi |
| Aspera HSTS Node Transfer | 100Mi | 700Mi |

### CPU

|Pod|CPU Requested|CPU Limit
|--|--|--|
| Redis Server | .01 | .2 |
| Redis Sentinel | .005 | .02 |
| Aspera Event Journal | .01 | .2 |
| Aspera HSTS HTTP Loadbalancer | .01 | .05 |
| Aspera HSTS ascp Loadbalancer | .01 | .05 |
| Aspera HSTS ascp Swarm | .01 | .1 |
| Aspera HSTS Node Swarm | .01 | .1 |
| Aspera HSTS Stats | .002 | .01 |
| Aspera HSTS TCP Proxy | .005 | .05 |
| Aspera HSTS HTTP Proxy | .005 | .05 |
| Aspera HSTS ascp Transfer | .01 | .5 |
| Aspera HSTS Node Transfer | .02 | .6 |

## Installing the Chart

### 1. Create the required secrets

```bash
kubectl create secret generic aspera-server \
--from-file=ASPERA_LICENSE="./aspera-license" \
--from-literal=TOKEN_ENCRYPTION_KEY="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 40)"
```

### 2. [Optional] Create Secrets to use existing credentials or certificates

```bash
kubectl create secret generic asperanode-nodeadmin \
--from-literal=NODE_USER="myuser" \
--from-literal=NODE_PASS="mypassword"

kubectl create secret generic asperanode-accesskey \
--from-literal=ACCESS_KEY_ID="my_access_key" \
--from-literal=ACCESS_KEY_SECRET="my_access_key_secret"
```

```bash
kubectl create secret tls asperahsts --key hsts.key --cert hsts.crt
```

### 3. [Optional] Create a secret containing the sshd server private/public keys

The following secret contains the RSA private/public keys:

```bash
kubectl create secret generic hsts-sshd-keys \
--from-file=ssh_host_rsa_key="./ssh_host_rsa_key" \
--from-file=ssh_host_rsa_key.pub="./ssh_host_rsa_key.pub" \
--from-literal=SSHD_FINGERPRINT=$(cat ./ssh_host_rsa_key.pub | awk '{print $2}' | base64 -d | sha1sum)
```

### 4. [Optional] If using a Kafka that requires authentication, create a secret containing the credentials

The following secret contains the username and password used to authenticate with Kafka:

```bash
kubectl create secret generic kafka-auth \
--from-literal=KAFKA_USER="username" \
--from-literal=KAFKA_PASS="password"
```

### 5. [Optional] If using a Kafka that requires ssl, create a secret containing the Kafka certificate

The following secret contains the username and password used to authenticate with Kafka:

```bash
kubectl create secret generic kafka-cert \
--from-file=KAFKA_CERT="./kafka.pem"
```

### 6. Create a corresponding **values.yaml**

Substitute **RPROXY_ADDRESS** as needed:

```yaml
ingress:
  hostname: asperahsts.mydomain

  # Only provide if using existing certificates
  tlsSecret: asperahsts

asperanode:
  # These secrets only need to be provided if created above
  serverSecret: aspera-server
  nodeAdminSecret: asperanode-nodeadmin
  accessKeySecret: asperanode-accesskey

rproxy:
  address: RPROXY_ADDRESS
```

#### Example **values.yaml** for configuring **aspera.conf** via **asconfigurator**

The available configuration can be viewed with the following command: `asuserdata -+`

```yaml
asperaconfig:
  - set_node_data;symbolic_links,follow
  - set_logging_data;level,dbg2
```

### Install the chart

```bash
helm install -f values.yaml . --tls
```

## Limitations

* The Aspera HSTS is available for x86-64 platforms only.
* The following Aspera products and features are not currently included as part of this installation:
  * async
  * asperawatchd and asperawatchfolderd
  * asperatrapd
  * asperacentral
  * alee
  * ascp4
* The following Aspera products are incompatible, or have limited functionality, when connecting to this installation:
  * IBM Aspera Connect Server Web UI
  * IBM Aspera Shares
  * IBM Aspera Orchestrator
  * IBM Aspera Faspex

### Verifying the Chart

See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

#### ICP on Red Hat OpenShift

If installing on ICP for RedHat OpenShift, the HSTS API can be accessed via port `3443` instead of the default `443`.

## Configuration

|Parameter|Description|Default
|--|--|--|
| `productionDeployment` | productionDeployment | `true` |
| `image.repository` | repository for image | `` |
| `image.pullSecret` | pullSecret for image | `` |
| `rbac.serviceAccountName` | serviceAccountName for rbac | `ibm-aspera-hsts-icp4i` |
| `arch.amd64` | amd64 for arch | `3 - Most preferred` |
| `deployRedis` | deployRedis | `true` |
| `redisHost` | redisHost | `` |
| `redisPort` | redisPort | `6379` |
| `redis.serviceAccount.create` | create redis service account | `false` |
| `redis.serviceAccount.name` | service account for redis server pods, if using an existing service account | `ibm-aspera-hsts-icp4i` |
| `redis.persistence.enabled` | enable redis persistence | `false` |
| `redis.persistence.useDynamicProvisioning` | enable dynamic provisioning for redis persistence | `false` |
| `redis.persistence.existingClaimName` | existing PVC for redis persistence | `` |
| `redis.persistence.accessMode` | accessMode for redis persistence, when dynamic provisioning enabled | `ReadWriteMany` |
| `redis.persistence.storageClassName` | storageClassName for redis persistence, when dynamic provisioning enabled | `` |
| `redis.image.repository` | repository for redis image | `` |
| `redis.image.name` | name for redis image | `aspera-redis` |
| `redis.image.tag` | tag for redis image | `4.0.12-rhel-amd64` |
| `redis.image.pullPolicy` | pullPolicy for redis image | `IfNotPresent` |
| `redis.image.pullSecret` | pullSecret for redis image | `` |
| `redis.rbac.create` | create redis RBAC resources | `false` |
| `redis.resources.server.requests.memory` | memory for redis resources server requests | `100Mi` |
| `redis.resources.server.requests.cpu` | cpu request for redis  server | `.01` |
| `redis.resources.server.limits.memory` | memory for redis resources server limits | `5Gi` |
| `redis.resources.server.limits.cpu` | cpu limit for redis server | `.2` |
| `redis.resources.sentinel.requests.memory` | memory for redis sentinel | `5Mi` |
| `redis.resources.sentinel.requests.cpu` | cpu request for redis sentinel | `.005` |
| `redis.resources.sentinel.limits.memory` | memory limit for redis sentinel | `100Mi` |
| `redis.resources.sentinel.limits.cpu` | cpu limit for redis sentinel | `.02` |
| `tls.issuer` | ClusterIssuer that will provide tls secret | `` |
| `ingress.hostname` | hostname for ingress | `` |
| `ingress.tlsSecret` | tlsSecret for ingress | `` |
| `asperaconfig` | list of `asconfigurator` commands to be run in each container | `[]` |
| `sshdKeysSecret` | Secret containing public/private sshd keys | `` |
| `persistence.useDynamicProvisioning` | useDynamicProvisioning for persistence | `true` |
| `persistence.storageClassName` | storageClassName for persistence | `` |
| `persistence.size` | size for persistence | `10Gi` |
| `persistence.existingClaimName` | existingClaimName for persistence | `` |
| `persistence.mountPath` | mountPath for persistence | `/asperanode` |
| `persistence.fsGroup` | The groupId that has read and write permissions on the transfer volume. See Storage Permissions | `1001` |
| `asperanode.clusterId` | clusterId for asperanode | `` |
| `asperanode.httpsPort` | httpsPort for asperanode | `9092` |
| `asperanode.nodeCount` | nodeCount for asperanode | `3` |
| `asperanode.serverSecret` | serverSecret for asperanode | `` |
| `asperanode.nodeAdminSecret` | nodeAdminSecret for asperanode | `` |
| `asperanode.accessKeySecret` | accessKeySecret for asperanode | `` |
| `asperanode.accessKeyConfig.transfer.target_rate_kbps` | target_rate_kbps for asperanode accessKeyConfig transfer | `100000` |
| `asperanode.image.repository` | repository for asperanode image | `` |
| `asperanode.image.name` | name for asperanode image | `aspera-hsts-asperanode` |
| `asperanode.image.tag` | tag for asperanode image | `3.9.1-rhel-amd64` |
| `asperanode.image.pullPolicy` | pullPolicy for asperanode image | `IfNotPresent` |
| `asperanode.autoscale.api.enabled` | enabled for asperanode autoscale api | `false` |
| `asperanode.autoscale.api.minReplicas` | minReplicas for asperanode autoscale api | `3` |
| `asperanode.autoscale.api.maxReplicas` | maxReplicas for asperanode autoscale api | `5` |
| `asperanode.autoscale.api.cpuAverageUtilization` | cpuAverageUtilization for asperanode autoscale api | `50` |
| `asperanode.resources.requests.memory` | memory for asperanode resources requests | `100Mi` |
| `asperanode.resources.requests.cpu` | cpu for asperanode resources requests | `.02` |
| `asperanode.resources.limits.memory` | memory for asperanode resources limits | `700Mi` |
| `asperanode.resources.limits.cpu` | cpu for asperanode resources limits | `0.6` |
| `dashboard.enabled` | Install HSTS Grafana dashboard  | `true` |
| `aej.kafkaHost` | kafkaHost for aej | `` |
| `aej.kafkaPort` | kafkaPort for aej | `9092` |
| `aej.kafkaProtocol` | kafkaProtocol for aej | `PLAINTEXT` |
| `aej.kafkaSaslMechanism` | kafkaSaslMechanism for aej | `PLAIN` |
| `aej.kafkaAuthSecret` | kafkaAuthSecret for aej | `` |
| `aej.kafkaCertSecret` | kafkaCertSecret for aej | `` |
| `aej.replicas` | replicas for aej | `3` |
| `aej.image.repository` | repository for aej image | `` |
| `aej.image.name` | name for aej image | `aspera-hsts-aej` |
| `aej.image.tag` | tag for aej image | `3.9.1-rhel-amd64` |
| `aej.image.pullPolicy` | pullPolicy for aej image | `IfNotPresent` |
| `aej.service.type` | type for aej service | `ClusterIP` |
| `prometheusEndpoint.replicas` | replicas for prometheusEndpoint  | `3` |
| `prometheusEndpoint.image.repository` | repository for prometheusEndpoint image | `` |
| `prometheusEndpoint.image.name` | name for prometheusEndpoint image | `aspera-hsts-prometheus-endpoint` |
| `prometheusEndpoint.image.tag` | tag for prometheusEndpoint image | `1.2.1-rhel-amd64` |
| `prometheusEndpoint.image.pullPolicy` | pullPolicy for prometheusEndpoint image | `IfNotPresent` |
| `prometheusEndpoint.service.api.type` | type for prometheusEndpoint service api | `ClusterIP` |
| `prometheusEndpoint.service.api.port` | port for prometheusEndpoint service api | `2112` |
| `prometheusEndpoint.config.listenAddr` | listenAddr for prometheusEndpoint config | `:2112` |
| `stats.image.repository` | repository for stats image | `` |
| `stats.image.name` | name for stats image | `aspera-hsts-stats` |
| `stats.image.tag` | tag for stats image | `1.2.1-rhel-amd64` |
| `stats.image.pullPolicy` | pullPolicy for stats image | `IfNotPresent` |
| `stats.service.api.type` | type for stats service api | `ClusterIP` |
| `stats.service.api.port` | port for stats service api | `80` |
| `ascpLoadbalancer.replicas` | replicas for ascpLoadbalancer | `3` |
| `ascpLoadbalancer.strategy` | strategy for ascpLoadbalancer | `MIN_SESSIONS` |
| `ascpLoadbalancer.service.type` | type for ascpLoadbalancer service | `ClusterIP` |
| `ascpLoadbalancer.service.port` | port for ascpLoadbalancer service | `80` |
| `utils.image.repository` | repository for utils image | `` |
| `utils.image.name` | name for utils image | `aspera-hsts-utils` |
| `utils.image.tag` | tag for utils image | `1.2.1-rhel-amd64` |
| `utils.image.pullPolicy` | pullPolicy for utils image | `IfNotPresent` |
| `ascpSwarm.replicas` | replicas for ascp swarm | `3` |
| `ascpSwarm.service.type` | type for ascp swarm service | `ClusterIP` |
| `ascpSwarm.service.port` | port for ascp swarm service | `80` |
| `ascpSwarm.config.hostPortMin` | hostPortMin for ascp swarm config | `34001` |
| `ascpSwarm.config.hostPortMax` | hostPortMax for ascp swarm config | `34101` |
| `ascpSwarm.config.minAvailable` | minAvailable for ascp swarm config | `1` |
| `ascpSwarm.config.maxRunning` | maxRunning for ascp swarm config | `2` |
| `ascpSwarm.config.member.name.prefix` | prefix for ascp swarm config member name | `` |
| `loadbalancer.image.repository` | repository for loadbalancer image | `` |
| `loadbalancer.image.name` | name for loadbalancer image | `aspera-hsts-loadbalancer` |
| `loadbalancer.image.tag` | tag for loadbalancer image | `1.2.1-rhel-amd64` |
| `loadbalancer.image.pullPolicy` | pullPolicy for loadbalancer image | `IfNotPresent` |
| `nodedLoadbalancer.replicas` | replicas for nodedLoadbalancer | `3` |
| `nodedLoadbalancer.strategy` | strategy for nodedLoadbalancer | `MIN_SESSIONS` |
| `nodedLoadbalancer.service.type` | type for nodedLoadbalancer service | `ClusterIP` |
| `nodedLoadbalancer.service.port` | port for nodedLoadbalancer service | `80` |
| `swarm.image.repository` | repository for swarm image | `` |
| `swarm.image.name` | name for swarm image | `aspera-hsts-swarm` |
| `swarm.image.tag` | tag for swarm image | `1.2.1-rhel-amd64` |
| `swarm.image.pullPolicy` | pullPolicy for swarm image | `IfNotPresent` |
| `nodedSwarm.replicas` | replicas for noded swarm | `3` |
| `nodedSwarm.service.type` | type for noded swarm service | `ClusterIP` |
| `nodedSwarm.service.port` | port for nodednoded swarmSwarm service | `80` |
| `nodedSwarm.config.minAvailable` | minAvailable for noded swarm config | `1` |
| `nodedSwarm.config.maxRunning` | maxRunning for noded swarm config | `2` |
| `nodedSwarm.config.member.name.prefix` | prefix for noded swarm config member name | `` |
| `firstboot.image.repository` | repository for receiver firstboot image | `` |
| `firstboot.image.name` | name for receiver firstboot image | `aspera-hsts-firstboot` |
| `firstboot.image.tag` | tag for receiver firstboot image | `3.9.1-1.2.1-rhel-amd64` |
| `firstboot.image.pullPolicy` | pullPolicy for receiver firstboot image | `IfNotPresent` |
| `nodedSwarmMember.image.repository` | repository for nodedSwarmMember image | `` |
| `nodedSwarmMember.image.name` | name for nodedSwarmMember image | `aspera-hsts-noded-swarm-member` |
| `nodedSwarmMember.image.tag` | tag for nodedSwarmMember image | `3.9.1-1.2.1-rhel-amd64` |
| `nodedSwarmMember.image.pullPolicy` | pullPolicy for nodedSwarmMember image | `IfNotPresent` |
| `receiver.authorizedKeys` | authorizedKeys for receiver | `[]` |
| `receiver.vlinks` | vlinks for receiver | `[]` |
| `receiver.swarm.image.repository` | repository for receiver swarm image | `` |
| `receiver.swarm.image.name` | name for receiver swarm image | `aspera-hsts-receiver-swarm-member` |
| `receiver.swarm.image.tag` | tag for receiver swarm image | `3.9.1-1.2.1-rhel-amd64` |
| `receiver.swarm.image.pullPolicy` | pullPolicy for receiver swarm image | `IfNotPresent` |
| `receiver.swarm.resources.requests.memory` | memory for receiver swarm resources requests | `50Mi` |
| `receiver.swarm.resources.requests.cpu` | cpu for receiver swarm resources requests | `.01` |
| `receiver.swarm.resources.limits.memory` | memory for receiver swarm resources limits | `700Mi` |
| `receiver.swarm.resources.limits.cpu` | cpu for receiver swarm resources limits | `0.5` |
| `httpProxy.replicas` | replicas for httpProxy | `3` |
| `httpProxy.image.repository` | repository for httpProxy image | `` |
| `httpProxy.image.name` | name for httpProxy image | `aspera-hsts-http-proxy` |
| `httpProxy.image.tag` | tag for httpProxy image | `1.2.1-rhel-amd64` |
| `httpProxy.image.pullPolicy` | pullPolicy for httpProxy image | `IfNotPresent` |
| `httpProxy.listenAddr` | listenAddr for httpProxy | `:8000` |
| `httpProxy.service.api.type` | type for httpProxy service api | `ClusterIP` |
| `httpProxy.service.api.port` | port for httpProxy service api | `9092` |
| `tcpProxy.replicas` | replicas for tcpProxy | `3` |
| `tcpProxy.image.repository` | repository for tcpProxy image | `` |
| `tcpProxy.image.name` | name for tcpProxy image | `aspera-hsts-tcp-proxy` |
| `tcpProxy.image.tag` | tag for tcpProxy image | `1.2.1-rhel-amd64` |
| `tcpProxy.image.pullPolicy` | pullPolicy for tcpProxy image | `IfNotPresent` |
| `tcpProxy.listenAddr` | listenAddr for tcpProxy | `:8022` |
| `tcpProxy.service.type` | type for tcpProxy service | `LoadBalancer` |
| `tcpProxy.service.port` | port for tcpProxy service | `33001` |
| `probe.image.repository` | repository for probe image | `` |
| `probe.image.name` | name for probe image | `aspera-hsts-probe` |
| `probe.image.tag` | tag for probe image | `1.2.1-rhel-amd64` |
| `probe.image.pullPolicy` | pullPolicy for probe image | `IfNotPresent` |
| `election.image.repository` | repository for election image | `` |
| `election.image.name` | name for election image | `aspera-hsts-election` |
| `election.image.tag` | tag for election image | `1.2.1-rhel-amd64` |
| `election.image.pullPolicy` | pullPolicy for election image | `IfNotPresent` |
| `rproxy.address` | address for rproxy | `` |
| `nameOverride` | nameOverride | `aspera-hsts` |
| `sch.rbac.serviceAccountName` | serviceAccountName for sch rbac | `ibm-sch-secret-gen` |
| `sch.global.image.repository` | repository for sch image | `` |
| `sch.image.name` | name for sch image | `aspera-hsts-utils` |
| `sch.image.tag` | tag for sch image | `1.2.1-rhel-amd64` |
| `sch.image.pullPolicy` | pullPolicy for sch image | `IfNotPresent` |
| `sch.image.pullSecret` | pullSecret for sch image | `` |
