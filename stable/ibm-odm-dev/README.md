# ODM for developers Helm chart (ibm-odm-dev)

The [IBM® Operational Decision Manager](https://www.ibm.com/hr-en/marketplace/operational-decision-manager) (ODM) chart (`ibm-odm-dev`) is used to deploy an ODM evaluation cluster in IBM  Kubernetes environments.

ODM is a tool for capturing, automating, and governing repeatable business decisions. You identify situations about your business and then automate the actions to take as a result of the insight you gained about your policies and customers. For more information, see [ODM in knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.9.2/welcome/kc_welcome_odmV.html).

This readme includes the following sections:

- [Prerequisites](#prerequisites)
- [What is the ODM for developers Helm chart?](#what-is-the-odm-for-developers-helm-chart)
- [How to create a release of ODM for developers](#how-to-create-a-release-of-odm-for-developers)
- [What to do next](#what-to-do-next)
- [How to create a release of ODM for developers from the command line](#how-to-create-a-release-of-odm-for-developers-from-the-command-line)
- [Configuration parameters](#configuration-parameters)
- [How to uninstall releases of ODM for developers](#how-to-uninstall-releases-of-odm-for-developers)

## Prerequisites

Before you install a release of  ODM for developers, you should ensure you have  a good understanding of the following technologies:

- Knowledge of concepts like Helm chart, Docker, container
- Knowledge of Kubernetes
- Familiarity with Helm commands (if you choose to install an ODM release with the command line)
- Familiarity with the Kubernetes command line tool (if you choose to install an ODM release with the command line)

Before you install ODM for developers, you need to gather all the configuration information that you will use for your release. For more details, refer to the [Configuration parameters](#configuration-parameters).

## What is the ODM for developers Helm chart?

The `ibm-odm-dev` Helm chart is a package of preconfigured Kubernetes resources that bootstrap an ODM deployment on a Kubernetes cluster. Configuration parameters are available to customize some aspects of the deployment. However, the chart is designed to get you up and running as quickly as possible, with appropriate default values. If you accept the default values, sample data is added to the database as part of the installation, and you can begin exploring rules in ODM immediately.

If you choose not to use the default values, be sure to review the configuration parameters [Configuration parameters](#configuration-parameters) that are available to you and understand the impact of changes before you start the installation process.

The `ibm-odm-dev` chart supports the following options for persistence:

- H2 as an internal database. This is the **default** option.
Persistent Volume (PV) is required if you choose to use an internal database. PV represents an underlying storage capacity in the infrastructure. PV must be created with accessMode ReadWriteOnce and storage capacity of 5Gi or more, before you install ODM. You create a PV in the Admin console or with a .yaml file.
- PostgreSQL as an external database. If you specify a server name for the external database, the external database is used, otherwise the internal database is used. Before you select this option, you must have an external PostgreSQL database up and running.
	> By default, the `internalDatabase.populateSampleData` parameter is set to `true`, which adds sample data to the database. A decision service is created in Decision Center and is also deployed to Rule Execution Server. The sample data can be used to test your newly created release.

	> **Note:** The ability to populate the database with sample data is available only when using the internal database and the persistence locale for Decision Center is set to English (United States). Sample data is not available for the external database.

## How to create a release of ODM for developers

1. In the `ibm-odm-dev` Helm chart page of the Admin console, click Configure.
2. Enter a value for the **Release**, and accept the license agreement. An example release name is *my-release*.
3. *Optional*: Modify the parameter values to change the defaults. For more information, see [Configuration parameters](#configuration-parameters).

4. Click Install.

	> The package is deployed asynchronously in a matter of minutes, and is composed of a single service.

5. When the installation is complete, click **View Helm Release** to see the details of the release.

	> The release name shows a status of DEPLOYED. The release is an instance of the `ibm-odm-dev` chart: all the ODM components are now running in a  Kubernetes cluster.

## What to do next

Inspect the ODM for developers release:

1. In the Admin console, click **Menu** > **Network Access** > **Services**, and search for the name you entered for the release, for example  *my-release*.
2. Click your service to view the **Service** details, then click the **Node port** link.

A **Welcome to IBM Operational Decision Manager** page displays with links to the different ODM services.
 - Decision Center Business Console
 - Decision Center Enterprise Console
 - Decision Server Console
 - Decision Server Runtime
 - Decision Server Runner

3. Right-click any of the links to access the services in a new window. To log in, use odmAdmin/odmAdmin.

### Explore the sample rules

If you accepted the default persistence, a sample project is available in your ODM release and you can explore and modify the rules and decision tables. The Loan Validation sample is a decision service that determines whether a borrower is eligible for a loan. The decision service validates transaction data, checks customer eligibility, assigns a score, and computes insurance rates that are based on the assigned score.

**Note:** The persistence locale for Decision Center is set to English (United States), which means that the project can be viewed only in English.

1. Log in to Decision Center by opening the service in a browser.

2. Navigate to the Library tab, select the decision service, then the release and browse Decision Artifacts to view the rules and make changes.

### Execute the sample decision service

Now you want to execute the sample decision service to request a loan.

1. Log in to Decision Server Console by opening the service in a new private browser window.
2. Click the **Explorer** tab. In the Navigator pane, expand **RuleApps**. Expand the sample RuleApp **LoanValidationDS**, and click the sample Ruleset **loan_validation_production** to open the **Ruleset View**.
3. On the **Ruleset View** page, click **Retrieve HTDS Description File**.
4. Select **REST** in the Service protocol type field, and select the **Open API - JSON format**.
5. Select the **Decision trace information** option, and then click **Test**.
6. On the **Decision Service** page, replace the template JSON code to request a loan with the following data:

```JSON
{
  "loan": {
    "numberOfMonthlyPayments": 180,
    "startDate": "2016-10-19T17:27:14.000+0000",    
    "amount": 999,
    "loanToValue": 0.9  
  },
  "__DecisionID__": "test",
  "borrower": {    
    "firstName": "Joe",
    "lastName": "Doe",    
    "birth": "1987-09-29T01:49:45.000+0000",    
    "SSN": {      
      "areaNumber": "424",      
      "groupCode": "56",
      "serialNumber": "7942"    
    },    
    "yearlyIncome": 50000,    
    "zipCode": "95372",    
    "creditScore": 6000,    
    "spouse": {
      "firstName": null,
      "lastName": null,
      "birth": "1989-08-29T01:49:45.000+0000",
      "SSN": {
        "areaNumber": "",
        "groupCode": "",
        "serialNumber": ""
      },
      "yearlyIncome": 0,
      "zipCode": null,
      "creditScore": 0,
      "spouse": null,
      "latestBankruptcy": {
        "date": null,
        "chapter": 0,
        "reason": null
      }
    },
    "latestBankruptcy": {
      "date": "2017-11-01T09:15:53.000+0100",
      "chapter": 3,
      "reason": "Summer loss"
    }
  },
 "__TraceFilter__": {
    "infoRulesetProperties": false,
    "infoOutputString": false,
    "infoInputParameters": false,
    "infoOutputParameters": false,
    "none": true,
    "infoExecutionEventsAsked": false,
    "workingMemoryFilter": "string",
    "infoBoundObjectByRule": false,
    "infoExecutionDuration": false,
    "infoExecutionDate": false,
    "infoExecutionEvents": false,
    "infoInetAddress": false,
    "infoRules": false,
    "infoRulesNotFired": false,
    "infoSystemProperties": false,
    "infoTasks": false,
    "infoTasksNotExecuted": false,
    "infoTotalRulesFired": true,
    "infoTotalRulesNotFired": false,
    "infoTotalTasksExecuted": false,
    "infoTotalTasksNotExecuted": false,
    "infoWorkingMemory": false,
    "infoRulesFired": false,
    "infoTasksExecuted": false,
    "infoBoundObjectSerializationType": "ClassName"
  }
}
```

7. Click **Execute Request**, and check the **Server Response** section. The trace shows that the service fired 15 rules, and the loan request is approved.

```JSON
{
  "score": 5950,
  "__decisionTrace__": {
    "totalRulesFired": 15
  },
  "grade": "A",
  "report": {
    ...
    "loan": {
      "numberOfMonthlyPayments": 180,
      "startDate": "2016-10-19T17:27:14.000+0000",
      "amount": 999,
      "loanToValue": 0.9
    },
    "validData": true,
    "insuranceRequired": true,
    "insuranceRate": 0.02,
    "approved": true,
    "messages": [
      "Very low risk loan",
      "Congratulations! Your loan has been approved"
    ],
    "yearlyInterestRate": 0.067,
    "monthlyRepayment": 8.812575375415308,
    "insurance": "2%",
    "message": "Very low risk loan\nCongratulations! Your loan has been approved",
    "yearlyRepayment": 105.75090450498371
  },
  "__DecisionID__": "test"
}
```

### For more information

See [ODM in knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.9.2/welcome/kc_welcome_odmV.html).

If you want to create your own decision services from scratch, you need to install Rule Designer from the [Eclipse Marketplace](https://marketplace.eclipse.org/content/ibm-operational-decision-manager-developers-rule-designer)


## How to create a release of ODM for developers from the command line

### Release configuration
A release must be configured before it is installed. For information about the parameters to configure ODM for installation, see [Configuration parameters](#configuration-parameters).

To install a release with the default configuration and a release name of `my-odm-dev-release` from the command line, use the following command:

```console
$ helm install --name my-odm-dev-release stable/ibm-odm-dev
```

> **Tip**: List all existing releases with the `helm list` command.

Using Helm, you specify each parameter with a `--set key=value` argument in the `helm install` command.
For example:

```console
$ helm install --name my-odm-dev-release \
  --set internalDatabase.databaseName=my-db \
  --set internalDatabase.user=my-user \
  --set internalDatabase.password=my-password \
  stable/ibm-odm-dev
```

It is also possible to use a custom-made .yaml file to specify the values of the parameters when you install the chart.
For example:

```console
$ helm install --name my-odm-dev-release -f values.yaml stable/ibm-odm-dev
```

> **Tip**: The default values are in the `values.yaml` file of the `ibm-odm-dev` chart.

If the Docker images are pulled from a private registry, you must [specify an image pull secret](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod). Proceed as follows:

1. [Create an image pull secret](https://kubernetes.io/docs/concepts/containers/images/#creating-a-secret-with-a-docker-config) in the namespace. For information about setting an appropriate secret, see the documentation of your image registry.

2. Set the secret in the `values.yaml` file by adding the SECRET_NAME to the `pullSecrets` parameter, as follows:

   ```yaml
   image:
     pullSecrets: SECRET_NAME
   ```
3. Add the `--set image.pullSecrets` parameter in the Helm install command line, as follows:

   ```console
   $ helm install --name my-odm-dev-release \
     --set image.pullSecrets=admin.registryKey \
     --set image.repository=mycluster.icp:8500/ibmcom \
     stable/ibm-odm-dev
   ```

## Configuration parameters

The following table shows the available parameters to configure the `ibm-odm-dev` chart.

| Parameter                                   | Description                             | Default value                                   |
| ------------------------------------------- | --------------------------------------- | ----------------------------------------------- |
| `decisionCenter.persistenceLocale`   | The persistence locale for Decision Center. | `en_US` |
| `externalDatabase.databaseName`             | The name of the external database used for ODM. If this parameter is empty, `odmdb` is used by default. | `""` (empty) |
| `externalDatabase.password`                 | The password of the user used to connect to the external database. If this parameter is empty, `odmpwd` is used by default. | `""` (empty) |
| `externalDatabase.port`                     | The port used to connect to the external database | `5432` |
| `externalDatabase.serverName`               | The name of the server running the database used for ODM. If it is not specified, the H2 internal database is used. Only PostgreSQL is supported as external database. Sample data is not available for the external database. | `""` (empty) |
| `externalDatabase.user`                     | The name of the user used to connect to the external database. If this parameter is empty, `odmusr` is used by default. | `""` (empty) |
| `image.pullPolicy`                          | The image pull policy         | `IfNotPresent`                                  |
| `image.pullSecrets`                         | The image pull secrets        | `nil` (does not add image pull secrets to deployed pods) |
| `image.repository`                          | The repository                | `ibmcom`                                        |
| `image.tag`                                 | The image tag version                   | `8.9.2`                                         |
| `internalDatabase.persistence.enabled`      | To use a Persistent Volume Claim (PVC) to persist data | `true` |
| `internalDatabase.persistence.useDynamicProvisioning` | To use dynamic provisioning for Persistent Volume Claim. If this parameter is set to `false`, the Kubernetes binding process selects a pre-existing volume. Ensure, in this case, that there is a remaining volume that is not already bound before installing the chart. | `false` |
| `internalDatabase.persistence.storageClassName`       | The storage class name for Persistent Volume  | `""` (empty) |
| `internalDatabase.persistence.resources` | The requested storage size for Persistent Volume | `requests`: `storage` `2Gi`  |
| `internalDatabase.populateSampleData`       | To populate sample data in the H2 internal database or not. This option is available only when the persistence locale for Decision Center is set to English (United States).| `true` |
| `resources`                                 | The CPU/Memory resource requests/limits     | `requests`: `cpu` `1`, `memory` `1024Mi`; `limits`: `cpu` `2`, `memory` `2048Mi` |
| `service.type`                              | The Kubernetes Service type   | `NodePort`                                   |


## How to uninstall releases of ODM for developers

To uninstall and delete a release through the user interface:

- In the list of Helm releases (under **Menu > Workload  >Helm Releases**), click the three-dotted Action button next to your release, and select Delete.

To uninstall and delete a release named `my-odm-dev-release` through the command line, use the following command:

```console
$ helm delete my-odm-dev-release
```

The command removes all of the Kubernetes components that are associated with the chart, and deletes the release.


> >**Note**: The associated Persistent Volume remains available.
Whichever uninstallation method you choose, you must delete the Persistent Volume manually.
