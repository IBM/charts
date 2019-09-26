# Watson Studio Base Charts

Responsible for laying down the core set of services for Watson Studio as part of WDP Fabric

1. Portal-Main
2. Portal-Common-API
3. Projects API
4. Portal Notifications
5. File Asset APIs
6. Shaper/Data Prep


## Installing the Chart

To install, issue the following helm command with the appropriate release-name

##### Single-node install:

```bash
$ helm upgrade ws-base ./ws-base --namespace wkc --install --set global.assetFilesApi.path=[/mnt/asset_file_api],global.assetFilesApi.host=[myhost]
```

##### Multi-node install:

```bash
$ helm upgrade ws-base ./ws-base --namespace wkc --install --set global.assetFilesApi.path=[/mnt/asset_file_api],global.assetFilesApi.host=[myhost] -f ./ws-base/values-multinode.yaml
```


## Configuration

You may change the default of each parameter using the `--set key=value[,key=value]`.

You can also change the default values.yaml and supply it with `-f`

The following tables lists the configurable parameters


| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `global.assetFilesApi.path`         | The path to the file system mount for files api     | Required                                                                        |                                                                           |
| `global.assetFilesApi.host`         | Host for nodeAffinityof files api     | Required                                                                        |                                                                           |
| `global.assetFilesApi.storage`      | The amount of storage for files api                 | `30Gi`                                                                          |
| `enabled.portal-main`               | Whether to install portal-main service              | `true`                                                                          |
| `enabled.ngp-projects-api`          | Whether to install projects service                 | `true`                                                                          |
| `enabled.portal-common-api`         | Whether to install common api service               | `true`                                                                          |
| `enabled.portal-notifications`      | Whether to install portal notifications service     | `true`                                                                          |
| `enabled.asset-files-api`           | Whether to install files asset api service          | `true`
| `enabled.shaper`                    | Whether to install shaper service                   | `true`
