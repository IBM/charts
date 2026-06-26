## Db2 Instance Helm Chart
Use this Helm chart to template a sample Db2uInstance Custom Resource (CR) for both Db2 OLTP and Db2 Warehouse.
This chart can be customized by modifying the values in the `values.yaml` file, or using `--set` flags during the Helm template command.

### Templating the Chart
To generate the Db2uInstance CR YAML file, run the following command:
```bash
helm template . --output-dir ./renders
```
This will create a directory under `renders` containing the rendered YAML files.

### Customizing the Chart
You can customize the chart by modifying the `values.yaml` file or by using `--set`.

An example of using `--set` to customize the chart:
```bash
helm template . --set name=mynewdb2instance --set storageclassname.rwx=managed-nfs-storage --output-dir ./renders
```

Available customization options in `values.yaml`:
- `name`: Name of the Db2 instance.
- `image.repository`: The container image repository for Db2.
- `image.tag`: The tag of the container image for Db2.
- `image.imageRegistryOverride`: Allows overriding the image registry so that images can come from a different registry (not icr.io).
- `storageclassname.rwo`: Storage class name for ReadWriteOnce volumes.
- `storageclassname.rwx`: Storage class name for ReadWriteMany volumes.
- `deployments`: Allows enabling/disabling of specific deployments (e.g., `db2oltp`, `db2wh`). Specify as a list.

### Renders Directory
Once you render your helm chart, you will find the rendered files in this directory.
