The clusterAdministration directory contains scripts that apply at a namespace scope that need to be done after deleting the chart:

* Delete any custom SecurityContextConstraint
* Delete any custom ClusterRole
