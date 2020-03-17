# What's new in IBM Sterling Configure Price Quote Software Enterprise Edition v10 Helm Charts
* IBM Sterling Configure Price Quote Software can be deployed in the form of docker images with DB2/Oracle database.
* Support for affinity configurations added.

# Breaking Changes
* Rolling upgrade from previous chart version `1.0.0` to this release is not supported, due to migration to new standard chart labels provided by kubernetes and helm.

# Documentation


# Fixes
N/A


# Prerequisites
1. Kubernetes version >= 1.11.3
2. Tiller version >= 2.9.1
3. DB2/Oracle database server is installed. The database should be accessible from inside the cluster.
4. Ensure that the timezone considerations for the deployment are made. Refer section "Timezone considerations" in readme for details.
5. The docker images for IBM Sterling Configure Price Quote Software Enterprise are loaded to an appropriate docker registry. The defauIBM Sterling Configure Price Quote Softwarenfigure Price Quote Software can be loaded  from IBM Passport Advantage. AlternatiIBM Sterling Configure Price Quote SoftwareBM Sterling Configure Price Quote Software can also be used.
6. Ensure that the docker registry used is configured in "Image Policies" in Manage -> Resource Security -> Image Policies
8. Ensure that docker image can be pulled on all of Kubernetes worker nodes.
9. Create a persistent volume with access mode as 'Read write many' with minimum 12GB space.
10. Before configuring any server in the chart, Refer to readme for details
TODO - Ram need to add details related to IFS


# Version History

| Chart | Date     | Kubernetes   | Image(s) Supported | Breaking Changes | Details |
| ----- | -------- | ------------ | ------------------ | ---------------- | ------- | 
| 1.0.0 | Dec, 2019| >=1.11.3     | cpq-vm-app:ent-10.0.0.1-amd64, cpq-oc-app:ent-10.0.0.1-amd64 | N/A | This is the version for IBM Sterling Configure Price Quote Software Enterprise Edition v10 Helm Chart |
