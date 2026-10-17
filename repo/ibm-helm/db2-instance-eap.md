# DB2 Instance Helm Chart

Generate DB2 instance manifests using profile-based configuration. Review the generated YAML before applying to your cluster.

## Quick Start

```bash
# 1. Generate the manifest
helm template my-db2 . -f values-dev.yaml \
  --namespace db2u \
  --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<your-rwo-class> \
  --set storageclassname.rwx=<your-rwx-class> \
  --output-dir renders/dev

# 2. Review it
cat renders/dev/db2-instance/templates/db2-oltp.yaml

# 3. Apply it
oc apply -f renders/dev/db2-instance/templates/
```

> The `--namespace` flag controls the namespace in the generated manifests. If omitted, Helm uses your current kubectl context namespace.

---

## Profile Files

There are two profile files. Start with `values-dev.yaml` — no decisions needed beyond image tag and storage classes.

### `values-dev.yaml` — Development / Evaluation

Single-node OLTP. Minimal resources. For local testing, CI, and evaluating DB2.

```bash
helm template my-db2 . -f values-dev.yaml \
  --namespace db2u \
  --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<your-rwo-class> \
  --set storageclassname.rwx=<your-rwx-class> \
  --output-dir renders/dev

oc apply -f renders/dev/db2-instance/templates/
```

### `values-prod.yaml` — Production (Warehouse MPP default)

Multi-node Warehouse MPP. Choose a size with `--set profile.size=small|medium|large`.

```bash
helm template my-db2 . -f values-prod.yaml \
  --namespace db2u \
  --set profile.size=small \
  --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<your-rwo-class> \
  --set storageclassname.rwx=<your-rwx-class> \
  --output-dir renders/prod

oc apply -f renders/prod/db2-instance/templates/
```

---

## Production Workload Types

The default production workload is Warehouse MPP. Layer an example file to switch workload type:

| Workload | What it is | How to select |
|---|---|---|
| **Warehouse MPP** *(default)* | Multi-node analytics warehouse | `values-prod.yaml` alone |
| **Warehouse SMP** | Single-node analytics warehouse | `+ -f examples/prod-wh-smp.yaml` |
| **OLTP** | Single-node transactional database | `+ -f examples/prod-oltp.yaml` |

```bash
# OLTP
helm template my-db2 . -f values-prod.yaml -f examples/prod-oltp.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/prod-oltp

# Warehouse SMP
helm template my-db2 . -f values-prod.yaml -f examples/prod-wh-smp.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/prod-wh-smp
```

---

## Production Size Reference

Set via `--set profile.size=<size>`. All sizes are certified workload specifications.

### OLTP (`examples/prod-oltp.yaml`)

Sizing: memory = 4 GB/core · data = 4.5× memory · all volumes = 20% of data

| Size | Nodes | CPU | Memory | Data |
|------|-------|-----|--------|------|
| `small` | 1 | 8 | 32Gi | 144Gi |
| `medium` | 1 | 32 | 128Gi | 576Gi |
| `large` | 1 | 64 | 256Gi | 1152Gi |

Full OLTP storage per node:

| Volume | Access | small | medium | large |
|--------|--------|-------|--------|-------|
| meta | RWX | 29Gi | 115Gi | 230Gi |
| backup | RWX | 29Gi | 115Gi | 230Gi |
| archivelogs | RWX | 29Gi | 115Gi | 230Gi |
| data | RWO | 144Gi | 576Gi | 1152Gi |
| activelogs | RWO | 29Gi | 115Gi | 230Gi |
| tempts | RWO | 29Gi | 115Gi | 230Gi |

### Warehouse SMP (`examples/prod-wh-smp.yaml`)

Sizing: memory = 16 GB/core · data = 4.5× memory · all volumes = 20% of data

| Size | Nodes | CPU | Memory | Data |
|------|-------|-----|--------|------|
| `small` | 1 | 8 | 128Gi | 576Gi |
| `medium` | 1 | 32 | 512Gi | 2304Gi |
| `large` | 1 | 64 | 1024Gi | 4608Gi |

Full Warehouse SMP storage per node:

| Volume | Access | small | medium | large |
|--------|--------|-------|--------|-------|
| meta | RWX | 115Gi | 461Gi | 922Gi |
| backup | RWX | 115Gi | 461Gi | 922Gi |
| archivelogs | RWX | 115Gi | 461Gi | 922Gi |
| data | RWO | 576Gi | 2304Gi | 4608Gi |
| tempts | RWO | 115Gi | 461Gi | 922Gi |

### Warehouse MPP (`values-prod.yaml` default)

Sizing: memory = 16 GB/core · data = 4.5× memory · all volumes = 20% of data

| Size | Nodes | CPU/node | Memory/node | Data/node |
|------|-------|----------|-------------|-----------|
| `small` | 3 | 8 | 128Gi | 576Gi |
| `medium` | 7 | 32 | 512Gi | 2304Gi |
| `large` | 9 | 64 | 1024Gi | 4608Gi |

Full Warehouse MPP storage per node:

| Volume | Access | small | medium | large |
|--------|--------|-------|--------|-------|
| meta | RWX | 115Gi | 461Gi | 922Gi |
| backup | RWX | 115Gi | 461Gi | 922Gi |
| archivelogs | RWX | 115Gi | 461Gi | 922Gi |
| data | RWO | 576Gi | 2304Gi | 4608Gi |
| tempts | RWO | 115Gi | 461Gi | 922Gi |

---

## Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `image.tag` | DB2 version | `12.1.6.0` |
| `storageclassname.rwo` | ReadWriteOnce storage class | `ebs-sc` |
| `storageclassname.rwx` | ReadWriteMany storage class | `efs-sc` |
| `profile.size` | Workload size *(prod only)* | `small` |

---

## Cloud Provider Storage Classes

Layer a cloud example file to set the storage classes for your platform.

| Platform | RWX (`rwx`) | RWO (`rwo`) | Example files |
|----------|-------------|-------------|---------------|
| AWS EKS / ROSA | `efs-sc` | `ebs-sc` | `aws-eks-*.yaml` |
| Azure AKS | `azurefile-nfs` | `azuredisk-premium` | `azure-aks-*.yaml` |
| Azure ARO | `ocs-storagecluster-cephfs` | `ocs-storagecluster-ceph-rbd` | `azure-aro-*.yaml` |
| GCP GKE | `standard-db2u-rwx` | `standard-rwo` | `gcp-gke-*.yaml` |
| On-Premises | your NFS class | your NFS class | — |

```bash
# Example: AWS EKS, Warehouse MPP medium
helm template my-db2 . -f values-prod.yaml -f examples/aws-eks-db2wh-mpp.yaml \
  --namespace db2u --set profile.size=medium --set image.tag=12.1.6.0 \
  --output-dir renders/aws-prod

oc apply -f renders/aws-prod/db2-instance/templates/
```

---

## High Availability (Db2uHa)

HA mode emits a `Db2uHa` CR instead of a `Db2uInstance`. It wraps the same sizing profile with standby replicas and read/write service endpoints. Supported workloads: `oltp` and `warehouse-smp` (not `warehouse-mpp`).

```bash
# HA OLTP
helm template my-db2 . -f values-prod.yaml -f examples/db2uha-oltp.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/db2uha-oltp

# HA Warehouse SMP
helm template my-db2 . -f values-prod.yaml -f examples/db2uha-smp.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/db2uha-smp
```

| Parameter | Description | Default |
|---|---|---|
| `ha.enabled` | Emit `Db2uHa` instead of `Db2uInstance` | `false` |
| `ha.standbyReplicas` | Number of standby replicas *(required)* | — |
| `ha.enableReadOnlyReplicas` | Expose standbys as read-only endpoints | `true` |
| `ha.syncMode` | Principal sync mode (`NEARSYNC`, `SYNC`, `ASYNC`) | — |
| `ha.timeout` | HA timeout in seconds | `120` |
| `ha.peerWindow` | Peer window in seconds | `120` |
| `ha.readWriteServiceType` | Service type for primary endpoint | `ClusterIP` |
| `ha.readOnlyServiceType` | Service type for standby endpoint | `ClusterIP` |

> **Note:** `ha.enabled=true` with `warehouse-mpp` is rejected at render time.

---

## Optional Add-ons

Layer an example file to enable add-ons:

### SSL/TLS

```bash
helm template my-db2 . -f values-dev.yaml -f examples/db2oltp-with-ssl.yaml \
  --namespace db2u --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/dev-ssl
```

Parameters: `ssl.enabled`, `ssl.secretName` *(required)*, `ssl.allowSslOnly`, `ssl.certLabel`

### LDAP Authentication

```bash
helm template my-db2 . -f values-prod.yaml -f examples/db2wh-with-ldap.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/prod-ldap
```

Parameters: `ldap.enabled`, `ldap.configMapName` *(required)*, `ldap.searcherPassword`, `ldap.transparentLdap`

### NCOS (Native Cloud Object Storage)

```bash
helm template my-db2 . -f values-prod.yaml -f examples/db2wh-with-ncos.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/prod-ncos
```

Parameters: `ncos.enabled`, `ncos.cosProvider` *(required: `self-hosted` or `cloud`)*, `ncos.storageSize` *(required)*

### Open Data Formats (ODF)

```bash
helm template my-db2 . -f values-prod.yaml -f examples/db2wh-with-odf.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/prod-odf
```

### OpenShift SCC

```bash
# OCP 4.11+ (recommended)
helm template my-db2 . -f values-prod.yaml -f examples/db2wh-restricted-v2.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=<rwo> --set storageclassname.rwx=<rwx> \
  --output-dir renders/prod-restricted-v2
```

Parameter: `securityContext.sccMode` — `"restricted-v2"` or `"restricted"`

---

## Overriding Profile Values

The profile size spec is the baseline. Any individual value can be overridden at deploy time using `--set override.*` without changing the rest of the profile.

```bash
# Override just data storage
helm template my-db2 . -f values-prod.yaml \
  --namespace db2u --set profile.size=medium --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=ebs-sc --set storageclassname.rwx=efs-sc \
  --set override.storage.data=3000Gi \
  --output-dir renders/prod-custom

# Override CPU and memory
helm template my-db2 . -f values-prod.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=ebs-sc --set storageclassname.rwx=efs-sc \
  --set override.resources.cpu=16 \
  --set override.resources.memory=256Gi \
  --output-dir renders/prod-custom

# Override multiple values
helm template my-db2 . -f values-prod.yaml -f examples/prod-oltp.yaml \
  --namespace db2u --set profile.size=small --set image.tag=12.1.6.0 \
  --set storageclassname.rwo=ebs-sc --set storageclassname.rwx=efs-sc \
  --set override.storage.data=800Gi \
  --set override.storage.activelogs=200Gi \
  --set override.resources.cpu=12 \
  --output-dir renders/prod-oltp-custom
```

| Override field | Description | Workloads |
|---|---|---|
| `override.nodes` | Node count | all |
| `override.resources.cpu` | CPU limit | all |
| `override.resources.memory` | Memory limit | all |
| `override.storage.data` | Data volume size | all |
| `override.storage.tempts` | Temp tablespace size | all |
| `override.storage.meta` | Metadata volume size | all |
| `override.storage.backup` | Backup volume size | all |
| `override.storage.archivelogs` | Archive logs volume size | all |
| `override.storage.activelogs` | Active logs volume size | OLTP only |

---

## Validation

The chart validates inputs and fails fast with clear messages:

```
ERROR: profile.size="xlarge" is not valid. Must be one of: dev, small, medium, large
ERROR: image.tag is required. Please specify the DB2 version (e.g., --set image.tag=12.1.6.0)
ERROR: storageclassname.rwo is required.
ERROR: ssl.secretName is required when SSL is enabled.
```

---

## Examples Directory

```
examples/
├── prod-oltp.yaml                # switch to OLTP workload
├── prod-wh-smp.yaml              # switch to Warehouse SMP (single-node)
├── db2uha-oltp.yaml              # HA OLTP (Db2uHa)
├── db2uha-smp.yaml               # HA Warehouse SMP (Db2uHa)
├── db2oltp-with-ssl.yaml         # OLTP + SSL
├── db2oltp-restricted.yaml       # OLTP + OpenShift restricted SCC
├── db2wh.yaml                    # Warehouse base (name + storage classes)
├── db2wh-with-ldap.yaml          # Warehouse + LDAP
├── db2wh-with-ncos.yaml          # Warehouse + NCOS
├── db2wh-with-odf.yaml           # Warehouse + ODF
├── db2wh-restricted.yaml         # Warehouse + OpenShift restricted SCC
├── db2wh-restricted-v2.yaml      # Warehouse + OpenShift restricted-v2 SCC
├── aws-eks-db2oltp.yaml          # AWS EKS / ROSA — OLTP
├── aws-eks-db2wh-smp.yaml        # AWS EKS / ROSA — Warehouse SMP
├── aws-eks-db2wh-mpp.yaml        # AWS EKS / ROSA — Warehouse MPP
├── azure-aks-db2oltp.yaml        # Azure AKS — OLTP
├── azure-aks-db2wh-smp.yaml      # Azure AKS — Warehouse SMP
├── azure-aks-db2wh-mpp.yaml      # Azure AKS — Warehouse MPP
├── azure-aro-db2oltp.yaml        # Azure ARO — OLTP
├── azure-aro-db2wh-smp.yaml      # Azure ARO — Warehouse SMP
├── azure-aro-db2wh-mpp.yaml      # Azure ARO — Warehouse MPP
├── gcp-gke-db2oltp.yaml          # GCP GKE — OLTP
├── gcp-gke-db2wh-smp.yaml        # GCP GKE — Warehouse SMP
└── gcp-gke-db2wh-mpp.yaml        # GCP GKE — Warehouse MPP
```
