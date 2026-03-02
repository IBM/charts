# IBM Connect Direct for Unix v6.3.0

## Introduction
  
IBM® Connect:Direct® for UNIX links technologies and moves all types of information between networked systems and computers. It manages high-performance transfers by providing such features as automation, reliability, efficient use of resources, application integration, and ease of use. Connect:Direct (C:D) for UNIX offers choices in communications protocols, hardware platforms, and operating systems. It provides the flexibility to move information among mainframe systems, midrange systems, desktop systems, LAN-based workstations and cloud based storage providers (Amazon S3 Object Store for current release). To find out more, see the Knowledge Center for [IBM Connect:Direct for UNIX](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=sterling-connectdirect-unix-v63).

## Chart Details

This chart deploys IBM Connect Direct on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-connect-direct` with 1 replica by default.
- a configMap `<release-name>-ibm-connect-direct`. This is used to provide default configuration in cd_param_file.
- a service `<release-name>-ibm-connect-direct`. This is used to expose the C:D services for accessing using clients.
- a service-account `<release-name>-ibm-connect-direct-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-connect-direct`.
- a monitoring dashboard `<release-name>-ibm-connect-direct`. This will not be created if `dashboard.enabled` is `false`.

## Prerequisites

Please refer to [Planning](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_ulg_c5m_lkb) section in the online Knowledge Center documentation. 

### Pod Security Standard and Security Context Constraints Requirements

Please refer to [PSS and SCC](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_t5n_rvx_lkb) section in the online Knowledge Center documentation.

## Resources Required

This chart uses the following resources by default:

* 100Mi of persistent volume
* 1 GB Disk space
* 500m CPU
* 2000MB Memory

Please refer [Requirements](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_ylx_4wm_lkb) section in the online Knowledge Center documentation.

## Agreement to IBM Connect:Direct for Unix License

You must read the IBM Connect:Direct for Unix License agreement terms before installation, using the below link:
[License](https://www.ibm.com/support/customer/csol/terms/licenses#license-search) (L/N:  L-FYHF-K7J2TN)

## Installing the Chart

Please refer [Installing](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_uhr_g5m_lkb__title__1) section in the online Knowledge Center documentation.

## Configuration

Please refer the [Configuring - Understanding values.yaml](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#ID4365111__title__1) section in the online Knowledge Center documentation.

## Verifying the Chart

Please refer the [Validating the Installation](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_cvq_j5m_lkb) section in the online Knowledge Center documentation.

## Upgrading the Chart

Please refer the [Upgrade - Upgrading a Release](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_vfd_mgn_lkb__title__1) section in the online Knowledge Center documentation.

## Uninstalling the Chart

Please refer the [Uninstall - Uninstalling a Release](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_zxp_5tx_lkb__title__1) section in the online Knowledge Center documentation.

## Backup & Restore

**To Backup:**

You need to take backup of configuration data and other information like stats and TCQ which are present in the persistent volume by following the below steps:

1. Go to mount path of Persistent Volume. 

2. Make copy of all of the directories listed below and store them at your desired and secured place.
   * `WORK`
   * `CFG`
   * `SECPLUS`
   * `SECURITY`
   * `PROCESS`
   * `FACONFIG`
   * `FALOG`

> **Note**:In case of traditional installation of Connect:Direct for Unix, you should take the backup of the below directories and save them at your desired location:
   * `<installDir>/work`
   * `<installDir>/ndm/cfg`
   * `<installDir>/ndm/secure+`
   * `<installDir>/ndm/security`
   * `<installDir>/process`
   * `<installDir>/file_agent/config`
   * `<installDir>/file_agent/log`
   

**To Restore:**

Restoring the data in new deployment, it can be achieved by following steps:

1. Create a Persistent Volume.

2. Copy all the backed up directories to the mount path of Persistent Volume.

3. Create a new deployment using the above Persistent Volume using variable `persistentVolume.name` in helm cli command. The pod would come up with desired data.

## Exposing Services

Please refer to [Exposed Services](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_cvq_j5m_lkb__title__1) section in the online Knowledge Center documentation.

## DIME and DARE

Please refer to [DIME and DARE Security Considerations](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_cvq_j5m_lkb__title__1) section in the online Knowledge Center documentation.

## Limitations

Please refer to [Limitations](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-connectdirect-unix-using-sterling-connectdirect-unix-container#concept_rd1_m5m_lkb__title__1) section in the online Knowledge Center documentation.
