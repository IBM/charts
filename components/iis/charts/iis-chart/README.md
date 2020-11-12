# IBM InfoSphere Information Server Enterprise Helm Chart

[InfoSphere Information Server](https://www.ibm.com/analytics/us/en/technology/information-server/) provides you with complete information management and governance solutions for analytical insights to create business value through data.

## Introduction

This chart consists of IBM InfoSphere Information Server Enterprise intended to be deployed in IBM Cloud Private production environments.

## Chart Details

This chart will do the following
- It deploys all tiers of Information Server in different pods
- It deploys Unified Governance pods

## Prerequisites

- Chart uses Persistent Volumes. Dynamic provisioning of Persistent Volumes is enabled by default. The cluster should be set up with Dynamic Provisioning (e.g. GlusterFS). See [persistence](#persistence) section. If dynamic provisioning is not enabled, create the persistent volumes using the template below

## Installing the Chart

### Deploying IIS with UG chart

 - Set the current directory `<git repo>/stable`

 - Update image repo secret

`vi ibm-iisee-zen/templates/_image-secret.tpl `

Change content to

```
{{- define "image-secret" }}
imagePullSecrets:
- name: igc-registry-secret
{{- end }}
```

- Create secret file
`vi igc-secret.yaml`

```
apiVersion: v1
data:
  .dockercfg: <image secret here - check with git repo owner>
kind: Secret
metadata:
  name: igc-registry-secret
  labels:
     app: igc-registry-secret
type: kubernetes.io/dockercfg

```
`kubectl create namespace zen`

`kubectl apply -f igc-secret.yaml -n zen`

- ICp configuration

`kubectl patch psp default -p '{"spec":{"allowedCapabilities":["*"]}, "hostIPC": true}'`

`kubectl taint nodes <master node ip> dedicated-`

- Create the NFS Volumes

`vi /etc/exports`

```
/mnt/nfs   *(rw,sync,subtree_check,no_root_squash)
```

`service nfs restart`

- Create volumes file

`vi iis-volumes.yaml`

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: user-home-pv
  labels:
    assign-to: "zen-user-home"
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/user-home
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: user-home-pvc
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      assign-to: "zen-user-home"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-services-pv
  labels:
    assign-to: "zen-services"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-services
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-engine-dedicated-pv
  labels:
    assign-to: "zen-engine-dedicated"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-engine-dedicated
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-sample-data
  labels:
    assign-to: "zen-iissampledata"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-sampledata
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-cert
  labels:
    assign-to: "zen-iiscert"
spec:
  capacity:
    storage: 1Mi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-cert
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-solr
  labels:
    assign-to: "zen-solr"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-solr
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-repository
  labels:
    assign-to: "zen-repository"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-repository
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-cassandra
  labels:
    assign-to: "zen-cassandra"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-cassandra
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-kafka
  labels:
    assign-to: "zen-kafka"
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-kafka
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zen-zookeeper
  labels:
    assign-to: "zen-zookeeper"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    server: <nfs server>
    path: /mnt/nfs/zen-zookeeper
```

```
rm -rf /mnt/nfs
mkdir -p /mnt/nfs
cat iis-volumes.yaml | grep path | awk '{print $2;}' | xargs mkdir -p
chmod -R 777 /mnt/nfs
```

`kubectl apply -f iis-volumes.yaml -n zen`

`helm install --values=ibm-iisee-zen/cv-tests/test-default/values.yaml  --namespace=zen ibm-iisee-zen --tls`


> **Tip**: List all releases using `helm list`

### Accessing IIS Launchpad

Once the install process is completed and all the pods are up and running, open a compatible browser and enter `http://<external ip>:<node port>/ibm/iis/launchpad`. Login using isadmin/P455w0rd.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
helm delete --purge my-release --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the ibm-iisee-eval chart and their default values.

### Common Parameters

| Parameter                                 | Description                       | Default Value                |
|-------------------------------------------|-----------------------------------|------------------------------|
| release.image.pullPolicy                  | Image Pull Policy                 | IfNotPresent                 |
| release.image.repository                  | Image Repository                  | N/A   |
| release.image.tag                         | Image Tag                         | 11.7.0.1SP1                  |
| persistence.enabled                       | Enable persistence                | true                         |
| persistence.useDynamicProvisioning        | Use Dynamic PV Provisioning       | true                         |

### Containers Parameters


#### Resources Required

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.requests.memory|
|-------------------------------|----------------------|-------------------------|
|**iis-service**	        |2000m                 |6000Mi                   |
|**iis-engine**		        |2000m                 |6000Mi                   |
|**iis-compute**	        |2000m                 |6000Mi                   |
|**iis-xmeta**		        |2000m                 |6000Mi                   |

#### Port Parameters

| Parameter                           | Description                                      | Default Value                |
|-------------------------------------|--------------------------------------------------|------------------------------|
| iisService.service.nodePort         | The external port for IIS launchpad              | 32501                        |

#### Storage Parameters

| Prefix/Suffix                         | volumeClaim.size          | volumeClaim.storageClassName | volumeClaim.existingClaimName|
|---------------------------------------|---------------------------|------------------------------|------------------------------|
|repository                              | 100Gi                       | `nil`                        |  `nil`                       |
|engine                             | 40Gi                       | `nil`                        |  `nil`                       |
|service                              | 20Gi                       | `nil`                        |  `nil`                       |
|cassandra                              | 90Gi                       | `nil`                        |  `nil`                       |
|zookeeper                              | 5Gi                       | `nil`                        |  `nil`                       |
|kafka                                  | 5Gi                       | `nil`                        |  `nil`                       |
|solr                                   | 5Gi                       | `nil`                        |  `nil`                       |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: true (default)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.

- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: false (non-default)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.    

The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) volume. The volume is created using dynamic volume provisioning. If the PersistentVolumeClaim should not be managed by the chart, define `persistence.existingClaim`.

## Resources Required
## PodSecurityPolicy Requirements

Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    helm.sh/hook: test-success
    kubernetes.io/description: "This policy is the most restrictive, requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp
```
## Red Hat OpenShift SecurityContextConstraints Requirements
This README does contain the right link: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
This README does contain the right link: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc)

Custom SecurityContextConstraints definition:

```
...
```

## Limitations
