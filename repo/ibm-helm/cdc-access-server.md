# CDC Access Server - Helm Chart

This chart deploys the IBM CDC Access Server in Kubernetes and OpenShift clusters.
The Access Server is the central management hub for all CDC replication engines -
the CDC Management Console and `chcclp` CLI connect to it to manage and monitor replication.

One Helm release corresponds to one Access Server instance. The user store - containing
user accounts and registered datastores - is backed by a PersistentVolumeClaim and survives
pod restarts and upgrades.

**What the chart deploys:** a single StatefulSet with one pod, a ClusterIP Service, and a
PersistentVolumeClaim. The Access Server listens on TCP port **10101** inside the container.

**Full documentation** is included in the `docs/` folder inside the chart tarball and in
the [IBM CDC Knowledge Center](https://www.ibm.com/docs/en/idr/12.0.0).

**System requirements and supported platform versions:**
[IBM Data Replication System Requirements](https://www.ibm.com/support/pages/node/608111)

**IBM Entitlement Key** (required for pulling images from the IBM entitled registry):
[IBM Container Library](https://myibm.ibm.com/products-services/containerlibrary)
