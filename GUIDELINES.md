# The IBM Community charts repository

The IBM Community charts repository is both a Helm repository and a repository for Helm chart source code, intended to host community-developed Helm charts meant for use with IBM Cloud Private. It is hosted in GitHub at the following location:

- Chart source: [https://github.com/IBM/charts/tree/master/community/](https://github.com/IBM/charts/tree/master/community/)
- Helm repository: [https://github.com/IBM/charts/tree/master/repo/community](https://github.com/IBM/charts/tree/master/repo/community)

IBM Cloud Private's catalog view displays a set of Helm charts that are available to be deployed by polling a list of Helm repositories. By default, these repositories include the Helm repository that is hosted locally inside the IBM Cloud Private cluster itself, and IBM's chart repository for IBM-developed charts, at [https://raw.githubusercontent.com/IBM/charts/master/repo/stable/](https://raw.githubusercontent.com/IBM/charts/master/repo/stable/).

As of IBM Cloud Private 3.1.1, the IBM Community charts repository is also displayed in the catalog by default.  If you are using and older version of ICP, users can manually add the repository to their catalog view by navigating to **Manage &gt; Helm Repositories** in the IBM Cloud Private user interface, and adding [https://raw.githubusercontent.com/IBM/charts/master/repo/community/](https://raw.githubusercontent.com/IBM/charts/master/repo/community/) to the list.

&nbsp;

# Developing Helm charts for IBM® Cloud Private

This document is intended to help you develop Helm charts for IBM Cloud Private and contribute them to the IBM Community charts repository.

IBM Cloud Private provides a Kubernetes-based environment for deploying and managing container-based workloads on your own infrastructure. IBM Cloud Private workloads are deployed using [Helm](https://helm.sh/), and all IBM Cloud Private clusters include [Tiller](https://docs.helm.sh/glossary/#tiller). Most Helm charts that can be deployed to other Kubernetes-based environments can be deployed to an IBM Cloud Private cluster unmodified.

The guidance in this document is meant to help you build charts that meet the standards for contributions to the IBM Community charts repository, and to build charts that integrate with the IBM Cloud Private platform to provide additional value to your users when deploying on IBM Cloud Private. Keep in mind that charts developed according to these guidelines will remain compatible with other standard Kubernetes environments, but will provide an enhanced user experience on IBM Cloud Private, similar to the experience you see when deploying charts developed and provided by IBM.

&nbsp;

# Verifying Developed Charts
IBM provides trial and Community Edition-based offerings for IBM Cloud Private in case you do not have access to the paid version. Links to information regarding these offerings is available from [the "Getting Started" section in the README.md.](https://github.com/IBM/charts/blob/master/README.md#getting-started) 

&nbsp;

# Contributing to the IBM Community charts repository

Rules for contributing to the IBM Community charts repository are covered in [CONTRIBUTING.md](https://github.com/IBM/charts/blob/master/CONTRIBUTING.md), which is hosted in the GitHub repository itself.

All contributions must include both chart source and a packaged Helm chart. Chart source must be added to the `charts/community` directory, and packaged chart `.tgz` files must be added to the Helm repository directory, `charts/repo/community`

Additionally, the contribution guidelines specify that all contributed Helm charts must be licensed under the Apache 2.0 License, and that all contributions must include a developer sign-off that certifies your right to contribute the code to this community, according to the [Developer Certificate of Origin](https://developercertificate.org/).

&nbsp;

# Standards and Guidelines for chart contributions

The tables below should be used as a readiness guide for anyone preparing to deliver a Helm chart to the `https://github.com/ibm/charts/community` directory. [**Table 1**](#table-1-required-for-all-charts-contributed-to-httpsgithubcomibmcharts) contains a short list of required standards for all charts contributed to the IBM Community charts repository. [**Table 2**](#table-2-recommendations-for-an-improved-user-experience-on-ibm-cloud-private) contains a guidance on how to build charts that further integrate with the platform, and provide a high-quality, consistent user experience on IBM Cloud Private. The guidelines in Table 2 are recommended, but not required. Each item in the chart provides a link to more details on implementation, farther down this page.

These guidelines are intended to augment the [Helm best practices](https://docs.helm.sh/chart_best_practices/) and not intended to replace those. If there is no guidance listed below, then it is best to refer to the Helm community best practices.

### Table 1: Required for all charts contributed to https://github.com/ibm/charts

| **Requirement** | **Description** |
| --- | --- |
| ***Security***| This section of the table contains security related requirements.|
| [**Image vulnerabilities**](#image-vulnerabilities) | All images used in the product need to be scanned by the IBM Cloud Private Vulnerability Advisor and vulnerable packages fixed.  You also need to have a process in place to address image vulnerabilities as they arise. |
| [**Document and follow principle of runtime least privilege**](#document-and-follow-principle-of-runtime-least-privilege) | Workloads must run with the least privilege required and clearly publish the required privileges in the chart README. |
| [**Secure sensitive data**](#secure-sensitive-data) | Sensitive data required to deploy the chart must be properly secured. |
| [**Clearly document required user install privileges**](#clearly-document-required-user-install-privileges) | If special IBM Cloud Private user privileges such as `cluster administrator` or `team administrator` are required to install the Helm chart, clearly document them in the chart README. |
| ***Integration***| This section of the table contains integration related requirements.|
| [**Helm lint**](#helm-lint) | The chart must pass the `helm lint` verification tool with no errors. |
| [**IBM Helm chart best practices**](#ibm-helm-chart-best-practices)| Follow the IBM prescribed best practices for Helm chart style and behavior. |
| [**Directory structure**](#directory-structure) | Chart source must be added to the `charts/community` directory. Chart archives, packaged as a `.tgz` file using `helm package` must be added to the `charts/repo/community` directory, which is a Helm repository. *Do not update index.yaml with your contribution*. index.yaml is automatically updated by a build process.|
| [**Chart file structure**](#chart-file-structure) | Charts must follow the standard Helm file structure: Chart.yaml, values.yaml, README.md, templates, and templates/NOTES.txt must all exist and have useful contents |
| [**Chart name**](#chart-name) | Helm chart names must follow the [Helm chart best practices](https://github.com/kubernetes/helm/blob/master/docs/chart_best_practices/conventions.md#chart-names). The chart name must be the same as the directory that contains the chart. Chart contributed by a company or organization may be prefixed with the company or organization name. Only charts contributed by IBM may be prefixed with ibm- |
| [**Chart version**](#chart-version) | SemVer2 numbering must be used, as per [Helm chart best practices](https://github.com/kubernetes/helm/blob/master/docs/chart_best_practices/conventions.md#version-numbers), and any update to a chart must include an updated version number, unless the changes are to the README file only.|
| [**Chart description**](#chart-description) | All contributed charts must have a chart description in chart.yaml. This will be displayed in the ICP catalog and should be meaningful. |
| [**Required chart keywords**](#required-chart-keywords) | Chart keywords are used by the IBM Cloud Private user interface, some of which are critical to the user interface's function. |
| [**tillerVersion constraint**](#tillerversion-constraint) | Add a `tillerVersion` to Chart.yaml that follows the Semantic Versioning 2.0.0 format (`>=MAJOR.MINOR.PATCH`); ensure that there is no additional metadata attached to this version number. Set this constraint to the lowest version of Helm that this chart has been verified to work on. |
| [**License**](#license) | The chart itself be Apache 2.0 licensed, and must contain the Apache 2.0 license in the LICENSE file at the root of the chart. The chart may also package additional license files, such as the license for the product being deployed, in the LICENSES directory. Both the LICENSE file and files in the LICENSES directory will be displayed to the user for agreement when deploying through the IBM Cloud Private user interface.|
| [**README.md**](#readmemd) | In the IBM Cloud Private GUI, when a user clicks on a tile corresponding to a chart in the catalog, the README.md for that chart is used to generate the chart's front page. Given the important role that the README.md plays in ICP's user experience, all contributed charts must contain a README.md file, and it must provide all of the information needed for users to understand how to configure, deploy, and otherwise use a chart. Mandatory information includes complete descriptions of all input parameters as well as sections for [image security](#image-security), [pod security](#pod-security) and a [support statement](#support-statement). |
| [**NOTES.txt**](#notestxt) | Include NOTES.txt with instructions to display usage notes, next steps, &amp; relevant information. |
| [**values-metadata.yaml**](#values-metadatayaml) | YAML file that provides formatting and validation data for each entry in `values.yaml` to the IBM Cloud Private web interface. |
| [**ibm_cloud_pak directory**](#ibm_cloud_pak-directory) | Your helm chart must include a new subdirectory `ibm_cloud_pak` which includes additional files containing a manifest and security prereqs. |
| [**ibm_cloud_pak/manifest.yaml**](#ibm_cloud_pakmanifestyaml) | YAML file describing the full contents of the Helm chart and allows automated creation of an offline install package for air-gapped clusters. |
| [**ibm_cloud_pak/qualification.yaml**](#ibm_cloud_pakqualificationyaml) | YAML file describing the security prereqs for the helm chart. |
| [**Metering**](#metering-integration) | Charts should include metering annotations so that users can meter usage with the IBM Cloud Private metering service. |
| ***Life cycle***| This section of the table contains life cycle related requirements.|
| [**Compatible with latest ICP**](#compatible-with-latest-icp) | Charts must be tested for compatibility with the latest releases of ICP within 60 days of general availability. |
| [**Avoid hard-coded version constraints**](#avoid-hard-coded-version-constraints) | Avoid setting kubeVersion of tillerVersion to a single specific version.  Instead allow for a particular version or greater. |
| [**Liveness and Readiness probes**](#liveness-and-readiness-probes) | Workloads should enable monitoring of their own health using livenessProbes and readinessProbes. |

&nbsp;

&nbsp;

### Table 2: Recommendations for an improved user experience on IBM Cloud Private

The following table contains guidance from IBM on how to build workloads that provide a full-featured and consistent user experience on IBM Cloud Private. Unlike the standards above, charts in the IBM Community charts repository are not required to implement these items. Chart developers should consider the items below best practices, and use them as appropriate to provide deeper integration with IBM Cloud Private and enhance the user experience. Some recommendations may not be applicable to all workload types.

| **Guideline** | **Description** |
| --- | --- |
| [Shared Configurable Helpers (SCH)](#shared-configurable-helpers-sch) | Make use of these helper templates to more easily incorporate IBM's required and recommended chart development practices. |
| [Chart icon](#chart-icon) | Providing a URL to an icon is preferred to embedding a local icon in the chart, to avoid chart size limits when using nested charts. |
| [Recommended Chart keywords](#recommended-chart-keywords) | In addition to the required keywords described in the previous section, optional keywords can be used to filter your chart into a set of categories recognized by the UI. |
| [Chart version / image version](#chart-version--image-version) | Workloads should maintain image versions/tags separately from chart versions. |
| [Images](#images) | Image URL should be parameterized, version of image(s) to be deployed should be exposed w/ the latest version as default, reference publicly available images by default when possible. |
| [Multi-platform support](#multi-platform-support) | IBM Cloud Private supports x86-64, Power, and z hardware architectures. Workloads can reach the largest possible audience by providing images for all three platforms and using a fat manifest. |
| [Init container definitions](#init-container-definitions) | If using [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/), use `spec` syntax vs `annotations` to describe them. These annotations are deprecated in Kubernetes 1.6 and 1.7, and are no longer supported in Kubernetes 1.8. |
| [Node affinity](#node-affinity) | IBM suggests using `nodeAffinity` to ensure workloads are scheduled on a valid platform in a heterogeneous cluster |
| [Persistent volumes](#persistent-volumes) | Do not create persistent volumes in a chart, as allocation is environment-specific and may require permissions the chart deployer doesn't have. A chart should contain a Persistent Volume Claim if persistent storage is required. |
| [Document Resource Usage](#document-resource-usage) | Charts should be clear about the resources they will consume, documented in the chart's `README.md` |
| [Logging integration](#logging-integration) | Workload containers should write logs to stdout and stderr, so they can be automatically consumed by the IBM Cloud Private logging service (Elasticsearch/Logstash/Kibana.) Workloads are also encouraged to include provide links to relevant Kibana dashboards in README.md, so that users can download them and import them to Kibana. |
| [Monitoring integration](#monitoring-integration) | Workloads should integrate with the default IBM Cloud Private monitoring service (Prometheus/Grafana), by exposing Prometheus metrics through a Kubernetes `Service` and annotating that endpoint so that it will be automatically consumed by the IBM Cloud Private monitoring service. |
| [License keys and pricing](#license-keys-and-pricing) | If your chart requires a license key to deploy or to otherwise use the workload, this should be stated in the Prerequisites section of the chart's README.md. |

# Detailed guidance

-------------------------------------

# Chart requirements

This section contains a list of standards that must be followed by all charts contributed to the IBM Community charts, as outlined in [GUIDELINES.md](https://github.com/IBM/charts/blob/master/GUIDELINES.md). Charts are expected to adhere to the published [Helm best practices](https://docs.helm.sh/chart_best_practices/) from the Helm community, which are not recreated here.

# Security

## Image vulnerabilities

All images used in the product need to be scanned by the IBM Cloud Private Vulnerability Advisor and vulnerable packages must be fixed.  In addition, you must have a process in place to address new image vulnerabilities over time.  The documentation for Vulnerability Advisor can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_cluster/vuln_advisor.html).

## Document and follow principle of runtime least privilege

Workloads must run with the least container privileges required and should avoid using escalated security privileges for containers whenever possible. When escalated privileges are required, charts must request the minimum level of privileges needed to achieve the desired functionality. IBM recommends avoiding the use of `privileged: true` or `capabilities: add: ["ALL"]` in your `securityContext`. If some elevated privileges are required, IBM recommends only adding the minimum set of privileges that are required to implement the desired functionality.

Workloads must also clearly publish the required privileges in the chart README.  As of version 3.1.1, ICP supports pod security policies for pod isolation.  Your chart must declare the pod security policy with the least privileges required to support the workload.  More information can be found in the Knowledge Center for [pod isolation](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/user_management/iso_pod.html).  A set of [pre-defined pod security policies](https://github.com/IBM/cloud-pak/tree/master/spec/security/psp) for helm charts are created in ICP by default.  Even if the workload uses a pod security policy per-defined by ICP, the README must still clearly indicate which privileges are required.

## Secure sensitive data

Helm chart values provided at install time as well as secrets created in the chart are not secured by Tiller as sensitive data can be exposed from the Helm release manifest.  Therefore sensitive information that cannot be changed after the deployment must be provided by the user as a secret they pre-create.  The secret name is then provided as a parameter to the helm release.  

## Clearly document required user install privileges

If special IBM Cloud Private user privileges/roles such as `cluster administrator` or `team administrator` are required to install the Helm chart, clearly document them in the chart README.

# Integration

## Helm lint

All charts must pass the `helm lint` verification tool with no errors.

## IBM Helm chart best practices

Similar to the Helm CLI linter, IBM has created a linter specifically for community helm charts.  There are three levels of messages produced by the linter:  

`Information`: Style or cosmetic recommendations; not required for certification.

`Warning`: These will not prevent successful deployment but may yield inconsistencies on the platform.  Strongly recommended to address but not strictly required for certification.

`Error`: Error level checks are must-fix for certification.

The linter is run by IBM against the chart in the pull request and then output is provided as a comment.

The rules and descriptions for the content linter can be found here:
[Lint rules](community-lint-rules.md)

## Directory structure

Chart source should be added to the charts/community directory. Chart archives, packaged as a .tgz file using helm package should be added to the charts/repo/community directory, which is a Helm repository.

**Do not update** `charts/repo/community/index.yaml` **with your contribution.** `index.yaml` **is automatically updated by a build process when pull requests are processed.**

## Chart file structure

Charts should follow the standard Helm file structure: Chart.yaml, values.yaml, README.md, templates, and templates/NOTES.txt should all exist and have useful contents.

## Chart name

Helm chart names should follow the [Helm chart best practices](https://github.com/kubernetes/helm/blob/master/docs/chart_best_practices/conventions.md#chart-names). The chart name must be the same as the directory that contains the chart source. Charts contributed by a company or organization may be prefixed with the company or organization name. Contributions from the community must **not** be prefixed with &quot;ibm-&quot;.

## Chart version

SemVer2 numbering should be used, as per [Helm chart best practices](https://github.com/kubernetes/helm/blob/master/docs/chart_best_practices/conventions.md#version-numbers).

## Chart description

All charts must have a chart description in chart.yaml. This will be displayed in the ICP catalog UI and should be meaningful to end users.

## Required chart keywords

Chart keywords are used by the IBM Cloud Private user interface for categorization and filtering of charts, and some of these keywords are critical to grant a chart the proper visibility in the catalog. The Chart.yaml must include at least one of these cloud platform keywords and at least one of these architecture keywords to be accepted into this repository:

Cloud Platform Keywords:  
- `ICP` - indicates that the chart is supported for use on IBM Cloud Private  
- `IKS` - indicates that the chart is supported for use on IBM Cloud Kubernetes Service  

Architecture Keywords:  
- `s390x`  
- `ppc64le`  
- `amd64`  

As a supplement to the required keywords, the list of optional keywords offered in [the section on recommended chart keywords](#recommended-chart-keywords) can be leveraged to provide the chart with additional categorization and catalog visibility.

## tillerVersion constraint

Add a tillerVersion to Chart.yaml that follows the Semantic Versioning 2.0.0 format (\&gt;>=MAJOR.MINOR.PATCH); ensure that there is no additional metadata attached to this version number. Set this constraint to the lowest version of Helm that this chart has been verified to work on.

## License

The chart itself be Apache 2.0 licensed, and must contain the Apache 2.0 license in the LICENSE file at the root of the chart. The chart may also package additional license files, such as the license for the product being deployed, in the LICENSES directory. Both the LICENSE file and files in the LICENSES directory will be displayed to the user for agreement when deploying through the IBM Cloud Private user interface.  Product licenses provided in the chart must align with the licenses in the Docker images.

## README.md

All contributed charts must contain a useful README.md file with useful information a user would need to deploy the chart. In the IBM Cloud Private GUI, the README.md file is the "front page" that a user will see after clicking on the chart in the catalog. A complete description and explanations of all input parameters are strongly suggested.

### Image security
The README must also indicate which images need to be added to IBM Cloud Private's list of trusted image registries, since [container image security](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_images/image_security.html) is enabled by default beginning with IBM Cloud Private 3.1.

### Pod security
The README must also include a statement on the pod security policy required to deploy the chart. As of ICP 3.1.1, [pod security is enabled by default.](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_cluster/security.html) Charts can reference one of the [pre-defined pod security policies from ICP](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/README.md) or describe a [custom pod security policy](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/user_management/iso_pod.html), if needed. The intent is for users to understand the required security requirements for the chart.

### Support statement

The README.md must include a section labeled `Support`.  This section should provide details and/or links to where users can get support for urgent issues with the product, get help, or submit issues.

## NOTES.txt

All charts must include NOTES.txt with instructions to display usage notes, next steps, &amp; relevant information. NOTES.txt is displayed by the IBM Cloud Private user interface after deployment.

## values-metadata.yaml

IBM Cloud Private supports defining metadata for fields containing immutable or hidden fields, rendering booleans as check boxes, specifying allowed values, etc. to provide a rich deployment experience in the IBM Cloud Private GUI. This metadata is defined within a chart by using a file named `values-metadata.yaml`.  You must provide metadata in values-metadata.yaml for each parameter in values.yaml.  Detailed information of the format and syntax can be found in the IBM Cloud Private [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/app_center/values_metadata.html) For an example of how to use this file, refer to the [sample chart in this repository](https://github.com/IBM/charts/blob/master/community/sample-chart/values-metadata.yaml) or the many [IBM-provided charts in the repository](https://github.com/IBM/charts/tree/master/stable)

## `ibm_cloud_pak` directory

Your helm chart must include a new subdirectory `ibm_cloud_pak` which includes additional files.  The `manifest.yaml` describes the helm chart contents (charts and images) while the `qualification.yaml` specifies the security pre-reqs for the helm chart.

## ibm_cloud_pak/manifest.yaml

IBM Cloud Private clusters are typically in an air-gapped environment with no access to the public internet.  When installing charts that point to a public image registry like Docker Hub, the chart pods will fail to pull the images.  To help alleviate this, IBM Cloud Private provides a local image registry as well as a local chart repository as well as tooling for building and installing binary packages in an air-gapped environment.

IBM Cloud Private provides tooling to [build offline binary packages](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_cluster/cli_catalog_commands.html#create-archive).  The tool reads a YAML manifest file in the helm chart and creates the binary package from the specified contents.  Helm charts must provide a such a manifest.yaml file for users to easily create offline binary packages in a consistent manner across products.  The manifest format can be found here: [manifest format](../spec/packaging/ibm_cloud_pak/manifest-yaml.md)

IBM Cloud Private also supports [importing binary packages that contain all the components (charts and images) required to deploy a product](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_cluster/cli_catalog_commands.html#load-archive).  The contents of the binary package are then stored in the local image registry / local chart repository and the charts can then be deployed without access to the public internet.

Helm charts must provide a valid manifest.yaml file and test that the ICP tooling can build the binary offline package, that the package can be installed in ICP and that the product can be deployed from that installed package.

## ibm_cloud_pak/qualification.yaml

The qualification YAML file is simply a statement of the details of the security pre-reqs for the helm chart. Add the following file, and update `name` fields for the `podSecurityPolicy` and ICP `installerRole`.

The qualification format can be found here: [qualification format](../spec/packaging/ibm_cloud_pak/qualification-yaml.md)

Example:
```
qualification:
  levelName: ""
  levelDescription: ""
  issueDate: ""
  duration: ""
  terms: ""
prereqs:
  security:
    kubernetes:
      podSecurityPolicy:
        name: "ibm-restricted-psp"
    ibmCloudPrivate:
      installerRole:
        name: "Operator"
```

## Metering integration

The IBM Cloud Private metering service collects usage information for containers running on IBM Cloud Private based on virtual processor cores available, capped, and/or utilized by the containerized components that make up the running workload.

Virtual core information is automatically collected by a metering daemon running in the IBM Cloud Private cluster. Workloads should identify themselves to this daemon so that the appropriate metrics can be gathered and attributed to the running offering.

The metadata is used to associate metrics gathered for metering purposes with the offering deployed. The metering service simply measures metrics for the running offering, and provides historical usage data to the user through the UI and as downloadable CSV-formatted data.

Workloads should specify their product ID, product name and product version for the meter reader using metadata annotations on the pods. This is defined in the spec template section of the helm chart for a specific deployment.

 - A Product Name (`productName`) is the human-readable name for the offering
 - A Product Identifier (`productID`) uniquely identifies the offering (please namespace with your company or organization name to ensure uniqueness)
 - A Product version identifier (`productVersion`) specifies the version of the offering

```
    kind: Deployment
    spec:
      template:
         metadata:
           annotations:
              productName: IBM Sample Chart
              productID: com.ibm.chartscommunity.samplechart.0.1.2
              productVersion: 0.1.2
```

# Lifecycle

## Compatible with latest ICP

Before creating a pull request to add a chart to the IBM Community charts repository, chart owners must verify that the chart deploys as expected on the latest version of IBM Cloud Private, using both the IBM Cloud Private user interface and the Helm command line.  Keep in mind ICP environments are typically air-gapped, without access to the public internet.  Any configurations supported by the command line install of the helm chart must also be supported via the UI installation.  In addition, if there are any versions of IBM Cloud Private known to not work with the chart, those details should be clearly specified in the README.md under a section such as `Limitations`.  For example: `This chart is only supported on IBM Cloud Private version 3.1.0 and above.`  
For a list of the available trial and Community Edition-based offerings, refer to [the "Getting Started" section in the README.md.](https://github.com/IBM/charts/blob/master/README.md#getting-started)

In an on-going basis, charts must be tested for compatibility with the latest releases of ICP within 60 days of general availability.  The expectation is that the helm chart will work on all future version of ICP, without skipping versions.

## Avoid hard-coded version constraints

Avoid setting kubeVersion of tillerVersion to a single specific version in both `Chart.yaml` as well as in Helm template files.  The intent is to make sure the helm chart continues to work on future versions of ICP without modification.  Instead of setting a specific version, allow for a particular version or greater:
```
tillerVersion: ">=2.5.0"
```

## Liveness and readiness probes

Workloads should enable monitoring of their own health using livenessProbes and readinessProbes.

&nbsp;

# Recommended chart features

This section contains a list of suggestions that will provide your end users with added value on IBM Cloud Private, by taking advantage of the features and services provided by the platform. They are not required for contributions to the IBM Community charts repository, but implementing them is strongly recommended, as they will provide an enhanced experience similar to that provided in charts developed by IBM.

## Shared Configurable Helpers (SCH)

IBM now officially provides the Helm template helpers used for its content standardization practices for inclusion in your charts. More information on how teams can take advantage of these helpers can be found on [SCH's README in the IBM/charts repo.](https://github.com/IBM/charts/tree/master/samples/ibm-sch)

## Chart icon

Helm charts should specify a link to an icon using the `icon` attribute in `Chart.yaml`. A default icon will be shown in the catalog UI for any chart that does not include an icon reference.
Including a link to an icon on the public internet is preferred, rather than including an icon file directly in your chart, to keep chart files small. Helm charts have a maximum size of 1MB, and while your individual chart may not approach that limit, users may build a chart that includes your chart as a subchart, so external links are the preferred approach.
If the icon is an `.svg` hosted on GitHub file, append `?sanitize=true` to the end of the URL for proper rendering in the ICP UI. For example:

```
icon: https://raw.githubusercontent.com/ot4i/ace-helm/master/appconnect_enterprise_logo.svg?sanitize=true
```

## Recommended chart keywords

In addition to the previously mentioned [required keywords](#required-chart-keywords), the following category and classification keywords should be included in the Chart.yaml's keywords where applicable to grant the chart additional visibility in the IBM Cloud Private catalog UI.

| **Category Label:** | **keywords** |
| --- | --- |
| AI & Watson: | `Watson, AI` |
| Blockchain: | `blockchain` |
| Business Automation: | `businessrules`, `Automation` |
| Data: | `database` |
| Data Science & Analytics: | `Data Science`, `Analytics` |
| DevOps: | `DevOps`, `deploy`, `Development`, `IDE`, `Pipeline`, `ci`, `build` |
| IoT: | `IoT` |
| Operations: | `Operations` |
| Integration: | `Integration`, `message queue` |
| Network: | `Network` |
| Runtimes & Frameworks: | `runtime`, `framework` |
| Storage: | `Storage` |
| Security: | `Security` |
| Tools: | `Tools` |

| **Classification Label:** | **keywords** |
| --- | --- |
| Beta | `Beta` |
| Commercial Use | `Commercial` |
| Limited Use | `Limited` |
| Open Source | `OpenSource` |
| Tech Preview | `Tech` |

## Chart version / image version

Workloads should maintain image versions/tags separately from chart versions.

## Images

Image URL should be a parameterized reference to values.yaml, and the version of the image(s) to be deployed should be exposed w/ the latest version as default, reference publicly available images by default.

## Multi-platform support

IBM Cloud Private supports x86-64, ppc64le, and z (s390) hardware architectures. Workloads can reach the largest possible audience by providing images for all three platforms and using a fat manifest.

For more information on developing images for the ppc64le platform refer to the [IBM Cloud Private on Power](https://developer.ibm.com/linuxonpower/ibm-cloud-private-on-power/) and [Docker on IBM Power Systems](https://developer.ibm.com/linuxonpower/docker-on-power/) sites on [developer.ibm.com](https://developer.ibm.com)

For more information on developing images for the z platform refer to  [the IBM Knowledge Center for Linux on IBM Systems](https://www.ibm.com/support/knowledgecenter/en/linuxonibm/com.ibm.linux.z.ldvd/ldvd_c_docker_image.html)

### Fat manifests

An individual container image contains binaries that have been compiled for a specific architecture. Using the concept known as a ‘fat manifest’, you can build a manifest list that makes it possible to serve multiple architectures from a single image reference. When the Docker daemon accesses such an image, it will automatically redirect to the image which matches the currently running platform architecture.

To use this capability, a Docker image must be pushed to the registry for each architecture, followed by the fat manifest.

### Deploying a fat manifest

The recommended method of deploying a fat manifest is to use docker tooling, namely the manifest sub-command. It is still currently in the PR review process, but can be easily used to create a multi-arch image and push it to any docker registry.

The docker-cli tool can be downloaded for various platforms here: [https://github.com/clnperez/cli/releases/tag/v0.1](https://github.com/clnperez/cli/releases/tag/v0.1)

For example, to build a fat manifest for the `web-terminal` component using the following image names:

 - `mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1` - name of the multi-arch image
 - `mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1-x86_64` - name of the x86_64 image
 - `mycluster.icp:8500/default/ibmcom//web-terminal:2.8.1-ppc64le` - name of the Power image
 - `mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1-s390` - name of the Z image

```
./docker-linux-amd64 manifest create mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1 mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1-86_64 mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1-ppc64le mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1-s390x
./docker-linux-amd64 manifest annotate mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1 mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1-x86_64 --os linux --arch amd64
./docker-linux-amd64 manifest annotate mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1 mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1-ppc64le --os linux --arch ppc64le
./docker-linux-amd64 manifest annotate mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1 mycluster.icp:8500/default/s390x/web-terminal:2.8.1-s390x --os linux --arch s390x
./docker-linux-amd64 manifest inspect mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1
./docker-linux-amd64 manifest push mycluster.icp:8500/default/ibmcom/web-terminal:2.8.1
```

**Note:** Pushing a multi-arch image to a registry does not push the image layers. It only pushes a list of pointers to accessible images. This is why it is better to think of a multi-arch image as what it really is: a manifest list.  In addition, when creating the fat manifest you must make sure all your platform specific docker images have been pre-imported into the registry otherwise you will get an error saying `cannot use source images from a different registry than the target image: docker.io != mycluster.icp:8500`.

After you have pushed your manifest list to a registry, you use it just as you would have previously used an image name.

**Note:** If you want to keep your local copy of the manifest list, remove the –purge flag. It is recommended to use it because if left, `manifest inspect` will return the local copy and not the registry copy, which could be confusing.

## Init container definitions

[init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) can be useful for a variety of reasons, including packaging utilities that you may not want to package with an application container, or for including startup ordering logic for workloads where all containers should not be started in parallel.

If using init containers, use the `spec` syntax instead of `annotations` to describe them, as described in the kubernetes documentation. The annotations are deprecated in Kubernetes 1.6 and 1.7, and are no longer supported in Kubernetes 1.8.

## Node affinity

IBM suggests using [nodeAffinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#node-affinity-beta-feature) to schedule chart installation on a valid platform.

Node affinity provides the ability to constrain which nodes a pod will run on, based on their architecture. In a heterogeneous cluster, a user can choose if they want a particular workload to run only on nodes with a particular hardware architecture.

IBM suggests adding an `arch` parameter to `values.yaml` and referring to that parameter to set `nodeAffinity` for your pods as shown in the [ibm-odm-dev](https://github.com/IBM/charts/blob/master/stable/ibm-odm-dev/templates/deployment.yaml) chart, for example.

## Persistent volumes

IBM does not recommend creating persistent volumes in a chart, as allocation is environment-specific and may require permissions the chart deployer doesn't have. A chart should contain a Persistent Volume Claim, as described in the [kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#writing-portable-configuration) if persistent storage is required.

Any required persistent volumes or storage classes that an administrator must pre-create for deployment should be clearly documented in README.md.

## Document resource usage

Charts should clearly document the minimum CPU, memory, and storage resources they require, and the amount of CPU, memory, and storage that they request by default in README.md.

## Logging integration

IBM Cloud Private nodes are instrumented to automatically gather log data written to the stdout and stderr streams and forward it to the integrated logging service (Elasticsearch/Logstash/Kibana.)

Workload containers should write log data to stdout and stderr, rather than discrete log files, so they can be automatically consumed by the IBM Cloud Private logging service.  Workloads are also encouraged to include provide links to relevant Kibana dashboards in README.md, so that users can download them and import them to Kibana.

## Monitoring integration

Workloads should integrate with the default IBM Cloud Private monitoring service (Prometheus/Grafana), by exposing Prometheus metrics through a Kubernetes `Service` and annotating that endpoint so that it will be automatically consumed by the IBM Cloud Private monitoring service. IBM recommends integrating with the platform's monitoring service, rather than packaging your own instances of Prometheus or Grafana. This enables users to get all data from a central instance, and reduces overhead.

To expose your Prometheus endpoint to the IBM Cloud Private monitoring service, use the annotation `prometheus.io/scrape: 'true'` as shown in the example below.

```
    apiVersion: v1
    kind: Service
    metadata:
      annotations:
        prometheus.io/scrape: 'true'
      labels:
        app: {{ template "fullname" . }}
      name: {{ template "fullname" . }}-metrics
    spec:
      ports:
      - name: {{ .Values.service.name }}-metrics
        targetPort: 9157
        port: 9157
        protocol: TCP
      selector:
        app: {{ template "fullname" . }}
      type: ClusterIP
```

Individual metric names should be prefixed with the name of the workload, (e.g., `ibmmq_object_mqput_bytes`).

## License keys and pricing  
If your chart requires a license key to deploy or to otherwise use the workload, this should be stated in the Prerequisites section of the chart's README.md. Additionally, instructions on how to acquire keys and information on pricing and trials should also be included or linked to alongside this statement so that users can readily and easily obtain the keys needed to install the chart and use the workload.  
