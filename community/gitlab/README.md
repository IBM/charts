# GitLab Helm Chart
#TODO: DLG: based on [GitLab's chart](https://gitlab.com/charts/gitlab)

## Installing chart

###TODO: DLG: is this a TL;DR?
To install the chart with the release name `my-release`:

```bash
helm install --name my-release community/gitlab
```

### Create secrets

#TODO: DLG: any secrets that need to be pre-created?

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
##TODO: DLG: 5 PVCs created depending on what subcharts you are installing

## RBAC

RBAC is enabled by default.  If you want to disable it you will need to do the following:

```bash
helm install community/gitlab --set <TODO: DLG: chartnames>.rbac.create=false
```

## Configuration

#TODO: enter huge table here?

## Uninstalling the chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release --purge
```

The command removes the Kubernetes objects associated with the chart and deletes the release.

## Support

Contact [support for GitLab](https://about.gitlab.com/support/).




___

The `gitlab` chart is the best way to operate GitLab on Kubernetes. It contains
all the required components to get started, and can scale to large deployments.

Some of the key benefits of this chart and [corresponding containers](https://gitlab.com/gitlab-org/build/CNG) are:

- Improved scalability and reliability.
- No requirement for root privileges.
- Utilization of object storage instead of NFS for storage.

## Detailed documentation

See the [repository documentation](https://gitlab.com/charts/gitlab/tree/8cd44f7ebde44adfda32513b9905976382a1caeb/doc/index.md) for how to install GitLab and
other information on charts, tools, and advanced configuration.

## Architecture and goals

See [architecture documentation](https://gitlab.com/charts/gitlab/tree/8cd44f7ebde44adfda32513b9905976382a1caeb/doc/architecture/index.md) for an overview
of this project goals and architecture.

## Known issues and limitations

See [limitations](https://gitlab.com/charts/gitlab/tree/8cd44f7ebde44adfda32513b9905976382a1caeb/doc/index.md#limitations).
