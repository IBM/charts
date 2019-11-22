# What's new...
IBM Watson Explorer Deep Analytics Edition V12.0.3 is a machine learning powered cognitive
search and content analytics platform that reveals trends and patterns in an organization's
data and helps improve decision-making. This release includes machine learning powered
improvements to the IBM Watson Explorer cloud-ready cognitive search features.

* Solution implementers can now use an assistant-style tool to create context-aware and
machine learning enabled cognitive search web applications that rank and recommend
documents based on user attributes and feedback.
* Security services are enhanced so that users of cognitive search applications can find only
documents they are authorized to see.
* Selected data source connectors now use the enhanced security services.
* Using natural language query, business users of cognitive search applications can now
search selected data sources.
* Initial administrator password can be configured by `Secret` resource.

# Breaking Changes
* NetworkPolicy configurations are installed. Only `Gateway` pods can be accessed from outside of Kubernetes.

# Fixes
See [Release Notes](http://www.ibm.com/support/docview.wss?uid=swg27050305) for details.

# Prerequisites
* Internet connection is needed to configure [crawlers](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_ee_adm_ds_crawl_import.html) for the data sources located on the internet.
* If you want to ensure all data in motion is encrypted, then IPsec needs to be enabled in the cluster.
* See [Software Product Compatibility Reports](https://www.ibm.com/software/reports/compatibility/clarity/index.html) for detailed system requirements.

## Documentation
See [Release Notes](http://www.ibm.com/support/docview.wss?uid=swg27050305) for details.

# Version History
| Chart | Date      | Kubernetes Required | Image(s) Supported                                                      | Breaking Changes                                               | Details                                                                                                                    |
| ----- | --------- | ------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| 1.5.0 | Sep, 2019 | >=1.9.0             | ibm-wex-ee: 12.0.3.\*, ibm-wex-hdp: 12.0.3.\*, ibm-wex-wksml: 12.0.3.\* | NetworkPolicy configurations are installed.                    |                                                                                                                            |
| 1.4.0 | Jun, 2019 | >=1.9.0             | ibm-wex-ee: 12.0.3.\*, ibm-wex-hdp: 12.0.3.\*, ibm-wex-wksml: 12.0.3.\* | ICP 2.1.0.3 is no longer supported.                            | The docker images base on Redhat UBI image. <br> Persistent Volumes wex-disc-log-\* and wex-hdp-log-\* are no longer used. |
| 1.3.0 | Feb, 2019 | >= 1.10.0           | ibm-wex-ee: 12.0.2.\*, ibm-wex-hdp: 12.0.2.\*                           | The execution user is switch to normal user in the entrypoint. | None                                                                                                                       |
| 1.2.0 | Dec, 2018 | >= 1.10.0           | ibm-wex-ee: 12.0.2.\*, ibm-wex-hdp: 12.0.2.\*                           | The minimum Tiller version is changed to 2.7.2.                | ICP 3.1.1 is supported.                                                                                                    |
| 1.1.0 | Oct, 2018 | >= 1.10.0           | ibm-wex-ee: 12.0.2.\*, ibm-wex-hdp: 12.0.2.\*                           | An additional Persistent Volume is introduced.                 | A new web UI and machine learning features are introduced.                                                                 |
| 1.0.2 | Jul, 2018 | >= 1.10.0           | ibm-wex-ee: 12.0.1.\*, ibm-wex-hdp: 12.0.1.\*                           | None                                                           |                                                                                                                            |
| 1.0.1 | Mar, 2018 | >= 1.8.3            | ibm-wex-ee: 12.0.0.82+, ibm-wex-hdp: 12.0.0.82+                         | None                                                           |                                                                                                                            |
| 1.0.0 | Feb, 2018 | >= 1.8.3            | ibm-wex-ee: 12.0.0.54+, ibm-wex-hdp: 12.0.0.54+                         | None                                                           |                                                                                                                            |

See [Release Notes](http://www.ibm.com/support/docview.wss?uid=swg27050305) for details.
