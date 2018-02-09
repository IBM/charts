This repository is the home directory of the IBM Operational Decision Manager for Developers Helm chart, where you can find materials for the early access program.

# Early Access: ODM for developers Helm chart (Beta Version)

The [IBM® Operational Decision Manager](https://www.ibm.com/hr-en/marketplace/operational-decision-management) (ODM) chart (`ibm-odm-dev`) is used to deploy a cluster for evaluation purposes on IBM Cloud Private or other Kubernetes environments.

ODM is a tool for capturing, automating, and governing repeatable business decisions. You identify situations about your business and then automate the actions to take as a result of the insight you gained about your policies and customers. For more information, see [ODM in knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.9.1/welcome/kc_welcome_odmV.html).

This readme include the following sections:
- [What is the ODM for developers Helm chart?](#What-is-the-ODM-for-developers-Helm-chart?)
- [How to create a release of ODM for developers](#How-to-create-a-release-of-ODM-for-developers)
- [What to do next](#What-to-do-next)
- [Configuration parameters](#configuration-parameters)
- [How to create a release of ODM for developers from the command line](#How-to-create-a-release-of-ODM-for-developers-from-the-command-line)
- [How to uninstall releases of ODM for developers](#How-to-uninstall-releases-of-ODM-for-developers)

## What is the ODM for developers Helm chart?

The `ibm-odm-dev` chart helps you to discover and evaluate ODM. The chart bootstraps an ODM deployment on a Kubernetes cluster. The deployment uses the Helm package manager.

## How to create a release of ODM for developers

1. In the `ibm-odm-dev` Helm chart page of the IBM Cloud Private Admin console, click Configure.
2. Enter a value for the **Release**, and accept the license agreement. An example release name is *my-release*.
3. *Optional*: Modify the parameter values to change the defaults. For more information, see [Configuration parameters](#configuration-parameters).
> By default, the `internalDatabase.populateSampleData` parameter is set to true, which adds sample data to the database. 
> A decision service is created in Decision Center and is also deployed to Rule Execution Server. 
> The sample data can be used to test your newly created release. 
4. Click Install.
> The package is deployed asynchronously in a matter of minutes, and is composed of a single service.
5. When the installation is complete, click **View Helm Release** to see the details of the release. 
> The release name shows a status of DEPLOYED. The release is an instance of the `ibm-odm-dev` chart, which is now running in a Kubernetes cluster.

## What to do next

To view the ODM for developers service:

1. In the Admin console, click **Menu** > **Network Access** > **Services**, and search for the name you entered for the release, for example  *my-release*. The service name always includes **odm**, so this string selects all of the ODM services.
2. Click your service to view the **Service** details, then click the **Node port** link.
 - Add /decisioncenter or /teamserver to the URL to access the Business console or the Enterprise console. To log in, use odmAdmin/odmAdmin.
 - Add /DecisionRunner to the URL to access Decision Runner.
 - Add /DecisionService to the URL to access the Decision Service Runtime. To log in, use odmAdmin/odmAdmin
 - Add /res to the URL to access the Rule Execution Server console. To log in, use odmAdmin/odmAdmin.

### View the rules of the sample

If the `internalDatabase.populateSampleData` parameter is set to true, a sample decision service is added to the H2 database in the Kubernetes cluster. The Loan Validation sample is a decision service that determines whether a borrower is eligible for a loan. The decision service validates transaction data, checks customer eligibility, assigns a score, and computes insurance rates that are based on the assigned score.

**Note:** The persistence locale for Decision Center is set to `en_US`, which means that the project can be viewed only in English.

1. Log in to Decision Center /decisioncenter with odmAdmin/odmAdmin by opening the service in a browser.
> The first level of identification is the decision service. Rules are stored within rule projects contained in a decision service. A decision service contains one or more rule projects. Each rule project contains action rules and decision tables. The second level of identification is through branches. Decision Center uses branches to manage rules over time.
2. Navigate to the Library tab, select the project then the release and browse Decision Artifacts to view the rules and make changes.

### Execute the sample decision service

1. Log in to Decision Server Console. /res with odmAdmin/odmAdmin by opening the service in a new private browser window.
2. Click the **Explorer** tab. In the Navigator pane, expand **RuleApps**. Expand the sample RuleApp, and click on the sample Ruleset to open the **Ruleset View**.
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

see [ODM in knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.9.1/welcome/kc_welcome_odmV.html).

## Configuration parameters

The following table shows the available parameters to configure the `ibm-odm-dev` chart.

| Parameter                                   | Description                             | Default value                                   |
| ------------------------------------------- | --------------------------------------- | ----------------------------------------------- |
| `decisionCenter.persistenceLocale`   | The persistence locale for Decision Center. This parameter is not taken into account when the database contains some sample data. | `en_US` |
| `externalDatabase.databaseName`             | The name of the external database used for ODM | `""` (empty) |
| `externalDatabase.password`                 | The password of the user used to connect to the external database | `""` (empty) |
| `externalDatabase.port`                     | The port used to connect to the external database | `5432` |
| `externalDatabase.serverName`               | The name of the server running the database used for ODM. Only PostgreSQL is supported as external database. Sample data is not available for externalDatabase. | `""` (empty) |
| `externalDatabase.user`                     | The name of the user used to connect to the external database | `""` (empty) |
| `image.pullPolicy`                          | The image pull policy         | `IfNotPresent`                                  |
| `image.pullSecrets`                         | The image pull secrets        | `nil` (does not add image pull secrets to deployed pods) |
| `image.repository`                          | The repository                | `ibmcom`                                        |
| `image.tag`                                 | The image tag version                   | `8.9.2`                                         |
| `internalDatabase.persistence.enabled`      | To use a Persistent Volume Claim (PVC) to persist data | `true` |
| `internalDatabase.persistence.useDynamicProvisioning` | To use dynamic provisioning for Persistent Volume Claim. If this parameter is set to `false`, the Kubernetes binding process selects a pre-existing volume. Ensure, in this case, that there is a remaining volume that is not already bound before installing the chart. | `false` |
| `internalDatabase.persistence.storageClassName`       | The storage class name for Persistent Volume  | `""` (empty) |
| `internalDatabase.persistence.resources` | The requested storage size for Persistent Volume | `requests`: `storage` `2Gi`  |
| `internalDatabase.populateSampleData`       | To use a H2 database containing some sample data or not. If it is set to `true`, the database contains some sample data and uses `en_US` as persistence locale for Decision Center. | `true` |
| `resources`                                 | The CPU/Memory resource requests/limits     | `requests`: `cpu` `1`, `memory` `1024Mi`; `limits`: `cpu` `2`, `memory` `2048Mi` |
| `service.type`                              | The Kubernetes Service type   | `NodePort`                                   |

The following options are supported for ODM persistence:
- H2 as an internal database. This is the **default** option.
- PostgreSQL as an external database. Before you select this option, you must have an external PostgreSQL database up and running.


## How to create a release of ODM for developers from the command line

### Prerequisites to install ODM for developers

- Kubernetes 1.7.5+ with beta APIs enabled.
- Persistent Volume (PV) provisioner support in the underlying infrastructure. A PV in Kubernetes represents an underlying storage capacity in the infrastructure. PV must be created with accessMode ReadWriteOnce and storage capacity of 2Gi or more. You create a persistent volume in the IBM Cloud Private interface or with a .yaml file.

### Release configuration
A release must be configured before it is installed. For information about the parameters to configure ODM for installation, see [Configuration parameters](#configuration-parameters). Click **Configure**, enter the parameter values in the deployment configuration, and then click **Install**.

A release can also be installed from the Helm command-line. To install a release with the default configuration and a release name of `my-odm-dev-release`, use the following command:

```console
$ helm install --name my-odm-dev-release stable/ibm-odm-dev
```

> **Tip**: List all existing releases with the `helm list` command.

Using Helm, you specify each parameter with a `--set key=value` argument in the `helm install` command.
For example:

```console
$ helm install --name my-odm-dev-release --set internalDatabase.databaseName=my-db --set internalDatabase.user=my-user --set internalDatabase.password=my-password stable/ibm-odm-dev
```

It is also possible to use a custom-made .yaml file to specify the values of the parameters when you install the chart.
For example:

```console
$ helm install --name my-odm-dev-release -f values.yaml stable/ibm-odm-dev
```

> **Tip**: The default values are in the `values.yaml` file of the `ibm-odm-dev` chart.

If the Docker images are pulled from a private registry, you must [specify an image pull secret](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

1. [Create an image pull secret](https://kubernetes.io/docs/concepts/containers/images/#creating-a-secret-with-a-docker-config) in the namespace. For information about setting an appropriate secret, see the documentation of your image registry.

2. To set the secret in the `values.yaml` file, add the SECRET_NAME to the `pullSecrets` parameter.

   ```yaml
   image:
     pullSecrets: SECRET_NAME
   ```
   To install the chart from the Helm command line, add the `--set image.pullSecrets` parameter.

   ```console
   $ helm install --name my-odm-dev-release --set image.pullSecrets=admin.registryKey --set image.repository=mycluster.icp:8500/ibmcom stable/ibm-odm-dev
   ```

## How to uninstall releases of ODM for developers

To uninstall and delete a release with a name `my-odm-dev-release`, use the following command:

```console
$ helm delete my-odm-dev-release
```

The command removes all of the Kubernetes components that are associated with the chart, and deletes the release.

