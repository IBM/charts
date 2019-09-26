## Configuration

The following table lists the configurable parameters for this chart and their default values.

| Parameter                  | Description                        | Default                                                    |
| -----------------------    | ---------------------------------- | ---------------------------------------------------------- |
| `db.image.repository`                 | db image name                      | cdi-db                                                     |
| `db.image.tag`                   | db image tag                       | latest                                                     |
| `clouseau.image.repository`           | clouseau image name                | cdi-clouseau                                               |
| `clouseau.image.tag`             | clouseau image tag                 | latest                                                     |
| `logging.level`            | logging level                      | notice                                                     |
| `systemdatabases`          | Cloudant system databases list     | _replicator, bacon stats tally users                       |
| `storage.db.storage_class` | storage class for db               | ibmc-block-bronze                                          |
| `storage.db.requests.storage`| storage capacity for db          | 20Gi                                                       |
| `dbpods.ulimit.core_file_size` | db container core file size    | 0                                                          |
| `dbpods.ulimit.stack_size` | db container stack size            | 8388608                                                    |
| `dbpods.ulimit.max_processes` | db container max process        | 516285                                                     |
| `dbpods.ulimit.max_open_files` | db container max open files    | 16384                                                      |
| `dbpods.erlang.max_ports`  | max ports for erlang               | 16384                                                      |
| `dbpods.resources.limits.cpu` | db container CPU limits         | 4                                                          |
| `dbpods.resources.limits.memory` | db container memory limits   | 4Gi                                                        |
| `dbpods.resources.requests.cpu` | db container CPU requests     | 4                                                          |
| `dbpods.resources.requests.memory` | db container memory requests | 4Gi                                                      |
| `global.antiAffinity.required`    | require db pods to be scheduled with anti-affinity | false                               |
| `global.antiAffinity.topologyKey` | topologyKey to use for antiAffinity | kubernetes.io/hostname                             |
| `global.docker.registry`   | image pulling secret               | cdtrainbow-registry                                        |
| `global.images.pullPolicy` | image pulling policy               | Always                                                     |
| `global.images.registry`   | image repository                   | registry.ng.bluemix.net/cdtrainbow                         |
| `global.replicas.db`       | k8s deployment replicas            | 3                                                          |
| `global.cloudant.username` | db admin username                  |                                                            |
| `global.cloudant.password` | db admin password                  |                                                            |
| `global.inMemoryOnly`      | use in-memory volumes only         | false                                                      |
| `global.cloudant.singleNode` | use single-node deployment       | false                                                    |
