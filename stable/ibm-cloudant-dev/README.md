[![IBM Cloudant](https://ablanks.cloudant.com/crud/welcome/ibm_cloudant_blue_x2.png)](https://ablanks.cloudant.com/crud/welcome/ibm_cloudant_blue_x2.png).

IBM® Cloudant is an IBM software product, which is primarily delivered as a cloud-based service. Cloudant is a non-relational, NoSQL, distributed database service.


[![Brief introduction to IBM Cloudant](https://img.youtube.com/vi/oZqf5gsvHDc/0.jpg)](https://www.youtube.com/watch?v=oZqf5gsvHDc)

Learn more about IBM Cloudant at the following link: [https://www.ibm.com/support/knowledgecenter/en/SSTPQH_1.0.0/com.ibm.cloudant.local.doc/SSTPQH_1.0.0_welcome.html](https://www.ibm.com/support/knowledgecenter/en/SSTPQH_1.0.0/com.ibm.cloudant.local.doc/SSTPQH_1.0.0_welcome.html).


# Quick Start

1. Create a Persistent Volume which will be utilized for storage

The Cloudant chart requires access to storage in order to persist the database data, which is performed through the Kubernetes Volume Claim mechanism. The storage can be allocated in the private cloud admin console. 

For minikube, use the following command to allocate a Persistent Volume directly on the minikube virtual machine: 

```console
$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ databasePVC.name | quote }}
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 3Gi
  hostPath:
    path: /data/cloudant
EOF
```

2. Install the chart

```bash
helm install ibm/ibm-cloudant-dev
```

Parameters
------------
The helm chart has the following Values that can be overriden using the install `--set` parameter. For example:

`helm install --set database.livenessProbePeriodSeconds=5 ibm/ibm-cloudant-dev`

| Value                                             | Description                                         | Default          |
|---------------------------------------------------|-----------------------------------------------------|------------------|
| image.repository                                  | The image to use for this deployment                | ibmcom/cloudant-developer  |
| image.tag                                         | The image tag to use for this deployment            | latest           |
| image.pullPolicy                                  | Image Pull Policy                                   | Always           |
| databasePVC.name                                  | Database PVC Name                                   | "cloudant-pvc"   |
| databasePVC.storageClassName                      | Database PVC Storage Class Name                     | ""               |
| databasePVC.size                                  | Database PVC Size                                   | "3Gi"            |
| databasePVC.existingClaimName                     | Cloudant PVC Existing Claim  Name                   | ""               |
| database.readinessProbePeriodSeconds              | Load Balancer ReadinessProbe PeriodSeconds          | 2                |
| database.readinessProbeInitialDelaySeconds        | Load Balancer ReadinessProbe InitialDelaySeconds    | 30               |
| database.livenessProbePeriodSeconds               | Load Balancer LivenessProbe PeriodSeconds           | 2                |
| database.livenessProbeInitialDelaySeconds         | Load Balancer LivenessProbe InitialDelaySeconds     | 200              |


-------------
_Copyright IBM Corporation 2017. All Rights Reserved._
