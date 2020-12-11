# What's new in Helm chart 20.3.0
The version 20.3.0 of the Helm chart installs version 8.10.5.0 of IBM Operational Decision Manager. For a complete list of new features in this release, go to [What's new](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.x/com.ibm.odm.distrib.overview/shared_whatsnew_topics/con_whats_new8105.html).

# Prerequisites
1. Kubernetes 1.11 or higher, with Helm 3.2 or higher.
2. For the internal database, create a persistent volume or use dynamic provisioning.
3. To secure access to the database, create a secret that encrypts the database user and password.

# Documentation
For more information, go to [Operational Decision Manager knowledge center](https://www.ibm.com/support/knowledgecenter/en/SSQP76_8.10.x/com.ibm.odm.kube/kc_welcome_odm_kube.html)

# Fixes
[Operational Decision Manager Interim Fixes](http://www.ibm.com/support/docview.wss?uid=swg21640630)

# Upgrading
## Support of a custom service account
Version 20.3.0 of the chart uses a custom service account named `<releasename>-ibm-odm-prod-service-account` by default. Hence to upgrade from version 20.2.x to 20.3.0, you need to make sure that this service account uses the appropriate psp or scc.

In OpenShift, to use the `restricted` scc, you must define the `customization.runAsUser` parameter as empty since the restricted scc requires to used an arbitrary UID.

```console
$ helm install my-odm-prod-release \
  --set customization.runAsUser='' \
  /path/to/ibm-odm-prod-<version>.tgz
```

> **Note**: Similarly, if you use the internal database, `internalDatabase.runAsUser` should be set empty.

## Upgrade the internal database data
With version 20.3.0 of the chart, the internal database used for evaluation and demonstration purposes requires PostgreSQL version 12.

As versions 9.6 and 12 are not compatible, you need to migrate the data between the two releases.

Here is the procedure to transfer your data from the previous release based on PostgreSQL 9.6 to the new release based on PostgreSQL 12.

1. Set up the environment variable
```console
export RELEASE_NAME=myhelmrelease
export DBSERVER_POD=`kubectl get pods | grep $RELEASE_NAME  | grep dbserver | awk '{print $1}'`
```

2. Scale down the ODM containers
```console
 kubectl get deployment | grep $RELEASE_NAME  | grep odm-decision | awk '{print $1}'  | xargs kubectl scale deployment --replicas 0
```

```
deployment.extensions/test2-odm-decisioncenter scaled
deployment.extensions/test2-odm-decisionrunner scaled
deployment.extensions/test2-odm-decisionserverconsole scaled
deployment.extensions/test2-odm-decisionserverruntime scaled
```

3. Verify that all pods are terminated

```console
kubectl get pods  | grep $RELEASE_NAME  | grep odm-decision
```
You should not see anything running after executing this command.

4. Back up the content of the dbserver container (PostgreSQL 9.6)
```console
kubectl exec -ti $DBSERVER_POD -- bash -c '/usr/bin/pg_dump -C -Fc -h localhost -U $POSTGRES_USER $POSTGRES_DB  -f /tmp/odmdb.dump'
```

5. Copy the dump to your local machine
```console
kubectl cp $DBSERVER_POD:/tmp/odmdb.dump ./odmdb.dump
```

6. Scale down the dbserver pods and delete the old PVC/PV
```console
kubectl get deployment | grep $RELEASE_NAME  | grep dbserver | awk '{print $1}'  | xargs kubectl scale deployment --replicas 0
kubectl delete pvc <PVCNAME>
kubectl delete pv <PVNAME>
```

7. Perform a helm upgrade

Do not forget to set the `reuse-values` flag and to set `internalDatabase.sample` to false.
```console
helm upgrade myhelmrelease ./ibm-odm-prod-8.10.5.0.tar.gz --reuse-values --repo file:./ --set internal.populateSampleData=false,image.tag=8.10.5.0
```

8. Scale up the dbserver pods
```console
kubectl get deployment | grep $RELEASE_NAME | grep dbserver | awk '{print $1}'  | xargs kubectl scale deployment --replicas 1
```

9. Verify the dbserver is up and running
```console
kubectl get deployment | grep $RELEASE_NAME | grep dbserver
```

10. Retrieve the new dbserver pods
```console
export DBSERVER_NEWPOD=`kubectl get pods | grep $RELEASE_NAME  | grep dbserver | awk '{print $1}'`
```

11. Copy and then restore the PostgreSQL dump
```console
kubectl cp ./odmdb.dump $DBSERVER_NEWPOD:/tmp/
```

```console
kubectl exec -ti $DBSERVER_NEWPOD -- bash -c  'pg_restore -Fc -d $POSTGRES_DB -h localhost -U $POSTGRES_USER /tmp/odmdb.dump'
```

12. Scale up the ODM containers
```console
kubectl get deployment | grep $RELEASE_NAME | grep odm-decision | awk '{print $1}'  | xargs kubectl scale deployment --replicas 1
```


For details about how to upgrade, see [Upgrading ODM releases](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/tsk_k8s_upgrade.html)


# Breaking Changes
 None

# Version History
| Chart | Date     | Details                           |
| ----- | -------- | --------------------------------- |
| 20.3.0 | Dec 2020 | ODM 8.10.5 release - Add default custom serviceAccount, Support `restricted` scc in Openshift, Microsoft SQL Server 2019 support, PostgreSQL version 12 support, Digest support, Automate Ingress creation to access ODM services, Decision Server Console title configuration |
| 20.2.1 | Sept 2020 | Security update, Bug fixes |
| 20.2.0 | June 2020 | ODM 8.10.4 release - Update Liberty version, OpenID integration, Xu configuration, Automate route creation for Openshift, Improve NetworkPolicies, Ability to populate sample data |
| 2.3.0 | Dec 2019 | Add logging / jvm options customization. - Change minimum memory for Decision Center |
| 2.2.1 | Sept 2019 | Network policy security isolation |
| 2.2.0 | June 2019 | ODM 8.10.2 release - UBI base image |
| 2.1.0 | March 2019 | ODM 8.10.1 release - Support for non-root  |
| 2.0.0 | Dec 2018 | ODM 8.10.0 release - Monitoring and HA improvements |
| 1.1.0 | July 2018 | ODM 8.9.2.1 release - Logging improvement and PVU pricing                |
| 1.0.1 | March 2018 | ODM 8.9.2.0 interim fix - ZLinux support (s390)               |
| 1.0.0 | March 2018 | First full release ODM 8.9.2.0                |
