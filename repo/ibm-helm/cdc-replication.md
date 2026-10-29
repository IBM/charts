# CDC Replication Engine - Helm Chart

This chart deploys IBM CDC replication engine instances in Kubernetes and OpenShift clusters.
One Helm release corresponds to one CDC engine instance. The engine type is selected by
setting `productType` in your values file.

**Supported engine types:**

| `productType` value | Engine |
|---|---|
| `udb` | CDC for IBM Db2 LUW |
| `postgresql` | CDC for PostgreSQL |
| `db2z` | CDC for IBM Db2 for z/OS Remote Source |
| `kafka` | CDC for Kafka (target engine) |
| `iceberg` | CDC for Iceberg (target engine) |

**What the chart deploys:** a single StatefulSet with one pod, a ClusterIP Service, and a
PersistentVolumeClaim. Instance state - subscriptions, bookmarks, replication metadata - is
stored on the PVC and survives pod restarts and upgrades.

**CLI tools:** The chart tarball includes `tools/cdc-container-cli-<version>.tgz` - a set
of `dm*` command-line utilities that proxy CDC engine commands into the running pod using
`kubectl exec`. Extract the tarball on Linux or macOS to use them.

**Full documentation** is included in the `docs/` folder inside the chart tarball and in
the [IBM CDC Knowledge Center](https://www.ibm.com/docs/en/idr/12.0.0).

**System requirements and supported platform versions:**
[IBM Data Replication System Requirements](https://www.ibm.com/support/pages/node/608111)

**IBM Entitlement Key** (required for pulling images from the IBM entitled registry):
[IBM Container Library](https://myibm.ibm.com/products-services/containerlibrary)
