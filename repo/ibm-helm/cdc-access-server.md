# CDC Access Server — Helm Chart

This chart deploys the IBM CDC Access Server in Kubernetes and OpenShift clusters.
The Access Server is the central management hub for all CDC replication engines —
the CDC Management Console and `chcclp` CLI connect to it to manage and monitor replication.

## Quick links

| What you need | Where to go |
|---|---|
| Step-by-step deployment guide | [docs/quickstart-access-server.md](docs/quickstart-access-server.md) |
| Air-gapped / private registry mirroring | [samples/mirror-images.sh](samples/mirror-images.sh) · [samples/mirror-images.txt](samples/mirror-images.txt) |
| Deployment examples (upgrade, credential rotation, multiple instances) | [samples/](samples/) |
| All configuration options | [values.yaml](values.yaml) |
| Configuration schema and validation | [values.schema.json](values.schema.json) |
