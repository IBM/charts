# ibm-csi-nfs

## Introduction
This is a sample nfs driver based on CSI 0.2.0.
## Chart Details
The deployment of this chart contains StatefulSet and DaemonSet, as well as RBAC roles for CSI.

The StatuefulSet contains csi-attacher and nfs plugin driver, to communicate with the Kubernetes controllers. Ensure no more than 1 instance running at a time.

The DaemonSet contains driver-registrar and nfs plugin driver, to communicate with kubelet. Ensure it run on each node.
## Prerequisites
- Kubernetes v1.10
- Worker nodes support nfs mounting
## Resources Required
Container Storage Interface (CSI) is now available as Beta in Kubernetes v1.10. With the promotion to Beta, CSI is now enabled by default.
Most CSI plug-ins require that the --allow-privileged=true flag is set on the API server binary and kubelet binaries. Set it as you need.
## Installing the Chart
To install the chart with default name and namespace:
```
helm install  ./ibm-csi-nfs
```
To install the chart with defined name and namespace:
```
kubectl create ns nfs

helm install  --name my-csi-nfs --namespace nfs ./ibm-csi-nfs
```
## Uninstalling the Chart
```
helm delete my-csi-nfs
```
## Configuration
The helm chart has the following Values that can be overriden using the install --set parameter. For example:
```
helm install --set nfspluginImage.pullPolicy=Always ./ibm-csi-nfs
```
| Value                          | Description                             | Default                           |
|--------------------------------|-----------------------------------------|-----------------------------------|
| nfspluginImage.repository      | The image repository of nsf plugin      | quay.io/k8scsi/nfsplugin          |
| nfspluginImage.tag             | The image tag of nfs plugin             | v0.2.0                            |
| nfspluginImage.pullPolicy      | Image Pull Policy                       | IfNotPresent                      |
| attacherImage.repository       | The image repository of csi-attacher    | quay.io/k8scsi/csi-attacher       |
| attacherImage.tag              | The image tag of csi-attacher           | v0.2.0                            |
| attacherImage.pullPolicy       | Image Pull Policy                       | IfNotPresent                      |
| registerImage.repository       | The image repository of driver-register | quay.io/k8scsi/driver-registrar   |
| registerImage.tag              | The image tag of driver-register        | v0.2.0                            |
| registerImage.pullPolicy       | Image Pull Policy                       | IfNotPresent                      |

## Documentation
Before deploying a pod to use this csi nfs driver, ensure you have installed nfs.
```
# showmount  -e
Export list for nfsserver:
/nfs *
```
Modify below nginx.yaml, replace "server: 127.0.0.1" and "share : /nfs" with your nfs server IP and shared directory.
```
# cat nginx.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-nfsplugin
  labels:
    name: data-nfsplugin
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 100Gi
  csi:
    driver: csi-nfsplugin
    volumeHandle: data-id
    volumeAttributes:
      server: 127.0.0.1
      share: /nfs
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-nfsplugin
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  selector:
    matchExpressions:
    - key: name
      operator: In
      values: ["data-nfsplugin"]
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: maersk/nginx
    imagePullPolicy: Always
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
    volumeMounts:
      - mountPath: /var/www
        name: data-nfsplugin
  volumes:
  - name: data-nfsplugin
    persistentVolumeClaim:
      claimName: data-nfsplugin

# kubectl create -f nginx.yaml
```
## Limitations
- Works on x86 platform
- Only users with privileged podsecuritypolicies can install this chart 
