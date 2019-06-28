# GitLab Helm Chart

GitLab is a web-based Git-repository manager with wiki and issue-tracking features. This `gitlab` chart is based on [GitLab's chart](https://gitlab.com/charts/gitlab).

## TL;DR;

To install the chart with the release name `my-release`:

```bash
helm install --name my-release community/gitlab
```

## Installing chart

### Create secrets

If TLS is enabled, you will need to create certificates for `unicorn`, `minio` (if installed), and the Docker registry. Instructions on how to create these certificates using IBM Cloud Private's Certificate manager can be found [here](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_applications/create_cert.html).

### Image Security Policies

If the cluster has image security policies enforced, the following images should be added to it.

```yaml
apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
kind: ImagePolicy
metadata:
  name: gitlab-cluster-image-policy
  namespace: gitlab
spec:
  repositories:
    - name: registry.gitlab.com/*
```

The following images may also need to be allowed depending on what subcharts you are installing as part of this chart.

- gitlab-runner
  - name: docker.io/gitlab/gitlab-runner:*

- minio
  - name: docker.io/minio/minio:*
  - name: docker.io/minio/mc:*

- postgresql
  - name: docker.io/postgres:*
  - name: docker.io/wrouesnel/postgres_exporter:*

- redis
  - name: docker.io/redis:*
  - name: docker.io/oliver006/redis_exporter:*

- prometheus
  - name: docker.io/prom/prometheus:*
  - name: docker.io/prom/alertmanager:*
  - name: docker.io/prom/node-exporter:*
  - name: docker.io/prom/pushgateway:*
  - name: docker.io/jimmidyson/configmap-reload:*
  - name: k8s.gcr.io/kube-state-metrics:*

- registry
  - name: docker.io/registry:*

- operator
  - name: gcr.io/google_containers/hyperkube:*

- cert-manager
  - name: quay.io/jetstack/cert-manager-controller:*

- nginx-ingress
  - name: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:*
  - name: k8s.gcr.io/defaultbackend:*

For documentation on managing image policies refer to [Enforcing container image security](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_images/image_security.html).

## Persistence

This chart will create Persistent Volume Claims with the assumption that a dynamic provisioner will create the required storage resources. For more information on storage configuration and installation, refer to [GitLab's storage documentation](https://gitlab.com/charts/gitlab/blob/master/doc/installation/storage.md)

## RBAC

RBAC is enabled by default.  If you want to disable it you will need to set the following settings to `false`:

```bash
certmanager.rbac.create=false
nginx-ingress.rbac.createRole=false
prometheus.rbac.create=false
gitlab-runner.rbac.create=false
```

## Configuration

GitLab provides many values to configure each of the parts of the chart. The tables below reflect those of the values provided in this serve as a bare minimum for installation. Further information can be found on [GitLab's documentation for this chart.](https://gitlab.com/charts/gitlab/tree/8cd44f7ebde44adfda32513b9905976382a1caeb/doc)

### global
|  Parameter                                                  |  Default                  | Description |
|  :--------                                                  |  :------                  | :---------- |
|  `edition`                             |  `"ee"`                  | Edition of GitLab to install; `"ce"` for Community Edition and `"ee"` for Enterprise Edition. |
|  `hosts.domain`                                             |  `"example.com"`  | The domain name to be used for the service. |
|  `hosts.https`                                              |  `true`  | Uses HTTPS when enabled; to use HTTP, set both this as well as `global.ingress.tls.enabled` to `false`. |
|  `hosts.externalIP`                                         |  `""`         | The IP that these services will be exposed on; this is the IP of the proxy or LoadBalancer used for the services. |
|  `ingress.configureCertmanager`                             |  `false`                  | This chart can set up its own `cert-manager` and create certificates to associate with its services. This is not advised on IBM Cloud Private. |
|  `ingress.tls.enabled`                                              |  `true`                  | TLS is used when set to `true`. |
---
### certmanager
> By default, IBM disables the install of `cert-manager` in this chart because it causes serious conflicts with the existing `cert-manager` and its associated CRDs on IBM Cloud Private. 

|  Parameter      |  Default  | Description |
|  :--------      |  :------  | :---------- |
|  `install`      |  `false`  | When set to `true`, the chart installs the [cert-manager chart](https://github.com/jetstack/cert-manager). Perform this at your own risk. |
|  `rbac.create`  |  `true`   | When set to `true`, the chart creates and uses RBAC. |
---
### gitlab-runner
|  Parameter      |  Default  | Description |
|  :--------      |  :------  | :---------- |
|  `install`      |  `false`  | Installs [GitLab Runner](https://docs.gitlab.com/runner/) when set to `true`. |
|  `rbac.create`  |  `true`   | When set to `true`, the chart creates and uses RBAC. |
---
### minio
|  Parameter         |  Default                      | Description |
|  :--------         |  :------                      | :---------- |
|  `ingress.tls.secretName`  |  `""`                         | Name of the secret containing the TLS certificate for the `minio` service. |
---
### nginx-ingress
|  Parameter      |  Default  | Description |
|  :--------      |  :------  | :---------- |
|  `enabled`      |  `false`  | Installs an nginx ingress controller when set to `true`; ICP already has an Ingress controller installed by default.  |
|  `rbac.create`  |  `true`   | When set to `true`, the chart creates and uses RBAC. |
---
### prometheus
|  Parameter      |  Default  | Description |
|  :--------      |  :------  | :---------- |
|  `install`      |  `false`  | Installs the `prometheus` subchart. |
|  `rbac.create`  |  `true`   | When set to `true`, the chart creates and uses RBAC. |
---
### registry
|  Parameter         |  Default  | Description |
|  :--------         |  :------  | :---------- |
|  `minReplicas`     |  `1`      | Minimum count of registry replicas. |
|  `maxReplicas`     |  `3`      | Maximum count of registry replicas. |
|  `ingress.tls.secretName`  |  `""`     | Name of the secret containing the TLS certificate for the `registry` service. |
---
### gitlab
|  Parameter                   |  Default  | Description |
|  :--------                   |  :------  | :---------- |
|  `gitlab-shell.minReplicas`  |  `1`      | Minimum count of `gitlab-shell` replicas. |
|  `gitlab-shell.maxReplicas`  |  `3`      | Maximum count of `gitlab-shell` replicas. |
|  `sidekiq.minReplicas`       |  `1`      | Minimum count of `sidekiq` replicas. |
|  `sidekiq.maxReplicas`       |  `3`      | Maximum count of `sidekiq` replicas. |
|  `unicorn.minReplicas`       |  `1`      | Minimum count of `unicorn` replicas. |
|  `unicorn.maxReplicas`       |  `3`      | Maximum count of `unicorn` replicas. |
|  `unicorn.ingress.tls.secretName`            |  `""`     | Name of the secret containing the TLS certificate for the `unicorn` service. |

## Uninstalling the chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release --purge
```

The command removes the Kubernetes objects associated with the chart and deletes the release.

## Detailed documentation

See the [repository documentation](https://gitlab.com/charts/gitlab/tree/8cd44f7ebde44adfda32513b9905976382a1caeb/doc/index.md) for how to install GitLab and other information on charts, tools, and advanced configuration.

## Architecture and goals

See [architecture documentation](https://gitlab.com/charts/gitlab/tree/8cd44f7ebde44adfda32513b9905976382a1caeb/doc/architecture/index.md) for an overview of this project goals and architecture.

## Known issues and limitations

See [limitations](https://gitlab.com/charts/gitlab/tree/8cd44f7ebde44adfda32513b9905976382a1caeb/doc/index.md#limitations).

## Support

Contact [support for GitLab](https://about.gitlab.com/support/).
