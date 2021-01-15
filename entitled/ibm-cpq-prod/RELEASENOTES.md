# What's new in IBM Sterling Configure Price Quote Software Enterprise Edition v10 Helm Charts
* IBM Sterling Configure Price Quote Software can be deployed in the form of docker images with DB2/Oracle database.
* Support for affinity configurations added.

# Breaking Changes
* Rolling upgrade from previous chart version `1.0.0` to this release is not supported, due to migration to new standard chart labels provided by kubernetes and helm.

# Documentation
* VM - Visual Modeler, OC - Omni Configurator, IFS - IBM Field Sales

# Fixes
N/A

# Prerequisites
1. Kubernetes version >= 1.11.3
2. DB2/Oracle database server is installed. The database should be accessible from inside the cluster. The database instance should be created for both VM/OC and IFS.
3. Ensure that the timezone considerations for the deployment are made. Refer section "Timezone considerations" in readme for details.
4. The docker images for IBM Sterling Configure Price Quote Software Enterprise are loaded to an appropriate docker registry. The defaut IBM Sterling Configure Price Quote Software can be loaded  from IBM Passport Advantage. AlternatiIBM Sterling Configure Price Quote SoftwareBM Sterling Configure Price Quote Software can also be used.
5. Ensure that the docker registry used is configured in "Image Policies" in Manage -> Resource Security -> Image Policies
6. Ensure that docker image can be pulled on all of Kubernetes worker nodes.
7. Create two persistent volumes with access mode as 'Read write many' with minimum 12GB space one for VM/OC and another for IFS.
8. Before configuring any IFS agents/integration server in the chart, Refer section "Configuring Agent/Integration Servers" in readme for details.


# Version History

| Chart | Date     | Kubernetes   | Image(s) Supported | Breaking Changes | Details |
| ----- | -------- | ------------ | ------------------ | ---------------- | ------- | 
| 1.0.0 | Mar, 2020| >=1.11.3     | cpq-vm-app:10.0-x86-64, cpq-oc-app:10.0-x86-64, cpq-vmoc-base:10.0-x86-64, cpq-ifs-app:10.0-x86-64, cpq-ifs-agent:10.0-x86-64, cpq-ifs-base:10.0-x86-64 | Initial on Helm 2| This is the version for IBM Sterling Configure Price Quote Software v10.0 Helm Chart |
| 2.0.0 | May, 2020| >=1.11.3     | cpq-vm-app:10.0.0.6-x86_64, cpq-oc-app:10.0.0.6-x86_64, cpq-vmoc-base:10.0.0.6-x86_64, cpq-ifs-app:10.0.0.3-x86_64, cpq-ifs-agent:10.0.0.3-x86_64, cpq-ifs-base:10.0.0.3-x86_64 | Helm 3 and Product available in RH catalog | This is the version for IBM Sterling Configure Price Quote Software v10.0.0.6 Helm Chart |
| 3.0.0 | Jun, 2020| >=1.11.3     | cpq-vm-app:10.0.0.7-x86_64, cpq-oc-app:10.0.0.7-x86_64, cpq-vmoc-base:10.0.0.7-x86_64, cpq-ifs-app:10.0.0.3-x86_64, cpq-ifs-agent:10.0.0.3-x86_64, cpq-ifs-base:10.0.0.3-x86_64 | Helm 3 and Product available in RH catalog | This is the version for IBM Sterling Configure Price Quote Software v10.0.0.7 Helm Chart |
| 3.1.0 | Jul, 2020| >=1.11.3     | cpq-vm-app:10.0.0.10-x86_64, cpq-oc-app:10.0.0.10-x86_64, cpq-vmoc-base:10.0.0.10-x86_64, cpq-ifs-app:10.0.0.7-x86_64, cpq-ifs-agent:10.0.0.7-x86_64, cpq-ifs-base:10.0.0.7-x86_64 | Fix Pack Upgrade feature allowing customer to upgrade CPQ with current image | This is the version for IBM Sterling Configure Price Quote Software v10.0.0.10 |
| 4.0.0 | Oct, 2020| >=1.11.3     | cpq-vm-app:10.0.0.12-x86_64, cpq-oc-app:10.0.0.12-x86_64, cpq-vmoc-base:10.0.0.12-x86_64, cpq-ifs-app:10.0.0.9-x86_64, cpq-ifs-agent:10.0.0.9-x86_64, cpq-ifs-base:10.0.0.9-x86_64 | Fix Pack Upgrade feature allowing customer to upgrade CPQ with current image | This is the version for IBM Sterling Configure Price Quote Software v10.0.0.12 |