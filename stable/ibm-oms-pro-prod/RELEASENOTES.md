# What's new in IBM Order Management Software Professional Edition v10 Helm Charts
* IBM Order Management Software can be deployed in the form of docker images with DB2 database and MQ messaging.
* Support for ppc64le architecture added.
* Support for affinity configurations added.
* Support for logging into standard output added for consumption by platform common service


# Breaking Changes
* Rolling upgrade from previous chart version `1.0.0` to this release is not supported, due to migration to new standard chart labels provided by kubernetes and helm.

# Documentation


# Fixes
N/A


# Prerequisites
1. Kubernetes version >= 1.11.3
2. Tiller version >= 2.9.1
3. DB2 database server is installed. The database should be accessible from inside the cluster.
4. Ensure that the timezone considerations for the deployment are made. Refer section "Timezone considerations" in readme for details.
5. MQ server is installed. The MQ server should be accessible from inside the cluster.
6. The docker images for IBM Order Management Software Professional are loaded to an appropriate docker registry. The default images for IBM Order Management Software can be loaded  from IBM Passport Advantage. Alternatively, customized images for IBM Order Management Software can also be used.
7. Ensure that the docker registry used is configured in "Image Policies" in Manage -> Resource Security -> Image Policies
8. Ensure that docker image can be pulled on all of Kubernetes worker nodes.
9. Create a persistent volume with access mode as 'Read write many' with minimum 10GB space.
10. Before configuring any agents/integration server in the chart, Refer section "Configuring Agent/Integration Servers" in readme for details



# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.0.0 | Dec, 2018| >=1.11.3 | om-app:pro-10.0.0, om-agent:pro-10.0.0 | N/A | This is the version for IBM Order Management Software Professional Edition v10 Helm Chart |
| 2.0.0 | Feb, 2019| >=1.11.3 | om-app:pro-10.0.0.2, om-agent:pro-10.0.0.2 | N/A | This is the version for IBM Order Management Software Professional Edition v10 Helm Chart |
| 3.1.0 | Nov, 2019| >=1.11.0 | om-app:pro-10.0.0.8, om-agent:pro-10.0.0.8 | N/A | This is the version for IBM Order Management Software Professional Edition v10 Helm Chart |
