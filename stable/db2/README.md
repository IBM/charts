# Db2 Developer-C 11.1.2.2 Helm chart

IBM® Db2® is a multi-workload database designed to help you quickly develop, test and build applications for your business. Designed for operational and analytic workloads, the solution provides in-memory computing and other features to help ensure high performance and scalability. Storage optimization and compression can make your applications more cost efficient, and continuous ingest ensures that they run at the speed of business.

[![Brief introduction to IBM Db2](https://img.youtube.com/vi/zogcErEwseo/0.jpg)](https://www.youtube.com/watch?v=zogcErEwseo)

Learn more about IBM Db2 at the following link: [https://www.ibm.com/analytics/us/en/technology/db2](https://www.ibm.com/analytics/us/en/technology/db2).

## Configuration and set up

1. Visit http://ibm.biz/db2-license to review Db2 license and receive the image secret needed to install this helm chart. The received secret needs to be entered into the values.yaml file as follows:

```
# Default values for db2.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
image:
  repository: na.cumulusrepo.com/db2dg/db2server
  tag: v11.1.2fp2_nonroot
  pullPolicy: IfNotPresent 
  secret: <ENTER SECRET HERE>
service:
  name: db2
  type: ClusterIP
  externalPort: 50000
  internalPort: 50000
storage:
  class: anything
  size: 5Gi
db2inst:
  instname: db2inst1
  password: password
license: "not accepted"
```

2. Create a Persistent Volume which will be utilized for storage

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
    storage: 5Gi
  hostPath:
    path: /data/pv0001/
EOF
```

3. Install the chart

```helm install --set license=accept db2```

Alternatively, when you install the chart, you can specify an alternative image name:

`helm install --set image=mydb2image`

# Configuration

## Configuration

The following tables lists the configurable parameters of the Db2 chart and their default values.

| Parameter                  | Description                                | Default                                                    |
| -----------------------    | ----------------------------------         | ---------------------------------------------------------- |
| `instname`                 | Username of Db2 instance user to create.   | `db2inst1`                                                 |
| `password`                 | Password for the new user.                 | password                                                   |

A default database is created - SAMPLE. Currently not configurable. Additional databases can be created via attaching into the container or via services such as IBM Data Server Manager. 

## Exposing as a Service

The chart currently uses a service of type NodePort which randomly assigns a port in the kubernetes clusters and maps it to the pod.

`kubectl get services`

Once you know the name of your service execute the following command to get the details of that service:

`kubectl describe service <service Name>`

```
Name:			mytest1-db2
Namespace:		default
Labels:			chart=db2-0.1.0
Annotations:		<none>
Selector:		app=mytest1-db2
Type:			NodePort
IP:			10.0.0.247
Port:			db2	50000/TCP
NodePort:		db2	32247/TCP
Endpoints:		10.1.230.134:50000
Session Affinity:	None
Events:			<none>
```

You can use the node port and IP address to connect to the instance/database. 

