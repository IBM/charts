# What’s new...

### Latest: Chart Version 1.0.1

1. Some minor bug fixes.

## Breaking Changes
* None

## Fixes
* None

## Prerequisites
* Tiller v2.9.1
* Kubernetes v1.12.4
* For all others, refer to prerequisites in README.md.

## Documentation
Please refer to README.md.

## Known Issues
* None

## Limitations

1. Installation of this chart is only supported on IBM Cloud Private (ICP).
1. Creating multiple instances of IBM Application Navigator's controller pods may cause redundant updates to Kubernetes resources and may affect the overall performance of the cluster. For this reason, installing the chart multiple times on the same cluster is not recommended. Scaling the number of controller pods >1 can have a similar effect and is also not recommended.
1. When the ICP management ingress is used, only authenticated users will have access to the IBM Application Navigator's UI. The chart does not provide finer grained access controls.

## Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.0.1 | Aug 20, 2019 | >=1.12.4 | app-nav-api:1.0.1, app-nav-ui:1.0.1, app-nav-controller:1.0.1, app-nav-was-controller:1.0.1, app-nav-init:1.0.1, app-nav-cmds:1.0.1 |  | Minor bug fixes |
| 1.0.0 | Jun 21, 2019 | >=1.12.4 | app-nav-api:1.0.0, app-nav-ui:1.0.0, app-nav-controller:1.0.0, app-nav-was-controller:1.0.0, app-nav-init:1.0.0, app-nav-cmds:1.0.0 |  | Initial release |
