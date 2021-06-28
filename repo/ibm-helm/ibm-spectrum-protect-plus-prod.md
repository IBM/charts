# IBM Spectrum Protect Plus 10.1.8.1

[IBM Spectrum Protect Plus](https://www.ibm.com/us-en/marketplace/ibm-spectrum-protect-plus) is a modern data protection solution that provides near-instant recovery, replication, retention, and reuse for VMs, databases, and containers in hybrid multicloud environments.

## Introduction

IBM Spectrum Protect Plus is a data protection and availability solution for virtual environments and database applications that can be rapidly deployed to protect your environment.

Container Backup Support is a feature of IBM Spectrum Protect Plus that extends data protection to containers in a Kubernetes or Red Hat OpenShift environment. Container Backup Support protects persistent volumes, namespace-scoped resources, and cluster-scoped resources that are associated with containers in Kubernetes or OpenShift clusters.  Snapshot backups of the persistent volumes are created and copied to IBM Spectrum Protect Plus vSnap servers.

[Product Documentation](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.8/spp/welcome.html)

## Chart Details

This chart deploys the Container Backup Support component of IBM Spectrum Protect Plus that supports data protection in the Kubernetes or OpenShift environment.

## Prerequisites and Required Resources

To view the requirements, prerequisites and required resources, see [Container backup and restore requirements](https://www.ibm.com/support/pages/node/6422823).

## Installing the Chart

You can install Container Backup Support by using one of several methods.

To install the Chart, see [Installing Container Backup Support](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.8/spp/c_spp_cbs_installation.html)

## Uninstalling the Chart

You can uninstall Container Backup Support completely so that all components, including all configurations and backups, are removed from the Kubernetes or OpenShift environment.

To uninstall the Chart, see [Uninstalling Container Backup Support](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.8/spp/t_spp_cbs_uninstall_full.html)

## Configuration parameters for Container Backup Support

The configuration parameters of the Container Backup Support Helm chart are available for review.

To review the configuration parameters, see [Configuration parameters for Container Backup Support](https://www.ibm.com/support/knowledgecenter/en/SSNQFQ_10.1.8/spp/r_spp_cbs_inst_configparms_helm3.html)

## Limitations

* You cannot deploy the product more than once
* A rollback to a previous version of the product is not supported. In other words, you cannot use Kubernetes Backup Support V10.1.5 to restore data that was backed up by Container Backup Support V10.1.8.
* The documentation and messages reference the term IBM Knowledge Center. In April 2021, IBM Knowledge Center was renamed to IBM Documentation (also known as IBM Docs). In the documentation and messages, the term IBM Knowledge Center is still used.

For more information, see [Additional limitations and known problems](https://www.ibm.com/support/pages/node/567387)

## Documentation

For more information about Container Backup Support, see the following resources in IBM Documentation:

* [Protecting containers](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.8/spp/c_spp_protecting_containers.html)
* [Protecting containers by using the command line](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.8/spp/c_spp_cbs_using_cmdline.html)
