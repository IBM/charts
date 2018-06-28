
# Setting Up the Content Runtime

The Content Runtime is a Cloud Automation Manager virtual machine environment that contains a pattern manager, a Chef server, and a software repository. For the WAS VM Quickstarter service, the Content Runtime is used to install and configure WebSphere Application Server on a guest virtual machine. For more information about the Content Runtime, see [Content Runtime Overview](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/content/cam_content_runtime_overview.html) in the Cloud Automation Manager documentation.

Before you get started, install Cloud Automation Manager and other software prerequisites as described in [WAS VM Quickstarter Prerequisites](http://ibm.biz/WASQuickstarterPrerequisites).

* [Installing the Content Runtime](#installing-the-content-runtime)
* [Updating WebSphere Application Server in the Content Runtime](#updating-websphere-application-server-in-the-content-runtime)
* [Installation Scripts](#installation-scripts)
* [Troubleshooting](#troubleshooting)

## Installing the Content Runtime

There are two ways for standing up a Content Runtime VM: automatically by using the provided `provision.py` script, or manually through the Cloud Automation Manager user interface.

### Automated Installation

Automated installation uses the [provision.py](#provisionpy) script to create and populate the Content Runtime VM.

  1. On the command line, [access the `wasaas-devops` container](OPERATIONS.md#accessing-the-scripts-in-the-wasaas-devops-container).
  1. Review the `/wasaas/content-runtime/conf/fixpacks.json` file, and edit it to specify the WebSphere versions needed. See [fixpacks.json](#fixpacksjson) for formatting details.
  1. Modify the `/wasaas/content-runtime/conf/content-runtime.json` file and provide `vsphere_user`, `vsphere_password`, and `vsphere_server` parameters under the `connection` section.
  1. Validate and adjust the parameters under the `runtime` section, and specify the `ipv4_address` value. For information about system requirements for a Content Runtime VM, see [System requirements](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/content/cam_content_camc_requirements.html) in the Cloud Automation Manager documentation.
      - If Red Hat Enterprise Linux (RHEL) is the base image for Content Runtime and Docker is not installed, add the `docker_ee_repo` parameter to the parameter list. RHEL supports Docker Enterprise Edition only. After you purchase the Docker EE license, get the Docker EE repository URL from https://store.docker.com/my-content.
      - If you are deploying a [GDPR-compliant Content Runtime](https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.2/content/cam_content_runtime_gdpr_setup.html) add the `encryption_passphrase` parameter to the parameter list.
  1. Set the `IBMID_USERNAME` and `IBMID_PASSWORD` environment variables to match your IBMid credentials. For example:
      ```
      export IBMID_USERNAME='myIBMid'
      export IBMID_PASSWORD='myPassword'
      ```
      Your IBMid must be entitled to download WebSphere Application Server packages from IBM Fix Central. For more information, see [Fix Central Entitlement](https://www-945.ibm.com/support/fixcentral/help?page=entitlementgeneral). If your IBMid does not have entitlement, the Installation Manager (IM) packages will fail to load.
  1. Run the `/wasaas/content-runtime/provision.py` script. The script is idempotent and can be rerun multiple times. For example, if the configuration contains a mistake, correct the problem and rerun the script. See the [Troubleshooting](#troubleshooting) section for additional details.
  1. The `provision.py` script will first provision a Content Runtime VM.
      * If the provision was successful, a `Content runtime running at user@x.x.x.x` message is generated.
      * If the provision failed, examine the output, correct the problem, and rerun the script with `--recreate` option.
  1. After the VM is successfully created, Chef cookbooks are loaded into the Content Runtime VM.
  1. Next, [Packaging Utility](https://www.ibm.com/support/knowledgecenter/SSDV2W_1.8.5/com.ibm.cic.auth.ui.doc/topics/c_modes_pu.html) is installed onto the VM. Packaging Utility requires the Installation Manager package to be present on the Content Runtime VM. You must manually download and copy the Installation Manager package onto the Content Runtime VM. The `provision.py` script will fail until this step is completed.
      1. Download the [agent.installer.linux.gtk.x86_64_1.8.8000.20171130_1105.zip](http://www.ibm.com/support/fixcentral/swg/quickorder?parent=ibm%7ERational&product=ibm/Rational/IBM+Installation+Manager&release=1.8.8.0&platform=Linux&function=fixId&fixids=1.8.8.0-IBMIM-LINUX-X86_64-20171130_1105&useReleaseAsTarget=true&includeRequisites=0&includeSupersedes=0&downloadMethod=http&source=fc) package.
      1. Copy the package to the Content Runtime VM and put it in the `/opt/ibm/docker/software-repo/var/swRepo/private/im/v1x/base/` directory.
      1. Rerun the `provision.py` script.
  1. When the script detects that the Installation Manager package is present, it installs Packaging Utility and then uses Packaging Utility to populate the Installation Manager repository on the Content Runtime VM. It can take several hours to populate the repository depending on how many WebSphere fix packs are specified in the `fixpacks.json` file.  
  1. Finally, the script imports Terraform templates into Cloud Automation Manager and configures the WAS VM Quickstarter service to use it.

After the WAS VM Quickstarter is configured to use the Terraform templates, the Content Runtime VM setup is complete.

### Manual Installation

The Content Runtime VM can also be manually created using the Cloud Automation Manager console. However, it must be populated with WAS VM Quickstarter Chef cookbooks and Terraform templates.

  1. Use the Cloud Automation Manager console to [create a VMWare Content Runtime](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/content/cam_provision_manage_content_runtime.html)
      1. Make sure the name of the Content Runtime matches the name specified in the Helm chart.
  1. Follow the [Automated Installation](#automated) steps to populate the Content Runtime VM.
      1. If you want to [build your own Installation Manager repository](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.2/content/cam_populating_imrepo_live.html) on the Content Runtime VM, run the `provision.py` script with the `--skip-im` option.

## Updating WebSphere Application Server in the Content Runtime

You can update the content within your Content Runtime VM, such as updating the WebSphere Application Server fix packs or interim fixes.

### Applying Fix Packs

To add, remove, or modify a fix pack, do the following:

  1. In the [fixpacks.json](#fixpacksjson) file, change the specified fix packs.
  1. Increment the `iteration` value in the `fixpacks.json` file.
  1. Run the `provision.py` script.

### Applying Interim Fixes

By default, interim fixes are not installed loaded into the Content Runtime Installation Manager repository. To load interim fixes during initial provisioning of the Content Runtime or at any later time, run the `provision.py` script with the `--load-fixes` option. Only recommended fixes are loaded into the Installation Manager repository. If you want to install a fix that is not recommended, you must manually load the fix into the Installation Manager repository.

Any recommended interim fixes found in the Installation Manager repository that apply to the particular guest VM are automatically installed when the VM is provisioned.

### Manually Adding Updates to the Installation Manager Repository

You can manually add fix packs and interim fixes to the Installation Manager repository on the Content Runtime VM by doing the following steps.

  1. Log in to the Content Runtime VM.
  1. Change to the `/opt/ibm/docker/software-repo/var/swRepo/private/` directory.
  1. Run the following command, where _<packageName\>_ is name of the fix pack or interim fix to load into the IM repository:
  ```
  sudo ./IMProducts/PUCL/PUCL  copy <packageName> -connectPassportAdvantage /
  -secureStorageFile ./IMTemp/credential.store -masterPasswordFile ./IMTemp/master_password.txt /
  -target ./IMRepo -platform os=linux,arch=x86 -acceptlicense
  ```

## Installation Scripts

You can use the following scripts to install or update your Content Runtime VM.

### provision.py

The `provision.py` script is used to provision a Content Runtime VM. Specifically, the script performs the following steps:

 1. Creates a new cloud connection
 1. Creates a new Content Runtime VM
 1. Loads Chef cookbooks
 1. Populates the Installation Manager (IM) repository
 1. Loads Terraform templates
 1. Configures the WAS VM Quickstarter service

The script is located on the `wasaas-devops` container in the `/wasaas/content-runtime/` directory. The script is designed to be idempotent. It will check and skip the steps that are already complete.

#### Command-line Options

| Option                | Description                      |
| --------------------- | -------------------------------- |
| `--recreate`          |   Recreate Content Runtime VM.   |
| `--reload-cookbooks`  |   Reload Chef cookbooks.         |
| `--reload-templates`  |   Reload Terraform templates.    |
| `--reinstall-pucl`    |   Reinstall Packaging Utility.   |
| `--load-fixes`        |   Load recommended interim fixes into the Installation Manager repository. |
| `--skip-im`           |   Skip steps related to Installation Manager.         |

#### Configuration Files

The script has two main configuration files: `/wasaas/content-runtime/conf/fixpacks.json` and `/wasaas/content-runtime/conf/content-runtime.json`.

##### fixpacks.json

The `fixpacks.json` file contains a list of WebSphere fixpacks (Liberty and traditional) to make available through the WAS VM Quickstarter service. The `provision.py` script downloads all the specified WebSphere versions from the IBM Passport Advantage site. Entitlement is required for any WebSphere 8.5.5.x version.

Specify Liberty fix pack entries in the following format:
```json
{
    "liberty_version": "18.0.0.1",
    "java_version": "8.0.5.11",
    "ihs_version": "9.0.0.7"
}
```

Specify WebSphere traditional fix pack entries in the following format:
```json
{
    "was_version": "9.0.0.7",
    "java_version": "8.0.5.11",
    "ihs_version": "9.0.0.7"
}
```

You can specify multiple WAS traditional or Liberty fix pack entries within the `fixpacks.json` file, but any given fix pack can be specified only once. For example, you can have three separate entries for Liberty `17.0.0.3`, `17.0.0.4`, and `18.0.0.1`, but you cannot have multiple entries for Liberty `18.0.0.1`.

**Note**: Always increment the `iteration` value in the `fixpacks.json` whenever you change the fix pack list. Updating the value ensures fix packs are accurately reflected in the WAS VM Quickstarter service.

##### content-runtime.json

The `content-runtime.json` file contains information needed to create a Content Runtime VM. Most of the information in this file is already populated based on the information provided when the WAS VM Quickstarter Helm chart was deployed. Some information, such as the IP address for the Content Runtime VM or vSphere user name and password, must be manually entered.

## Troubleshooting

### CRIMA1130E

```
CRIMA1130E ERROR: The Installation Manager could not be started because another Installation Manager instance is already running. Only a single Installation Manager can run at any time.
```

An Installation Manager process is already running on the Content Runtime VM. Log in to the Content Runtime VM, and kill any Installation Manager or Packaging Utility processes. To find see all Packaging Utility processes, run the following command:
```
ps -ef | grep PUCL
```

### saveCredential error

```
Saving IBMid credential
Cannot connect to the URL.
  - Verify that the URL is correct.
  - Verify that the user name and password are correct.
  - Verify that you can access the network.

00:02.82 ERROR [main] com.ibm.cic.agent.core.application.HeadlessApplication run
  saveCredential error
```

The IBMid credentials for the IBM software repository could not be saved.
Ensure the `IBMID_USERNAME` and `IBMID_PASSWORD` environment variables specify valid IBMid credentials. Rerun the `provision.py` script with the `--reinstall-pucl` option.
