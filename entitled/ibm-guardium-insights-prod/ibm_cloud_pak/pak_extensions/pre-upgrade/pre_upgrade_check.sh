#!/bin/bash

RELEASE_NAME=staging
NAMESPACE=staging
is_error=false
curtime=`date "+%Y%m%d%H%M%S"`
error_log="/var/tmp/pre_upgrade_errors.${curtime}.log"
msg=""


# Statuses:
# 0 - SUCCESS
# 1 - ERROR
# 2 - WARNING

statuses+=( [0]="SUCCESS" [1]="ERROR" [2]="WARNING" )


# get the target version from script parameter
target_version="$1"

target_version_formatted=${target_version//./_}

declare -A required_versions

if [[ ! -z $target_version && $target_version == "2.5" ]];then
   required_versions+=( ["docker"]="17.03" ["kubectl"]="v1.16" ["cloudctl"]="v3.2.4" ["helm"]="v2.12" ["oc"]="4.3.13" )
else
   echo "Please provide a proper target version. "
   exit
fi

function handle_status() {

   status=$1
   msg=$2

   echo "${statuses[$status]}:" $msg >> $error_log

}


function check_disk_space() {

   status=0
   pod_name=`oc get po -n=$NAMESPACE -lrelease=$RELEASE_NAME -ltype=engine -oname | head -1 | sed -e 's#pod/##'`
   disk_used_string=`oc exec -n=$NAMESPACE $pod_name -- /bin/bash -c "df -mP" |grep "/mnt/bludata0" |awk '{print $5}'`
   disk_used_percentage=`echo ${disk_used_string%\%}`

   if [[ $disk_used_percentage -gt 50 ]];then

       status=1 
       msg="Cluster has less than 50% of free space."
   else 
       msg="Cluster has enough space for upgrade."
   fi 

   handle_status $status "$msg"
}

function check_installed_tools() {

   status=0
# check that all tools are installed and available in PATH
   if [[ -z "$(which docker 2>/dev/null)" ]]; then 
        msg="docker not installed"
        status=1
        handle_status $status "$msg"
   fi
   if [[ -z "$(which kubectl 2>/dev/null)" ]]; then 
        msg="kubectl not installed"
        status=1
        handle_status $status "$msg"
   fi
   if [[ -z "$(which cloudctl 2>/dev/null)" ]]; then 
        msg="cloudctl not installed"
        status=1
        handle_status $status "$msg"
   fi
   if [[ -z "$(which helm 2>/dev/null)" ]]; then 
        msg="helm not installed" 
        status=1
        handle_status $status "$msg"
   fi
   if [[ -z "$(which oc 2>/dev/null)" ]]; then 
        msg="oc not installed"
        status=1
        handle_status $status "$msg"
   fi

   if [[ $status -eq 0 ]];then
       msg="All tools are installed properly."
       handle_status $status "$msg"
   fi

}

function check_tools_versions() {

   status=0
   docker_current_version=$(docker version -f '{{.Client.Version}}' 2>/dev/null)
   docker_required_version=${required_versions[docker]}
   if [ "$(printf '%s\n' "$docker_current_version" "$docker_required_version" | sort -V | head -n 1)" != "$docker_required_version" ]; then 
        msg="docker's version $docker_current_version is lower than required $docker_required_version"
        status=1
        handle_status $status "$msg"
   fi

   kubectl_current_version=$(kubectl version --short | grep "Client" | awk '{print $3}')
   kubectl_required_version=${required_versions[kubectl]}
   if [ "$(printf '%s\n' "$kubectl_current_version" "$kubectl_required_version" | sort -V | head -n 1)" != "$kubectl_required_version" ]; then 
        msg="kubectl's version $kubectl_current_version is lower than required $kubectl_required_version"
        status=1
        handle_status $status "$msg"
   fi

   cloudctl_current_version=$(cloudctl version | grep "Client" | awk '{print $3}'|cut -d"+" -f1)
   cloudctl_required_version=${required_versions[cloudctl]}
   if [ "$(printf '%s\n' "$cloudctl_current_version" "$cloudctl_required_version" | sort -V | head -n 1)" != "$cloudctl_required_version" ]; then 
        msg="cloudctl's version $cloudctl_current_version is lower than required $cloudctl_required_version"
        status=1
        handle_status $status "$msg"  
   fi

   helm_current_version=$(helm version -c --short | awk '{print $2}'|cut -d"+" -f1)
   helm_required_version=${required_versions[helm]}
   if [ "$(printf '%s\n' "$helm_current_version" "$helm_required_version" | sort -V | head -n 1)" != "$helm_required_version" ]; then 
        msg="helm's version $helm_current_version is lower than required $helm_required_version"
        status=1
        handle_status $status "$msg"
   fi

   oc_current_version=$(oc version | grep "Client" | awk '{print $3}')
   oc_required_version=${required_versions[oc]}
   if [ "$(printf '%s\n' "$oc_current_version" "$oc_required_version" | sort -V | head -n 1)" != "$oc_required_version" ]; then 
        msg="oc's version $oc_current_version is lower than required $oc_required_version"
        status=1
        handle_status $status "$msg"
   fi

   if [[ $status -eq 0 ]];then
       msg="All tools have required versions."
       handle_status $status "$msg" 
   fi

}

function validate_db2_installation() {

   status=0
   tmp_log="/var/tmp/tmp.log"
   db2_pod_name=$(oc get pods -l api-progress=db2wh-api --no-headers | head -n 1 | awk '{print $1}')
   db2_nodes_json=""

   # check if wvcli is properly installed
   oc exec ${db2_pod_name} -- wvcli system nodes --format json &>$tmp_log
   if grep -q Error $tmp_log ;then
      status=1
      msg="wvcli is not properly installed" 
      handle_status $status "$msg"
   else
      db2_nodes_json=`cat $tmp_log`
      db2_mln_json=$(oc exec ${db2_pod_name} -- wvcli system ds --format json)   
   
      # use jq to parse output and determine if any resources are not in an UP state
      # select all statuses that start with some character other than 'U' (not UP state)
      db2_nodes_status=$(echo $db2_nodes_json | jq -r ".[\"$pod_name\"]  | select(.State|test(\"^[^U].\")) | .State")
      db2_mln_status=$(echo ${db2_mln_json} | jq -r '.mln_data.nodes[].mlns[] | select(.status|test("^[^U].")) | .status')

      if [[ -z "$db2_nodes_status" ]]; then
         msg="DB2 Nodes are in a good state."
      else
         status=1
         msg="DB2 Nodes are not all in a good state. Please inspect with 'wvcli system nodes' on a db2 node."
      fi

      # print message after db2_nodes_status check  
      handle_status $status "$msg"
      status=0

      if [[ -z "$db2_mln_status" ]]; then
         msg="DB2 MLNs are in a good state"
      else
         msg="DB2 MLNs are not all in a good state. Please inspect with 'wvcli system ds' on a db2 node."
         status=1  
      fi

      # print message after db2_mln_status check
      handle_status $status "$msg"

    fi
    rm -f $tmp_log

}
##########################
# MAIN
##########################

echo "===========================================" >> $error_log

check_disk_space
check_installed_tools
check_tools_versions
validate_db2_installation

if grep -q "ERROR:"  $error_log ; then
   touch /var/tmp/pre_upgrade_check_fail
else
   msg="Environment is ready for upgrade"
   handle_status 0 "$msg"
   touch /var/tmp/pre_upgrade_check_pass
fi

echo "===========================================" >> $error_log

cat $error_log
