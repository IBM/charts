[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # ((C) Copyright IBM Corporation 2016, 2017 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)
# CAM Local scripts

## Script: onboard_cam.sh
- This script is used to onboard CAM local. Currently this script register the given tenant and configures LDAP registry for authentication.
- The script takes the input CAM hostname/ipaddress, tenant name and LDAP registry configuration.
- The LDAP configuration input can be provided as an env file or through environment variables.

  ```shellscript
  Usage: bash onboard_cam.sh cam-hostname-or-ipaddress tenant-name [ ldap-config-env-file ]

         cam-hostname-or-ipaddress     CAM hostname or IP address
         tenant-name                   Tenant name
         ldap-env-file                 Provide LDAP config as env file or through environment variables

         e.g., bash onboard_cam.sh cam-proxy pepsi ldap_config.env
  ```

  ```
  Sample LDAP configuration for IBM bluepages:

    LDAP_ID=bluepages
    LDAP_REALM=w3
    LDAP_HOST="bluepages.ibm.com"
    LDAP_PORT="389"
    LDAP_IGNORECASE=true
    LDAP_BASEDN="o=ibm.com"
    LDAP_BINDDN=
    LDAP_BINDPASSWORD=
    LDAP_TYPE="IBM Tivoli Directory Server"
    LDAP_USERFILTER="(emailAddress=%v)(objectclass=person)"
    LDAP_GROUPFILTER="(cn=%v)(objectclass=groupOfUniqueNames)"
    LDAP_USERIDMAP="*:emailAddress"
    LDAP_GROUPIDMAP="*:cn"
    LDAP_GROUPMEMBERIDMAP="groupOfUniqueNames:uniquemember"
  ```
