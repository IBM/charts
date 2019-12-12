# ibm-watson-nlu-prod

[IBM Watson™ Natural Language Understanding](https://www.ibm.com/watson/services/natural-language-understanding/index.html#about) is natural language processing for advanced text analysis.

## Introduction

With [IBM Watson™ Natural Language Understanding](https://www.ibm.com/watson/services/natural-language-understanding/index.html#about), developers can analyze semantic features of text input, including keywords, custom entities, relations and sentiment.

## Chart Details

This chart creates several pods, statefulsets, services, and secrets to create the NLU offering.

Pods:

* `ibm-watson-nlu-server` - The API server.  All calls go through here.
* `ibm-watson-nlu-orchestrator` - Orchestrates processing among the various processing pods.
* `ibm-watson-nlu-keywords` - Implements the keywords feature.
* `ibm-watson-nlp-prod` - Tokenizes the incoming text.  Only English text is supported.
* `ibm-watson-nms` - Used to import and export models.
* `ibm-watson-mma` - Frontend to PostgresSql database for storing model information.
* `ibm-watson-cs` - Enables Watson Natural Language Processing features, like Sentiment, Entities, and Categories
* `ibm-watson-sire-runtime` - Relationship extraction engine for entities and relations
* `ibm-etcd` - Database
* `postgres-<keeper,proxy,sentinel>` - Database
* `minio` - Database

Statefulsets:

* `ibm-etcd`
* `postgres-keeper`
* `ibm-minio`

Secrets:

* `{release-name}-nlu-tls`: TLS key/cert pairs for NLU components.
* `{release-name}-nlu-minio-access-secret`: Authentication secrets for Minio.
* `{release-name}-nlu-postgres-auth-secret`: Authentication secret for accessing PostgresSQL.

## Pre-install steps

This script has to be run once per cluster by a cluster admin. Run: ./ibm_cloud_pak/pak_extensions/pre-install/ clusterAdministration/labelNamespace.sh ICP4D_NAMESPACE where ICP4D_NAMESPACE is the namespace where ICP4D is installed (usually zen).

The ICP4D_NAMESPACE namespace must have a label for the NetworkPolicy to correctly work. Only nginx and zen pods will be allowed to communicate with the pods in the namespace where this chart is installed.

## Prerequisites

* IBM® Cloud Private for Data 2.1

  Before installing Watson NLU, __you must install and configure [ICP4D](https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/com.ibm.icpdata.doc/zen/overview/relnotes-2.1.0.0.html)__.
* Persistent volumes are set up, prior to installation; see [Storage](#storage) section.

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP4D user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

    - From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

        - Custom PodSecurityPolicy definition:
        ```
        apiVersion: extensions/v1beta1
        kind: PodSecurityPolicy
        metadata:
          name: ibm-watson-nlu-psp
        spec:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false
          allowedCapabilities:
          - CHOWN
          - DAC_OVERRIDE
          - SETGID
          - SETUID
          - NET_BIND_SERVICE
          seLinux:
            rule: RunAsAny
          supplementalGroups:
            rule: RunAsAny
          runAsUser:
            rule: RunAsAny
          fsGroup:
            rule: RunAsAny
          volumes:
          - configMap
          - secret
        ```

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart.

    - From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints

        - Custom SecurityContextConstraints definition:
        ```
        apiVersion: security.openshift.io/v1
        kind: SecurityContextConstraints
        metadata:
          name: ibm-watson-nlu-scc
        readOnlyRootFilesystem: false
        allowedCapabilities:
        - CHOWN
        - DAC_OVERRIDE
        - SETGID
        - SETUID
        - NET_BIND_SERVICE
        seLinux:
          type: RunAsAny
        supplementalGroups:
          type: RunAsAny
        runAsUser:
          type: RunAsAny
        fsGroup:
          rule: RunAsAny
        volumes:
        - configMap
        - secret
        ```

## Resources Required

In addition to the [general hardware requirements and recommendations](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/supported_system_config/hardware_reqs.html), the IBM Watson NLU has the following requirements:

* Minimum CPU - 12 for dev, 22 for HA
* Minimum RAM - 15GB for dev, 40GB for HA


## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --name my-release stable/ibm-watson-nlu-prod;
```

The command deploys ibm-watson-nlu-prod on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

 List all releases using  `helm list --tls`


### Verifying the Chart

```bash
$ helm test my-release --tls --cleanup
```

See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

### Uninstalling the Chart

To uninstall and delete the `my-release` deployment, run the following command:

```bash
$ helm delete --tls my-release
```

To irrevocably uninstall and delete the `my-release` deployment, run the following command:

```bash
$ helm delete --purge --tls my-release
```

If you omit the `--purge` option, Helm deletes all resources for the deployment, but retains the record with the release name. This allows you to roll back the deletion. If you include the `--purge` option, Helm removes all records for the deployment, so that the name can be used for another installation.

## Configuration

Find out more about configuring IBM Watson NLU by reading the [product install documentation](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/natural-language-understanding-install.html)

## Storage

Parenthetical numbers are the PVs required/created when deploying with the recommended HA configuration. See [HA-configuration](#ha-configuration) for more information.

| Component      | Number of replicas | Space per PVC | Storage type            |
|----------------|--------------------|---------------|-------------------------|
| Postgres       |                  1 |          1 GB | Block Storage |
| Etcd           |               1(3) |          1 GB | Block Storage |
| Minio          |               1(4) |         10 GB | Block Storage |

## Limitations

* Watson NLU can currently run only on Intel 64-bit architecture.
* DataStores only support block storage for persistence
* This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart.
* Watson NLU deployment supports a single service instance.
* The chart must be installed through the CLI.
* The chart must be installed by a ClusterAdministrator see [Pre-install steps](#pre-install-steps).
* This chart currently does not support upgrades or rollbacks. Please see the [product documentation](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/natural-language-understanding.html) on backup and restore procedures.
* Release names cannot be longer than 20 characters, should be lower case characters

## Documentation

Find out more about IBM Watson NLU by reading the [product documentation](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/watson/natural-language-understanding.html)
