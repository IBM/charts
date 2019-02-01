# Overview

Due to Helm secret management anyone with access to tiller can run a `helm get values --tls` command and see secret information in plain text (https://github.com/helm/helm/issues/2196) - only administrators or cluster administrators should have access to tiller. The configuration for an integration server (detailed in the `Configuration` section below) is stored in a secret. In order to separate this secret from the Helm release it should be created using the `generateSecrets.sh` command prior to the Helm chart installation.

## Configuration
The following table lists and describes the configurable files supported by the `generateSecrets.sh` script.

| File                             | Description                                                        |
| -------------------------------- | ------------------------------------------------------------------ |
| `adminPassword.txt`              | MQ Developer defaults - administrator password                     |  
| `appPassword.txt`                | MQ Developer defaults - app password                               |
| `mqsc.txt`                       | An mqsc file to run against the Queue Manager                      |
| `keystorePassword`               | A password to set for the Integration Server's keystore            |
| `keystore-{keyname}.pass`        | The passphrase for the private key being imported, if there is one |
| `keystore-{keyname}.key`         | The private key in PEM format                                      |
| `keystore-{keyname}.crt`         | The certificate in PEM format                                      |
| `truststorePassword.txt`         | A password to set for the Integration Server's truststore          |
| `truststore-{certname}.crt`      | The trust certificate in PEM format                                |
| `odbc.ini`                       | An odbc.ini file for the Integration Server to define any ODBC data connections |
| `policy.xml`                     | Policies to apply                                                  |
| `policyDescriptor.xml`           | The policy descriptor file                                         |
| `serverconf.yaml`                | The server.conf.yaml                                               |
| `setdbparms.txt`                 | Multi-line file containing the `{ResourceName} {UserId} {Password}` to pass to [mqsisetdbparms command](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/an09155_.htm) |

Sample configuration files can be found in the `sample-configuration-files` sub-directory.

> **NB**: Take care not to include additional new lines at the end of the files (such as keystorePassword.txt) - some editors add these automatically on save and can result in the containers not starting due to password mismatch.

## Running

To run the script:
- The kubectl command must be installed and available
- The kubectl environment must be configured to point to the intended target cluster
- The name of the secret to be created must be supplied as an argument on the command line

```
./generateSecrets.sh my-secret
```

The script will look for any files detailed in the `Configuration` section in the same directory and if found will add them into keys in the generated secret. The script will then use the kubectl command to generate a secret containing the specified configuration for the integration server.
