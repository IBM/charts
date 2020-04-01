# ibm-nodejs-sample@2.0.1

## Breaking Changes 

THIS CHART IS NOW DEPRECATED. On March 30, 2020 the ibm-nodejs-sample Helm chart will no longer be supported. As this chart was a demonstrative sample application, that was not intended to be used in production, there will be no replacement chart. The chart will be removed on April 30, 2020.

## Prerequisites
* Kubernetes >=1.9.1
* Tiller >=2.6.0

## Documentation

### Upgrade

To upgrade an existing release with name `my-release` to the latest version of this chart:

```bash
$ helm upgrade my-release stable/ibm-nodejs-sample --tls
```

### General

The application is self-documenting by serving a web page containing its general documentation.
See NOTES.txt associated with this chart for information on accessing the sanple application.

## Version History

| Chart | Date     | Kubernetes Required | Image(s) Supported       | Breaking Changes | Details |
| ----- | -------- | ------------------- | -----------------------  | ---------------- | ------- | 
| 2.0.1 | Mar 2020 | >=1.9.1             | icp-nodejs-sample:latest | None             | Chart Deprecation |
| 2.0.0 | Mar 2019 | >=1.9.1             | icp-nodejs-sample:latest | None             | Node 10 changes                            |
| 1.2.1 | Dec 2018 | >=1.9.1             | icp-nodejs-sample:latest | None             | Chart metadata and documentation changes |
| 1.2.0 | Mar 2018 | >=1.9.1             | icp-nodejs-sample:latest | None             | First release                              |
