# What’s new in Compare and Comply Chart Version 1.1.6

Released latest Compare and Comply APIs. You can find the latest API signature from the README.md file.

ROLLING UPGRADES FROM PREVIOUS CHART RELEASES ARE NOT SUPPORTED
 
# Prerequisites
  - IBM Cloud Pak for Data 2.1.0 or later
  - Kubernetes 1.11 or later
  - Tiller 2.9.0 or later
  
# Fixes
* Latest Compare and Comply Ingestion Code (v1.7.23)
* The `version` parameter used in all functions will produce a new output schema when `version=2018-10-15` (or a later day) is used.
To get the output schema from versions 1.1.0 or before, use `version=2018-10-14` (or an earlier date).
* Functions now support images in addition to PDF documents. Image types supported: TIFF, PNG, JPEG, JPEG2000, GIF, BMP, RAW. 
Images have to be scanned pages of documents with at least 300 DPI.  Plain text files with mono-space fonts and page breaks are supported. 
Rich text files that include formatting and font-weights like bold/italic are not supported yet.
    * html_conversion: supports all above image formats and text files.
    * element_classification: supports all above image formats. Does not support text files.
    * tables: supports all above image formats and text files.
    * comparison: supports all above image formats. Does not support text files. (Notice that comparison continues to support element classification output JSON as input).

# Breaking Changes

No breaking changes are present in this release

# Documentation

For detailed installation instructions go to the [documentation](https://cloud.ibm.com/apidocs/compare-comply-data)

# Version History

| Chart | Date | IBM Cloud Automation Manager version | Kubernetes Required | Details |
| ----- | ---- | ------------------------------------ | ------------------- | ------- | 
| 1.1.6 | Aug 30,2019 | 2.1.0.3 FP1 & 3.1| >=1.11.0 | Integrate addon service |
| 1.1.3 | Jan 18, 2018| 2.1.0.3 FP1 & 3.1| >=1.9.0 | Model updates |
| 1.1.2 | Dec 27, 2018| 2.1.0.3 FP1 & 3.1 | >=1.9.0 | Add authentication support |
| 1.1.1 | Nov 13, 2018| 2.1.0.3 FP1 & 3.1 | >=1.9.0 | Ingestion API with version support |
| 1.1.0 | Sep 28, 2018| 2.1.0.3 FP1 & 3.1 | >=1.9.0 | Ingestion API breaking changes |
 v1.0.6 | Sep 14, 2018| 2.1.0.3 FP1 | >=1.9.0 | Updated Statsd docker image |
| v1.0.5 | July 30, 2018| 2.1.0.3 | >=1.9.0 | pdf/nlp sprint36 release |
| v1.0.4 | July 02, 2018| 2.1.0.3 FP1 | >=1.9.0 | Update ClusterIP Ingress support |
| v1.0.3 | May 21, 2018| 2.1.0.2 | >=1.9.0 | pdf/nlp sprint31 release |
| v1.0.2 | April 04, 2018| 2.1.0.2 FP1 | >=1.9.0 | pdf/nlp sprint28 release |
| v1.0.1 | March 23, 2018| 2.1.0.2 FP1 | >=1.9.0 | the first ICP release |
