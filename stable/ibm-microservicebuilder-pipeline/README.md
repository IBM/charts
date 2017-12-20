# Microservice Builder pipeline

The Microservice Builder pipeline runs on a Jenkins image in a Docker container, and it is deployed by using this Helm chart. It is designed to integrate with GitHub, GitHub Enterprise, or other Git services that are supported by the Jenkins GitHub plug-ins.

## Prerequisites
To install the pipeline, you must first integrate Jenkins and GitHub. This integration is done in 5 steps.

1. Generate a personal access token for Jenkins to access the microservice projects in GitHub.
2. Add OAuth integration so that users can log in to Jenkins using GitHub for authentication.
3. Set up webhooks in your GitHub organizations so that Git pushes automatically trigger builds
4. Create a list of GitHub user IDs for the users that you want to have administrative access to the Jenkins instance.
5. Configure IBM Cloud private to automatically add the Docker registry secret to deployed pods so that they can retrieve images from the built-in registry

[Learn more about setting up the Microservice Builder Prerequisites](https://www.ibm.com/support/knowledgecenter/en/SS5PWC/pipeline.html).

## Installing the Chart

To install the chart with the release name `pipeline`:

```bash
helm install --name pipeline ibm-microservicebuilder-pipeline
```

This command deploys a Microservice Builder Jenkins pipeline on the Kubernetes cluster. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=pipeline`

## Uninstalling the Chart

To uninstall/delete the `pipeline` release:

```bash
helm delete pipeline --purge
```

The command removes all the Kubernetes components associated with the chart. The `--purge` option will allow you to re-deploy the chart with the same release name

## Configuration
The following table lists the configurable parameters of the `ibm-microservicebuilder-pipeline` chart and their default values.

| Parameter | Description | Default |
| - | - | - |
| Agent.Cpu  | Jenkins build agent cpu |  |
| Agent.Image  | Jenkings build agent image | jenkinsci/jnlp-slave |
| Agent.ImageTag  | Jenkings build agent image tag| 2.52 |
| Agent.Memory  | Jenkins build agent | |
| GitHub.Admins  | Comma-separated list of GitHub IDs for the users that should be able to access Jenkins as an administrator. For a description of the other parameters, see the community Jenkins chart from which they are inherited. |                            <GITHUB_ADMINS> |
| GitHub.App.Id  | Client ID created earlier. | <CLIENT_ID> |
| GitHub.App.Secret  | Client secret created earlier. | <CLIENT_SECRET> |
| GitHub.Name  | GitHub label |GitHub |
| GitHub.OAuth.Token  | Personal access token created earlier. | <GITHUB_OAUTH_TOKEN> |
| GitHub.OAuth.User  | GitHub ID of the user associated with the personal access token. | <GITHUB_OAUTH_USER> |
| GitHub.Orgs  | Comma-separated list of GitHub organizations that Jenkins should build from. | <Your Orgs> |
| GitHub.RepoPattern  | A regular expression that matches the repositories in the organizations that should be built by Jenkins. .* will build all repositories. | <Your repo regex> |
| GitHub.Url  | URL of the GitHub or GitHub Enterprise to build from. | <Your github url>  |
| Master.Component  | Jenkins master component name | jenkins-master |
| Master.ContainerPort  | Jenkins master ContainerPort | 8080 |
| Master.Cpu  | Jenkins master cpu | 200m |
| Master.CustomConfigMap | Advanced configuration - reference offical jenkins chart at https://github.com/kubernetes/charts/tree/master/stable/jenkins | false |
| Master.HostName | External hostame for Ingress | |
| Master.Image  | Jenkins master docker image  | ibmcom/mb-jenkins |
| Master.ImagePullPolicy  | Jenkins master docker image pull policy | Always |
| Master.ImagePullSecret  | Jenkins master docker image pull secret, nil means do not use a pull secret. | nil |
| Master.ImagePullSecret.Name  | Jenkins master docker image pull secret name. This must match the name used in pre-req step 5. | <KUBE_SECRET> |
| Master.ImageTag  | Jenkins master docker image tag | 1.0.0 |
| Master.JavaOpts  | java options used when staring Jenkins master | -Xmx512m -Dfile.encoding=UTF-8 -Dhudson.security.ArtifactsPermission=true |
| Master.Memory  | Jenkins master memory | 256Mi |
| Master.Name  | Name of the Jenkins master | jenkins-master |
| Master.NodePort  | Port to be exposed on all nodes in the cluster for external access | 31000 |
| Master.ServicePort  | Master service port | 8080 |
| Master.ServiceType  | Master service type | NodePort |
| Master.SlaveListenerPort  | Master slave listener service port | 50000 |
| Persistence.AccessMode  | If persistence is enabled, this is the access mode used | ReadWriteOnce |
| Persistence.Enabled | If set to true, an existing persistent volume claim can be used by specifying a value in Persistence.ExistingClaim or by specifying a Persistence.StorageClass value | false |
| Persistence.ExistingClaim | Name of an existing persistent volume claim | nil |
| Persistence.StorageClass | Name of a storageClass to be used to dynamically provision a persistent volume | nil |
| Persistence.Size  | Size of volume | 8Gi |
| Pipeline.Build | Build step for all pipelines that are built by this Jenkins. | true |
| Pipeline.ChartFolder  | Folder containing the Helm chart source for this repository. | chart |
| Pipeline.Debug | Setting this to 'true' will prevent temporary namespaces from being deleted after tests are run against them. | false |
| Pipeline.Deploy | Deploy step for all pipelines built by this Jenkins. | true |
| Pipeline.DeployBranch  | Each pipeline's Deploy step executes only when commits are made to a particular branch. This setting defines the default branch for all pipelines. The default value is master. It may be overridden for a particular repository by setting the deployBranch property in the JenkinsFile. | master |
| Pipeline.ManifestFolder  | We recommend that repositories not use this, and instead use Helm charts to deploy their microservices. This setting is carried over from version 1, in which configuration was stored in kubernetes.yaml in the folder pointed to by this setting. Default = 'manifests'.| manifests |
| Pipeline.Registry.Secret  | The name of the Kubernetes secret to be used for registry access. | admin.registrykey |
| Pipeline.Registry.Url  | The URL of the Docker registry for this pipeline.| mycluster:8500/default |
| Pipeline.TargetNamespace  | The Kubernetes namespace to use for this pipeline |  |
| Pipeline.Template.RepositoryUrl  | The location of the Git repository from which the microserviceBuilderPipeline.groovy library is obtained. | https://github.com/WASdev/microservicebuilder.lib.git |
| Pipeline.Template.Version  | Version of the groovy library |  1.0.0 |
| Pipeline.Test | Setting this to true enables testing in the pipeline. | true |
| Pipeline.LibertyLicenseJar.BaseUrl | Optionally defines the location of a license upgrade JAR file |  |
| Pipeline.LibertyLicenseJar.Name |  Appended to BaseUrl - can be overridden by libertyLicenseJarName in Jenkinsfile | wlp-core-license.jar |
| Pipeline.MirrorOf | The ID of the Maven repository for which the mirror given by `MirrorUrl` should be used e.g. `central` for Maven Central or `*` for all repositories | _central_ |
| Pipeline.MirrorUrl | Optional URL for Maven mirror e.g. http://nexus:8081/repository/maven-central/ | |

In version 2.0.0 of this chart, `Agent.Cpu` had a default value of `200m` and `Agent.Memory` a default of `256Mi`. These defaults were removed because they were found to be too low for some environments, causing semi-random breaks and failures in pipeline builds. Set values higher than these if you find it necessary to set these constraints. 

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

To use a YAML file with overrides, specify `--values <override.yaml>` argument to `helm install'

[Learn more about Micrservice Builder](https://www.ibm.com/support/knowledgecenter/en/SS5PWC/index.html)
