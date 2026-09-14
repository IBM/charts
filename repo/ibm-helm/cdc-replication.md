# CDC Replication Engine — Helm Chart

This chart deploys IBM CDC replication engine instances in Kubernetes and OpenShift clusters.
One chart supports all CDC source engine types; the deployed engine is selected by setting
`productType` in your values file.

## Quick links

| What you need | Where to go |
|---|---|
| Common setup (namespace, pull secret, registry, networking) | [docs/common-quickstart.md](docs/common-quickstart.md) |
| Deploy CDC for IBM Db2 LUW | [docs/quickstart-udb.md](docs/quickstart-udb.md) |
| Deploy CDC for PostgreSQL | [docs/quickstart-postgresql.md](docs/quickstart-postgresql.md) |
| Air-gapped / private registry mirroring | [samples/mirror-images.sh](samples/mirror-images.sh) · [samples/mirror-images.txt](samples/mirror-images.txt) |
| Deployment examples (upgrade, credential rotation, multiple instances) | [samples/](samples/) |
| All configuration options | [values.yaml](values.yaml) |
| Configuration schema and validation | [values.schema.json](values.schema.json) |
