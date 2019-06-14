# What’s new... 

## Latest: Chart Version 1.10.0

1. Open Liberty Docker images based on Universal Base Images (UBI) are now publicly available from [Docker hub](https://hub.docker.com/r/openliberty/open-liberty) and the chart uses it as the default image.
1. Integration with Application Navigator
1. Defined the most restrictive SecurityContextConstraints
1. Updated Grafana and Kibana dashboards
1. Updated `kubeVersion` of chart to `>=1.9.0` to support various cloud environments. Ensure patch for [CVE-2018-1002105](https://github.com/kubernetes/kubernetes/issues/71411) is installed in your Kubernetes environment.
1. Updated default resource limit values for CPU and memory

## Breaking Changes

* None

## Fixes

* None

## Prerequisites

* Tiller v2.8.0
* For all others, refer to prerequisites in [README.md](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty-spring/README.md).

## Documentation

Please refer to [README.md](https://github.com/IBM/charts/tree/master/stable/ibm-open-liberty-spring/README.md).

## Known Issues

1. The ability to set the reuse flag while upgrading may not work between all versions. However, it can be used when upgrading from v1.0.0 to v1.10.0.
1. If you enable ingress during deployment _and_ specify a host value, the Launch button will return error 404. 
1. If deploying to the IBM Kubernetes Service on the IBM Public Cloud, you can only create one ingress resource per host. 
1. The createClusterSSLConfiguration option is not supported on z/Linux. To use the useClusterSSLConfiguration option for a deployment targeting z/Linux, you must first do a deployment on a non-z/Linux node in the same cluster, specifying the createClusterSSLConfiguration option in order to establish the cluster-scope SSL configuration.
1. When upgrading the helm chart release on ICP 3.1.x with Helm CLI v2.9.1, the following [issue](https://github.com/helm/helm/issues/4337) may be encountered. Workaround is to specify at least one key-value pair using `--set` as part of the `helm upgrade` command.
1. Istio sidecar injection is not supported in namespaces associated with [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp#podsecuritypolicy-reference), [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc#securitycontextconstraint-reference) or the custom ones defined in the README file. To get around this problem, you would need to associate your namespace with [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp#podsecuritypolicy-reference) or [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc#securitycontextconstraint-reference). This because, sidecar pods must have the `NET_ADMIN` capability allowed.
1. When upgrading to ICP 3.2.0 or deploying Helm charts into ICP 3.2.0, Ingress might fail if `ingress.rewriteTarget` does not follow [the new `rewrite-target` annotation guideline](https://kubernetes.github.io/ingress-nginx/examples/rewrite/#rewrite-target). For more information on this, see [Ingress Configuration](https://github.com/OpenLiberty/ci.docker/docs).

## Limitations 

The chart does not yet provide an out of the box secure configuration for the Metrics endpoint. The Metrics endpoint is served only via HTTP since Prometheus in IBM Cloud Private is not able to scrape secured endpoints at this time. 

## Version History

| Chart | Date         | IBM Cloud Private Supported | Details                      |
| ----- | ------------ | --------------------------- | ---------------------------- |
| 1.10.0 | Jun 14, 2019 | >=3.1.2                   | Use Universal Base Images (UBI) as default; Integration with Application Navigator; Defined the most restrictive SecurityContextConstraints; Updated Grafana and Kibana dashboards; Updated `kubeVersion`; Updated default resource limit values     |
| 1.1.0 - 1.9.0  | N/A          | N/A                         | Skipped these releases to align chart version with other charts                                         |
| 1.0.0 | May 20, 2019 | >=3.1.0                     | Initial release              |
