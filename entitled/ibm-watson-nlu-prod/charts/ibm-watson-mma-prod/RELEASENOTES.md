Latest: v1.0.2

### What's new...

1.1.0
  Change app name to ibm-watson-mma and service type to ClusterIP

1.0.2
  Satisfying CV Lint 2.0.8

1.0.1
  Chart now supported on Red Hat OpenShift

1.0.0
  Initial release

### Fixes

None

### Prerequisites

See [README.md](./README.md)

### Breaking Changes

None

### Documentation

See [README.md](./README.md)

### Version History

| Chart | Date              | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ----------------- | --------------------------- | ---------------- | ------- |
| 1.0.0 | June 28th, 2019  | >=1.10                       | None             | Initial Release |
| 1.0.1 | August 30th, 2019 | >=1.10 | None | Support RedHat OpenShift |
| 1.0.2 | November 1st, 2019 | >=1.11 | None | Satisfying CV Lint 2.0.8 |
| 1.1.0 | November 30th, 2019 | >=1.11  | Application name change; will affect anything that references MMA by application name; use ClusterIP not NodePort | Change application name and service type to ClusterIP |
