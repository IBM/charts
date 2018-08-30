# Standards and Guidelines for chart contributions

The tables below should be use as a readiness guide for anyone preparing to deliver a helm chart to the `https://github.com/ibm/charts/community` directory. These guidelines are intended to augment the [Helm best practices](https://docs.helm.sh/chart_best_practices/) and not intended to replace those. If there is no guidance listed below, then it is best to refer to the Helm community best practices.

### Required for all charts contributed to https://github.com/ibm/charts

| **Requirement** | **Description** |
| --- | --- |
| **Directory structure** | Chart source should be added to the `charts/community` directory. Chart archives, packaged as a `.tgz` file using `helm package` should be added to the `charts/repo/community` directory, which is a helm repository. *Do not uupdate index.yaml with your contribution* index.yaml is automatically updated by a build process.|
| **Chart name** | Helm chart names should follow the [Helm chart best practices](https://github.com/kubernetes/helm/blob/master/docs/chart_best_practices/conventions.md#chart-names). The chart name must be the same as the directory that contains the chart. Chart contributed by a company or organization must be prefixed with the company or organization name. Only charts contributed by IBM should be prefixed with ibm- |
| **Chart file structure** | Charts should follow the standard Helm file structure: Chart.yaml, values.yaml, README.md, templates, and templates/NOTES.txt should all exist |
| **Chart version** | SemVer2 numbering should be used, as per [Helm chart best practices](https://github.com/kubernetes/helm/blob/master/docs/chart_best_practices/conventions.md#version-numbers). |
| **Chart description** | All contributed charts must have a chart description in chart.yaml. This will be displayed in the ICP catalog and should be meaningful. |
| **Helm lint** | The chart must pass the `helm lint` verification tool with no errors. |
| **License** | The chart must contain the Apache 2.0 license in the LICENSE file at the root of the chart. The chart _should_ contain the license for the product being deployed in the LICENSES directory. |
| **NOTES.txt** | Include NOTES.txt with instructions to display usage notes, next steps, &amp; relevant information. |
| **tillerVersion constraint** | Add a `tillerVersion` to Chart.yaml that follows the Semantic Versioning 2.0.0 format (`>=MAJOR.MINOR.PATCH`); ensure that there is no additional metadata attached to this version number. Set this constraint to the lowest version of Helm that this chart has been verified to work on. |

&nbsp;
&nbsp;

### Recommendations for an improved user experience on IBM Cloud Private
(A detailed onboarding guide with more information on these recommendations will be published soon)

| **Guideline** | **Description** |
| --- | --- |
| Chart icon | Providing a URL to an icon is preferred to embedding a local icon in the chart, to avoid chart size limits when using nested charts. |
| Chart keywords | Chart keywords are used by the IBM Cloud Private user interface, and should be included in Chart.yaml. Use keyword `ICP` to indicate the chart is meant for use with IBM Cloud Private, and/or keyword `IKS` to indicate that the chart is meant for use with IBM Cloud Kubernetes Service. A chart should also include one or more keywords to indicate the hardware architectures it supports, from the set of `s390x`, `ppc64le`, and `amd64` |
| Chart version / image version | Workloads should maintain image versions/tags separately from chart versions. |
| Images | Image url should be parameterized, version of image(s) to be deployed should be exposed w/ the latest version as default, reference publically available images by default when possible. |
| Platform support | IBM Cloud Private supports x86-64, Power, and z hardware architectures. Workloads can reach the largest possible audience by providing images for all three platforms and using a fat manifest. |
| Init container definitions | If using [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/), use `spec` syntax vs `annotations` to describe them. These annotations are deprecated in Kubernetes 1.6 and 1.7, and are no longer supported in Kubernetes 1.8. |
| Node affinity | Use `nodeAffinity` to schedule chart installation on valid platform |
| Portable configurations | Do not create persistent volumes in a chart, as allocation is environment-specific and may require permissions the chart deployer doesn&#39;t have. A chart should contain a Persistent Volume Claim if persistent storage is required. |
| Parameter grouping and naming | Use common naming conventions (outlined in the onboarding guide)  to provide consistent parameters and user experience across charts. |
| Values metadata | Define metadata for fields containing passwords, allowed values, etc. to provide a rich deployment experience in the ICP UI. Metadata format is described in the onboarding guide. |
| Labels and annotations | Use labels for all Kubernetes resources. |
| URLs in charts | Avoid use of non-public URLs from within charts. |
| Storage (PVs) | Do not create PV resources in helm charts. All PVs should be documented pre-requisites for the administrator. |
| Liveness and Readiness probes | Workloads should enable monitoring of monitoring their own health using livenessProbes and readinessProbes. |
| Kind | All helm templates that define resources must have a `Kind`. Helm defaults to a pod however we avoid this practice. Helm best practice is to not define multiple resources in a single template file. |
| Security privileges (container) | Workloads should avoid using escalated security privileges for containers whenever possible. When escalated privileges are required, charts must request the minimum level of privileges needed to achieve the desired functionality. |
| Security privileges (kubernetes) | Charts should be deployable by a regular user, who does not have an administrative role, such as cluster admin. If an elevated role is required, this must be clearly documented in the chart's README.md |
| hostPath | Avoid using hostPath storage, as it is not a robust storage solution. |
| hostNetwork | avoid using hostNetwork as it prevents containers from cohabitating. |
| Alpha features | It is not recommended to use Kubernetes alpha API features. |
| Resources | Charts should be clear about the resources they will consume, documented in the chart's `README.md` |
| Base OS image | Alpine is the preferred base OS for images, but others are allowed. Ubuntu 16.04 is common among many IBM product workloads. |
| Deployment validation | Charts should be validated to deploy successfully on IBM Cloud Private using both the helm CLI and the IBM Cloud Private GUI |
| Metering | The workload should integrate with the IBM Cloud Private metering service, as described in the onboarding guide. |
| Logging | The workload should integrate with the default IBM Cloud Private logging service (Elastic stack), as described in the onboarding guide. |
| Monitoring | The workload should integrate with the default IBM Cloud Private monitoring service (Prometheus), as described in the onboarding guide. |

