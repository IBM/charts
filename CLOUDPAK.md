# IBM Cloud Pak

## What is an IBM Cloud Pak?

IBM Cloud Paks provide enterprise software container images that are pre-packaged in production-ready configurations that can be quickly and easily deployed to IBM’s container platforms, with support for resiliency, scalability, and integration with core platform services, like monitoring or identity management.  Read the white paper that introduces [IBM Cloud Paks](http://ibm.biz/IBMCloudPaks-Whitepaper) and read why enterprises need [more than just Helm charts](https://www.ibm.com/cloud/private/why-containers).

## How do I make my Helm chart an IBM Cloud Pak?

The process is very similar to contributing your Helm chart to the IBM community repo with some additional requirements to follow and a few new files to include in your chart.  You can find out more about both in the IBM Cloud Private [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/app_center/cloud_paks_over.html).

## IBM Cloud Pak requirements

In addition to the [minimum guidelines to be added to the community](GUIDELINES.md) repo, this section describes the requirements to be labeled an `IBM Cloud Pak`

### Table 1: Required for `IBM Cloud Pak` status

| **Requirement** | **Description** |
| --- | --- |
| ***Security***| This section of the table contains security related requirements.|
| [**Image vulnerabilities**](#image-vulnerabilities) | All images used in the product need to be scanned by the IBM Cloud Private Vulnerability Advisor and vulnerable packages fixed.  You also need to have a process in place to address image vulnerabilities as they arise. |
| [**Document and follow principle of runtime least privilege**](#runtime-least-privilege) | Workloads must run with the least privilege required and clearly publish the required privileges in the chart README. |
| [**Clearly document required ICP user install privileges**](#document-install-privileges) | If special IBM Cloud Private user privileges such as `cluster administrator` or `team administrator` are required to install the Helm chart, clearly document them in the chart README. |
| [**Secure sensitive data**](#secure-sensitive-data) | Sensitive data required to deploy the chart must be properly secured. |
| ***Integration***| This section of the table contains integration related requirements.|
| [**Follow IBM community guidelines**](GUIDELINES.md) | Follow all of the required guidelines for contributing any helm chart to the IBM community repo (the optional guidelines are also optional for IBM Cloud Pak unless otherwise specified in this Cloud Pak guidance.) |
| [**IBM Helm chart best practices**](#ibm-helm-chart-best-practices)| Follow the IBM prescribed best practices for Helm chart style and behavior. |
| [**values-metadata.yaml**](#values-metadatayaml) | YAML file that provides formatting and validation data for each entry in `values.yaml` to the IBM Cloud Private web interface. |
| [**ibm_cloud_pak directory**](#ibm_cloud_pak-directory) | Your helm chart must include a new subdirectory `ibm_cloud_pak` which contains additional files specific to IBM Cloud Paks. |
| [**ibm_cloud_pak/manifest.yaml**](#ibm_cloud_pakmanifestyaml) | YAML file describing the full contents of the Helm chart and allows automated creation of an offline install package for air-gapped clusters. |
| [**ibm_cloud_pak/qualification.yaml**](#ibm_cloud_pakqualificationyaml) | YAML file describing the details of IBM Cloud Pak certification level. |
| [**Metering annotations**](#metering-annotations) | Add metering annotations to your chart for easy integration into IBM Cloud Private metering service or implement custom metering. |
| ***Life cycle***| This section of the table contains life cycle related requirements.|
| [**Compatible with latest ICP**](#compatible-with-latest-icp) | Charts must be tested for compatibility with the latest releases of ICP within 60 days of general availability. |
| [**Avoid hard-coded version constraints**](#avoid-hard-coded-version-constraints) | Avoid setting kubeVersion of tillerVersion to a single specific version.  Instead allow for a particular version or greater. |
| [**Liveness and Readiness probes**](#liveness-and-readiness-probes) | Workloads must enable monitoring of their own health using livenessProbes and readinessProbes. |


# ***Detailed guidance***

# Security

## Image vulnerabilities

All images used in the product need to be scanned by the IBM Cloud Private Vulnerability Advisor and vulnerable packages must be fixed.  In addition, you must have a process in place to address new image vulnerabilities over time.  The documentation for Vulnerability Advisor can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/manage_cluster/vuln_advisor.html).

## Document and follow principle of least privilege

Workloads must run with the least container privileges required.  Workloads must also clearly publish the required privileges in the chart README.  As of version 3.1.1, ICP supports pod security policies for pod isolation.  You chart must declare the pod security policy with the least privileges required to support the workload.  More information can be found in the Knowledge Center for [pod isolation](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/user_management/iso_pod_overview.html).  A set of [pre-defined pod security policies](https://github.com/IBM/cloud-pak/tree/master/spec/security/psp) for Cloud Paks are created in ICP by default.  Even if the workload uses a pod security policy per-defined by ICP, the README must still clearly indicate which privileges are required.

## Clearly document required ICP user install privileges

If special IBM Cloud Private user privileges/roles such as `cluster administrator` or `team administrator` are required to install the Helm chart, clearly document them in the chart README.

## Secure sensitive data

Helm chart values provided at install time as well as secrets created in the chart are not secured by Tiller as sensitive data can be exposed from the Helm release manifest.  Therefore sensitive information that cannot be changed after the deployment must be provided by the user as a secret they pre-create.  The secret name is then provided as a parameter to the helm release.  

# Integration

## Follow IBM community guidelines

Follow all of the [required guidelines](GUIDELINES.md)
 for contributing any helm chart to the IBM community repo (the optional guidelines are also optional for IBM Cloud Pak unless otherwise specified in this Cloud Pak guidance) 

## IBM Helm chart best practices

Similar to the Helm CLI linter, IBM has created a linter specifically for IBM Cloud Pak certification.  There are three levels of messages produced by the linter:  

`Information`: Style or cosmetic recommendations; not required for certification.

`Warning`: These will not prevent successful deployment but may yield inconsistencies on the platform.  Strongly recommended to address but not strictly required for certification.

`Error`: Error level checks are must-fix for certification.

The linter is run by IBM against the chart in the pull request and then output is provided as a comment.

The rules and descriptions for the content linter can be found here:
[Lint rules for IBM Cloud Pak](LINT_RULES.md)

## values-metadata.yaml

IBM Cloud Private supports defining metadata for fields containing immutable or hidden fields, rendering booleans as check boxes, specifying allowed values, etc. to provide a rich deployment experience in the IBM Cloud Private GUI. This metadata is defined within a chart by using a file named `values-metadata.yaml`.  You must provide metadata in values-metadata.yaml for each parameter in values.yaml.  Detailed information of the format and syntax can be found in the IBM Cloud Private [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/app_center/values_metadata.html) For an example of how to use this file, refer to the [sample chart in this repository](https://github.com/IBM/charts/blob/master/community/sample-chart/values-metadata.yaml) or the many [IBM-provided charts in the repository](https://github.com/IBM/charts/tree/master/stable)

## `ibm_cloud_pak` directory

Your helm chart must include a new subdirectory `ibm_cloud_pak` which contains additional files specific to IBM Cloud Paks.  The `manifest.yaml` describes the Cloud Pak contents (charts and images) while the `qualification.yaml` specifies the level and duration of the Cloud Pak status.

## ibm_cloud_pak/manifest.yaml

IBM Cloud Private clusters are typically in an air-gapped environment with no access to the public internet.  When installing charts that point to a public image registry like Docker Hub, the chart pods will fail to pull the images.  To help alleviate this, IBM Cloud Private provides a local image registry as well as a local chart repository as well as tooling for building and installing binary packages in an air-gapped environment.

IBM Cloud Private provides tooling to [build offline binary packages](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/manage_cluster/cli_catalog_commands.html#create-archive).  The tool reads a YAML manifest file in the helm chart and creates the binary package from the specified contents.  Cloud Paks must provide a such a manifest.yaml file for users to easily create offline binary packages in a consistent manner across products.  The manifest format can be found here: [IBM Cloud Pak manifest format](MANIFEST_FORMAT.md)

IBM Cloud Private also supports [importing binary packages that contain all the components (charts and images) required to deploy a product](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/manage_cluster/cli_catalog_commands.html#load-archive).  The contents of the binary package are then stored in the local image registry / local chart repository and the charts can then be deployed without access to the public internet.

Cloud Paks must provide a valid manifest.yaml file and test that the ICP tooling can build the binary offline package, that the package can be installed in ICP and that the product can be deployed from that installed package.

## ibm_cloud_pak/qualification.yaml

The qualification YAML file is simply a statement of the details of the Cloud Pak such as when the Cloud Pak was certified, what level of certification was achieved and how long that certification is valid. Start with the following, and update the `issueDate` and `name` fields for the `podSecurityPolicy` and ICP `installerRole`.

```
qualification:
  levelName: "ibm-cloud-pak"
  levelDescription: "IBM Cloud Pak"
  issueDate: "01/2019"
  duration: "6M"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"
prereqs:
  security:
    kubernetes:
      podSecurityPolicy:
        name: "ibm-restricted-psp"
    ibmCloudPrivate:
      installerRole:
        name: "Operator"
```

## Metering annotations

Add metering annotations to your chart for easy integration into IBM Cloud Private metering service.  The metering service looks for 3 annotations:

`productName`: A product name is the human readable name for the offering.

`productID`: A product identifier that uniquely identifies the offering.  To avoid name collisions, start product ID with `com_CompanyName`. If you have different editions of the same product version (dev vs enterprise) use this ID to distinguish between them.

`productVersion`: The version of the product.  

```
kind: Deployment
spec:
  template:
     metadata:
       annotations:
          productName: "Acme Best App Ever"
          productID: "com_Acme_BestApp_Dev_specific_id_string"
          productVersion: "1.0.0"
```

# Lifecycle

## Compatible with latest ICP

Charts must be tested for compatibility with the latest releases of ICP within 60 days of general availability.  The expectation is that a Cloud Pak will work on all future version of ICP, without skipping versions. 

## Avoid hard-coded version constraints

Avoid setting kubeVersion of tillerVersion to a single specific version in both `Chart.yaml` as well as in Helm template files.  The intent is to make sure the Cloud Pak continues to work on future versions of ICP without modification.  Instead of setting a specific version, allow for a particular version or greater:
```
tillerVersion: ">=2.5.0"
```

## Liveness and readiness probes

Workloads must enable monitoring of their own health using livenessProbes and readinessProbes.

