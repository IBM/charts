## Configuration

The following table lists the configurable parameters for this chart and their default values.

| Parameter                  | Description                        | Default                                                    |
| -----------------------    | ---------------------------------- | ---------------------------------------------------------- |
| `httpsPort`                | Kubernetes external service port for HTTPS | 443                                                |
| `httpPort`                 | Kubernetes external service port for HTTP  | 80                                                 |
| `serveHttp`                | enable HTTP service in LB          | true (but this should be false for production              |
| `serveHttps`               | enable HTTPS service in LB         | false                                                      |
| `sslCertSecret`            | name of secret containing SSL cert to use | None                                                |
| `glum.image.repository`               | glum image name                    | cdi-glum                                                   |
| `glum.image.tag`                 | glum image tag                     | latest                                                     |
| `glum.version`             | glum version                       | 1.60.1-beacon                                              |
| `glum.proc.frontend_process`| list of proc ids to bind as http-proxy  | [1]                                                  |
| `glum.proc.nbproc`         | number of processes to spawn       | 1                                                          |
| `glum.dns.resolve_retries` | retry times of dns resolver        | 3                                                          |
| `glum.resources.limits.cpu`| cpu limits for haproxy container   | 1                                                          |
| `glum.resources.limits.memory`| memory limits for haproxy container | 2Gi                                                    |
| `glum.resources.requests.cpu`| cpu requests for haproxy container | 0.5                                                      |
| `glum.resources.requests.memory`| memory requests for haproxy container | 1Gi                                                |
| `dnsmasq.image.repository`            | dnsmasq image name                 | kdi-dnsmasq                                                |
| `dnsmasq.image.tag`              | dnsmasq image tag                  | latest                                                     |
| `global.docker.registry`   | image pulling secret               | cdtrainbow-registry                                        |
| `global.images.pullPolicy` | image pulling policy               | Always                                                     |
| `global.images.registry`   | image repository                   | registry.ng.bluemix.net/cdtrainbow                         |
| `global.replicas.glum`     | k8s deployment replicas            | 2                                                          |
