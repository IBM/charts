Cluster administrator has to run this script once prior to installing the Watson Assistant chart.
  It is enough to run the script once per cluster.

Run: `./labelNamespace.sh ICP4D_NAMESPACE` where `ICP4D_NAMESPACE` is the namespace where ICP4D is installed (usually `zen`)

The script adds label `ns=${ICP4D_NAMESPACE}` to the specified namespace.
  The label on `ICP4D_NAMESPACE` is needed to permit the nginx pods in `ICP4D_NAMESPACE` communication with our namespace using network policy.


Expected output of the script:
```
> ./labelNamespace.sh zen
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
zen            Active    7d6h      <none>
> kubectl get namespace zen --show-labels
zen            Active    7d6h      <none>


Setting the label 'ns' (with value zen) for the namespace zen
> kubectl label --overwrite namespace zen ns=zen
namespace/zen labeled

Label 'ns=zen' successfully added to the namespace zen.


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
```