## What's new
* Integrated Behaviour Test framework
* Integrated graphical Service Designer
* CI/CD Hub
* Dynamic view of ongoing intent progress and tasks. View the execution history related to Assembly instances.
* Updated modern user interface with sections for Operations, Design and System Administration
* Add, edit and remove Deployment Locations and Resource Managers
* Role Based Access Control (RBAC) adds the ability to control access to specific functionality within Lifecycle Manager to specific individuals
* Assemblies searchable by partial name
* All logging information now sent to ElasticSeach so that it can be searched and queried from one tool.
* Communication to Resources Managers through REST api can now be secured via HTTPS.

For more information see [IBM Agile Lifecycle Manager v2.0.0 Release Notes](https://www.ibm.com/support/knowledgecenter/SS8HQ3_2.0.0/ReleaseNotes/alm_rn_20_0_about.html)

## Breaking Changes

## Fixes
* IBM - 3 cassandra nodes are not HA enabled
* IBM Ticket - Valid Resource Manager url is initially flagged as invalid
* ALM UI : The Discard (changes) button should only need to be hit once
* ALM UI : The UI Properties values display needs to have a tooltip for values not fully visible
* ALM UI : Long assembly descriptor name overwrites action icons
* Assembly Instance on Main GUI screen displays the next-to-last process rather than last process when the latest process is DeleteAssembly (i.e. delete in-progress or failed)
* GUI Take Action window contents overflow onto main screen
* UI : Info popup displaying Resource Manager locations disappears too quickly
* UI : Differentiate between active and inactive assembly instances in the main list view
* UI : Part of error message is missing
* UI : Wrong message displayed when assembly instance is deleted
* UI : Error displayed in UI needs to be more than just the logfile output
* UI : Inconsistency with 'Take Action' icon for assemblies
* UI : Relationships graphic needs updating or removal
* UI : The assemblies search bar should cover partial assembly name search
* UI : Main banner needs restructuring
* Incorrect RM URL leads to customer confusion
* Wrong message given if Descriptor omitted when creating Assembly Configuration
* Part of error messages get obscured by the OK button
* Blank error popup if resource manager port is changed
* Blank error if 'readonly' user attempts to create or delete
* INVALID REQUEST ALM Driver error if 'secadmin' user logs in to ALM UI.
* Two relationships with same source/target leave inconsistent system
* Execution Graph not refreshed during complex heal
* Deleting an Assembly cease relationship not performed on second relationship
* Process Execution View not updating when a Process is re-calculated


## Prerequisites
* You will need to delete existing job resources prior to upgrading
* This chart must be installed by a team administrator
* You can only deploy a single instance per namespace
* This chart only supports the amd64 architecture
* This chart requires IBM Cloud Private version 3.1.2 or later
* If you want to ensure all data in motion is encrypted, then IPsec needs to be enabled in the cluster.

## Documentation
For more information, see the [IBM Agile Lifecycle Manager Knowledge Center: Upgrading on ICP](https://www.ibm.com/support/knowledgecenter/SS8HQ3_2.0.0/Installing/t_alm_icp_upgrading.html)

## Version History
| Chart | Date        | Kubernetes Required | Breaking Changes                              | Details                      |
| ----- | ----------  | ------------------- | --------------------------------------------- | ---------------------------- |
| 2.0.1 | June, 2019  | >=1.12.4            | Cannot upgrade from previous versions of chart| Refresh of ALM 2.0.0         |
| 2.0.0 | Apr, 2 019  | >=1.12.4            | Cannot upgrade directly from chart 1.0.0      | Update for ALM 2.0.0         |
| 1.0.0 | Dec,  2018  | >=1.11.3            | -                                             | Initial release of ALM chart |
