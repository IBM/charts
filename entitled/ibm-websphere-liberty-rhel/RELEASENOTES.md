# What’s new...

## Latest: Chart Version 1.9.0

1. Defined the most restrictive SecurityContextConstraints and removed PodSecurityPolicy definition from the chart as it does not apply.
1. Added support for WebSphere Liberty OpenID Connect Client feature, so applications can be secured using OpenID Connect.
1. Updated Kibana dashboards.

## Breaking Changes

- None

## Fixes

- None

## Prerequisites

- Tiller v2.9.1
- For all others, refer to prerequisites in README.md.

## Documentation

Please refer to README.md.

## Known Issues

1. The ability to set the reuse flag while upgrading may not work between all versions. However, it can be used when upgrading from v1.8.0 to v1.9.0.
1. If your application uses IIOP, you must remove the iiopEndpoint configuration from your server.xml before building the Docker image you intend to deploy via this Helm chart. Failure to do so will prevent port values you specify through this Helm chart from overriding those specified in your server.xml. 
1. If your deployment enables IIOP and/or JMS endpoints, they will be erroneously displayed in the Launch button dropdown on the Helm Releases page of the ICP console. The Launch button only works with HTTP/S endpoints, so launching IIOP or JMS endpoints obviously will result in errors.
1. If you enable ingress during deployment _and_ specify a host value, the Launch button will return error 404.
1. If your deployment enables persistence, ensure `persistence.fsGroupGid` is set to the group ID of the group owning the persistent volumes' file systems.
1. When upgrading the Helm chart release on ICP 3.1.x with Helm CLI v2.9.1, the following [issue](https://github.com/helm/helm/issues/4337) may be encountered.
1. If `rbac.install` is set to `true` while upgrading to v1.9.0, it may fail due to an issue related to rolebinding. The release's rolebinding must be deleted prior to upgrade. Run following commands after replacing NAMESPACE and RELEASE-NAME with your values:
    ```
    helm delete -n NAMESPACE rolebinding RELEASE-NAME-ibm-websphere-liberty
    helm upgrade --tls --reuse-values RELEASE-NAME ibm-charts/ibm-websphere-liberty
    ```

## Limitations

1. The chart does not yet provide an out of the box secure configuration for the `/metrics` endpoint.  The `/metrics` endpoint is served only via HTTP without authentication since prometheus in IBM Cloud Private is not able to scrape secured endpoints at this time.
1. The createClusterSSLConfiguration option is not supported when using [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) PodSecurityPolicy or the custom one defined in the README.md file. To use the useClusterSSLConfiguration option for a deployment, you must first create a deployment using [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) PodSecurityPolicy in the same cluster, specifying the createClusterSSLConfiguration option in order to establish the cluster-scope SSL configuration.

## Version History

| Chart         | Date          | IBM Cloud Private Supported | Details                      |
| ------------  | ------------- | --------------------------- | ---------------------------- |
| 1.9.0         | MAR, 29, 2019 | >=3.1.0                     | Defined the most restrictive SecurityContextConstraints; Added support for OpenID Connect Client feature; Updated Kibana dashboards |
| 1.8.0         | JAN 31, 2019  | >=3.1.0                     | Defined the most restrictive PodSecurityPolicy; Added support for more configurable parameters; Changed HTTP, JMS and IIOP service names; Updated Kibana dashboards, Updated Docker image requirements     |
| 1.2.0 - 1.7.0 | N/A           | N/A                         | Skipped these releases to align version with other charts     |
| 1.1.0         | NOV 9, 2018   | >=3.1.0                     | Added support to serve `/metrics` on HTTP port; Added new Grafana dashboard file; Updated Kibana dashboard files  |
| 1.0.0         | SEP 24, 2018  | >=3.1.0                     | Initial release               |
