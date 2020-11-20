
```
The Open Group OSDU™ Forum is developing an Open Energy Data Platform to support an increasing number of energy sources such as:

• Oil and Gas: Here we support the full spectrum from Exploration to Upstream Production
• Other Energy Sources: Wind Farms, Solar Farms, Hydrogen, Hydro, GeoThermal, etc.

For all of these energy sources, we are putting the relevant data into a single Data Platform. This will then be accessible from a single set of APIs where the Data Platform acts as the System of Record and where the data will be mastered. Other key features include:

• Open Source Based: Supporting fast development and adoption of new features
• Public Cloud and On Premise: Supported by the major Cloud providers and supported for On Premise Deployments
• Realtime support becomes key given that all new energy sources are realtime based
• Given the clear set of APIs, we offer a good platform for application/service developers (startups, universities, companies, in-house etc) to develop new applications and bring the latest innovations to market
• Broad and ever increasing support for data types matching the needs of the energy sources
• Development of Edge capabilities where we need OSDU facilities close to the actual energy source

OEDU release 2 Published for OSDU Forum Members
Release 2 is available for adoption. What's new in this release?
This version of the OSDU Data Platform has been updated with the OpenDES core services contributed by Schlumberger in preparation for the full integration of OpenDES in Release 3 later this year. Release 2 supports seismic data in SEG-Y and OpenVDS formats for which we recognize contributions by Bluware, INT, and SubsurfaceIO. The OSDU Forum would also to acknowledge and thank EPAM for the ingestion and test scripts that they contributed to Release 2.

Who is this release for?
Release 2 is a Developer Ready release. Now that the data platform is on a stable, common codebase, it is ready for application developers to:

Refactor existing applications to integrate with and use the data platform
Develop new applications to take advantage of the broad range of functionality and capabilities now available
To get access to OSDU Release 2, please contact your preferred cloud provider to get Release 2 installed.

If your organization is not yet a Member of the OSDU Forum and would like to get involved, email memberservices@opengroup.org
```






# Details

### IBM Open Energy Data Universe

IBM® Cloud Pak for Data

Installation and Usage Content

Contents
========

[OEDU Landing Page 3](#oedu-landing-page)

[Installing OEDU 4](#installing-oedu)

[Setting up the cluster for Open Energy Data Universe:
5](#setting-up-the-cluster-for-open-energy-data-universe)

[Installing the Open Energy Data Universe:
12](#installing-the-open-energy-data-universe)

[Uninstalling IBM Open Energy Data Universe : 14](#_Toc52830430)

[Backup and Restore: 14](#backup-and-restore)

[Enterprise governance 15](#enterprise-governance)

[IBM Open Energy Data Universe Usage Landing Page
15](#ibm-open-energy-data-universe-api)

[Delivery API: 16](#delivery-api)

[Entitlement API: 18](#entitlement-api)

[Legal Service: 27](#legal-service)

[Indexer Service: 39](#indexer-service)

[Indexer-Queue Service: 44](#indexer-queue-service)

[Storage Service: 45](#storage-service)

[Search Service: 52](#search-service)

# Introduction

OEDU Landing Page
=================

OEDU (Open Subsurface Data Universe) is an industry standard on how Oil
& Gas data needs to be collected, described and served to various
applications and services. Historically, this data has been highly
segmented, came in different formats and was spread across different
systems so major companies have been working on building very similar
data platforms to integrate data silos and simplify access to it across
the organization and to third parties.

OEDU provides a reference implementation for such data platform and
standardizes on data schemas and a set of unified APIs for bringing data
into the data platform, describing, validating, finding and retrieving
data elements and their metadata (effectively, becoming a system of
record for subsurface and wells data).

Application developers can utilize these APIs to create applications
that are directly connected to the operator's datasets. Once the
application is developed it requires minimal or no customization to
deploy it for multiple operators adhering to the same APIs and data
schemas.

The OEDU ecosystem allows various stakeholders to interface their
applications with the platform and take advantage of the seamless data
lifecycle. Following depiction shows the various interfaces of the
ecosystem.

![](media/image1.png){width="6.5in" height="3.4131944444444446in"}



# Installing

Installing OEDU
---------------

# Resources Required

To install IBM® Open Energy Data Universe (OEDU), you must first set up
the cluster and then install the OEDU APIs on IBM Cloud Pak for Data
control plane.

To install the Open Energy Data Universe service, complete the following
procedures.

1.  *Setting up the cluster for the Open Energy Data Universe*

If you plan to install the IBM Open Energy Data Universe service on IBM
Cloud Pak for Data, a cluster administrator must set up the cluster for
the service.

2.  *Installing the Open Energy Data Universe service*

A project administrator can install the IBM Open Energy Data Universe
service on IBM Cloud Pak for Data.

### Setting up the cluster for Open Energy Data Universe: 

## Prerequisites

Prerequisites: Preparing the cluster for CP4D and IBM Open Energy Data
Universe Services to be provisioned.

*Target:*

-   To setup the local environment of the administrator, executing the
    installation, to carry out all the relevant tasks.

-   To create, configure and deploy relevant supporting artifacts for
    preparing IBM Open Energy Data Universe platform.



Installing a PodDisruptionBudget

A PodDisruptionBudget has three fields:

A label selector .spec.selector to specify the set of pods to which it applies. This field is required.
.spec.minAvailable which is a description of the number of pods from that set that must still be available after the eviction, even in the absence of the evicted pod. minAvailable can be either an absolute number or a percentage.
.spec.maxUnavailable (available in Kubernetes 1.7 and higher) which is a description of the number of pods from that set that can be unavailable after the eviction. It can be either an absolute number or a percentage.
Note: For versions 1.8 and earlier: When creating a PodDisruptionBudget object using the kubectl command line tool, the minAvailable field has a default value of 1 if neither minAvailable nor maxUnavailable is specified.
You can specify only one of maxUnavailable and minAvailable in a single PodDisruptionBudget. maxUnavailable can only be used to control the eviction of pods that have an associated controller managing them. In the examples below, "desired replicas" is the scale of the controller managing the pods being selected by the PodDisruptionBudget.

Example 1: With a minAvailable of 5, evictions are allowed as long as they leave behind 5 or more healthy pods among those selected by the PodDisruptionBudget's selector.

Example 2: With a minAvailable of 30%, evictions are allowed as long as at least 30% of the number of desired replicas are healthy.

Example 3: With a maxUnavailable of 5, evictions are allowed as long as there are at most 5 unhealthy replicas among the total number of desired replicas.

Example 4: With a maxUnavailable of 30%, evictions are allowed as long as no more than 30% of the desired replicas are unhealthy.

In typical usage, a single budget would be used for a collection of pods managed by a controller—for example, the pods in a single ReplicaSet or StatefulSet.

Note: A disruption budget does not truly guarantee that the specified number/percentage of pods will always be up. For example, a node that hosts a pod from the collection may fail when the collection is at the minimum size specified in the budget, thus bringing the number of available pods from the collection below the specified size. The budget can only protect against voluntary evictions, not all causes of unavailability.
If you set maxUnavailable to 0% or 0, or you set minAvailable to 100% or the number of replicas, you are requiring zero voluntary evictions. When you set zero voluntary evictions for a workload object such as ReplicaSet, then you cannot successfully drain a Node running one of those Pods. If you try to drain a Node where an unevictable Pod is running, the drain never completes. This is permitted as per the semantics of PodDisruptionBudget.

You can find examples of pod disruption budgets defined below. They match pods with the label app: zookeeper.

### Example PDB Using minAvailable:

policy/zookeeper-pod-disruption-budget-minavailable.yaml Copy policy/zookeeper-pod-disruption-budget-minavailable.yaml to clipboard

```
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: zk-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: zookeeper
```

Example PDB Using maxUnavailable (Kubernetes 1.7 or higher):

policy/zookeeper-pod-disruption-budget-maxunavailable.yaml Copy policy/zookeeper-pod-disruption-budget-maxunavailable.yaml to clipboard

```
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: zk-pdb
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: zookeeper
```

For example, if the above zk-pdb object selects the pods of a StatefulSet of size 3, both specifications have the exact same meaning. The use of maxUnavailable is recommended as it automatically responds to changes in the number of replicas of the corresponding controller.



*Process:*

Setting up local environment:

**Note:** *Wherever required the administrator should install the
utilities as per the os environment they have on their local machine or
the edge location/node on the cluster.*


Following utilities need to be installed on the local/edge location
environment:

-   Getting git utility

-   Getting OC utility

-   Getting CPD utility

Getting Git Utility:

Steps for getting Git utility for connecting to the git repository.

-   Download the Git installation binaries from
    <https://git-scm.com/downloads>

-   Execute the downloaded environment specific binary with proper
    permissions.

-   Once installed validate the installation by executing version check
    command on the OS terminal

Getting OC Utility:

Steps for getting the OC utility to interact with Openshift Container
Platform.

-   Download oc Client Tools for Linux from:
    > <https://cloud.redhat.com/openshift/install>

***Note: This might require Red Hat Account*** Credentials

-   Extract the downloaded file and you will get **oc** file

-   The **oc** file should be moved to any directory in the OS path
    > environment variable or the directory should be added to the
    > environments path variable.

-   Provide execution permission to **oc** file

Reference:
<https://docs.openshift.com/container-platform/4.5/cli_reference/openshift_cli/getting-started-cli.html>

Getting CPD Utility:

For CPD (Cloud Pak For Data) CLI Tools, follow the below step:

-   On the local environment, download the appropriate file from cpd-cli
    GitHub (<https://github.com/IBM/cpd-cli/releases>)

-   Extract the contents of the TAR file, in a new path and take note of
    the path:

-   The path should be then added to the OS path environment variable.

-   Provide execution permission to the CPD command file.

*Validate the Utilities: Execute the following from the local OS
terminal*

Validate git: Execute the following command and it should display the
version of the git client

Validate OC: Execute the following command and it should display the
version of the oc client.

Validate CPD: Execute the following command

To Install Supporting Services:

Provision a Red Hat® OpenShift® cluster and save the url and credentials
to connect with it through command line.

*Target:*

-   Following services with corresponding versions need to be installed
    on the cluster, through ArgoCD operator on Openshift cluster

**Version Details:**

  **Services**     **Version Supported**
  ---------------- -----------------------
  Argocd           0.0.8
  Couch DB         3.1.0
  MinIO            1.0.9
  Elastic Search   4.5.0
  Keycloak         11.0.0
  AMQ Broker       7.7.0



# Configuration

*Process:*

Clone the git repository on the cluster edge node for installing the
above services.

git_repo: <https://us-south.git.cloud.ibm.com/osdu/gitops>

Configure GitLab access token for Argo CD:

Update the password field in the file called
[gitlab-deploykey.env](file:///C:\osdu\gitops\-\blob\master\gitops\argocd\overlays\default\gitlab-deploykey.env)
(.argocd/overlays/default)

From the root directory of git clone from above, perform the following:

A script called launch.sh need to be executed bootstrap the entire
environment. With the prerequisites complete, execute the script

Once complete, you should be able to access the ArgoCD server. Locate
the address of the newly created route using the address discovered by
executing the command below:

Click the Login with OpenShift button and use your OpenShift credentials
to access the interface.

Once the launch.sh script has executed, it will result in shared
services being installed on the cluster.

Following services need to be accessed and configured as part of
pre-requisite for installation of the CPD control plane and OEDU API's

**Configure Keycloak**

Please validate that all the above pre-requisite steps have completed in
success before going forward to access and configure Keycloak identity
provider.

Keycloak is used to serve as an identity provider to authenticate and
authorize users accessing the various OEDU API's.

The administrator needs to access the Keycloak UI, by obtaining the url
from the OpenShift administrator console.

The default user 'admin' and default password 'admin' can be used to
access the Keycloak administrator page for the first time.

Note: Default user password is required to be changed on the first
login.

Following entities need to be created and configured for creating the
credentials to be authenticated and authorized by the identity provider.

**Realm:** A realm manages a set of users, credentials, roles, and
groups.

Login to the admin console and hover the mouse over the top left corner
drop down, titled "Master", the default realm.

![](media/image2.png){width="6.5in" height="2.2805555555555554in"}

In the drop down choose 'Add realm' and proceed to get the page for
adding the realm.

![create realm](media/image3.png){width="6.5in"
height="1.7944444444444445in"}

Provide the realm name and click on create.

Choose the valid realm to proceed further on creating client/s.

**Clients:** Clients are entities that can request authentication of a
user.

From the menu on left choose clients and access the page on the right:

![clients](media/image4.png){width="6.5in" height="2.145138888888889in"}

Click on the create button on the right and you will land on the below
page to enter minimum configurations for creation of the client.

![add client oidc](media/image5.png){width="6.5in"
height="2.7368055555555557in"}

Enter in the Client ID of the client. This should be a simple
alpha-numeric string that will be used in requests and in the Keycloak
database to identify the client. Next select openid-connect in the
Client Protocol drop down box. Finally enter in the base URL of your
application in the Root URL field and click Save. This will create the
client and bring you to the client Settings tab. Configuring these
parameters are important for the way the client will authenticate the
users and can be seen in detail on Keycloak client documentation.

**Roles:** Roles identify a type or category of user

Create roles by clicking the Roles left menu item:

![roles](media/image6.png){width="6.5in" height="1.6666666666666667in"}

To create a role, click Add Role on this page, enter in the name and
description of the role, and click Save.

![role](media/image7.png){width="6.5in" height="2.9270833333333335in"}

**Users:** Persona's that want to get themself authenticated and
authorized to access various clients on the identity provider.

To create a user, click on Users in the left menu bar.

![users](media/image8.png){width="6.5in" height="2.7423611111111112in"}

On the right side of the empty user list, you should see an Add User
button. Click that to start creating your new user.

![add user](media/image9.png){width="6.5in"
height="3.8944444444444444in"}

The only required field is Username. Click save. This will bring you to
the management page for your new user.

**Configure token:**

Keycloak gives you fine grain control of session, cookie, and token
timeouts. This is all done on the Tokens tab in the Realm Settings left
menu item.

![](media/image10.png){width="6.5in" height="3.798611111111111in"}

**This will set the Keycloak as identity provider for minimum access and
can be enhanced as the demand for segregating the entities in various
capacity are needed for a mature interaction with the platform.**

IBM Open Energy Data Universe Specific Config-Map and Secrets to be
configured

1\. props-core (Delivery env variables need to be moved)

2\. props-secret

3\. props-ent

4\. props-ent-secret.

5\. MinIO Procedure for binding sub user. (wiki)

### Installing the Open Energy Data Universe: 

*Target:*

-   To install IBM Open Energy Data Universe services with CPD control
    plane.

-   To validate the installation process of the following services

    -   Delivery

    -   Entitlement

    -   Indexer

    -   Indexer-queue

    -   Legal

    -   Storage

    -   Search

*Process:*

Verify that the pre-requisite steps above have been completed.

Installing CPD core services with IBM Open Energy Data Universe
Services:

-   Login to cluster using the following command

-   **C**hange **D**irectory to CPD CLI tool path and edit the repo.yaml
    file with following content:

-   Perform the CPD dry-run with the following command

-   Perform the CPD apply command to create admin artifacts into OCP
    cluster

-   Install the CPD assemble lite( example: zec-core, zendata,
    ibm-nginx\...) and osdu-core into OCP cluster

*Validate:*

The installation process will provision API pods on the OpenShift
platform. Follow the link below for validating the sanity of the OEDU
service on the platform.

***A link to CPD validation process***

### [Uninstalling IBM Open Energy Data Universe](https:// www-03preprod .ibm .com/support/knowledgecenter/SSQNUZ_3.5.0_test/copy-me/sample-svc-upgrade-adm.html) : 

***A link to CPD uninstall process***

### Backup and Restore: 

***A link to CPD backup and restore process***

Enterprise governance
=====================

### IBM Open Energy Data Universe API 

Following IBM Open Energy Data Universe API's can be leveraged to build
data agnostic applications:

Delivery API

*The Delivery API provides a general-purpose delivery mechanism which
supports work product components beyond files. In the case of files, its
wrappers the File service.*

Entitlements API

*Entitlements API is used to enable authorization in Data Ecosystem.*

Indexer API

*The Indexer API provides a mechanism for indexing documents that
contain structured or unstructured data.*

Indexer Queue API

*A queue-based API which listen to the messages published by storage API
and calls indexer API for further processing.*

Legal API

*Legal API governs the Data compliance through the Records in the
storage API.*

Storage API

*The Storage API provides a set of APIs to manage the entire metadata
life cycle such as ingestion*

Search API

*The Search API provides a mechanism for indexing documents that contain
structured data.*

*\
*

### Delivery API:

Usage

The Delivery API provides a general-purpose delivery mechanism which
supports work product components beyond files. In the case of files, its
wrappers the File service.

Assumptions

Delivery API relies on how objects were stored during the ingestion
routine.

-   It was agreed to skip mapping between file and storage API entities
    by using same record ID in both. Using this approach, we can
    directly call FileService to obtain file location using storage ID.

-   Otherwise the relationship between these two record IDs must be
    maintained either on the record or in a mapping table.

Delivery API:

/GetResources

GetResources takes list of SRNs and returns signed URL for file objects
and complete JSON object if it's not the file.

*Request*:

-   SRNs (\[string\]) -- list of SRNs to return

*Response*:

-   Processed (json object, see below) -- found entries

-   Unprocessed (\[string\]) -- list of SRNs which were not located in
    the system

Processed entities have format:

-   SRN (string) -- entity SRN

-   Data (json object) -- if entity is not a file entity, Data contains
    full entity details. Otherwise Signed URL object is returned (see
    below)

Data object format:

-   SignedURL (string) -- GCS location

For some cloud providers extra fields might be present, e.g. temp
credentials, etc.

Please note, that this format is sufficient for R2 (R3?) only, since
we're assuming only file-based entities are going to be processed. For
the broader cases, Driver information from the FileService's entity
should be included in the future.

Delivery Logical Flow

![](media/image11.png){width="4.980304024496938in"
height="6.844725503062117in"}

* *
---

### Entitlement API:

Usage

Entitlements API is used to enable authorization in Data Ecosystem. It
relies on Keycloak JWT making native authorization a possibility. The
API allows for the creation of User Groups. A group name defines a
common set of permission. Users who are added to that group obtain that
permission. The main motivation for entitlements API is data
authorization but the functionality enables three use cases:

-   **Data groups** used for data authorization e.g.
    *data.welldb.viewer*, *data.welldb.owner*

-   **Service groups** used for service authorization e.g.
    *service.storage.user*, *service.storage.admin*

-   **User groups** used for hierarchical grouping of user and service
    identities e.g. *users.datalake.viewers*, *users.datalake.editors*

For each group you can either be added as an OWNER or a MEMBER. The only
difference being if you are an OWNER of a group, then you can manage the
members of that group.

Group naming strategy

All group identifiers (emails) will be of form:

{groupType}.{serviceName\|resourceName}.{permission}@{slb-data-partition-id}.{domain}.com
with:

-   groupType ∈ {\'data\', \'service\', \'users\'}

-   serviceName ∈ {\'storage\', \'search\', \'entitlements\', \...}

-   resourceName ∈ {\'welldb\', \'npd\', \'ihs\', \'datalake\',
    \'public\', \...}

-   permission ∈ {\'viewers\', \'editors\', \'admins\' \...}

-   slb-data-partition-id ∈ {\'slb\', \'common\', \...}

-   domain ∈ {\'instance.osdu.opengroup.org\', \...}

As shown, a group is unique to each data partition. This means that
access is defined on a per data partition basis i.e. giving a service
permission in one data partition does not give that user service
permission in another data partition. See below for more information on
data partitions.

Group naming convention

A group naming convention has been adopted, such that the group\'s name
should start with the word \"data.\" for data groups; \"service.\" for
service groups; and \"users.\" for user groups. The group\'s name is
case-insensitive. Please refer to group creation guideline under the API
section for more details.

Authentication and Authorization

Authentication

Both AppKey and SAuth token are required to be provided when calling
Entitlements APIs.

Authorization:

The SAuth app or client needs to be granted authorization through
developer portal to the requested data partition, if the provided token
is issued by the SAuth app or client. Note: common data partition is
public to all SAuth app and client. The user encoded in the JWT needs to
be added into the proper contract, to be granted permission to the
requested data partition. The SAuth service ID needs to be whitelisted
by the Data Ecosystem support team, given the provided token is issued
by the SAuth service.

Entitlements service also requires users or services to have the
following authorization to access the APIs. Users\' authorization is
automatically granted if they are added to the proper contract. For new
users, authorization is granted instantly. For existing users, changes
to the contract or department are synced every 8 hours.

**Valid data partition member** - Entitlements service checks whether
the member ID from the Authorization header consisting of JWT belongs to
users@{data-partition-id}.instance.osdu.opengroup.org, where
{data-partition-id} information is received from slb-data-partition-id
header.

-   **Valid entitlements service user** - Entitlements service checks
    whether the member ID from Authorization header consisting of JWT
    belongs to
    service.entitlements.user@{data-partition-id}.instance.osdu.opengroup.org,
    where {data-partition-id} information is received from
    slb-data-partition-id header.

**Service authorization**

Service authorization is used to establish if the client or service
calling another service has a proper permission to invoke the service.
This means that the clients or services must provide JWT to identify
itself to the Data Ecosystem API it is calling. This token should be
provided in the Authorization header. Specifically, if service is
calling another service that service must provide valid SAuth token for
the service account it uses to identify itself to the Data Ecosystem API
it is calling.

In each data partition that the service is used, the group corresponding
to the permission that the service supports should be created. For
example, given a service named my_service, where user and admin
permissions are desired, then groups called service.my_service.user and
service.my_service.admin should be created in all relevant data
partitions.

Service that wants to authorize access that one makes to it should call
Entitlements service *GET /entitlements/v1/groups* API by providing its
JWT in *Authorization* header and required data partition identifier in
*Slb-Data_Partition_Id* header.

Entitlements service will return all the groups of the user if:

-   the service is a member of specified data partition;

-   the user is a member of specified data partition;

-   service is a member of *service.entitlements.user* group in
    specified data partition.

If one of the above conditions is not met, Entitlements service will
return Unauthorized error. If multiple data partitions are used in the
slb-data-partition-id header, but the user does not belong to at least
one of them, Entitlements service will also return Unauthorized. On
success, calling service can inspect returned groups to determine if
required group (e.g., service.my_service.user) is returned and depending
on result, can authorize access.

Data authorization:

Once the client or service has the storage service authorization, the
data authorization will use the Keycloak group on the data. The ACL
provided in the record to be ingested is directly applied on MinIO
objects. Storage service will leverage Keycloak user authorization
mechanism to determine if the user has access to the record.

Cross partition data authorization

In most cases, data authorization happens within one data partition, but
there is use case (e.g. data marketplace) requires cross partition data
authorization. Cross partition data authorization allows data group
OWNER of the vendor partition to grant access to a user group from a
primary partition.

*primary data partition* is a private data partition, where only its
members can access the data, i.e. client or slb.

*vendor data partition* is a sharable data partition, where members from
other non-vendor data partitions can access the data, i.e. common.

Entitlement Service API:

-   **GET /entitlements/v1/groups** - Retrieves all the groups for the
    user or service extracted from JWT (email claim) in Authorization
    header for the data partition provided in *slb-data-partition-id*
    header. This API gives the flat list of the groups (including all
    hierarchical groups) that user belongs to. Service that wants to
    authorize access that one makes to it should call Entitlements
    service *GET /entitlements/v1/groups* API by providing SAuth token
    in *Authorization* header and required data partition identifier in
    *slb-data-partition-id* header. Calling service can inspect returned
    groups to determine if required group (e.g.,
    *service.my_service.user*) is returned and depending on result can
    authorize access.

> In cross partition scenario, slb-data-partition-id header could be set
> as multiple values with one primary data partition plus many vendor
> data partitions, then it returns the merged group results in one
> response.

curl \--request GET \\

\--url \'/entitlements/v1/groups\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'slb-data-partition-id: slb, common\'

-   **POST /entitlements/v1/groups** - Creates the group within the data
    partition provided in *slb-data-partition-id* header. This api will
    create a group with following email
    {name}@{data-partition-id}.{domain}.com, where {data-partition-id}
    is received from *Slb-Data-Partition_Id* header. The user or service
    extracted from JWT (email claim) in *Authorization* header is made
    OWNER of the group.

> The user or service must belong to
> service.entitlements.admin@{data-partition-id}.{domain}.com group.
> This API will be mainly used to create service and data groups.
>
> Group creation guidelines:

-   **Data groups** used for data authorization e.g. of group name is:
    data. {resourceName}.{permission}@{data-partition-id}.{domain}.com

-   **Service groups** used for service authorization e.g. of group name
    is: service.
    {serviceName}.{permission}@{data-partition-id}.{domain}.com

-   **User groups** used for hierarchical grouping of user and service
    identities e.g. of group name is: users.
    {serviceName}.{permission}@{data-partition-id}.{domain}.com

Details

curl \--request POST \\

\--url \'/entitlements/v1/groups\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'slb-data-partition-id: slb\' \\

\--data \'{

\"name\": \"service.example.viewers\",

\"description\": \"This is an service group for example service which
has viewer permission.\"

}\'

-   **GET /entitlements/v1/groups/{group_email}/members** - Retrieves
    > members that belong to a group_email within the data partition
    > provided in *slb-data-partition-id* header. E.g. group_email value
    > is {name}@{data-partition-id}.{domain}.com. Query parameter role
    > can be specified to filter group members by role of OWNER or
    > MEMBER. The user or service extracted from JWT (email claim)
    > in *Authorization* header is checked for membership within
    > group_email as the MEMBER or OWNER. This API lists the direct
    > members of the group (excluding hierarchical groups).

Details

curl \--request GET \\

\--url
\'/entitlements/v1/groups/service.example.viewers\@instance.osdu.opengroup.org/members\'
\\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'slb-data-partition-id: slb\'

-   **POST /entitlements/v1/groups/{group_email}/members** - Adds
    > members to a group with group_email within the data partition
    > provided in *slb-data-partition-id* header. The member being added
    > can either be a *user* or a *group*. E.g. group_email value is
    > {name}@{data-partitionn-id}.{domain}.com. Member body needs to
    > have an email and role for a member. Member role can be OWNER or
    > MEMBER. The user or service extracted from JWT (email claim)
    > in *Authorization* header is checked for OWNER role membership
    > within group_email.

curl \--request POST \\

\--url
\'/entitlements/v1/groups/service.example.viewers\@instance.osdu.opengroup.org/members\'
\\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'slb-data-partition-id: slb\' \\

\--data \'{

\"email\": \"member\@domain.com\",

\"role\": \"MEMBER\"

}\'

-   **POST /entitlements/v1/groups/data/{group_email}/members** -
    > Adds *user group* of a primary partition to a *data group* of a
    > vendor partition. The given group_email must be a *data
    > group* which is within the vendor data partition provided
    > in *slb-data-partition-id* header. The member must a *user group*.
    > E.g. group_email value is
    > {data.xxx.viewers}@{vendor-data-partitionn-id}.{domain}.com.
    > Member body needs to have an email and role for a member. Member
    > role can only be MEMBER. The user or service extracted from JWT
    > (email claim) in *Authorization* header is checked for OWNER role
    > membership within group_email.

curl \--request POST \\

\--url
\'/entitlements/v1/groups/data/data.example.viewers\@instance.osdu.opengroup.org/members\'
\\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'slb-data-partition-id: common\' \\

\--data \'{

\"email\": \"users.example\@instance.osdu.opengroup.org\",

\"role\": \"MEMBER\"

}\'

-   **DELETE /entitlements/v1/groups/{group_email}/members** - Deletes
    > members from a group with email group_email within the data
    > partition provided in *slb-data-partition-id* header. The member
    > being deleted can either be an *user* or a *group*. E.g.
    > group_email value is {name}@{data-partition-id}.{domain}.com. Path
    > parameter member_email needs an email of a member. The user or
    > service extracted from JWT (email claim) in *Authorization* header
    > is checked for OWNER role membership within group_email.

curl \--request DELETE \\

\--url
\'/entitlements/v1/groups/service.example.viewers\@instance.osdu.opengroup.org/members/member\@domain.com\'
\\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'slb-data-partition-id: slb\'

Data Ecosystem user groups

Data Ecosystem user groups provides an abstraction from permission and
user management. Clients or services can be directly added to the user
groups to gain the permissions associated with that user group. The
following user groups exists by default:

-   **users.datalake.viewers** used for viewer level authorization for
    Data Ecosystem services.

-   **users.datalake.editors** used for editor level authorization for
    Data Ecosystem services and authorization to create the data using
    Data Ecosystem storage service.

-   **users.datalake.admins** used for admin level authorization for
    Data Ecosystem services.

**Authorizing calls to service/API/backend**

1\. Ensuring service identity and corresponding token

Authorization with Identity service did not care about the identity of
the service making the call but relied on just passing the token
received in the *Authorization* header. This opens door for an attacker
who could steal user\'s token and use it to gain access to our services.
To reduce this attack surface, we will require that services need to be
authorized as well.

This means that service must provide SAuth token for the service account
it uses to identify itself to the Data Ecosystem API it is calling. This
token should be provided in the *Authorization* header.

2\. **Ensuring service is a member in desired data partition**

Service account email for the service making the calls to Data Ecosystem
APIs in specific data partition, should be added to users of the data
partition in question.

For example,
[*storage\@instance.osdu.opengroup.org.iam.gserviceaccount.com*](mailto:storage@instance.osdu.opengroup.org.iam.gserviceaccount.com)
should be added to
[*users\@instance.osdu.opengroup.org*](mailto:users@instance.osdu.opengroup.org).

3**. Ensuring service can use Entitlements service**

Service account email for the service using Entitlements service to
perform service authorization in specific data partition, should be
added to users of the entitlements service (group named
*service.entitlements.user*).

For example,
[*storage\@instance.osdu.opengroup.org.iam.gserviceaccount.com*](mailto:storage@instance.osdu.opengroup.org.iam.gserviceaccount.com)
should be added to
[*service.entitlements.user\@instance.osdu.opengroup.org*](mailto:service.entitlements.user@instance.osdu.opengroup.org).

4\. **Authorizing calls to your service/API/backend**

a\. Creating required service group

In each data partition that the service should be used, group
corresponding to the permission the service supports should be created.
For example, if one is creating a service called *my_service* and wants
to have specific permission with roles *user* and *admin*, groups called
*service.my_service.user* and *service.my_service.admin* should be
created in all relevant data partitions.

b\. Adding users

All users that are authorized to call a specific API should be added to
the group representing desired role on the service.

For example, if one wants to give *user* role on *my_service* in data
partition *my_data_partition* to <joe@customer.com>:

one would add <joe@customer.com> to
*service.my_service.user\@my_data_partition.{domain}.com*. Groups
grouping the roles will be created for the standard end user profiles
(e.g., users.datalake.users will have all the default roles).

c\. Authorizing the access

Data Ecosystem user groups

Data Ecosystem user groups provides an abstraction from Data Ecosystem
service level permission groups. Data Ecosystem users groups
hierarchically groups the various service groups. Client or service can
be directly added to the user groups to get access to various services.
Following Data Ecosystem user groups exists in Data Ecosystem per data
partition:

-   **users.datalake.viewers** used for viewer level authorization for
    Data Ecosystem services.

-   **users.datalake.editors** used for viewer level authorization for
    Data Ecosystem services and authorization to create the data using
    Data Ecosystem storage service.

-   **users.datalake.admins** used for admin level authorization for
    Data Ecosystem services.

Permissions

  ***Endpoint URL***                              ***Method***   ***Minimum Permissions Required***
  ----------------------------------------------- -------------- ------------------------------------
  /entitlements/v1/groups                         GET            users.datalake.viewers
  /entitlements/v1/groups                         POST           users.datalake.admins
  /entitlements/v1/groups/{group_email}/members   GET            users.datalake.viewers
  /entitlements/v1/groups/{group_email}/members   POST           users.datalake.admins
  /entitlements/v1/groups/{group_email}/members   DELETE         users.datalake.admins

### Legal Service:

Usage

This document covers how to remain compliant at the different stages of
the data lifecycle inside the Data Ecosystem.

1.  When ingesting data

2.  Whilst the data is inside the Data Ecosystem

3.  When consuming data

The clients\' interaction revolves around ingestion and consumption, so
this is when you need to use what is contained in this guide. Point 2
should be mostly handled on the clients' behalf; however, it is still
important to understand that this is happening as it has ramifications
on when and how data can be consumed.

Data compliance is largely governed through the Records in the storage
service. Though there is an independent legal service and LegalTags
entity, these offer no compliance by themselves.

Records have a Legal section in their schema, and this is where the
compliance is enforced. However, clients must still make sure they are
using the Record service correctly to remain compliant.

API usage

You currently need the role **users. datalake.viewers** to access the
LegalTag API. When creating a LegalTag you need at least the
**users.datalake.editors** role. You need the **users. datalake.admins**
role to update legalTags

The Data Ecosystem stores data in different data partitions depending on
the access to those data partitions in the IBM Open Energy Data Universe
system.

A user may have access to many data partitions in IBM Open Energy Data
Universe e.g. an IBM Open Energy Data Universe user may have access to
both the OEDU data partition and a customer's data partition. When a
user logs into the OEDU portal they choose which data partition they
currently want to be active.

When using the LegalTag APIs, you need to specify which data partition
they currently have active access to and send it in the
OSDU-data-partition-id header.

OSDU-data-partition-id

The correct values can be obtained from CFS services.

We use this value to work out which data partition to use. There is also
a special data partition known as common

OSDU-data-partition-id: common

This has all public data in the Data Ecosystem. Users always have access
to this as well as their current active data partition.

Currently you can only specify 1 data partition Id value at a time when
using the Legal APIs. If you want to retrieve all LegalTags from both
the user\'s data partition and the common data partition, you need to do
2 separate requests, changing the header value used in each.

You can also send a correlation id as a header so that a single request
can be tracked throughout all the services it passes through. This can
be a GUID on the header with a key:

OSDU-Correlation-Id 1e0fef08-22fd-49b1-a5cc-dffa21bc0b70

If you are the service initiating the request, you should generate the
id. Otherwise, you should just forward it on in the request.

What is a LegalTag?

A LegalTag is the entity that represents the legal status of data in the
Data Ecosystem. It is a collection of *properties* that governs how the
data can be consumed and ingested.

A legal tag is required for data ingestion. Therefore, creation of a
legal tag is a necessary first step if there isn\'t a legal tag already
exists for use with the ingested data. The LegalTag name is used for
reference.

When data is ingested, it is assigned the LegalTag *name*. This name is
checked for a corresponding valid LegalTag in the system. A valid
LegalTag means it exists and has not expired. If a LegalTag is invalid,
the data is rejected.

For instance, we may not allow ingestion of data from a certain country,
or we may not allow consumption of data that has an expired contract.

A name needs to be assigned to the LegalTag during creation. The name is
a unique identifier for the LegalTag that is used to access it.

Ingestion workflow That Uses Legal API

![API Security - High
level](media/image12.png){width="5.970833333333333in"
height="5.907638888888889in"}

The above diagram shows the typical sequence of events of a data
ingestion. The important points to highlight are as follow:

-   It is the clients\' responsibility to create a LegalTag. LegalTag
    validation happens at this point.

-   The Storage service validates the LegalTag for the data being
    ingested.

-   Only after validating a LegalTag exists can we ingest data. No data
    should be stored at any point in the Data Ecosystem that does not
    have a valid LegalTag.

Creating a LegalTag

Any data being ingested needs a LegalTag associated with it. You can
create a LegalTag by using the POST LegalTag API e.g.

POST /api/legal/v1/legaltags

{

\"name\": \"demo-legaltag\",

\"description\": \"A legaltag used for demonstration purposes.\",

\"properties\": {

\"countryOfOrigin\":\[\"US\"\],

\"contractId\": \"No Contract Related\",

\"expirationDate\": \"2099-01-01\",

\"dataType\":\"Public Domain Data\",

\"originator\":\"OEDU\",

\"securityClassification\":\"Public\",

\"exportClassification\":\"EAR99\",

\"personalData\":\"No Personal Data\"

}

}

Curl

curl \--request POST \\

\--url \'https://api.osdu.\[osdu\].org/de/legal/v1/legaltags\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-data-partition-id: common\' \\

\--data \'{

\"name\": \"demo-legaltag\",

\"description\": \"A legaltag used for demonstration purposes.\",

\"properties\": {

\"countryOfOrigin\":\[\"US\"\],

\"contractId\":\"No Contract Related\",

\"expirationDate\":\"2099-01-01\",

\"dataType\":\"Public Domain Data\",

\"originator\":\"OEDU\",

\"securityClassification\":\"Public\",

\"exportClassification\":\"EAR99\",

\"personalData\":\"No Personal Data\"

}

}\'

It is good practice for LegalTag names to be clear and descriptive of
the properties it represents, so it would be easy to discover and to
associate to the correct data with it. Also, the description field is a
free form optional field to allow for you to add context to the
LegalTag, making easier to understand and retrieve over time.

When creating LegalTags, the name is automatically prefixed with the
data partition Id that is sent in the request. So, in the example above,
if the given OSDU-data-partition-id header value is **common**, then the
actual name of the LegalTag would be **common-demo-legaltag**.

To help with LegalTag creation, it is advised to use the Get LegalTag
Properties API to obtain the allowed properties before creating a legal
tag. This returns the allowed values for many of the LegalTag
properties.

LegalTag properties

Below are details of the properties you can supply when creating a
LegalTag along with the values you can use. The allowed properties
values can be data partition specific. Valid values associated with the
property are shown. All values are mandatory unless otherwise stated.

You can get the data partition\'s specific allowed properties values by
using LegalTag Properties api e.g.

GET /api/legal/v1/legaltags:properties

Example 200 Response

{

\"countriesOfOrigin\": {

\"TT\": \"Trinidad and Tobago\",

\"TW\": \"Taiwan, Province of China\",

\"LR\": \"Liberia\",

\"DK\": \"Denmark\",

\"LT\": \"Lithuania\",

\"PY\": \"Paraguay\",

\"US\": \"United States\",

\...

\...

},

\"otherRelevantDataCountries\": {

\"PT\": \"Portugal\",

\"PW\": \"Palau\",

\"PY\": \"Paraguay\",

\"QA\": \"Qatar\",

\"AD\": \"Andorra\",

\"AE\": \"United Arab Emirates\",

\...

\...

},

\"securityClassifications\": \[\"Private\", \"Public\",
\"Confidential\"\],

\"exportClassificationControlNumbers\": \[\"No License Required\", \"Not
- Technical Data\", \"EAR99\"\],

\"personalDataTypes\": \[\"Personally Identifiable\", \"No Personal
Data\"\]

}

Curl

curl \--request GET \\

\--url
\'https://api.osdu.\[osdu\].org/de/legal/v1/legaltags:properties\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-data-partition-id: common\' \\

*Country of origin*

Valid values: An array of ISO Alpha-2 country code. This is normally one
value but can be more. This is required.

Notes: This is the country from where the data originally came, NOT from
where the data was sent. The list of allowed countries is below. If
ingesting Third Party Data, you can ingest data from any country that is
not embargoed, if you have a valid contract associated with it that
allows for this.

*Contract Id*

Valid values: This should be the Contract Id associated with the data or
\'Unknown\' or \'No Contract Related\'.

Notes: This is always required for any data types.

*Expiration date*

Valid values: Any date in the future in the format yyyy-MM-dd (e.g.
2099-12-25) or empty.

Notes: This sets the inclusive date when the LegalTag expires and the
data it relates to is no longer usable in the Data Ecosystem. This
normally is taken from the physical contract's expiration date i.e. when
you supply a contract ID. This is non-mandatory field but is required
for certain types of data e.g. 3rd party. If the field is not set it
will be auto populated with the value 9999-12-31.

*Originator*

Valid values: Should be the name of the client, supplier or Self

Notes: This is always required.

Data type

Valid values: \'OSDU Data\', \'Public Domain Data\', \'EHC Data\',
\'Index Data\', \'Third Party Data\', \'Client Data\'\'.

Notes: Different data types are allowed dependent on the data partitions
e.g. vendor partitions have different governing rules as opposed to
standard partitions. To list the allowed data types for your data
partition use the LegalTag Properties. \'Third Party Data\' is allowed
ONLY with a contract ID and expiration date set. \'Client Data\' is the
ONLY allowed value in Client data partitions, and \'Client Data\' can be
allowed in OEDU data partitions under exemption, in which case the
contract ID and expiration date are required; contract ID and expiration
date are not required if ingesting \'Client Data\" in client data
partitions.

Security classification

Valid values: \'Public\', \'Private\', \'Confidential\'

Notes: This is the OEDU standard security classification for the data.
We currently do not allow \'Secret\' data to be stored in the Data
Ecosystem.

Export classification

Valid values: \'EAR99\', \'Not - Technical Data\', \'No License
Required\'

Notes: We currently only allow data with the ECCN classification
\'EAR99\'

Personal data

Valid values: \'Personally Identifiable\', \'No Personal Data\'

Notes: We do not currently allow data that is \'Sensitive Personal
Information\' and this should not be ingested.

Creating a Record

This relates to creating Records that are *NOT* derivatives. See the
derivative section below for details on Record creation for derivative
data.

Once you have a LegalTag created, you can assign it to as many Records
as you like. However, it is the data managers\' responsibility to assign
accurate LegalTags to data.

When creating a Record, the following needs to be assigned for legal
compliance:

-   The LegalTag name associated with the Record

-   The Alpha-2 country code of the original caller where the data is
    being ingested from

Below is a full example of the payload needed when creating a Record.
The *legal* section shows what is required.

\[{

\"acl\": {

\"owners\": \[

\"data.default.owners\@common.osdu.\[osdu\].org\"

\],

\"viewers\": \[

\"data.default.viewers\@common.osdu.\[osdu\].org\"

\]

},

\"data\": {

\"count\": 123456789

},

\"id\": \"common:id:123456789\",

\"kind\": \"common:welldb:wellbore:1.0.0\",

\"legal\" :{

\"legaltags\": \[

\"common-demo-legaltag\"

\],

\"otherRelevantDataCountries\": \[\"US\"\] //the physical location of
the person ingesting the data

}

}\]

-   legaltags - This section represents the names of the LegalTag(s)
    associated with the Record. This has to be supplied when the Record
    represents raw or source data (i,e, not derivative data)

-   otherRelevantDataCountries - This is the Alpha-2 country codes for
    the country the data was ingested from and the country where the
    data is located in Data Ecosystem.

You can get the list of all valid LegalTags using the Get LegalTags API
method. You can use this to help assign only valid LegalTags to data
when ingesting.

GET /api/legal/v1/legaltags?valid=true

Example 200 Response

{

\"legalTags\": \[

{

\"name\": \"OSDU-ehc-public\",

\"description\": \"\",

\"properties\": {

\"countryOfOrigin\": \[

\"US\"

\],

\"contractId\": \"A1234\",

\"expirationDate\": \"2099-01-25\",

\"originator\": \"OSDU\",

\"dataType\": \"EHC Data\",

\"securityClassification\": \"Public\",

\"personalData\": \"No Personal Data\",

\"exportClassification\": \"EAR99\"

}

},

{

\"name\": \"OSDU-welldb-public\",

\"description\": \"\",

\"properties\": {

\"countryOfOrigin\": \[

\"US\"

\],

\"contractId\": \"AB123\",

\"expirationDate\": \"2099-12-25\",

\"originator\": \"OSDU\",

\"dataType\": \"OSDU Data\",

\"securityClassification\": \"Public\",

\"personalData\": \"No Personal Data\",

\"exportClassification\": \"EAR99\"

}

},

\...

\...

\...

}

Curl

curl \--request GET \\

\--url
\'https://api.osdu.\[osdu\].org/de/legal/v1/legaltags?valid=true\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-data-partition-id: common\' \\

What are Derivatives?

Often when ingesting data into the Data Ecosystem, it is the raw data
itself. In these scenarios, you associate a single LegalTag with this
data.

However, in the case when the data to be ingested come from multiple
sources, it is the case of derivative data. For instance, what if you
take multiple Records from the Data Ecosystem and create a whole new
Record based on them all? Or what if you run an algorithm over your
seismic data and create an attribute associated with this data you want
to ingest?

At this point, you have derivative data (i.e., data derived from data).
In these scenarios, you will need to assign LegalTags to this new data
which is the union of the LegalTags associated to all the source data
from which it was created.

For instance, I have Data A associated with LegalTag 1, and Data B
associated with LegalTag 2. If I create Data C from Data A and Data B,
then I need to associate both LegaltTag 1 and LegalTag 2 to Data C.

Creating derivative Records

When creating Records that represent derivative data, the following must
be assigned:

-   The Record Id and version of all the Records that are the direct
    parents of the new derivative. This is added to the *ancestry*
    section

-   The Alpha-2 country code of where the derivative was created

Below is an example of the minimum number of fields required to ingest a
derivative Record.

\[{

\"acl\": {

\"owners\": \[

\"data.default.owners\@common.osdu.\[osdu\].org\"

\],

\"viewers\": \[

\"data.default.viewers\@common.osdu.\[osdu\].org\"

\]

},

\"data\": {

\"count\": 123456789

},

\"id\": \"common:id:123456789\",

\"kind\": \"common:welldb:wellbore:1.0.0\",

\"legal\" :{

\"otherRelevantDataCountries\": \[\"US\"\] //the physical location of
where the derivative was created

},

\"ancestry\" :{

\"parents\": \[\"common:id:1:version\", \"common:id:2:version\"\] //the
record ids and versions of the Records this derivative was created from

}

}\]

As shown the parent Records are provided as well as the ORDC of where
the derivative was created. The Record service takes responsibility for
populating the full LegalTag and ORDC values based on the parents.

Validating a LegalTag

The Storage service validates whether a Record is legally compliant
during ingestion and consumption. Therefore, you can delegate the effort
to the Record service as the request will fail if the Record is not
compliant.

However, there may be times you want to validate LegalTags directly.

You can validate a LegalTag by using the LegalTag validate API supplying
the names of the LegalTags you wish to validate e.g.

POST /api/legal/v1/legaltags:validate

Body

{

\"names\": \[\"common-demo-legaltag\"\]

}

If the LegalTag is valid, the response then looks something like this

{

\"invalidLegalTags\": \[\]

}

If the LegalTag is invalid, the response then looks something like this

{

\"invalidLegalTags\": \[

{\"name\":\"common-demo-legaltag\", \"reason\": \"Contract expired\"}

\]

}

Curl

curl \--request POST \\

\--url \'https://api.osdu.\[osdu\].org/de/legal/v1/legaltags:validate\'
\\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-data-partition-id: common\' \\

\--data \'{

\"names\": \[\"common-demo-legaltag\"\]

}\'

So if you just want to check that the given LegalTag(s) are currently
valid, you only have to check if the returned \'invalidLegalTags\'
collection is empty.

Ingestion services forward the request to the LegalTag API using the
same *SAuth* token making the ingestion request. This checks both that a
LegalTag exists and that the data has appropriate access to it.

Updating a LegalTag

One of the main cases where a LegalTag can become invalid is if a
contract expiration date passes. This makes both the LegalTag invalid
and *all* data associated with that LegalTag including derivatives.

In these situations, we can update LegalTags to make them valid again
and so make the associated data accessible. Currently we only allow the
update of the *description*, *contract ID* and *expiration date*
properties.

PUT /api/legal/v1/legaltags

Body

{

\"name\": \"common-demo-legaltag\", //the name of the legaltag you are
updating

\"contractId\", \"AE12345\"

\"expirationDate\", \"2099-12-21\"

}

Compliance on consumption

As previously stated, the Records in the Storage service largely governs
data compliance. This means that if you use the Storage or Search core
services, then compliance on consumption is handled on your behalf i.e.
these services will not return Records that are no longer legally
compliant.

However, there are use cases where you may not use these services all
the time e.g. if you have your own operational data store. In these
cases, you will need to check the LegalTags associated with your data
are still valid before allowing consumption. For this, we have a Pub-Sub
topic that can be subscribed to.

This topic has the form

projects/{oeduProjectId}/topics/legaltags_changed

This means you need to make a subscription to every data partition
project you wish to receive the notifications on.

*NOTE: When new data partitions are added into the Data Ecosystem, it
may take up to 24 hours for the topic to become available to subscribe
to.*

The LegalTag Changed notification

After subscribing to the topic, you will receive notifications daily.
These notifications will list all LegalTags that have changed, and
whether the LegalTag has become compliant or non-compliant.

{

\"statusChangedTags\": \[ {

\"changedTagName\": \"legaltag-name1\",

\"changedTagStatus\": \"compliant\"

},

{

\"changedTagName\": \"legaltag-name2\",

\"changedTagStatus\": \"incompliant\"

} \]

}

The above shows an example message sent to subscribers. It shows you
receive an array of items. Each item has the LegalTag name that has
changed and whether it has changed to be compliant or incompliant.

If it has become incompliant, you must make sure associated data is no
longer allowed to be consumed.

If it is marked compliant, data that was not allowed for consumption can
now be consumed through your services.

### Indexer Service: 

Usage

The Indexer API provides a mechanism for indexing documents that contain
structured or unstructured data. Documents and indices are saved in a
separate persistent store optimized for search operations. The indexer
API can index any number of documents.

The indexer is indexes attributes defined in the schema. Schema can be
created at the time of record ingestion in Data Ecosystem via Storage
Service. The Indexer service also adds number of Data Ecosystem meta
attributes such as id, kind, parent, acl, namespace, type, version,
legaltags, index to each record at the time of indexing.

Indexer API access

-   Required roles

> Indexer service requires that users (and service accounts) have
> dedicated roles in order to use it. The following roles should be
> created and assigned using the entitlements service:
>
> **users.OSDU.viewers**
>
> **users.OSDU.editors**
>
> **users.OSDU.admin**

-   Required headers

> The Data Ecosystem stores data in different data partitions depending
> on the different accounts in the OEDU system.
>
> A user may belong to many partitions in OEDU e.g. an OEDU user may
> belong to both the OEDU partition and a customer\'s partition. When a
> user logs into the OEDU portal they choose which data partition they
> currently want to be active.
>
> When using the Indexer APIs, you need to specify which data partition
> they currently have active and send it in the OSDU-Data-Partition-Id
> header. e.g.
>
> OSDU-Data-Partition-Id: OSDU
>
> The correct values can be obtained from CFS services.
>
> We use this value to work out which partition to use. There is also a
> special data partition known as common
>
> OSDU-Data-Partition-Id: common
>
> This has all public data in the Data Ecosystem. Users always have
> access to this as well as their current active data partition.
>
> You should also send a correlation id as a header so that a single
> request can be tracked throughout all the services it passes through.
> This can be a GUID on the header with a key
>
> OSDU-Correlation-Id: 1e0fef08-22fd-49b1-a5cc-dffa21bc0b70
>
> If you are the service initiating the request you should generate the
> id, otherwise you should just forward it on in the request.

Get indexing status

Indexer service adds internal meta data to each record which registers
the status of the indexing. The meta data includes the status and the
last indexing date and time. This additional meta block helps to see the
details of indexing. The format of the index meta block is as follows:

\"index\": {

\"trace\": \[

String,

String

\],

\"statusCode\": Integer,

\"lastUpdateTime\": Datetime

}

Example:

{

\"results\": \[

{

\"index\": {

\"trace\": \[

\"datetime parsing error: unknown format for attribute: endDate \|
value: 9000-01-01T00:00:00.0000000\",

\"datetime parsing error: unknown format for attribute: startDate \|
value: 1990-01-01T00:00:00.0000000\"

\],

\"statusCode\": 400,

\"lastUpdateTime\": \"2018-11-16T01:44:08.687Z\"

}

}

\],

\"totalCount\": 31895

}

Details of the index block:

1.  trace: This field collects all the issues related to the indexing
    and concatinates using \'\|\'. This is a String field.

2.  statusCode: This field determines the category of the error. This is
    integer field. It can have the following values:

    -   200 - All OK

    -   404 - Schema is missing in Storage

    -   400 - Some fields were not properly mapped with the schema
        defined

3.  lastUpdateTime: This field captures the last time the record was
    updated by by the indexer service. This is datetime field so you can
    do range queries on this field.

You can query the index status using the following example query:

curl \--request POST \\

\--url /api/search/v2/query \\

\--header \'Authorization: Token\' \\

\--header \'Content-Type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: Data partition id\' \\

\--data \'{\"kind\": \"\*:\*:\*:\*\",\"query\":
\"index.statusCode:404\",\"returnedFields\": \[\"index\"\]}\'

NOTE: By default, the API response excludes the \'index\' attribute
block. The user must specify \'index\' as the \'returnedFields\" in
order to see it in the response.

The above query will return all records which had problems due to fields
mismatch.

Reindex

Reindex API allows users to re-index a kind without re-ingesting the
records via storage API. Reindexing a kind is an asynchronous operation
and when a user calls this API, it will respond with HTTP 200 if it can
launch the re-indexing or appropriate error code if it cannot. The
current status of the indexing can be tracked by calling search API and
making query with this particular kind. Please be advised, it may take
few seconds to few hours to finish the re-indexing as multiple factors
contribute to latency, such as number of records in the kind, current
load at the indexer service etc.

**Note**: If a kind has been previously indexed with particular schema
and if you wish to apply the schema changes during re-indexing, previous
kind index has to be deleted via Index Delete API. In absence of this
clean-up, reindex API will use the same schema and overwrite records
with the same ids.

POST /api/indexer/v2/reindex

{

\"kind\": \"common:welldb:wellbore:1.0.0\"

}

\*\*Curl\*\*

curl \--request POST \\

\--url \'/api/indexer/v2/reindex\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: common\' \\

\--data \'{

\"kind\": \"common:welldb:wellbore:1.0.0\"

}\'

Copy Index

Copy Index API can be used copy kind index from common to a private data
partition search backend. To call it, kind from common partition should
be provided as path parameter and private partition-id should be
specified in OSDU-Data-Partition-Id header.

**Note**: Copy Index API is intended for only copying kind index from
common cluster to private partition cluster, no other combination of
data partitions is honored at this time.

POST /api/indexer/v2/copyIndex/copy/{kind}

OSDU-Data-Partition-Id:OSDU

\*\*Curl\*\*

curl \--request POST \\

\--url \'/api/indexer/v2/copyIndex/copy/common:welldb:wellbore:1.0.0\'
\\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: OSDU\'

The successful response from the above request will be a task-id, this
can be later used to track the status of the task via task status
API(\#get-task-status).

{

\"task\": \"CrOX4STSQF6kgtSRdERhbw:92863567\"

}

Get task status

Status of ongoing or completed index copy request for given taskId can
retrieved via GET task status api.

GET /api/indexer/v2/copyIndex/taskStatus/{taskId}

\*\*Curl\*\*

curl \--request GET \\

\--url \'/api/indexer/v2/copyIndex/taskStatus/\[taskid\]\]\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: OSDU\'

API will respond with status of task.

{

\"completed\": true,

\"task\": {

\"node\": \"\[nodeid\]\",

\"id\": 113159669,

\"type\": \"transport\",

\"action\": \"indices:data/write/reindex\",

\"status\": {

\"total\": 1530,

\"updated\": 0,

\"created\": 1530,

\"deleted\": 0,

\"batches\": 1,

\"version_conflicts\": 0,

\"noops\": 0,

\"retries\": {

\"bulk\": 0,

\"search\": 0 },

\"throttled_millis\": 0,

\"requests_per_second\": -1,

\"throttled_until_millis\": 0

},

\"description\": \"reindex from \[scheme=https host=host-id port=9243
query={\\n \\\"match_all\\\" : {\\n \\\"boost\\\" : 1.0\\n
}\\n}\]\[common:welldb:wellbore:1.0.0\] to
\[common:welldb:wellbore:1.0.0\]\",

\"start_time_in_millis\": 1539735233086,

\"running_time_in_nanos\": 1094744315,

\"cancellable\": true,

\"headers\": {} },

\"response\": {

\"took\": 1084,

\"timed_out\": false,

\"total\": 1530,

\"updated\": 0,

\"created\": 1530,

\"deleted\": 0,

\"batches\": 1,

\"version_conflicts\": 0,

\"noops\": 0,

\"retries\": {

\"bulk\": 0,

\"search\": 0 },

\"throttled_millis\": 0,

\"requests_per_second\": -1,

\"throttled_until_millis\": 0,

\"failures\": \[\]

}

}

### Indexer-Queue Service: 

Usage

A queue-based service which listen to the messages published by storage
service and calls indexer service for further processing. This service
is not public facing and is internal to the platform. The service
provisions number of message queues for handling the fail-safe scenarios
of Storage and Legal services.

Thus, to support exception handling feature to place message
back(requeue) on original queue is provided as part of this service.
Thus, Storage and Legal services can decouple themselves from the
Indexer service and work asynchronously with it.

The design below illustrates, how the queue service facilitates the
Storage and Legal service to have a consistent handshake between them.

![](media/image13.png){width="4.692556867891514in"
height="4.795833333333333in"}

**\<\<WIP\>\>**

### Storage Service:

Usage

After performing the basic user management procedures (create users and
groups, assign users to groups, etc.) through Entitlements Service,
industry developer/users can use the OEDU Data Ecosystem Storage API to
ingest metadata information generated by any industry applications into
the OEDU Data Ecosystem. The Storage Service provides a set of APIs to
manage the entire metadata life cycle such as ingestion (persistence),
modification, deletion, versioning and data schema.

Record structure

From the Storage Service perspective, the metadata to be ingested is
called **record**. Below is a basic example of a Data Ecosystem record
with a brief explanation of each field:

{

\"id\": \"common:hello:123456\",

\"kind\": \"common:test:hello:1.0.0\",

\"acl\": {

\"viewers\":
\[\"data.default.viewers\@common.\[osdu.opengroup.org\]\"\],

\"owners\": \[\"data.default.owners\@common.\[osdu.opengroup.org\]\"\]

},

\"legal\": {

\"legaltags\": \[\"common-sample-legaltag\"\],

\"otherRelevantDataCountries\": \[\"FR\",\"US\",\"CA\"\]

},

\"data\": {

\"msg\": \"Hello World, Data Ecosystem!\"

}

}

-   **id**: *(optional)* Unique identifier in the Data Ecosystem. When
    not provided, the service will create and assign an id to the
    record. Must follow the naming convention:
    {Data-Partition-Id}:{object-type}:{uuid}.

-   **kind**: *(mandatory)* Kind of data being ingested. Must follow the
    naming convention:
    {Data-Partition-Id}:{dataset-name}:{record-type}:{version}.

-   **acl**: *(mandatory)* Group of users who have access to the record.

    -   **acl.viewers**: List of valid groups which will have view/read
        privileges over the record. We follow the naming convention such
        that data groups begin with data..

    -   **acl.owners**: List of valid groups which will have write
        privileges over the record. We follow the naming convention such
        that data groups begin with data..

-   **legal**: *(mandatory)* Attributes which represent the legal
    constraints associated with the record.

    -   **legal.legaltags**: List of legal tag names associated with the
        record.

    -   **legal.otherRelevantDataCountries**: List of other relevant
        data countries. Must have at least 2 values: where the data was
        ingested from and where Data Ecosystem stores the data.

-   **data**: *(mandatory)* Record payload represented as a list of
    key-value pairs.

Schema structure

Another important concept in the OEDU Data Ecosystem Storage Service is
**schema**. Schema is a structure, also defined in JSON, which provides
data type information for the record fields. In other words, the schema
defines whether a given field in the record is a string, or an integer,
or a float, or a geopoint, etc.

It is important to note that only fields with schema information
associated with are indexed by the Search Service. For this reason, the
OEDU users must create the respective schema for his/her records kind
before start ingesting records into the Data Ecosystem.

Schemas and records are tied together by the kind attribute. On top of
that, a given kind can have zero or exactly one schema associated with.
Having that concept in mind, the OEDU user can make use of two APIs for
schema management provided by the OEDU Data Ecosystem Storage Service
API:

POST /api/storage/v2/schemas

GET /api/storage/v2/schemas/{kind}

In order to make use of the storage API, for any functional scenario
following steps need to be followed:

Choosing a partition

The OEDU Data Ecosystem stores data in different tenants depending on
the different accounts in the DELFI system. A user may belong to many
accounts in DELFI e.g. a SLB user may belong to both the SLB account and
a customer\'s account. When a user logs into the industry applications
at his/her end, one chooses which account to be active. When using the
Storage Service APIs, specify the active account as the
Slb-Data-Partition-Id. The correct values can be obtained from CFS
services.

Creating data groups

Please refer to Entitlements Service to learn how to create data groups
(the ones which starts with data.) and assign users to them. For data
access authorization purposes in this example, let\'s assume the groups
data.default.viewers\@instance.osdu.opengroup.org and
data.default.owners\@instance.osdu.opengroup.org were previously created
via Entitlements Service.

Creating the schema

The schema creation is done via the POST /api/storage/v2/schemas API.
For the sample workflow in question, the schema could be created as
follows:

**curl**

curl \--request POST \\

\--url \'/api/storage/v2/schemas\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'Slb-Data-Partition-Id: common\' \\

\--data \'{

\"kind\": \"common:welldb:wellbore:1.0.0\",

\"schema\": \[

{

\"path\": \"name\",

\"kind\": \"string\"

},

{

\"path\": \"company\",

\"kind\": \"string\"

},

{

\"path\": \"drillingYear\",

\"kind\": \"int\"

},

{

\"path\": \"depth\",

\"kind\": \"float\"

},

{

\"path\": \"location\",

\"kind\": \"core:dl:geopoint:1.0.0\"

}

\]

}\'

The schema is basically composed by a list of path/kinds pairs where the
record fields are related to their data type.

Storage service APIs

The OEDU Data Ecosystem Storage service has three different categories
of API\'s

> 1.Schemas
>
> 2.Records
>
> 3.Query for schema and record management.

Schema API's

> Create Schema : As explained in the section above.
>
> Get Schema: The schema for a given \'kind\' can be retrieved using the
> Get Schema API.
>
> *GET /api/storage/v2/schemas/{kind}*
>
> **curl**
>
> curl \--request GET \\
>
> \--url \'/api/storage/v2/schemas/{kind}\' \\
>
> \--header \'accept: application/json\' \\
>
> \--header \'authorization: Bearer \<JWT\>\' \\
>
> \--header \'content-type: application/json\' \\
>
> \--header \'Data-Partition-Id: common\'

Query: The API returns a list of all kinds in the specific
{Data-Partition-Id}.

> *GET /api/storage/v2/query/kinds*
>
> Parameters

  **Parameter**   **Description**
  --------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  limit           The maximum number of results to return from the given offset. If no limit is provided, then it will return **10** items. Max number of items which can be fetched by the query is **100**.

> **curl**
>
> curl \--request GET \\
>
> \--url \'/api/storage/v2/query/kinds\' \\
>
> \--header \'accept: application/json\' \\
>
> \--header \'authorization: Bearer \<JWT\>\' \\
>
> \--header \'content-type: application/json\' \\
>
> \--header \'Data-Partition-Id: common\'
>
> \--data \'{
>
> \"limit\": 10,
>
> }

Fetch Records

The API fetches multiple records (maximum 20) from storage service at
once, it allows user to request data being converted to common standard
by using customized header {frame-of-reference}. Common standard is
units in SI, crs in wgs84, elevation in msl, azimuth in true north,
dates in utc. Currently only \"none\" and
\"units=SI;crs=wgs84;elevation=msl;azimuth=true north;dates=utc;\" are
valid values for the header {frame-of-reference}.

As for now, we only support conversion for units and crs. Dates,
elevation and azimuth will be available later. Returned records could be
either original value or converted(units=SI;crs=wgs84) value depending
on users\' requests and conversion status, original value will be
returned when users not request the conversion or the conversion is
requested but failed. In addition to records user requests, if
conversion is requested, a list of conversion status of each record
would be included in the response, indicating whether the conversion was
successful or not, it not, what were the errors happened.

POST /api/storage/v2/query/records:batch

**curl**

> curl \--request POST \\
>
> \--url \'/api/storage/v2/query/records:batch\' \\
>
> \--header \'Authorization: Bearer \<JWT\>\' \\
>
> \--header \'Content-Type: application/json\' \\
>
> \--header \'Data-Partition-Id: common\' \\
>
> \--header \'frame-of-reference:
> units=SI;crs=wgs84;elevation=msl;azimuth=true north;dates=utc;\' \\
>
> \--data \'{
>
> \"records\": \[
>
> \"common:well:123456789\",
>
> \"common:wellTop:abc789456\",
>
> \"common:wellLog:4531wega22\"
>
> \]
>
> }

Create or Update records []{#Creating-records .anchor}

The API represents the main injection mechanism into the Data Ecosystem.
It allows records creation and/or update. When no record id is provided
or when the provided id is not already present in the Data Ecosystemthen
a new record is created. If the id is related to an existing record in
the Data Ecosystemthen an update operation takes place and a new version
of the record is created. More details available at [Creating
records](#Creating-records) and [Ingesting records](#Ingesting-records)
sections.

Get record version

The API retrieves the specific version of the given record.

*GET /api/storage/v2/records/{id}/{version}*

Parameters

  **Parameter**   **Description**
  --------------- --------------------------------------------------------------------------------------------------------
  attribute       Filter attributes to restrict the returned fields of the record. Usage: data.{record-data-field-name}.

**curl**

curl \--request GET \\

\--url \'/api/storage/v2/records/{id}/{version}\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'Data-Partition-Id: common\'

\--data \'{

\"attributes\": \[

\"data.msg\"

\]

}

Get all record versions

The API returns a list containing all versions for the given record id.

*GET /api/storage/v2/records/versions/{id}*

**curl**

curl \--request GET \\

\--url \'/api/storage/v2/records/versions/{id}\'\\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'Data-Partition-Id: common\'

Get record

This API returns the latest version of the given record.

*GET /api/storage/v2/records/{id}*

Parameters

  **Parameter**   **Description**
  --------------- --------------------------------------------------------------------------------------------------------
  attribute       Filter attributes to restrict the returned fields of the record. Usage: data.{record-data-field-name}.

**curl**

> curl \--request GET \\
>
> \--url \'/api/storage/v2/records/{id}\'\\
>
> \--header \'accept: application/json\' \\
>
> \--header \'authorization: Bearer \<JWT\>\' \\
>
> \--header \'content-type: application/json\' \\
>
> \--header \'Data-Partition-Id: common\' \\
>
> \--data \'{
>
> \"attributes\": \[
>
> \"data.msg\"
>
> \]
>
> }

Delete record

The API performs a logical deletion of the given record. This operation
can be reverted later.

*POST /api/storage/v2/records/{id}:delete*

**curl**

> curl \--request POST \\
>
> \--url \'/api/storage/v2/records/{id}:delete\' \\
>
> \--header \'accept: application/json\' \\
>
> \--header \'authorization: Bearer \<JWT\>\' \\
>
> \--header \'content-type: application/json\'\\
>
> \--header \'Data-Partition-Id: common\'

Using service accounts to access Storage APIs

The Storage service relies on the Google native data access
authorization mechanisms to provide access control on the records. Based
on design decisions, when the Storage service caller is a federated
user, no additional configuration is necessary, however if the API
caller is a service account, a mandatory configuration is necessary as
follows:

-   Navigate to the GCP project which the caller service account belongs
    to;

-   Go to IAM & admin \> service accounts;

-   Select the caller service account;

-   In the right-hand side Permissions panel, click at \"Add member\"
    button;

-   In the member text box add the following email
    {DATA_ECOSYSTEM_PROJECT}\@appspot.gserviceaccount.com. For instance,
    in P4D environment the member email is
    p4d-ddl-eu-services\@appspot.gserviceaccount.com;

-   Select the role Service Accounts \> Service Account Token Creator.

Using skipdupes

The skipdupes param is only related to update operations, which means
you are calling the API with record IDs already present into the Data
Ecosystem. If skipdupes==true, it means the service will not update the
record if the payload is the same (duplicates). If there is a difference
in the payload, then a new version of the record will be created. On the
other hand, skipdupes == false, in an update operation, the service will
not check whether the payload is the same or not and will always create
a new version, even if identical to a previous version. On the response
side, skipedRecordIds are the record IDs which weren\'t updated
(skipped) due skipdupes == true and same payload. In PUT response, there
will be no more replication in the record IDs, they will be in either
recordIds or skippedRecordIds.

### Search Service:

Usage

The Search API provides a mechanism for searching indexed documents that
contain structured data. You can search an index and organize and
present search results. Documents and indexes are saved in a separate
persistent store optimized for search operations. The Search API can
index any number of documents.

The API supports full text search on string fields, range queries on
date, numeric or string fields etc. along with geo-spatial search.

Search API access

-   Required roles

> Search service requires that users have dedicated roles in order to
> use it. Users must be a member of users.osdu.viewers or
> users.osdu.editors or users.osdu.admins, roles can be assigned using
> the Entitlements Service. Please look at the API documentation for
> specific requirements.
>
> In addition to service roles, users must be a member of data groups to
> access the data.

-   Required headers

> The OEDU Data Ecosystem stores data in different partitions, depending
> on the different accounts in the OEDU system.
>
> A user may belong to more than one account. As a user, after logging
> into the OEDU portal, you need to select the account you wish to be
> active. Likewise, when using the Search APIs, you need to specify the
> active account in the header called OSDU-Data-Partition-Id. The
> correct OSDU-Data-Partition-Id can be obtained from the CFS services.
> The OSDU-Data-Partition-Id enables the search within the mapped
> partition. e.g.
>
> OSDU-Data-Partition-Id: OEDU
>
> There is also a special data partition known as "common", which
> contains all public data in the Data Ecosystem, and is accessible to
> all users.
>
> OSDU-Data-Partition-Id: common

-   Optional headers

> The Correlation-Id is a traceable ID to track the journey of a single
> request. The Correlation-Id can be a GUID on the header with a key. It
> is best practice to provide the Correlation-Id so the request can be
> tracked through all the services.
>
> OSDU-Correlation-Id: 1e0fef08-22fd-49b1-a5cc-dffa21bc0b70

If the service is initiating the request, an ID should be generated. If
the Correlation-Id is not provided, then a new ID will be generated by
the service so that the request would be traceable.

Query

Data Ecosystem search provides a JSON-style domain-specific language
that you can use to execute queries. Query request URL and samples are
as follows:

**curl**

> curl
>
> \--request POST \\
>
> \--url \'/api/search/v2/query\' \\
>
> \--header \'accept: application/json\' \\
>
> \--header \'authorization: Bearer \<JWT\>\' \\
>
> \--header \'content-type: application/json\' \\
>
> \--header \'OSDU-Data-Partition-Id: common\' \\
>
> \--data \'{
>
> \"kind\": \"common:welldb:wellbore:1.0.0\",
>
> \"query\": \"data.Status:Active\",
>
> \"offset\": 0,
>
> \"limit\": 30,
>
> \"sort\": {
>
> \"field\": \[\"id\"\],
>
> \"order\": \[\"ASC\"\]
>
> },
>
> \"queryAsOwner\": false,
>
> \"spatialFilter\": {
>
> \"field\": \"data.Location\",
>
> \"byBoundingBox\": {
>
> \"topLeft\": {
>
> \"latitude\": 37.450727,
>
> \"longitude\": -122.174762
>
> },
>
> \"bottomRight\": {
>
> \"latitude\": 36.450727,
>
> \"longitude\": -122.174762
>
> } } },
>
> \"returnedFields\": \[ \"data.Status\" \]
>
> }\'

**Note:** It can take a delay of atleast 30 seconds once records are
successfully ingested via Storage service to become searchable in DE.
You can check the index status.

Parameters

  **Parameter**    **Description**
  ---------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  kind             The kind of the record to query e.g. \'common:welldb:wellbore:1.0.0\'. kind is a **required** field and can be formatted as OSDU-Data-Partition-Id:data-source-id:entity-type:schema-version
  query            The query string in Lucene query string syntax.
  offset           The starting offset from which to return results.
  limit            The maximum number of results to return from the given offset. If no limit is provided, then it will return **10** items. Max number of items which can be fetched by the query is **100**. (If you wish to fetch large set of items, please use query_with_cursor API).
  sort             Allows you to add one or more sorts on specific fields. The length of fields and the length of order must match. Order value must be either ASC or DESC (case insensitive). For more details, ability and limitation about this feature, please refer to Sort
  queryAsOwner     If true, the result only contains the records that the user owns. If false, the result contains all records that the user is entitled to see. Default value is false
  spatialFilter    A spatial filter to apply, please see Geo-Spatial Queries.
  returnedFields   The fields on which to project the results.

**Note:** Offset + Limit cannot be more than the 10,000. See the Query
with Cursor for more efficient ways to do deep scrolling.

Query by kind

\"kind\" can be formatted as
account-id:data-source-id:type:schema-version and a **required** field.
Available list of \"kind\" can be retrieved via storage service. Users
can make search documents just by providing \"kind\" as shown:

**curl**

> curl \--request POST \\
>
> \--url \'/api/search/v2/query\' \\
>
> \--header \'accept: application/json\' \\
>
> \--header \'authorization: Bearer \<JWT\>\' \\
>
> \--header \'content-type: application/json\' \\
>
> \--header \'OSDU-Data-Partition-Id: common\' \\
>
> \--data \'{
>
> \"kind\": \"common:welldb:wellbore:1.0.0\"
>
> }\'

The query will return 10 (default limit) documents for the kind.

Wildcard queries on kind are also supported, please look at Cross-Kind
Queries & Cross-Partition Queries below for more information.

Data Ecosystem indexer also splits \"kind\" and index each part
individually. These terms can then be queried by query request
parameter, e.g. common:welldb:wellbore:1.0.0 will be indexed
as namespace=common:welldb, type=well and version=1.0.0. Data Ecosystem
can be now queried to search based on one these attributes.

Text Queries

Data Ecosystem provides comprehensive query options in Lucene query
syntax. The query string is parsed into a series of terms and operators.
A term can be a single word - \"producing\" or \"well\" - or a phrase,
surrounded by double quotes - \"producing well\" - which searches for
all the words in the phrase, in the same order. The default operator for
query is **OR**.

A field in the document can be searched by
using \<field-name\>:\<value\>. If field is not defined, then it
defaults to all queryable fields; and the query will automatically
attempt to determine the existing fields in the index's mapping that are
queryable and perform the search on those fields.

The query language is quite comprehensive and can be intimidating at
first glance, but the best way to actually learn it is to start with a
few basic examples.

**Note:** kind is a required parameter and is omitted for brevity in
following examples. Also, all storage record properties are in \'data\'
block, any reference to a field inside the block should be prefixed with
\'data.\'

Examples

-   search all fields which contains text \'well\'

> {
>
> \"query\": \"well\"
>
> }
>
> **Note:** In absence of \<field-name\>, the query string will
> automatically attempt to determine the existing fields in the index's
> mapping that are queryable, and perform the search on those fields.
> Search query will be more performant if field name is specified in the
> query instead of searching across all queryable attribute. The
> following examples cover this:

-   where the Basin field contains \"Permian\"

> {
>
> \"query\": \"data.Basin:Permian\"
>
> }

-   where the Rig_Contractor field contains \"Ocean\" or \"Drilling\".
    > OR is the default operator

> {
>
> \"query\": \"data.Rig_Contractor:(Ocean OR Drilling)\"
>
> }
>
> Or
>
> {
>
> \"query\": \"data.Rig_Contractor:(Ocean Drilling)\"
>
> }

-   where the Rig_Contractor field contains the exact phrase \"Ocean
    > Drilling\"

> {
>
> \"query\": \"data.Rig_Contractor:\\\"Ocean Drilling\\\"\"
>
> }

-   where any of the fields ValueList.OriginalValue, ValueList.Value or
    > ValueList.AppDataType contains \"PRODUCING\" or \"DUAINE\" (note
    > how we need to escape the \* with a backslash)

> {
>
> \"query\": \"data.ValueList.\\\\\*:(PRODUCING DUAINE)\"
>
> }

-   where the field Status has any non-null value, use the \_exists\_
    > prefix for a field will search to see if the field exists

> {
>
> \"query\": \"\_exists\_:data.Status\"
>
> }

Grouping

Multiple terms or clauses can be grouped together with parentheses, to
form sub-queries

{

\"query\": \"data.Rig_Contractor:(Ocean OR Drilling) AND Exploration NOT
Basin\"

}

Reserved characters

If you need to use any of the characters which function as operators in
your query itself (and not as operators), then you should escape them
with a leading backslash. For instance, to search for (1+1)=2, you would
need to write your query as \\(1\\+1\\)\\=2.

The reserved characters are: + - = && \|\| \> \< ! ( ) { } \[ \] \^ \"
\~ \* ? : \\ /

Failing to escape these special characters correctly could lead to a
syntax error which prevents your query from running.

**Note:** \< and \> can't be escaped at all. The only way to prevent
them from attempting to create a range query is to remove them from the
query string entirely.

Wildcards

Wildcard searches can be run on individual terms, using? to replace a
single character, and \* to replace zero or more characters.

{

\"query\": \"data.Rig_Contractor:Oc?an Dr\*\"

}

Be aware that wildcard queries can use an enormous amount of memory and
therefore can affect the performance. They should be used very
sparingly.

**Note:** Leading wildcards are disabled by Data Ecosystem Search.
Allowing a wildcard at the beginning of a word (e.g. \"\*ean\") is
particularly heavy, because all terms in the index need to be examined,
just in case they match.

Date Format

If you need to use date in your query, it has to be in one of the
following formats

date-opt-time = date-element \[\'T\' \[time-element\] \[offset\]\]

*Example:* 2017-12-29T00:00:00.987

Please note that the time element is optional

date-element = std-date-element

std-date-element = yyyy \[\'-\' MM \[\'-\' dd\]\]

*Example:* 2017-12-29

time-element = HH \[minute-element\] \| \[fraction\]

minute-element = \':\' mm \[second-element\] \| \[fraction\]

second-element = \':\' ss \[fraction\]

fraction = (\'.\' \| \',\') digit+

offset = \'Z\' \| ((\'+\' \| \'-\') HH \[\':\' mm \[\':\' ss \[(\'.\' \|
\',\') SSS\]\]\])

Sort

The sort feature supports int, float, double, long and datetime, but it
does not support array object, nested object or string field as of now,
and for the records contain such types won\'t return in the response.

The records either does not have the sorted fields or have empty value
will be listed last in the result.

E.g. Given

1.  here are 2 kinds match the request: common:welldb:wellbore:1.0.0 and
    > common:welldb:well:1.0.0

2.  data.Id in common:welldb:wellbore:1.0.0 has been ingested as
    > INTEGER, but data.Id in common:welldb:well:1.0.0 has been ingested
    > as TEXT

3.  common:welldb:wellbore:1.0.0 has 10 records in total and 5 of them
    > have empty value of data.Id field

4.  common:welldb:well:1.0.0 also has 10 records in total and all of
    > them have values in data.Id field

{

\"kind\": \"common:welldb:\*:\*\",

\"sort\": {

\"field\": \[\"data.Id\"\],

\"order\": \[\"ASC\"\]

}

}

The above request payload asks search service to sort on \"data.Id\" in
an ascending order, and the expected response will have \"totalCount:
10\" (instead of 20, please note that the 10 returned records are only
from common:welldb:wellbore:1.0.0 because the data.Id in
common:welldb:well:1.0.0 is of data type string, which is not currently
supported - and therefore, will not be returned) and should list the 5
records which have empty data.Id value at last.

**NOTE:** Search service does not validate the provided sort field,
whether it exists or is of the supported data types. Different kinds may
have attributes with the same names but are different data types.
Therefore, it is the user\'s responsibility to be aware and validate
this in one\'s own workflow.

The sort query could be very expensive, especially if the given kind is
too broad (e.g. \"kind\": \"*:*:*:*\"). The current time-out threshold
is 60 seconds; a 504 error (\"Request timed out after waiting for 1m\")
will be returned if the request times out. The suggestion is to make the
kind parameter as narrow as possible while using the sort feature.

Range Queries

Ranges can be specified for date, numeric or string fields. Inclusive
ranges are specified with square brackets \[min TO max\] and exclusive
ranges with curly brackets {min TO max}. Here are some of the examples:

-   All SpudDate in 2012

> {
>
> \"query\": \"data.SpudDate:\[2012-01-01 TO 2012-12-31\]\"
>
> }

-   Count 1..5

> {
>
> \"query\": \"data.Count:\[1 TO 5\]\"
>
> }

-   Count from 10 upwards

> {
>
> \"query\": \"data.Count:\[10 TO \*\]\"
>
> }

-   Ranges with one side unbounded can use the following syntax

> {
>
> \"query\": \"data.ProjDepth:\>10\" }

-   Combine an upper and lower bound with the simplified syntax, you
    > would need to join two clauses with an AND operator

> {
>
> \"query\": \"data.ProjDepth:(\>=10 AND \<20)\"
>
> }

Geo-Spatial Queries

Data Ecosystem supports geo-point geo data which supports lat/lon
pairs. spatialFilter and query group in the request have AND
relationship. If both of the criteria are defined in the query, then the
search service will return results which match both clauses.

The queries in this group are Geo Distance, Geo Polygon and Bounding
Box. Only one spatial criterion can be used while defining filter.

Geo Distance

Filters documents that include only hits that exist within a specific
distance from a geo point.

**curl**

> curl \--request POST \\
>
> \--url \'/api/search/v2/query\' \\
>
> \--header \'accept: application/json\' \\
>
> \--header \'authorization: Bearer \<JWT\>\' \\
>
> \--header \'content-type: application/json\' \\
>
> \--header \'OSDU-Data-Partition-Id: common\' \\
>
> \--data \'{
>
> \"kind\": \"common:welldb:wellbore:1.0.0\",
>
> \"spatialFilter\": {
>
> \"field\": \"data.Location\",
>
> \"byDistance\": {
>
> \"point\": {
>
> \"latitude\": 37.450727,
>
> \"longitude\": -122.174762
>
> },
>
> \"distance\": 1500
>
> }
>
> },
>
> \"offset\": 0,
>
> \"limit\": 30
>
> }\'

  **Parameter**     **Description**
  ----------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  field             geo-point field in the index on which filtering will be performed.
  distance          The radius of the circle centered on the specified location. Points which fall into this circle are considered to be matches. The distance can be specified in various units. See [Distance Units](https://community.opengroup.org/osdu/platform/system/search-service/-/blob/master/docs/tutorial/SearchService.md#distance-units)
  point.latitude    latitude of field.
  point.longitude   longitude of field.

Distance Units

If no unit is specified, then the default unit of the distance parameter
is meter. Distance can be specified in other units, such as \"1km\" or
\"2mi\" (2 miles).

**Note:** In the current version, the Search API only supports distance
in meters. In future versions, distance in other units will be made
available. The maximum value of distance is 1.5E308.

Bounding Box

A query allowing to filter hits based on a point location within a
bounding box.

**curl**

curl \--request POST \\

\--url \'/api/search/v2/query\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: common\' \\

\--data \'{

\"kind\": \"common:welldb:wellbore:1.0.0\",

\"spatialFilter\": {

\"field\": \"data.Location\",

\"byBoundingBox\": {

\"topLeft\": {

\"latitude\": 37.450727,

\"longitude\": -122.174762

},

\"bottomRight\": {

\"latitude\": 37.438485,

\"longitude\": -122.156110

}

}

},

\"offset\": 0,

\"limit\": 30

}\'

  **Parameter**           **Description**
  ----------------------- --------------------------------------------------------------------
  field                   geo-point field in the index on which filtering will be performed.
  topLeft.latitude        latitude of top left corner of bounding box.
  topLeft.longitude       longitude of top left corner of bounding box.
  bottomRight.latitude    latitude of bottom right corner of bounding box.
  bottomRight.longitude   longitude of bottom right corner of bounding box.

Geo Polygon

A query allowing to filter hits that only fall within a polygon of
points.

**curl**

curl \--request POST \\

\--url \'/api/search/v2/query\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: common\' \\

\--data \'{

\"kind\": \"common:welldb:wellbore:1.0.0\",

\"spatialFilter\": {

\"field\": \"data.Location\",

\"byGeoPolygon\": {

\"points\": \[

{\"longitude\":-90.65, \"latitude\":28.56},

{\"longitude\":-90.65, \"latitude\":35.56},

{\"longitude\":-85.65, \"latitude\":35.56},

{\"longitude\":-85.65, \"latitude\":28.56},

{\"longitude\":-90.65, \"latitude\":28.56}

\]

}

},

\"offset\": 0,

\"limit\": 30

}\'

Cross-Kind Queries

Data Ecosystem search supports cross-kind queries. A typical kind can be
formatted as account-id:data-source-id:type:schema-version. Each of the
text partitioned by \':\' can be replaced with wildcard characters to
support cross-kind search.

-   search across all data-source, types & versions for common

> {
>
> \"kind\": \"common:\*:\*:\*\"
>
> }

-   search across all data-source, type well with schema version 1.0.0

> {
>
> \"kind\": \"common:\*:well:1.0.0\"
>
> }

-   search across all types and versions for welldb namespace in common

> {
>
> \"kind\": \"common:welldb:\*:\*\"
>
> }

Cross-Partition Queries

In addition to cross-kind queries, Data Ecosystem search also supports
cross-partition queries thus enabling users to search records from
muliple partitions. Only one private and common partition are supported
for cross-partition searches. To call it, one should provide comma
separated list of partitions in OSDU-Data-Partition-Id. Cross-partition
search of course deals with larger data set and entitlements from
multiple partitions so it will always be less performant than
single-partition search. We should have this in mind when designing
queries so that they are optimized for the use case in question.

-   search across all types and versions for welldb namespace
    > in common and common partitions

> **curl**
>
> curl \--request POST \\
>
> \--url \'/api/search/v2/query\' \\
>
> \--header \'accept: application/json\' \\
>
> \--header \'authorization: Bearer \<JWT\>\' \\
>
> \--header \'content-type: application/json\' \\
>
> \--header \'OSDU-Data-Partition-Id: common,common\' \\
>
> \--data \'{
>
> \"kind\": \":welldb:\*:\*\"
>
> }\'

**Note:** Cross-partition queries are only supported to
one private & common partition, no other combinations are supported at
this time.

Query with Cursor

While a search request returns a single "page" of results,
the query_with_cursor API can be used to retrieve large numbers of
results (or even all results) from a single search request, in much the
same way as you would use a cursor on a traditional database.

Cursor API is not intended for real time user requests, but rather for
processing large amounts of data.

The parameters passed in the request body are exactly the same as
the query API except for the offset and cursor values. Please note that
offset is not a valid parameter in query_with_cursor API

**Note:** The results that are returned from a query_with_cursor request
reflect the state of the index at the time that the initial search
request was made, like a snapshot in time. Subsequent changes to
documents (index, update or delete) will only affect later search
requests.

In order to use the query_with_cursor request, initial search request
should use the following:

**curl**

curl \--request POST \\

\--url \'/api/search/v2/query_with_cursor\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: common\' \\

\--data \'{

\"kind\": \"common:welldb:wellbore:1.0.0\",

\"query\": \"data.Status:Active\",

\"limit\": 30,

\"spatialFilter\": {

\"field\": \"data.Location\",

\"byBoundingBox\": {

\"topLeft\": {

\"latitude\": 48.450727,

\"longitude\": -122.174762

},

\"bottomRight\": {

\"latitude\": 37.450727,

\"longitude\": 22.174762

}

}

},

\"returnedFields\": \[ \"data.Status\" \]

}\'

The successful response from the above request will include a
\"cursor\", which should be passed to next call of query_with_cursor API
in order to retrieve the next batch of results.

**curl**

curl \--request POST \\

\--url \'/api/search/v2/query_with_cursor\' \\

\--header \'accept: application/json\' \\

\--header \'authorization: Bearer \<JWT\>\' \\

\--header \'content-type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: common\' \\

\--data \'{

\"kind\": \"common:welldb:wellbore:1.0.0\",

\"cursor\": \"cursor-key\"

}\'

**Caution:** As next batches of results are retrieved
by query_with_cursor API, cursor value may or may not change. API users
should not expect different cursor value in
each query_with_cursor response.

**Note:** To process the next query_with_cursor request, the search
service keeps the search context alive for 1 minute, which is the time
required to process the next batch of results. Each cursor request sets
a new expiry time. The cursor will expire after 1 min and won\'t return
any more results if the requests are not made in specified time.

Get indexing status

Indexer service adds internal meta data to each record which registers
the status of the indexing. The meta data includes the status and the
last indexing date and time. This additional meta block helps to see the
details of indexing. The format of the index meta block is as follows:

\"index\": {

\"trace\": \[

String,

String

\],

\"statusCode\": Integer,

\"lastUpdateTime\": Datetime

}

Example:

{

\"results\": \[

{

\"index\": {

\"trace\": \[

\"datetime parsing error: unknown format for attribute: endDate \|
value: 9000-01-01T00:00:00.0000000\",

\"datetime parsing error: unknown format for attribute: startDate \|
value: 1990-01-01T00:00:00.0000000\"

\],

\"statusCode\": 400,

\"lastUpdateTime\": \"2018-11-16T01:44:08.687Z\"

}

}

\],

\"totalCount\": 31895

}

Details of the index block:

1.  trace: This field collects all the issues related to the indexing
    > and concatenates using \'\|\'. This is a String field.

2.  statusCode: This field determines the category of the error. This is
    > integer field. It can have the following values:

    -   200 - All OK

    -   404 - Schema is missing in Storage

    -   400 - Some fields were not properly mapped with the schema
        > defined

3.  lastUpdateTime: This field captures the last time the record was
    > updated by by the indexer service. This is datetime field so you
    > can do range queries on this field.

You can query the index status using the following example query:

curl \--request POST \\

\--url /api/search/v2/query \\

\--header \'Authorization: Token\' \\

\--header \'Content-Type: application/json\' \\

\--header \'OSDU-Data-Partition-Id: Data partition id\' \\

\--data \'{\"kind\": \"\*:\*:\*:\*\",\"query\":
\"index.statusCode:404\",\"returnedFields\": \[\"index\"\]}\'

NOTE: By default, the API response excludes the \'index\' attribute
block. The user must specify \'index\' as the \'returnedFields\" in
order to see it in the response.

The above query will return all records which had problems due to fields
mismatch.

Permissions

  ***Endpoint URL***                 ***Method***   ***Minimum Permissions Required***   **\_Data Permissions Required \_**
  ---------------------------------- -------------- ------------------------------------ ------------------------------------
  /api/search/v2/query               POST           users.osdu.viewers                   Yes
  /api/search/v2/query_with_cursor   POST           users.osdu.viewers                   Yes

**Note:** This is a documentation draft version of the structure and
content of the OEDU service platform on the CPD control plane. The same
needs to be ported on IBM Knowledge center using DCS tools.

### Limitations

### Chart Details

### Installing the Chart
