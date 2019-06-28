Forked from https://github.com/helm/charts/tree/master/stable/docker-registry

With a few tweaks to make it play nicely with GitLab, including Minio S3
storage and GitLab authentication endpoint.

## Configuration

In addition to the original configuration that are inherited from the upstream,
this chart also introduces some additional configuration. See [additional options](https://gitlab.com/charts/gitlab/blob/8cd44f7ebde44adfda32513b9905976382a1caeb/doc/charts/registry/index.md#installation-command-line-options)

## Development

For more details, see [development notes](https://gitlab.com/charts/gitlab/blob/8cd44f7ebde44adfda32513b9905976382a1caeb/doc/development/index.md#verifying-registry)
