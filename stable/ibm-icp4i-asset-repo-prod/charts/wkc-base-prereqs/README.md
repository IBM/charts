# WKC Cloudpaks / Uber Helm Charts

### UG&I Base Pre-reqs
Responsible for installing all the pre-reqs for UG&I base.  Currently it will lay down the following pre-req
1. Cloudant
2. Rabbit-MQ

### Installing 

- Register `dataconn` helm repository `helm repo add dataconn `artifactory_url --username xxx@xx.ibm.com --password xxx`


- Update dependencies using `helm dep update /wkc-cloudpaks/wkc-base-prereqs`


- Install/upgrade with 


##### Single-node install:

```bash
$ helm upgrade --install wkc-base-pre ./wkc-base-prereqs --set global.cloudant.password=test,wdp-cloudant.pre-reqs.cloudant.db_1.path=</mnt/data/cloudant_1>,wdp-cloudant.pre-reqs.cloudant.db_1.host=<host1>,wdp-rabbitmq.rabbitmqPassword=test,wdp-rabbitmq.persistentVolume.path=</mnt/data/rmq> --namespace wkc --wait --timeout=600
```

##### Multi-node install:

```bash
$ helm upgrade --install wkc-base-pre ./wkc-base-prereqs --set global.cloudant.password=test,wdp-cloudant.pre-reqs.cloudant.db_1.path=</mnt/data/cloudant_1>,wdp-cloudant.pre-reqs.cloudant.db_2.path=</mnt/data/cloudant_2>,<wdp-cloudant.pre-reqs.cloudant.db_3.path=</mnt/data/cloudant_3>,wdp-cloudant.pre-reqs.cloudant.db_1.host=<host1>,wdp-cloudant.pre-reqs.cloudant.db_2.host=<host2>,wdp-cloudant.pre-reqs.cloudant.db_3.host=<host3>,wdp-rabbitmq.rabbitmqPassword=test,wdp-rabbitmq.persistentVolume.path=</mnt/data/rmq> --namespace wkc --wait --timeout=600 -f ./wkc-base-prereqs/values-multinode.yaml
```


### Configuration

You may change the default of each parameter using the --set key=value[,key=value].

You can also change the default values.yaml and supply it with -f

The following table lists some of configurable parameters of the Cloudant chart and their default values.
                                               
| Parameter                                      | Description                                                      | Default                             |
|------------------------------------------------|------------------------------------------------------------------|-------------------------------------|
| `global.cloudant.password`               | Required - password used for cloudant                            | Required `None`                             |
| `global.cloudant.singleNode`     | single node deployment - if true, replicas will be set to 1 automatically.                 | `false`                             |
| `global.replicas.db`                      | Cloudant replicas                                                | 3                                   |
| `global.docker.registry`                 | Docker image pull secret                                         | `None`                             |
| `global.images.registry`                 | Images                               | `localhost:5000/wdp-cloudant`                             |
| `wdp-cloudant.pre-reqs.cloudant.storage`   | Cloudant PV storage                                    | `30Gi`                                   |
| `wdp-cloudant.ibm-cloudant-internal.storage.db.requests.storage`                 | Cloudant PVC storage      | `30Gi`                 |
| `wdp-cloudant.pre-reqs.db_1.path`   | Cloudant PV storage                                    | Required                                    |
| `wdp-cloudant.pre-reqs.db_2.path`   | Cloudant PV storage for db node 2                                  | Required if multi-node                |
| `wdp-cloudant.pre-reqs.db_3.path`   | Cloudant PV storage for db node 3                                  | Required if multi-node                 |
| `wdp-cloudant.pre-reqs.db_1.host`   | Cloudant PV storage host affinity                                  | Required                                    |
| `wdp-cloudant.pre-reqs.db_2.host`   | Cloudant PV storage host affinity                                  | Required if multi-node                |
| `wdp-cloudant.pre-reqs.db_3.host`   | Cloudant PV storage host affinity                                  | Required if multi-node                 |


The following table lists some of configurable parameters of the RabbitMQ chart and their default values.

| Parameter                                      | Description                                                      | Default                             |
|------------------------------------------------|------------------------------------------------------------------|-------------------------------------|
| `wdp-rabbitmq.image.repository`               | Docker image repository      |  `localhost:5000/wdp-rabbitmq/rabbitmq`             |
| `wdp-rabbitmq.image.pullSecrets{}`                      | Docker image pull secret                  | `None`                                   |
| `wdp-rabbitmq.busyboxImage`                 | Docker busybox image pull secret             | `localhost:5000/wdp-rabbitmq/busybox`       |
| `wdp-rabbitmq.persistentVolume.path`   | RMQ PV path                              | Required                             |

