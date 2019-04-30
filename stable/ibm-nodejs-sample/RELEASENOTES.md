# ibm-nodejs-sample@2.0.0

## Breaking Changes
* Removal of Node 6 Docker image due to Node 6 being End-of-Life. 
* Defaults to Node 10 Docker image. 

## What’s new in Chart Version 2.0.0
* Node 10 Docker image. 

## Fixes
* Includes missing metadata for catalog classification and parameter values

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
| 2.0.0 | Mar 2018 | >=1.9.1             | icp-nodejs-sample:latest | None             | Node 10 changes                            |
| 1.2.1 | Dec 2018 | >=1.9.1             | icp-nodejs-sample:latest | None             | Chart metadata and documentation changes |
| 1.2.0 | Mar 2018 | >=1.9.1             | icp-nodejs-sample:latest | None             | First release                              |
