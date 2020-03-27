#!/bin/bash
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018, 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################

INITIALIZE() {
total_cpu_request=0
total_cpu_limit=0
total_mem_request=0
total_mem_limit=0
show_heap=0
command="kubectl"
heap_text=""
namespace=""
include=""
exclude=""
stateful="cassandra|mongo|couch|datalayer|kafka|zookeeper|elasticsearch"
nodes=""
show_pod_results=0
show_container_results=1
}
USAGE() {
echo "Use this script to display information on kubernetes resource requests, limits, and current utilization."
echo "Flags: $0 "
echo "   [ --namespace <namespace> ]     Specify the namespace to display resource information about. Default is the current namespace."
echo "   [ --all-namespaces ]            Show information for all namespaces. Default is the current namespace."
echo "   [ --nodes <\"node or nodes\"> ]   Specify the node or nodes to include results from.  Use quotes to surround a space or comma delimited list. Default is all nodes."
echo "   [ --oc ]                        Use the openshift \"oc\" command instead of \"kubectl\" to gather information."
echo "   [ --include <\"regex|regex\"> ]   Filter your results to only include pods matching the regular expression(s) specified."
echo "   [ --exclude <\"regex|regex\"> ]   Filter your results to not include pods matching the regular expression(s) specified."
echo "   [ --pod_totals ]                Include the total usage for the pods, along with the individual containers.  Default is only containers."
echo "   [ --pods_only ]                 Only show the totals for a pod, not the individual containers.  Default is only containers."
echo
echo "example:"
echo "$0 --namespace icam"
echo "$0 --namespace icam --nodes \"1.2.3.4 1.2.3.5\""
echo "$0 --namespace icam --nodes \"1.2.3.4 1.2.3.5\" --include \"cassandra\""
echo
exit 0
}
PARSE_ARGS() {
ARGC=$#

while [ $ARGC != 0 ] ; do
	if [ "$1" == "-n" ] || [ "$1" == "-N" ] ; then
		ARG="-N"
	else
		ARG=`echo $1 | tr .[a-z]. .[A-Z].`
	fi
	case $ARG in
		"--OC")  #
			command="oc"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--POD_TOTALS")  #
			show_pod_results=1; show_container_results=1; shift 1; ARGC=$(($ARGC-1)) ;;
		"--PODS_ONLY")  #
			show_pod_results=1; show_container_results=0; shift 1; ARGC=$(($ARGC-1)) ;;
		"--CONTAINERS_ONLY")  #
			show_container_results=1; show_pod_results=0; shift 1; ARGC=$(($ARGC-1)) ;;
		"--INCLUDE")  #
			include="$2"; shift 2; ARGC=$(($ARGC-2)) ;;
		"--EXCLUDE")  #
			exclude="$2"; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NODES")  #
			nodes="$2"; shift 2; ARGC=$(($ARGC-2)) ;;
		"-N")  #
			namespace="-n $2"; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NAMESPACE")  #
			namespace="-n $2"; shift 2; ARGC=$(($ARGC-2)) ;;
		"--ALL-NAMESPACES")  #
			namespace="--all-namespaces"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--SHOW-HEAP")  #
			show_heap=1; heap_text="heap settings,"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--HELP")  #
			USAGE; exit 0 ;;
		#"--SHOW_HEAPS") #
		#	show_heaps=1; shift 1; ARGC=$(($ARGC-1)) ;;
		*)
			echo "Argument \"$ARG\" not known, exiting...\n"
			USAGE; exit 1 ;;
    esac
done
}

MAIN() {

if [ -n "${exclude}" ] ; then
	pods=`${command} get pods ${namespace} -o=jsonpath='{range .items[*]}{.metadata.name}{","}{.spec.containers[*].name}{","}{.spec.containers[*].resources}{","}{.status.hostIP}{","}{"\n"}{end}' | egrep "${include}" | egrep -v "${exclude}"`
else
	pods=`${command} get pods ${namespace} -o=jsonpath='{range .items[*]}{.metadata.name}{","}{.spec.containers[*].name}{","}{.spec.containers[*].resources}{","}{.status.hostIP}{","}{"\n"}{end}' | egrep "${include}"`
fi

if [ "${command}" == "oc" ] ; then
	top=`${command} adm top pods --containers ${namespace} | sort -k 1 -k 2 | grep -v "NAME" | awk '{ print $1","$2","$3","$4 }'`
else
	top=`${command} top pods --containers ${namespace} | sort -k 1 -k 2 | grep -v "NAME" | awk '{ print $1","$2","$3","$4 }'`
fi

printf "%65s %60s %9s, %9s, %9s, %9s, %9s, %9s, %15s  %20s\n" "" "" "Mem (Mi)" "Mem (Mi)" "Mem (Mi)" "CPU (m)" "CPU (m)" "CPU (m)" ""
printf "%-65s %-60s %9s, %9s, %9s, %9s, %9s, %9s, %15s, %20s\n" "Pod Name," "Container Name," "Current" "Request" "Limit" "Current" "Request" "Limit" "Node" "$heap_text"
ORIGINAL_IFS=$IFS
IFS=$'\n' 
for pod in $pods ; do 
	pod_name=`echo "$pod" | cut -d ',' -f 1`
	containers=`echo "$pod" | cut -d ',' -f 2`
	resources=`echo "${pod}" | cut -d ',' -f 3 | tr -s '[[:space:]]' '\n'`
	node=`echo "${pod}" | cut -d ',' -f 4`
	if [ -n "${nodes}" ] ; then
		if [[ "${nodes}" != *"${node}"* ]] ; then
			continue
		fi
	fi
	container_number=0
	pod_cpu_current=0
	pod_cpu_request=0
	pod_cpu_limit=0
	pod_mem_current=0
	pod_mem_request=0
	pod_mem_limit=0
	unset container_print_string
	IFS=$' ' 
	for container_name in $containers ; do 
		container_number=$(($container_number+1))
		cpu_current=`echo "$top" | grep "${pod_name}," | grep ",${container_name}," | cut -d ',' -f 3 | sed 's/[^0-9]*//g'`
		mem_current=`echo "$top" | grep "${pod_name}," | grep ",${container_name}," | cut -d ',' -f 4 | sed 's/[^0-9]*//g'`
	
		if [ $show_heap -eq '1' ] ; then
			env_variables=`${command} get pod $pod_name -o jsonpath="{.spec.containers[?(@.name==\"$container_name\")].env}" | tr -s '[[:space:]]' '\n')`
			heap=`echo "$env_variables" | egrep 'HEAP_SIZE|NODE_HEAP_SIZE_MB|Xmx' -B1 -A1 | egrep 'value:|Xmx' | cut -d ':' -f 2 | tr "\n" ' ' | tr -s ' ' | sed -e 's/[ \t]*$//g'`
			heap=`echo "${heap},"`
			cache_size=`echo "$env_variables" | egrep 'KAIROSDB_ROW_KEY_CACHE_SIZE' -B1 -A1 | egrep 'value:' | cut -d ':' -f 2 | tr "\n" ' ' | tr -s ' ' | sed -e 's/[ \t]*$//g'`
		fi
		if [ -n "${cache_size}" ] ; then
			cache_size=`echo "Row key cache ${cache_size}"`
		fi
		
		mem_request_raw=`echo "$resources" | grep requests -A 2 | grep memory | cut -d ':' -f 2 | head -${container_number} | tail -1`
		mem_request=`echo ${mem_request_raw} | sed 's/[^0-9]*//g'`
		if [ -z "${mem_request}" ] ; then
			mem_request=0
		fi
		if [[ "${mem_request_raw}" =~ "Ki" ]] ; then
			mem_request=$((${mem_request}/1024))
		elif [[ "${mem_request_raw}" =~ "Mi" ]] ; then
			mem_request=$((${mem_request}))
		elif [[ "${mem_request_raw}" =~ "Gi" ]] ; then
			mem_request=$((${mem_request}*1024))
		else
			mem_request=$((${mem_request}/1024/1024))
		fi
		
		mem_limit_raw=`echo "$resources" | grep limit -A 2 | grep memory | cut -d ':' -f 2 | head -${container_number} | tail -1`
		mem_limit=`echo ${mem_limit_raw} | sed 's/[^0-9]*//g'`
		if [ -z "${mem_limit}" ] ; then
			mem_limit=0
		fi
		if [[ "${mem_limit_raw}" =~ "Ki" ]] ; then
			mem_limit=$((${mem_limit}/1024))
		elif [[ "${mem_limit_raw}" =~ "Mi" ]] ; then
			mem_limit=$((${mem_limit}))
		elif [[ "${mem_limit_raw}" =~ "Gi" ]] ; then
			mem_limit=$((${mem_limit}*1024))
		else
			mem_limit=$((${mem_limit}/1024/1024))
		fi	
		
		cpu_request=`echo "$resources" | grep requests -A 2 | grep cpu | cut -d ':' -f 2 | head -${container_number} | tail -1`
		if [ -z "${cpu_request}" ] ; then
			cpu_request=0
		fi
		if [[ "${cpu_request}" =~ "m" ]] ; then
			cpu_request=`echo ${cpu_request} | sed 's/[^0-9]*//g'`
		else
			cpu_request=$((${cpu_request}*1000))
		fi
		
		cpu_limit=`echo "$resources" | grep limit -A 2 | grep cpu | cut -d ':' -f 2 | head -${container_number} | tail -1`
		if [ -z "${cpu_limit}" ] ; then
			cpu_limit=0
		fi
		if [[ "${cpu_limit}" =~ "m" ]] ; then
			cpu_limit=`echo ${cpu_limit} | sed 's/[^0-9]*//g'`
		else
			cpu_limit=$((${cpu_limit}*1000))
		fi
		
		if [ -z "${cpu_current}" ] ; then
			cpu_current=0
		fi
		if [ -z "${mem_current}" ] ; then
			mem_current=0
		fi
		
		pod_cpu_current=$(($pod_cpu_current+$cpu_current))
		pod_cpu_request=$(($pod_cpu_request+$cpu_request))
		pod_cpu_limit=$(($pod_cpu_limit+$cpu_limit))
		pod_mem_current=$(($pod_mem_current+$mem_current))
		pod_mem_request=$(($pod_mem_request+$mem_request))
		pod_mem_limit=$(($pod_mem_limit+$mem_limit))
		
		total_cpu_current=$(($total_cpu_current+$cpu_current))
		total_cpu_request=$(($total_cpu_request+$cpu_request))
		total_cpu_limit=$(($total_cpu_limit+$cpu_limit))
		total_mem_current=$(($total_mem_current+$mem_current))
		total_mem_request=$(($total_mem_request+$mem_request))
		total_mem_limit=$(($total_mem_limit+$mem_limit))
		
		if [ $show_heap -eq '1' ] ; then
			container_print_string[${container_number}]=`printf "%-65s %-60s %9s, %9s, %9s, %9s, %9s, %9s, %15s, %20s %20s\n" "$pod_name," "$container_name," "$mem_current" "$mem_request" "$mem_limit" "$cpu_current" "$cpu_request" "$cpu_limit" "$node" "$heap" "$cache_size"`
		else
			container_print_string[${container_number}]=`printf "%-65s %-60s %9s, %9s, %9s, %9s, %9s, %9s, %15s,\n" "$pod_name," "$container_name," "$mem_current" "$mem_request" "$mem_limit" "$cpu_current" "$cpu_request" "$cpu_limit" "$node"`
		fi
	done
	
	
	container_count=`echo "$containers" | wc -w`
	
	if [ ${container_count} -gt 1 ] ; then	
		if [ ${show_pod_results} -eq 1 ] ; then
			printf "%-65s %-60s %9s, %9s, %9s, %9s, %9s, %9s, %15s,\n" "$pod_name," "POD Total for $container_count containers," "$pod_mem_current" "$pod_mem_request" "$pod_mem_limit" "$pod_cpu_current" "$pod_cpu_request" "$pod_cpu_limit" "$node"
		fi
		if [ ${show_container_results} -eq 1 ] ; then
			for (( i=1; i<=${#container_print_string[@]}; i++ )); do
				echo "${container_print_string[$i]}"
			done
		fi
	else 
		printf "%-65s %-60s %9s, %9s, %9s, %9s, %9s, %9s, %15s,\n" "$pod_name," "$container_name," "$pod_mem_current" "$pod_mem_request" "$pod_mem_limit" "$pod_cpu_current" "$pod_cpu_request" "$pod_cpu_limit" "$node"
	fi
	
	IFS=$'\n' 
done
IFS=$ORIGINAL_IFS
printf "%-65s %-60s %9s, %9s, %9s, %9s, %9s, %9s,\n" "Total," "Total," "$total_mem_current" "$total_mem_request" "$total_mem_limit" "$total_cpu_current" "$total_cpu_request" "$total_cpu_limit"
}

INITIALIZE
PARSE_ARGS "$@"
MAIN
