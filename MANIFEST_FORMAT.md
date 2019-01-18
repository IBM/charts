# ibm_cloud_pak/manifest.yaml file format

The table outlines the various attributes supported within the file: 

| Element                                 | Description                             |
| --------------------------------------- | --------------------------------------- |
| [charts](#charts)                       | Contains list of Helm charts to archive |
| [charts.archive](#charts-archive)    | The url of the archive to download. 'http:', 'https:' and 'file:' protocols supported | 
| [charts.repository-keys](#chart-repository-keys) | A list of string keys which represent image repositories in values.yml which require updates after import |
| [images](#images)                       | Contains a list of Docker images to include in the archive |
| [images.image](#image) | The target Docker image name/tag for the multi-arch/fat manifest |
| [images.references](#image-references) | Contains a list of images referenced by the above |
| [images.references.repository](#repository)  | The target Docker image name for the current architecture specific repository |
| [images.references.pull-repository](#pull-repository) | The architecture specific repository where the image is pulled from |

## Element Detail

### Charts

The charts element contains a list of helm charts to download and incorporate into the archive

### Chart Archive

Contains the url of the archive to download. The following protocols are supported: 

* http
* https
* file

The 'file' protocol enables referencing of files on the local file system. Any mounted file system is supported using either relative or absolute paths by prefixing the desired path with the 'file:' protocol prefix. For example, to load the 'mychart.tgz' file from the current directory, use the value 'file:mychart.tgz'. 

### Chart Repository Keys

The chart repository-keys element refers to those values.yaml elements which need to be updated as a result of the image uri changing during the import process. Since docker image uris contain the registry host, this is often necessary so that the chart by default will refer to the newly pushed image found in the local image registry. 

Consider a chart which currently references myimage:1.0 with the following values.yml:

```
myservice:
  image:
    repository: myimage
    tag: 1.0
```

The associated spec file should contain a repository-keys element which references `myservice.image.repository`:

```
charts:
  - archive: ...
    repository-keys: 
      - myservice.image.repository

```

After import, the image uri may have changed to include a different docker registry host: `docker-registry.mycorp.com/myimage:1.0`. Note that the change to the image uri is by prefixing the provided uri. 

The values.yml will be updated by the import process to include the following adjusted text: 

```
myservice:
  image:
    repository: docker-registry.mycorp.com/myimage
    tag: 1.0
```

### Images

Contains a list of images to be incorporated into the target archive. 

### Image

References the target docker image name/tag for the manifest. Does not include the final push host which will be determined at import time. 

For example, the value `myimage:1.0` might be available from the final registry under the name `docker-registry.mycorp.com/myimage:1.0` 

### Image References

Contains a list of images incorporated into the manifest for the current image. Usually, each image will be an architecture or operating system variant. 

### Repository

### Pull Repository

The pull repository contains the Docker image uri which will be pulled while building the archive. This image reference may be to an internal server. 

## Examples

### Single architecture image:

Builds a single architecture archive. 

```
charts:
  - archive: https://kubernetes-charts.storage.googleapis.com/mysql-0.2.9.tgz
    repository-keys: 
      - image

images:
- image: mysql:5.7.14
  references:
  - repository: mysql:5.7.14-linux-amd64 # target image will be tagged with os/arch even though the pull repo was not
    pull-repository: mysql:5.7.14
```