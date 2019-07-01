# What's new in Chart Version 1.2.11
* Updated the secret generation image to be the Universal Base Image

# Fixes
* Fixed the way that the image path is resolved for the secret generation yaml

# Prerequisites
* Kubernetes version 1.9 or greater

# Breaking Changes
* None

# Documentation
* See README.md

# Version History
| Chart  | Date     | Kubernetes Required | Details |
|--------|----------|---------------------|---------|
| 1.2.11 | 06/25/19 | >=1.9.0 | Updated secret generation image and bug fixes |
| 1.2.10 | 05/29/19 | >=1.9.0 | Updated secret generation image and bug fixes |
| 1.2.9  | 05/10/19 | >=1.9.0 | Added secret generation support |
| 1.2.8  | 03/14/19 | >=1.9.0 | Bug fixes |
| 1.2.7  | 02/18/19 | >=1.9.0 | Added ingress rules, pod affinity/anti-affinity rules, ilmt annotations, and security context rules |
| 1.2.6  | 11/26/18 | >=1.9.0 | Bug fixes. Include release label with new standard labels |
| 1.2.7  | 11/06/18 | >=1.9.0 | Bug fixes |
| 1.2.4  | 11/02/18 | >=1.9.0 | Added new standard label support |
| 1.2.3  | 09/24/18 | >=1.9.0 | Added affinity support |
| 1.2.2  | 08/02/18 | >=1.9.0 | Avoid panic by failing to render if issue with values-metadata |
| 1.2.1  | 05/30/18 | >=1.9.0 | Bug fixes |
| 1.2.0  | 04/11/18 | >=1.9.0 | Updated readme and support as subchart |
| 1.1.0  | 02/06/18 | >=1.9.0 | Added helpers for labels and metering annotations |
| 1.0.0  | 01/27/18 | >=1.9.0 | Initial version |
