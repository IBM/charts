# Administering WAS VM Quickstarter

To administer the WAS VM Quickstarter service, a number of scripts are provided in the `wasaas-devops` container. These scripts include an installation verification test (IVT) script and management scripts for service usage and diagnosis purposes.

| Script Name |  Function |  Location  |
| ------------- | --------- | --------- |
| [collect_logs.sh](#collect_logssh) | This script gathers logs from WAS VM Quickstarter pods and other components.| `/wasaas/bin/` |
| [idauth.py](#idauthpy) | This script helps create, read, or delete client IDs that are used to enable OAuth. | `/wasaas/bin/` |
| [ivt.sh](#ivtsh) | This script runs a basic test against WAS VM Quickstarter REST APIs to validate the service is behaving properly. | `/wasaas/test/` |
| [provision.py](https://ibm.biz/WASQuickstarterContentRuntime#provisionpy) | This script provisions a Cloud Automation Manager Content Runtime VM. See [Setting Up the Content Runtime](https://ibm.biz/WASQuickstarterContentRuntime).| `/wasaas/content-runtime/` |
| [register_console.sh](#register_consolesh) | This script registers the WAS VM Quickstarter console with the IAM component. | `/wasaas/bin/`   |
| [wasaas.py](#wasaaspy) | This script provides a set of commands to use and administer the service.| `/wasaas/bin/` |

## Using the Scripts

### Accessing the Scripts in the `wasaas-devops` Container

The scripts are located in subfolders of the `/wasaas` directory of the `wasaas-devops` container. To run the scripts manually, you'll need to get a shell to the container.
1. Find the name of the pod that is running the container by running the following command, where _release-name_ is the name that you used to deploy the Helm chart.
    ```
    kubectl get pods -l component=devops,release=<release-name>
    ```
1. Get a shell to the container by running the following command:
    ```
    kubectl exec -it <devops pod name> bash
    ```

### Registering the WAS VM Quickstarter Console with IAM

After you deploy the Helm chart, you need to register the WAS VM Quickstarter console with the IBM Cloud Private Identity and Access Management (IAM) component. IAM enables seamless authentication and authorization. Registering the console is a one-time action that you only need to do during your initial WAS VM Quickstarter installation.

To register the WAS VM Quickstarter console with IAM, perform the following steps:

  1. [Access the `wasaas-devops` container](#accessing-the-scripts-in-the-wasaas-devops-container).
  1. Run the `/wasaas/bin/register_console.sh` command.

### Collecting Troubleshooting Data

To collect troubleshooting data for problem determination, complete the following steps:

1. [Access the `wasaas-devops` container](#accessing-the-scripts-in-the-wasaas-devops-container).
1. Run the `./bin/collect_logs.sh` script to collect the logs.

   The script creates a .zip file that contains the log files under the `/wasaas/logs` directory.
1. Exit the `wasaas-devops` container, and download the .zip file by running the `kubectl cp` command. For example:

    ```
    kubectl cp <devops pod name>:/wasaas/logs/20180626-201019.zip .
    ```

## Scripts

### collect_logs.sh

_Description_: Gathers WAS VM Quickstarter logs

_Instructions_: Run using the command `./collect_logs.sh`

_Environment Variables_:

* `TIME_FILTER`: Set to a duration such as `5s`, `7h`, or `2d`. If this value is set, the script collects pod logs newer than the specified duration. Otherwise, the script collects all logs from the pod.

_Behavior_: This script gathers the logs from various WAS VM Quickstarter components.

Individual logs are stored in the `/wassaas/logs/<timestamp>` directory, and the script creates a `/wassaas/logs/<timestamp>.zip` file that contains all the log files. The _<timestamp\>_ value corresponds to the date and time when the script was run.

### idauth.py

_Description_: Create, read, or delete `WLP_CLIENT_ID` and `WLP_CLIENT_SECRET`. This client ID and secret are used to set up OAuth for the console application.

_Prerequisites_: The following environment variables must be set before you run this script:
  * `WLP_CLIENT_REGISTRATION_SECRET`: The secret used to authenticate requests with. To find this value, run the following Kubernetes CLI command: `export WLP_CLIENT_REGISTRATION_SECRET=$(kubectl get secret -n services oauth-client-secret -o jsonpath='{.data.WLP_CLIENT_REGISTRATION_SECRET}' | base64 -d)`.

_Instructions_: Run using the command `idauth.py <command> <options>` from any location within the `wasaas-devops` container.

_Available commands_:

**list**

Summary: List all registered client IDs

Usage: `./idauth.py list`

**create**

Summary: Create a client ID and secret

Usage: `./idauth.py create <clientID> <clientSecret> <redirectUrl1> [redirectUrlN]`
 * `clientID` is `wasaas-broker`
 * `clientSecret` is the secret for the given clientID
 * `redirectUrlN` is a list of redirect URIs. For example, `https://<proxy_ip>:/wasaas-console/iamcallback`

**get**

Summary: Get a client ID

Usage: `./idauth.py get <clientID>`
  * `clientID` is the name of the client ID you want to get

**delete**

Summary: Delete a client ID

Usage: `./idauth.py delete <clientID>`
  * `clientID` is the name of the client ID you want to delete

### ivt.sh

_Description_:  This script runs a basic test against WAS VM Quickstarter REST APIs to validate that the service is behaving properly.

_Instructions_: Run using the command `./ivt.sh` from the `/wasaas/test/` directory.

_Behavior_: This script creates a Liberty Core service instance, installs a simple application, and pings the application to make sure everything is set up correctly. Then, it deletes the service instance.


### register_console.sh

_Description_:  Registers the WAS VM Quickstarter console with the IBM Private Cloud's Identity and Access Management (IAM) component.

_Instructions_: See [Registering the WAS VM Quickstarter Console with IAM](#registering-the-was-vm-quickstarter-console-with-iam).

### wasaas.py

_Description_: This script includes a set of commands to use and administer the WAS VM Quickstarter service.

_Instructions_: Run using the command `wasaas.py <command> <options>` from any location within the `wasaas-devops` container.

_Available commands_:

**create**

Summary: Creates a WebSphere Application Server service instance of the desired configuration.

Usage: `wasaas.py create Name <LibertyCollective|LibertyCore|LibertyNDServer|WASBase|WASCell|WASNDServer> [options]`

Where `[options]` are:
+ `-v` Product level (`9.0.0`, `8.5.5`, `18.0.0.1`)
+ `-a` Application server VM size (`S`, `M`, `L`, `XL`, `XXL`), defaults to `S`
+ `-n` Number of application server nodes (only for `LibertyCollective` & `WASCell`)
+ `-c` Control server VM size (`S`, `M`, `L`, `XL`, `XXL`)

**get**

Summary: Get information for the supplied service instance ID.

Usage: `wasaas.py get ServiceInstanceID`

**delete**

Summary: Release a service instance by service instance ID.

Usage: `wasaas.py delete ServiceInstanceID`

**list**

Summary: Lists all active service instances for the current default resource group.

Usage: `wasaas.py list`

**get-features**

Summary: Get active features for the current environment.

Usage: `wasaas.py get-features`

**set-features**

Summary: Enable or disable a feature for the current environment.

Usage: `wasaas.py set-feature FeatureName <public|private|disabled>`

**get-pools**

Summary: Get information about the resource pools.

Usage: `wasaas.py get-pools`

**set-pools**

Summary: Set resource pool sizes.

Usage: `wasaas.py set-pools poolName=poolSize [poolNameN=poolSizeN]`

Where `[poolName]` is one of the following: `tWASND`, `tWASV9`, `dmAndIHSV9`, `collectiveLibertyHost`, `collectiveControllerIHS`, `customNodeV9`, `dmAndIHS`, `tWAS`, `customNode`, `liberty`, `libertyND`, or `all`.     

Examples:

 * Set the `liberty` pool to 1 and the `customNode` pool to 2: `wasaas.py set-pools liberty=1 customNode=2`
 * Set all pools to 1: `wasaas.py set-pools all=1`

**get-resources**

Summary: Get a list of resources.

Usage: `wasaas.py get-resources [options]`

Where `[options]` are:
+ `-a` Show all resources
+ `-f` Filter failed resources
+ `-p` Filter pooled resources

Examples:

  * Show all failed resources that are in the pools: `wasaas.py get-resources -f -p`
  * Show all resources: `wasaas.py get-resources -a`

**delete-resource**

Summary: Delete a resource by resource ID

Usage: `wasaas.py delete-resource ResourceID`
