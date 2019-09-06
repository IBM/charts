# Portworx

[Portworx](https://portworx.com/) is a software defined persistent storage solution designed and purpose built for applications deployed as containers, via container orchestrators such as Kubernetes, Marathon and Swarm. It is a clustered block storage solution and provides a Cloud-Native layer from which containerized stateful applications programmatically consume block, file and object storage services directly through the scheduler.

## Pre-requisites

This helm chart deploys [Portworx](https://portworx.com/) and [Stork](https://docs.portworx.com/scheduler/kubernetes/stork.html) on your Kubernetes cluster. The minimum requirements for deploying the helm chart are as follows:

- Tiller v2.9.0 and above is running on the Kubernetes cluster where you wish to deploy Portworx.
- All [Pre-requisites](https://docs.portworx.com/#minimum-requirements). for Portworx fulfilled.

### Trusted registries

Container Image Security is enabled by default in ICP 3.1 and above. Hence add the following to the trusted registries so they can be pulled.
* docker.io/portworx/*
* docker.io/openstorage/*
* gcr.io/google-containers/*
* docker.io/lachlanevenson/*
* quay.io/k8scsi/*


### PodSecurityPolicy Requirements

This chart requires a `PodSecurityPolicy` role to be bound to the target namespace prior to installation.  On IBM Cloud Private, choose the following Custom PodSecurityPolicy definition: [ibm-anyuid-hostaccess-psp](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/ibm-anyuid-hostaccess-psp.yaml).

## Limitations
* The portworx helm chart can only be deployed in the kube-system namespace. Hence use "kube-system" in the "Target namespace" during configuration.
* You can only deploy one portworx helm chart per Kubernetes cluster.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

> **Tip** > The Portworx configuration files under `/etc/pwx/` directory are preserved, and will not be deleted.

```
helm delete my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release.


## Documentation
* [Portworx docs site](https://docs.portworx.com/scheduler/kubernetes/)
* [Portworx interactive tutorials](https://docs.portworx.com/scheduler/kubernetes/px-k8s-interactive.html)

## Installing the Chart using the CLI

To install the chart with the release name `my-release` run the following commands substituting relevant values for your setup:

##### NOTE:
`kvdb` is a required field. The chart installation would not proceed unless this option is provided.
If the etcdcluster being used is a secured ETCD (SSL/TLS) then please follow instructions to create a kubernetes secret with the certs. https://docs.portworx.com/scheduler/kubernetes/etcd-certs-using-secrets.html#create-kubernetes-secret


`clusterName` should be a unique name identifying your Portworx cluster. The default value is `mycluster`, but it is suggested to update it with your naming scheme.

Example of using the helm CLI to install the chart:
```
helm install --debug --name my-release --set kvdb=etcd:http://192.168.70.90:2379,clusterName=$(uuidgen) ./helm/charts/portworx/
```

## Basic troubleshooting

#### Helm install errors with "no available release name found"

```
helm install --dry-run --debug --set kvdb=etcd:http://192.168.70.90:2379,clusterName=$(uuidgen) ./helm/charts/px/
[debug] Created tunnel using local port: '37304'
[debug] SERVER: "127.0.0.1:37304"
[debug] Original chart version: ""
[debug] CHART PATH: /root/helm/charts/px

Error: no available release name found
```
This most likely indicates that Tiller doesn't have the right RBAC permissions.
You can verify the tiller logs
```
[storage/driver] 2018/02/07 06:00:13 get: failed to get "singing-bison.v1": configmaps "singing-bison.v1" is forbidden: User "system:serviceaccount:kube-system:default" cannot get configmaps in the namespace "kube-system"
[tiller] 2018/02/07 06:00:13 info: generated name singing-bison is taken. Searching again.
[tiller] 2018/02/07 06:00:13 warning: No available release names found after 5 tries
[tiller] 2018/02/07 06:00:13 failed install prepare step: no available release name found
```

#### Helm install errors with  "Job failed: BackoffLimitExceeded"

```
helm install --debug --set dataInterface=eth1,managementInterface=eth1,kvdb=etcd:http://192.168.70.179:2379,clusterName=$(uuidgen) ./helm/charts/px/
[debug] Created tunnel using local port: '36389'

[debug] SERVER: "127.0.0.1:36389"

[debug] Original chart version: ""
[debug] CHART PATH: /root/helm/charts/px

Error: Job failed: BackoffLimitExceeded
```
This most likely indicates that the pre-install hook for the helm chart has failed due to a misconfigured or inaccessible ETCD url.
Follow the below steps to check the reason for failure.

```
kubectl get pods -nkube-system -a | grep preinstall
px-etcd-preinstall-hook-hxvmb   0/1       Error     0          57s

kubectl logs po/px-etcd-preinstall-hook-hxvmb -nkube-system
Initializing...
Verifying if the provided etcd url is accessible: http://192.168.70.179:2379
Response Code: 000
Incorrect ETCD URL provided. It is either not reachable or is incorrect...

```

Ensure the correct etcd URL is set as a parameter to the `helm install` command.

#### Helm install errors with "Job failed: Deadline exceeded"

```
helm install --debug --set dataInterface=eth1,managementInterface=eth1,kvdb=etcd:http://192.168.20.290:2379,clusterName=$(uuidgen) ./charts/px/
[debug] Created tunnel using local port: '39771'

[debug] SERVER: "127.0.0.1:39771"

[debug] Original chart version: ""
[debug] CHART PATH: /root/helm/charts/px

Error: Job failed: DeadlineExceeded
```
This error indicates that the pre-install hook for the helm chart has failed to run to completion correctly. Verify that the etcd URL is accessible. This error occurs on kubernetes cluster(s) with version below 1.8
Follow the below steps to check the reason for failure.

```
kubectl get pods -nkube-system -a | grep preinstall
px-hook-etcd-preinstall-dzmkl    0/1       Error     0          6m
px-hook-etcd-preinstall-nlqwl    0/1       Error     0          6m
px-hook-etcd-preinstall-nsjrj    0/1       Error     0          5m
px-hook-etcd-preinstall-r9gmz    0/1       Error     0          6m

kubectl logs po/px-hook-etcd-preinstall-dzmkl -nkube-system
Initializing...
Verifying if the provided etcd url is accessible: http://192.168.20.290:2379
Response Code: 000
Incorrect ETCD URL provided. It is either not reachable or is incorrect...
```
Ensure the correct etcd URL is set as a parameter to the `helm install` command.


## Support

If you have an enterprise license, please contact us at support@portworx.com with your license key and logs.

We are always available on Slack. Join us on [Slack](http://slack.portworx.com)
