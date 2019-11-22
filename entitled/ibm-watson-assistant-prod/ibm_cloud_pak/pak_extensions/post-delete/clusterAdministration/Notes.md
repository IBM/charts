Cluster administrator may run this script once all the instances of the Watson Assistant chart have been removed from the cluster
  and no other installations of Watson Assistant are planned in the cluster.

Beware, script *will/may break other ICP4D addons* already installed in the cluster.
We strongly recommend NOT to execute the script and leave `zen` namespace labeled by label `ns=zen`.


The script is provided to revert the action performed by `pre-install\clusterAdministration\labelNamespace.sh`;
  i.e., it will remove label `ns=${namesace}` from the namespace. 
This script is provided only to have complementary cleaning action to pre-install step.

To clean-up the the cluster execute:
  `./removeLabelNamespace.sh ICP4D_NAMESPACE` where `ICP4D_NAMESPACE` is the namespace where ICP4D is installed (usually `zen`)
  
Expected output of the script:
```
> ./removeLabelNamespace.sh zen
Printing all namespaces and their labels
> kubectl get namespace --show-labels
NAME           STATUS    AGE       LABELS
cert-manager   Active    7d7h      icp=system
default        Active    7d7h      <none>
ibmcom         Active    7d7h      <none>
istio-system   Active    7d7h      icp=system
kube-public    Active    7d7h      <none>
kube-system    Active    7d7h      icp=system
platform       Active    7d6h      <none>
services       Active    7d6h      <none>
zen            Active    7d6h      ns=zen
> kubectl get namespace zen --show-labels
zen            Active    7d6h      ns=zen


Removing the label 'ns' from the namespace zen
> kubectl label namespace zen ns-
namespace/zen labeled

Label 'ns' successfully removed.


Printing all namespaces and their labels after the label removal
> kubectl get namespace --show-labels
NAME           STATUS    AGE       LABELS
cert-manager   Active    7d7h      icp=system
default        Active    7d7h      <none>
ibmcom         Active    7d7h      <none>
istio-system   Active    7d7h      icp=system
kube-public    Active    7d7h      <none>
kube-system    Active    7d7h      icp=system
platform       Active    7d6h      <none>
services       Active    7d6h      <none>
zen            Active    7d6h      <none>
> kubectl get namespace zen --show-labels
zen            Active    7d6h      <none>
```