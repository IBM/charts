#!/bin/bash

INITIALIZE() {
total_cpu_request=0
total_cpu_limit=0
total_mem_request=0
total_mem_limit=0
type=0 # 0 = all, 1 = stateless, 2 = stateful
nodes=""
show_heaps=0
stateful="cassandra|mongo|couch|datalayer|kafka|zookeeper"
}
USAGE() {
	echo "Use this script to display information on kubernetes resource requests and limits."
	echo "Flags: $0 "
	echo "   --grep <regex>             Regex of pods to look for, example: kube-system or ibmcloudappmgmt"
	echo "   [ --stateless ]            For ICAM pods, only shows the stateless services (excludes ${stateful})"
	echo "   [ --stateful ]             For ICAM pods, only shows the stateful services (includes ${stateful})"
	echo "   [ --nodes <node_list>  ]   Only displayes resources for pods on the nodes listed"
	echo "   [ --show_heaps ]   Only displayes resources for pods on the nodes listed"
	echo
	echo "example:"
	echo "$0 --grep 'ibmcloudappmgmt-'"
	echo "$0 --grep 'kube-system' --nodes perfvm4009"
	echo
	exit 0

}
PARSE_ARGS() {
ARGC=$#
if [ $ARGC == 0 ] ; then
	USAGE
	exit 1 
fi
while [ $ARGC != 0 ] ; do
	if [ "$1" == "-n" ] || [ "$1" == "-N" ] ; then
		ARG="-N"
	else
		ARG=`echo $1 | tr .[a-z]. .[A-Z].`
	fi
	case $ARG in
		"--STATELESS")	#
			type=1; shift 1; ARGC=$(($ARGC-1)) ;;
		"--STATEFUL")	#
			type=2; shift 1; ARGC=$(($ARGC-1)) ;;
		"--GREP")	#
			grep_regex="${2}"; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NODES")	#
			nodes="${2}"; shift 2; ARGC=$(($ARGC-2)) ;;
		"--SHOW_HEAPS")	#
			show_heaps=1; shift 1; ARGC=$(($ARGC-1)) ;;
		*)
			echo "Argument \"$ARG\" not known, exiting...\n"
			USAGE
            exit 1 ;;
    esac
done
}

MAIN() {

printf "%-70s %9s, %9s, %9s, %9s,\n" "" "Mem (Mi)" "Mem (Mi)" "CPU (m)" "CPU (m)"
printf "%-70s %9s, %9s, %9s, %9s,\n" "Pod Name," "Request" "Limit" "Request" "Limit"

#all
if [ ${type} == 1 ] ; then
	pods=`kubectl describe nodes ${nodes} --all-namespaces | egrep "${grep_regex}" | egrep -v "${stateful}" | grep -v 'performance-' | sort -k 2 | awk '{ print $2","$3","$5","$7","$9 }'`
elif [ ${type} == 2 ] ; then
	pods=`kubectl describe nodes ${nodes} --all-namespaces | egrep "${grep_regex}" | egrep "${stateful}" | grep -v 'performance-' | sort -k 2 | awk '{ print $2","$3","$5","$7","$9 }'`
else 
	pods=`kubectl describe nodes ${nodes} --all-namespaces | egrep "${grep_regex}"  | sort -k 2 | grep -v 'performance-' | awk '{ print $2","$3","$5","$7","$9 }'`
fi

for pod in ${pods} ; do 
	#echo "pod: ${pod}"
	pod_name=`echo ${pod} | cut -d ',' -f 1`
	
	cpu_request=`echo ${pod} | cut -d ',' -f 2`
	if [[ "${cpu_request}" =~ "m" ]] ; then
		cpu_request=`echo ${cpu_request} | sed 's/[^0-9]*//g'`
	else
		cpu_request=$((${cpu_request}*1000))
	fi	
	
	cpu_limit=`echo ${pod} | cut -d ',' -f 3`
	if [[ "${cpu_limit}" =~ "m" ]] ; then
		cpu_limit=`echo ${cpu_limit} | sed 's/[^0-9]*//g'`
	else
		cpu_limit=$((${cpu_limit}*1000))
	fi	
	
	mem_request_raw=`echo ${pod} | cut -d ',' -f 4`
	mem_request=`echo ${mem_request_raw} | sed 's/[^0-9]*//g'`
	if [[ "${mem_request_raw}" =~ "Ki" ]] ; then
		mem_request=$((${mem_request}/1024))
	fi
	if [[ "${mem_request_raw}" =~ "Gi" ]] ; then
		mem_request=$((${mem_request}*1024))
	fi
	
	mem_limit_raw=`echo ${pod} | cut -d ',' -f 5`
	mem_limit=`echo ${mem_limit_raw} | sed 's/[^0-9]*//g'`
	if [[ "${mem_limit_raw}" =~ "Ki" ]] ; then
		mem_limit=$((${mem_limit}/1024))
	fi
	if [[ "${mem_limit_raw}" =~ "Gi" ]] ; then
		mem_limit=$((${mem_limit}*1024))
	fi
	total_cpu_request=$(($total_cpu_request+$cpu_request))
	total_cpu_limit=$(($total_cpu_limit+$cpu_limit))
	total_mem_request=$(($total_mem_request+$mem_request))
	total_mem_limit=$(($total_mem_limit+$mem_limit))
	
	if [ "${show_heaps}" -eq '1' ] ; then
		heap=`kubectl describe pod ${pod_name} | egrep -i 'heap|jvm|cache_size' | tr "\n" ' ' | tr -s ' ' | sed -e 's/[ \t]/ /g'`
	fi
	printf "%-70s %9d, %9d, %9d, %9d,  ${heap}\n" "${pod_name}," ${mem_request} ${mem_limit} ${cpu_request} ${cpu_limit}
done
printf "%-70s %9d, %9d, %9d, %9d,\n" "Total," ${total_mem_request} ${total_mem_limit} ${total_cpu_request} ${total_cpu_limit}
}

INITIALIZE
PARSE_ARGS "$@"
MAIN
