#!/bin/sh

#*===================================================================
#*  Licensed Materials - Property of IBM
#*   5737-E67
#*  IBM Cloud Cost and Asset Management
#*  (C) Copyright IBM Corporation 2018 All Rights Reserved.
#*  US Government Users Restricted Rights - Use, duplication or
#*  disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#*===================================================================

# Variables section
# Refer to pre_install_core.md for description about these variables

BASEDIR="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
SCRIPTSDIR=$(dirname $BASEDIR)
UTILSDIR=$SCRIPTSDIR'/utils'
LOGSDIR=$SCRIPTSDIR'/logs'
RESDIR=$(dirname $SCRIPTSDIR)'/resources'
admin_key=''
admin_user='icb_bootstrap_admin'
RED='\033[0;31m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

if ! [ -d $LOGSDIR ] ;then
    mkdir $LOGSDIR
fi

log_file=$LOGSDIR'/log_'$(date +%F_%T)'.log'

usage()
{
    echo "Usage: sh post-install.sh -f <file_name> "
    echo ""
    echo "Options:"
    echo "  -h/--help     : print this help message. "
    echo "  -f/--file     : <properties file name>"
    echo "                          eg., \"-f post_install.properties\" "
}

validate_property_file()
{
    . "$RESDIR/$properties_file"

    # checking user input in properties file
    msg=false
    key_msg="Initialisation incomplete. Enter property values : "

    if [ -z "$host_ip" ]; then
        key_msg="$key_msg host_ip"
        msg=true
    fi

    if [ -z "$clientSecret" ]; then
        key_msg="$key_msg clientSecret"
        msg=true
    fi

    if [ -z "$clientID" ]; then
        key_msg="$key_msg clientID"
        msg=true
    fi

    if [ -z "$app_user" ]; then
        key_msg="$key_msg app_user"
        msg=true
    fi

    if [ -z "$new_password" ] ; then
        key_msg="$key_msg new_password"
        msg=true
    fi

    if [ -z "$api_key" ] ; then
        key_msg="$key_msg api_key"
        msg=true
    fi

    if [ -z "$icp_proxy_ip" ] ; then
        key_msg="$key_msg icp_proxy_ip"
        msg=true
    fi

    if [ -z "$cluster_name" ] ; then
        key_msg="$key_msg cluster_name"
        msg=true
    fi

    port=$gateway_port;

    if [ -z "$port" ] ; then
        key_msg="$key_msg port"
        msg=true
    fi

    if [ "$msg" = true ] ; then
        echo | tee -a "$log_file"
        echo "${RED}$key_msg ${NC}" | tee -a "$log_file"
        exit
    fi
}

reset_passwd()
{
   "$UTILSDIR/"reset_passwd.sh -g $GATEWAY_URL -p OTP-$api_key -n $new_password
   if [ $? -ne 0 ]; then
       echo "${RED}Unable to reset password, please verify api_key and retry... ${NC}"  | tee -a "$log_file"
       exit
   else
       echo "${BLUE}Password has been reset successfully!${NC}"  | tee -a "$log_file"
       touch "$SCRIPTSDIR"/reset
   fi
}

oidc_regn()
{
    "$UTILSDIR/"oidc_regn.sh -g $GATEWAY_URL -n $RESDIR/openid_sso_sample.json -p $host_ip:$icp_master_port
    if [ $? -ne 0 ]; then
        echo "${RED}Unable to complete OIDC registration, Please verify clientID and clientSecret ${NC}" | tee -a "$log_file"
        exit
    else
        echo "${BLUE}OIDC registration completed.${NC}"  | tee -a "$log_file"
    fi
}

get_admin_key()
{
    res=$( "$UTILSDIR/"get_admin_key.sh -g $GATEWAY_URL -p $new_password )
    if [ $? -ne 0 ]; then
        echo "${RED}Unable to get the admin key. ${NC}" | tee -a "$log_file"
        exit
    else
        echo "${BLUE}Retrieved admin key.${NC}"  | tee -a "$log_file"
    fi
    admin_key=$( echo "$res" | grep -i "\"key\"" | python -c 'import json, sys; print json.load(sys.stdin)["key"]')
}

setup_sso_configuration()
{
    "$UTILSDIR/"setup_sso_configuration.sh -g $GATEWAY_URL -u "$admin_user" -p "$admin_key" -n $RESDIR/openid_sso_sample.json
    if [ $? -ne 0 ]; then
        echo "${RED}Unable to setup SSO configuration.Please verify openid_sso_sso_sample.json ${NC}" | tee -a "$log_file"
        exit 1
    else
        echo "${BLUE}Setup SSO configuration completed successfully.${NC}"  | tee -a "$log_file"
    fi
}

setup_authorization_type()
{
    "$UTILSDIR/"setup_authorization_type.sh -g $GATEWAY_URL -u $admin_user -p "$admin_key" -n $RESDIR/sample_authorization_type_bootstrap.json
    if [ $? -ne 0 ]; then
        echo "${RED}Unable to setup authorization type.Please verify sample_authorization_type_bootstrap.json ${NC}"
        exit
    else
        echo "${BLUE}Setup authorization type completed successfully.${NC}"  | tee -a "$log_file"
    fi
}

if [ "$#" -eq 0 ]; then
    usage | tee -a "$log_file"
    exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        -f | --file )               shift
                                    properties_file=$1
                                    ;;
        -h | --help )               usage | tee -a "$log_file"
                                    exit 1
                                    ;;
        * )                         usage | tee -a "$log_file"
                                    exit 1
    esac
    shift
done

if ! [ "$properties_file" ]  ;then
    echo "${RED}Properties file is mandatory${NC}" | tee -a "$log_file"
    usage | tee -a "$log_file"
    exit 1
fi

if ! [ -s "$RESDIR/$properties_file" ] ; then
    echo "${RED}Couldnot find properties file '$properties_file' in $RESDIR directory or its emtpy, Please verify and rerun again.${NC}" | tee -a "$log_file"
    exit 1
fi

if ! [ -s "$RESDIR/openid_sso_sample.json" ] ; then
    echo "${RED}Couldnot find file 'openid_sso_sample.json' in $RESDIR directory or its emtpy, Please verify and rerun again.${NC}" | tee -a "$log_file"
    exit 1
fi

if ! [ -s "$RESDIR/sample_authorization_type_bootstrap.json" ] ; then
    echo "${RED}Couldnot find  file '$sample_authorization_type_bootstrap.json' in $RESDIR directory or its emtpy, Please verify and rerun again.${NC}" | tee -a "$log_file"
    exit 1
fi

validate_property_file || exit 1

GATEWAY_URL="https://"$icp_proxy_ip":$port"

if ! [ -f $SCRIPTSDIR/reset ]; then
    reset_passwd || exit 1
fi

$(python -c "import json;
with open('$RESDIR/openid_sso_sample.json') as file:
    data = json.load(file)
    data['_clientID']='$clientID'
    data['_clientSecret']='$clientSecret'
with open('$RESDIR/openid_sso_sample.json','w') as file_new:
    json.dump(data,file_new,indent=4)")

sed -i "s/MASTER-ICP-IP/$host_ip/g" $RESDIR/openid_sso_sample.json || exit 1
sed -i "s/MASTER-ICP-PORT/$icp_master_port/g" $RESDIR/openid_sso_sample.json || exit 1
sed -i "s/mycluster/$cluster_name/g" $RESDIR/openid_sso_sample.json || exit 1

oidc_regn || exit 1

get_admin_key || exit 1

sed -i "s/MASTER-ICP-IP/$host_ip/g" $RESDIR/sample_authorization_type_bootstrap.json || exit 1
sed -i "s/MASTER-ICP-PORT/$icp_master_port/g" $RESDIR/sample_authorization_type_bootstrap.json || exit 1
setup_authorization_type || exit 1

setup_sso_configuration || exit 1

if [ -f $SCRIPTSDIR/reset ]; then
    rm -f $SCRIPTSDIR/reset
fi
echo "${BLUE}IBM cloud cost and asset mangement bootsrap setup completed successfully.${NC}" | tee -a "$log_file"
