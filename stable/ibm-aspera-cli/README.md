# Aspera CLI

## Introduction

The IBM Aspera Command-Line Interface (the Aspera CLI) is used to transfer files to or from an external Aspera transfer server. This external server can be an existing on-premises or cloud Aspera deployment, or one that Aspera manages as part of an IBM Aspera On Cloud (AoC) subscription. In either case, the Aspera CLI enables fast, reliable, and secure data transfer from your local environment to cloud storage and private datacenters.

## Chart Details

This chart creates either a one-time Job or repeated CronJob to execute an Aspera CLI transfer session using the Helm package manager.

The type of job is dictated by users' needs. For example, users might configure a one-time job for a one-off data migration or other big-data use case. Or they might create a Kubernetes CronJob for nightly backup and restore, or as part of a weekly reporting job. In the case of a CronJob, users can further configure the Helm chart to set the CronJob frequency.

## Prerequisites

- You must have credentials to transfer to or from an existing Aspera endpoint. The endpoint can be an existing Aspera deployment or an Aspera on Cloud account.
- A PersistentVolume and PersistentVolumeClaim must exist ahead of time. This can be a PVC for this specific task, or one that is part of another service that users want to transfer to or from. See [Storage](#storage).
- When the endpoint is a transfer server that is part of Aspera on Cloud (AoC) transfers, you must create a secret object that contains the following:
  - a private key (a **.pem** file)
  - the client ID
  - the client secret

  For instructions on creating this secret, see [Setting Up Aspera on Cloud](#settingupasperaoncloud).

## Resources Required

- See [Configuration](#Configuration).
- Minimum resources per job:
  - 1 GB Memory
  - 1 CPU unit

## Setting Up Aspera on Cloud

To use the Aspera CLI to transfer to or from an existing Aspera on Cloud subscription, follow the steps below.

### [CLI User] - Adding a private key

1. Generate a public/private key pair for use in authenticating the Aspera CLI against an AoC transfer server.
2. On your local machine, run the following commands:
    ```bash
    openssl genrsa -out private_key.pem 2048
    openssl rsa -in private_key.pem -pubout -out public_key.pem
    ```
3. In AoC, add the contents of **public_key.pem** to the **Public Key** field in Account Settings

### [AoC admin user] - Adding a private key to a user

1. In AoC's Admin app, add the public key to a user.
    **NOTE:** If the admin user already has an admin-scoped bearer token, this step can also be done through the Files API. For more information, see [https://developer.ibm.com/aspera/](https://developer.ibm.com/aspera/).
2. Log in to Aspera on Cloud using your organization's authentication method.
3. Open the Admin app.
4. In the lefthand navigation bar, select **Users**.
5. Find the username of the user you want to run transfers as, and click it to open the user's profile.
6. In the **Public Key** field, paste the public key that you generated in Step 1 above.
7. Click **Save** to make your changes take effect.

### [AoC admin user] - Create a client ID and secret by registering an API client.

  1. In the Admin app, select **Organization > Integrations**.
  2. Click **Create new**.
  3. In the **Name** field, enter a name for your client. This name is for your reference only, and does not need to match the actual name of your app.
  4. If you want users of your application to be prompted to allow your client application to access Aspera on Cloud (for contacts, for example), select the checkbox to **Users must explicitly allow the client to access IBM Aspera on Cloud**.
  5. In the **Redirect URIs** field, enter the redirect URIs for your application, separating multiple URIs with commas. You do not need to enter real values in the **Redirect URIs** field. A redirect URI is an absolute URI that is invoked after the authorization flow, to return the user to the client app. For more information, see the [Files API documentation](https://developer.ibm.com/api/view/aspera-prod:ibm-aspera:title-IBM_Aspera).
  6. In the **Origins** field, enter the origins for your app, separating multiple origins with commas. You do not need to enter real values in the **Origins** field. An origin is the URI of the client app initial login page, from which the user must arrive to the authentication flow.
  7. Click **Save** and store the resulting client ID and secret for future use.

### [AoC admin user] - Enable JWT in your API client.

1. In the Admin app, go to **Organization > Integrations** and select the name of the client you just created.
2. Select the **JSON Web Token Auth** tab.
3. Click **Enable JWT grant type**.
4. Click **Save**.

To use the Aspera CLI with Aspera on Cloud, you must provide the following artifacts when you configure the chart:

- **private_key.pem**
- client ID
- client secret
- AoC organization name
- AoC workspace name


## Installing the Chart

### [For AoC Transfers] - Set the required secrets (**.pem** file, client secret, and client ID):

```bash
kubectl create secret generic my-aoc-secret \
--from-file=ACLI_AOC_PRIVATE_KEY="$HOME/.ssh/aoc_id_rsa" \
--from-literal=ACLI_AOC_CLIENT_SECRET="my_client_secret" \
--from-literal=ACLI_AOC_CLIENT_ID="my_client_id"
```

### [For Non-AoC Transfers] Set the required secrets (password):

```bash
kubectl create secret generic xfer-remote-password \
--from-literal=ACLI_PASSWORD="remote_password"
 ```

1. Set the required variables. To do this, create a **values.yaml** file. The values you specify in **values.yaml** are described in more detail at [ibmcom/aspera-cli](https://hub.docker.com/r/ibmcom/aspera-cli/).

  Sample **values.yaml** file for an AoC transfer:

```yaml
    cli:
      subcommand: aoc
      direction: download
      remoteHost: aspera.ibmaspera.com
      username: someone@mydomain.com
      localPath: /relative_volume_path
      remotePath: Files/testing/file1
      aoc:
        org: my-org-name
        workspace: Marketing
        secret: my-aoc-secret

    volume:
      name: aspera-cli-example-volume
      existingClaimName: aspera-cli-example-volume-claim
```

  Sample **values.yaml** file for an Aspera Transfer Server (ATS) transfer:

```yaml
    cli:
      subcommand: ats
      direction: upload
      remoteHost: ats-sl-dal.aspera.io
      username: my_access_key
      passwordSecretName: xfer-remote-password
      localPath: /relative_volume_path
      remotePath: /target

    volume:
      name: aspera-cli-example-volume
      existingClaimName: aspera-cli-example-volume-claim
```

2. Install the chart:

```bash
helm install -f values.yaml ./aspera-cli
```

## Configuration

| Parameter |Description|Default
|--|--|--|
| `image.repository` | Container image to use | `ibmcom/aspera-cli` |
| `image.pullSecrets` | Array of image pull secrets to use | `[]` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `job.backoffLimit` | Retries before job considered failed | `2` |
| `job.restartPolicy` | Pod restartPolicy | `Never` |
| `cronjob.enabled` | Run as a CronJob | `false` |
| `cronjob.schedule` | CronJob schedule | `"*/5 * * * *"` |
| `cronjob.successfulJobsHistoryLimit` | CronJob successfulJobsHistoryLimit | `1` |
| `cronjob.failedJobsHistoryLimit` | CronJob failedJobsHistoryLimit | `1` |
| `cronjob.concurrencyPolicy` | CronJob concurrencyPolicy | `Forbid` |
| `volume.name` | PersistentVolume to be used in the transfer  | `null` |
| `volume.existingClaimName` | PersistentVolumeClaim for `volume.name`  | `null` |
| `volume.mountPath` | Location to mount volume  | `/mount` |
| `cli.subcommand` | aspera CLI subcommand to execute | `node` |
| `cli.direction` | aspera CLI subcommand transfer direction | `upload` |
| `cli.remoteHost` | Remote host for the transfer | `null` |
| `cli.remotePort` | Remote host port for the transfer | `null` |
| `cli.username` | Remote user for authentication | `null` |
| `cli.passwordSecretName` | Secret object containing remote password (ACLI_PASSWORD) | `null` |
| `cli.localPath` | Local path for the transfer. Relative to `volume.mountPath` | `null` |
| `cli.remotePath` | Remote path for the transfer | `null` |
| `cli.debugLevel` | Log verbosity to be used (0-3) | `2` |
| `cli.additionalOptions` | Additional command line options to be appended to generated `aspera` command | `''` |
| `cli.aoc.org` | AoC org to interact with | `null` |
| `cli.aoc.workspace` | AoC org workspace to interact with | `null` |
| `cli.aoc.secret` | Secret containing AoC pem key, AoC client ID, AoC client secret | `null` |
| `cli.aoc.package.name` | Name of AoC package to be sent | `null` |
| `cli.aoc.package.recipients` | Recipients of AoC package to be sent | `null` |
| `cli.aoc.package.id` | ID of AoC package to be downloaded  | `null` |
| `resources.limits.cpu`          | CPU limit for the container | `2`                                                   |
| `resources.limits.memory`       | Memory limit for the container | `2048Mi`                                              |
| `resources.requests.cpu`        | CPU request for the container | `1`                                                 |
| `resources.requests.memory`     | Memory request for the container | `1024Mi`                                            |

## Storage

- Since this chart seeks to use or provide data to existing workloads, no volumes or claims will be created dynamically.
- You must specify PersistentVolume and PersistentVolumeClaim names.
- The `cli.localPath` must be relative to the `volume.mountPath`.
- The PVC used must have at least `ReadMany` for uploads and write privileges for downloads.

## Limitations

- The Aspera CLI is available for x86-64 platforms only.
- The chart must be installed in the same namespace as the PersistentVolume and PersistentVolumeClaim specified in the `volume` configuration.
- Transfer functionality is currently limited to AoC, ATS, and Node transfers.

## Documentation

- [Aspera CLI Documentation](https://downloads.asperasoft.com/en/documentation/62)
- [Aspera on Cloud Help](https://ibm.ibmaspera.com/helpcenter)

