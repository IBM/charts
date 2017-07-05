# Quick Start

1. Create the image pull secret. 

Since the image is only available on an internally accessible server at this time, an image pull secret is required to perform the authentication. 

*Note:* You need to get a valid authorization token from the DB2 team. 

```kubectl create secret docker-registry svl.cumulusrepo.com --docker-server=svl.cumulusrepo.com --docker-username=token --docker-password=xxxxxxxxxxxxx --docker-email=none@ibm.com```

2. Minikube or IBM Cloud Local: Create a Persistent Volume which will be utilized for storage

The DB2 chart requires acces to storage in order to persist the database, which is performed through the Kubernetes Volume Claim mechanism. If your Kubernetes cluster provider supports dynamic provisioning, this step is unnecessary. 

For minikube, use the following command to allocate a Persistent Volume directly on the minikube virtual machine: 

```cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0001
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: anything
  capacity:
    storage: 5Gi
  hostPath:
    path: /data/pv0001/
EOF
```

3. Install the chart

```helm install --set license=accept db2```

Alternatively, when you install the chart, you can specify an alternative image name:

`helm install --set image=mydb2image`

# Parameters

## Exposing as a Service

By default, the service will be available only within the cluster (service type is ClusterIP). To expose as a NodePort type, use `--set service.type=NodePort`



# TODOs

* Parameters: The DB2 image exposes a few parameters such as the database name which are not currently exported through the chart right now. 
* Image location: It is likely that the image will find its wait into either Docker hub or the local image registry, in which case the image: parameter in values.yml should change
* Templated docs: The output doc is currently left as the Helm default, so this should include DB2 specific text. 