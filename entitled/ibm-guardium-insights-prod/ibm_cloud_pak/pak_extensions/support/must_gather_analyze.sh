#!/bin/bash

curtime=`date "+%Y%m%d%H%M%S"`
logdir=$1
logfile="${logdir}/must_gather.${curtime}.log"


#==========================================================
#FUNCTIONS
#==========================================================

print_log () {

    msg=$1
    echo $msg
}

header () {

   msg=$1
   echo "============ $msg  ============"
}

get_failed_pods () {
#getting logs for failed pods:

   header "List of failed pods"

   failed_pods=`oc get pods|egrep  "Error|Crash" |awk '{print $1}'`
 
   if [[ "x$failed_pods" == "x" ]]; then 

      print_log "NO failed pod found"

   else
      for failed_pod in ${failed_pods[@]}
      do
         print_log "Failed pod $failed_pod"
         #oc logs $failed_pod &>> $logfile
         oc logs $failed_pod 
         print_log "-------------------------------------------------"
      done
   fi
}

get_missing_resources() {

  header "List of missing api resources"
  missing_api_resources=`grep "No resources found in staging namespace" ${logdir}/*.log|cut -d'-' -f3`
  if [ -n "${missing_api_resources}" ] ; then
     echo "${missing_api_resources}"
  else
     echo "There are no missing api resources"
  fi
}

verify_charts_list() {
# compare the list of the deployed charts to the predefined list

    cloudctl catalog charts > deployed_charts.txt
    diff deployed_charts.txt predefined_charts.txt &> chart_diffs.txt


#   list_of_deployed_charts=`cloudctl catalog repos|awk '{print $1}'`
#   for deployed_chart in ${list_of_deployed_charts[@]}
#   do
#      cloudctl catalog charts --repo $deployed_chart
#   done
}

#============================================================
#MAIN
#============================================================

get_failed_pods
get_missing_resources
#verify_charts_list
