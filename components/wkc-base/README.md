# Watson Knowledge Catalog - Unified Governance & Integration Base Charts

# Introduction
Responsible for laying down the core set of services for Unified Governance & Integration Base

1. Catalog Service (CAMS)
2. Catalog UI
3. Connections Services
4. Auth Proxy Services
5. WKC Ingress
6. All necessary core secrets


# Chart Details
## Installing the Chart

To install, issue the following helm command with the appropriate release `release-name`

##### Single-node install:

```bash
$ helm upgrade wkc-base ./wkc-base --namespace wkc --install --set userMgmt.adminUsername=[isadmin],userMgmt.adminPassword=[passw0rd],ingress.host.ip=[1.2.3.4],xmeta.dbHost=[10.74.55.90],iis.hostName=[10.74.55.90],iis.hostPort=[9446]
```

Note: Use a strong password for the adminPassword variable instead of using the same default password shown above  

##### Multi-node install:

```bash
$ helm upgrade wkc-base ./wkc-base --namespace wkc --install --set userMgmt.adminUsername=[isadmin],userMgmt.adminPassword=[passw0rd],ingress.host.ip=[1.2.3.4],xmeta.dbHost=[10.74.55.90],iis.hostName=[10.74.55.90],iis.hostPort=[9446] -f ./wkc-base/values-multinode.yaml
```
Note: Use a strong password for the adminPassword variable instead of using the same default password shown above  

## Configuration

You may change the default of each parameter using the `--set key=value[,key=value]`.

You can also change the default values.yaml and supply it with `-f`

The following tables lists the configurable parameters


| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `ingress.host.ip`                   | Host IP                                             |Required if `ingress.host.domain` is not provided                                |           
| `ingress.host.domain`               | Host domain for ingress                             | Required if `ingress.host.ip` is not provided                                   |                                                                                   |
| `xmeta.dbHost`                      | The host ip of xmeta db server                      | Required if authProxyService is installed                                                                    |
| `iis.hostName`                      | The host ip of iis server                           | Required if authProxyService is installed                                                                       |
| `iis.hostPort`                      | The host port of iis server                         | Required if authProxyService is installed                                                                        |
| `enabled.catalog-ui`                | Whether to install catalog-ui service               | `true`                                                                          |
| `enabled.catalog`                   | Whether to install catalog service                  | `true`                                                                          |
| `enabled.connection`                | Whether to install connection service               | `true`                                                                          |
| `enabled.authProxyService`          | Whether to install wkc auth proxy service           | `true`                                                                          |
| `enabled.secrets`                   | Whether to install all the secrets and config values| `true`                                                                          |

# Prerequisites
None

## Resources Required
## PodSecurityPolicy Requirements

Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive, requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp
```
## Red Hat OpenShift SecurityContextConstraints Requirements
This README does contain the right link: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)

This README does contain the right link: [`restricted`](https://ibm.biz/cpkspec-scc)

Custom SecurityContextConstraints definition:
```
...
```
# SecurityContextConstraints Requirements
## Limitations

