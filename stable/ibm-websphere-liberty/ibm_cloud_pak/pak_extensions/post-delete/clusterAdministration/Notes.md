The clusterAdministration directory contains scripts that apply at a namespace scope that need to be done after deleting the chart:

* Delete any custom SecurityContextConstraints
* Delete any custom ClusterRole
* Delete any custom PodSecurityPolicy
