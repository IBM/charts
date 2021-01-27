## Introduction

This document describes how to deploy Enterprise MongoDB v4.4 on RedHat's OpenShift Container Platform on  IBM Power Systems
The docker image leveraged are custom built for IBM Power Architecture i.e. ppc64le

## Chart details

The Helm chart creates the following resources:
- Service with the name,
- Deployment with the name, 

**Note** : Here, `<release name>` refers to the name of the helm release.

## Prerequisites

- Ensure to install Kubernetes version 1.16.0-0 or later

- Ensure to install Helm version 3.0.0 or later

- The default images are available through ibmcom/ibm-enterprise-mongodb-ppc64le

- Create a persistent volume with the access mode as 'Read write many' and a minimum of 10 GB space.


## Resources Required

####By default, the chart uses the following resources:

## Configuration



## Instructions to deploy this helm chart
Git clone this repository on your server -

```
cd $HOME/
git clone https://github.ibm.com/krishvoor/ibm-mongodb-enterprise-helm
cd ibm-mongodb-enterprise-helm
```

Create a new project/namespace 

```
oc new-project ibm -description="IBM ISDL" --display-name="ibm"
oc project ibm
```

Update the following variables in values.yaml file -

`adminuser` , `adminpassword` ,`name_database`

this information would be leveraged and corresponding custom user/password with superadmin privileges would be created inside container.

Update SCC in your Namespace, this would be required to allow mongodb container to be executed -

`oc adm policy add-scc-to-user anyuid -z default mongod`

Installing helm chart

`helm install <HELM_NAME> -f ./values.yaml ../ibm-mongodb-enterprise-helm/`

e.g :-

`helm install test -f ./values.yaml ../ibm-mongodb-enterprise-helm/` 


To validate if chart got installed successfully -

```
[root@p634-bastion ~]# helm ls
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
NAME	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART                            	APP VERSION
test	harsha   	1       	2021-01-19 11:49:53.626581975 -0500 EST	deployed	ibm-mongodb-enterprise-helm-0.1.0	1.16.0     
[root@p634-bastion ~]# oc get po
NAME                                                           READY   STATUS    RESTARTS   AGE
test-ibm-mongodb-enterprise-helm-deployment-7d77767cf8-mspj4   1/1     Running   0          3m37s
[root@p634-bastion ~]# 

```


#### To-DO Add Instructions to create PV and allocation ####
