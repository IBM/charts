### In RHOS, following commands have to be run to grant privileges for certain components. 

release_name variable has to be set to the release name used when the chart is deployed

```
oc adm policy add-scc-to-user privileged -z ${release_name}-db2
oc adm policy add-scc-to-user privileged -z ${release_name}-case-manager
oc adm policy add-scc-to-user privileged -z ${release_name}-kafka
oc adm policy add-scc-to-user anyuid -z ${release_name}-cognos
oc adm policy add-scc-to-user anyuid -z ${release_name}-wca
oc adm policy add-scc-to-user anyuid -z ${release_name}-rms-streams
```

### Also, following commands have to be run to delete immutable manifests during helm upgrade

inst_namespace and release_name have to set to the values used during helm chart deployment

```
kubectl delete sts -n "$inst_namespace" --cascade=false -l "app in (kafka-zk,db2-datastore,mongodb,kafka),release in (${release_name})"
kubectl delete po -n "$inst_namespace" -l "release in (${release_name}),app in (kafka-zk,db2-datastore,mongodb,kafka)"
kubectl delete deploy -n "$inst_namespace" -l "release in (${release_name})"
kubectl delete job -n "$inst_namespace" -l "release in (${release_name}),app=kafka-config"
kubectl delete job -n "$inst_namespace" -l "release in (${release_name}),app=mongodb-config"
kubectl delete job -n "$inst_namespace" -l "release in (${release_name}),app=logging-curator"
kubectl delete psp -n "$inst_namespace" -l "release in (${release_name}),app=grafana"
```
