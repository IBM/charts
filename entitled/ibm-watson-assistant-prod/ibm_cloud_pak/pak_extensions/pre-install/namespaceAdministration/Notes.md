This script has to be run once per namespace. Note that this can only run after the namespace has been created.

Run:
```
./createSecurityNamespacePrereqs.sh releaseNamespace
```
Once the script is executed, the ibm-restricted-psp Pod Security Policy will be enforced.

This creates the rolebinding `watson-assistant-chart-role-binding-for-namespace-{{ .Release.Namespace }}`
  in the namespace specified and prevent pods that don't meet the ibm-restricted-psp Pod Security Policy from being started.
