This script has to be run once per namespace. Note that this can only run after the namespace has been created.

Run:
```
./deleteSecurityNamespacePrereqs.sh releaseNamespace
```
Once the script is executed, the namespace specified will accept traffic from other namespaces.


This deletes the rolebinding `watson-assistant-chart-role-binding-for-namespace-{{ .Release.Namespace }}` in the namespace specified, created by the `pak_extensions/pre-install/NamespaceAdministration/createSecurityNamespacePrereqs.sh` script.
