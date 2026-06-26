
# Install MonetDb

## Docker images (for airgap env)

If you are using mirrored images you need change the registry url.
You can also change image digest (i.e. replace it with a tag)

```
images: 
  registry: 'my.companyregistry.io'
  monet: 'processmining-monet:20260413-2038'
```

## Configuration options
You can optionally override following settings in the value file

```
# storage options
storage:
  #size in Gb
  size: 30
  # storageClass, if empty the cluster default will be used
  class: ''
  # create or not the PVC
  # if false a name of an existing one must be privided
  create: true
  name:  ''

# pod resources
resources:
  requests:
    cpu: "500m"
    memory: "2Gi"
    ephemeralstorage: "2Gi"
  limits:
    cpu: "8000m"
    memory: "18Gi"
    ephemeralstorage: "8Gi"
```

## Install MonetDb release

`helm install  <RELEASE NAME> ./ibm-monetdb  --namespace <YOUR NAMESPACE> -f sample-monet.yml` 
