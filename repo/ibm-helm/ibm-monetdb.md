
## Install MonetDb (dedicated page)

`helm install  <RELEASE NAME> ./ibm-monetdb  --namespace <YOUR NAMESPACE> -f sample-monet.yml` 



### Configuration options
You can override following settings in the value file

```
# image and registry
images: 
  registry: 'my.companyregistry.io'
  monet: 'processmining-monet:20260413-2038'

# storage options
storage:
  #size in Gb
  size: 30
  # storageClass, if empty the cluster default will be used
  class: ''
  # create or not the PVC
  # if false a nanem of an existing one must be privided
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
