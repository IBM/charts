# WAS VM Quickstarter Prerequisites

## Software Prerequisites
* VMware vSphere 6.5 or later
* VMware ESXi 6.5 or later
* [IBM Cloud Private 2.1.0.3](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/kc_welcome_containers.html)
* IBM Cloud Automation Manager 2.1.0.2 with FP1, including [its prerequisites](https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.2/cam_prereq.html) and [content requirements](https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.2/content/cam_content_camc_requirements.html)

Create a unique IBM Cloud Private and Cloud Automation Manager for each instance of the WAS VM Quickstarter service.

## License Prerequisites

The WAS VM Quickstarter service does not provide license entitlement to WebSphere Application Server product binary files or any other products, such as IBM Cloud Private or Cloud Automation Manager.  Your deployed WAS configurations are subject to normal WebSphere Application Server license entitlement requirements. WebSphere Application Server instances in guest VMs that are pooled or stopped are not counted as actively used licenses.

## Operational Prerequisites
* **vSphere datacenter**. A vSphere datacenter is required to host the WAS virtual machines.  
  * For best performance, dedicate the datacenter for WAS VM Quickstarter usage. Although WAS VM Quickstarter can constrain WAS deployments to the defined capacity, other workloads that use the shared resources can cause unexpected issues in the service.
* **Hardware resources**. CPUs, memory, and disk space must be defined in the vSphere datacenter.
  * When users create a WAS service instance, they specify a simplified capacity using a unit of measure called a _service block_.  A service block is defined as 1 vCPU, 2 GB of RAM, and 25 GB of disk space.
  * To compute the service blocks needed, divide each of the resources by the service block size and find the resource that constrains the environment (_i.e._ the smallest value).
  * For example, suppose you want to constrain WAS VM Quickstarter VM usage to a given set of hardware that has 16 vCPU, 256 GB RAM, and 2 TB of disk space.  
    * 16 vCPU / 1 vCPU per block = 16 blocks maximum
    * 256 GB / 2 GB per block = 128 blocks maximum
    * 2 TB / 25 GB per block = 80 blocks maximum
  * In this example, the number of WAS VM Quickstarter service blocks that could be assigned is 16, because the constraining resource is vCPU, assuming no CPU overcommitment.  
  *  Typically, however, you can overcommit CPUs to adjust the number of available service blocks.  If you are running your vSphere datacenter at 3:1 CPU overcommitment, you can multiply your actual vCPUs by 3, which for the previous example results in 48 vCPUs.  With this overcommitment, the constraining resource is still vCPU, but you can set the capacity to 48 service blocks instead of 16.
* **IP addresses**.  Each provisioned WAS service instance must be assigned an IP address.  The smallest T-shirt-sized VM that you can provision is 1 service block. To ensure that you have enough IP addresses to operate the service, supply one IP address per service block. For example, if you defined 48 service blocks of capacity, we recommend supplying 48 IP addresses.

## VM Template Requirements
You must provide a VMware VM template, which is used by the WAS Quickstarter service to create the WAS VMs. Within your VM template, make sure to fulfill the following requirements.

### General Requirements for the Template
* VMware Tools must be enabled.
* The root user or a sudo-enabled user must exist and be allowed for use.
* The non-root user must have password-less sudo access
* A default firewall must be installed and running
* The default firewall configuration must allow the following traffic:
  * Inbound traffic to port 22
  * Outbound traffic to any port
* The VM template must have disk space between 10 GB and 25 GB. The root partition (`/`) and the home partition (`/home`) must each have at least 5 GB of free space. For addition information, see the [Template Disk Size](#template-disk-size) section below.

### Operating System Requirements

#### Ubuntu 16.04
* The VM must have a connection to the internet for the duration of the provisioning process.
* The Ubuntu repositories must be enabled and accessible.
* The `iptables-persistent` package must be installed and the `iptables` service must be enabled.
* Python 2 must be installed.

#### Red Hat Enterprise Linux (RHEL) 7.4
* The RHEL Satellite repositories must be enabled and accessible.
* The `firewalld` service must be stopped and disabled. The `iptables-services` package must be installed and the `iptables` service must be enabled.

### Disk Scaling Restrictions

The WAS VM Quickstarter service creates virtual machines initially using the specified template and _might_ need to scale the VMs depending on the T-shirt size that is requested for the guest VM being provisioned.  

When a VM is scaled to a larger size, the memory, number of CPUs, and disk size of the VM are increased.  If the disk follows the partitioning scheme defined in the [Center for Internet Security (CIS)](https://www.cisecurity.org/cis-benchmarks/) 2.1.0.0 specifications, the partitions are automatically resized to a size based on a percentage of the total disk size as shown in the following table:

| Partition | Percent of Total Disk Size |
| --------- | -------------------------- |
| _/_       |<p align="right">22%        |
| _/home_   |<p align="right">22%        |
| _/tmp_    |<p align="right">10%        |
| _/var/tmp_ |<p align="right">10%       |
| _/var/log_ |<p align="right">12%       |
| _/var/log/audit_ | <p align="right">8% |
| _/swap_ | <p align="right">8% |

For example, if the disk size was increased from 25 GB to 100 GB, the _/home_ partition would grow from 5.5 GB to 22 GB.

Each above partition must correspond to a single logical volume on the same logical volume group.

If there are any additional partitions on the disk beyond the ones described above, they will not be resized.

If the disk does not have any of the partitions described above, no action will be taken. The VM administrator must manually partition the additional space and mount it, or they must resize the existing partitions.

### Template Disk Size

If a VM template has a disk size smaller than 25 GB, and the smaller disk size was not explicitly specified, the guest VM's disk is automatically resized to 25GB. The additional disk space must be manually formatted, partitioned, and mounted. Therefore, for best results, the VM template should have 25 GB disk space, or the smaller disk size must be explicitly set.

During scaling, the disk size is always resized to a size set by the given T-shirt size. For example, if the VM template disk size is 15 GB, and the guest VM was scaled to a medium T-shirt size, the disk size increases from 15 GB to 50 GB.
