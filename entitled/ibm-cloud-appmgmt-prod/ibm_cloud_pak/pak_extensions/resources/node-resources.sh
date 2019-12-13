#!/bin/bash

PRINT_MESSAGE() {
	echo -ne "$@" 2>&1 | tee -a ${log_file}
}

GET_WORKER_NODE_LIST() {
if [ -z "${all_node_list}" ] ; then
	PRINT_MESSAGE "Getting worker node list. \n\n"
	all_node_list=`kubectl get nodes | grep -v NAME | awk '{ print $1 }' | tr "\n" ' ' | tr -s ' '`
	worker_node_count=0
	total_mem=0
	total_mem_request=0
	total_mem_free=0
	total_cpu=0
	total_cpu_request=0
	total_cpu_free=0
	string=`printf "%-30s %15s %15s %15s %15s %15s %15s" "Node" "CPU Free" "CPU Request" "CPU Total" "Mem Free" "Mem Request" "Mem Total"`
	PRINT_MESSAGE "${string}\n"
	for node in ${all_node_list} ; do
		describe=`kubectl describe node ${node}`
		NoSchedule=`echo ${describe} | grep NoSchedule`
		if [ -z "${NoSchedule}" ] ; then
			worker_node_count=$((${worker_node_count}+1))
			node_resources=`kubectl describe node ${node} | grep 'Allocatable' -A 5 | egrep 'cpu|memory' | tr "\n" ' ' | tr -s ' '`
			
			node_cpu_raw=`echo ${node_resources} | awk '{ print $2 }'`
			if [[ "${node_cpu_raw}" =~ "m" ]] ; then
				node_cpu_allocatable=`echo ${node_cpu_raw} | sed 's/[^0-9]*//g'`
			else
				node_cpu_allocatable=$((${node_cpu_raw}*1000))
			fi			
			
			node_mem_raw=`echo ${node_resources} | awk '{ print $4 }'`
			node_mem_allocatable=`echo ${node_mem_raw} | sed 's/[^0-9]*//g'`
			if [[ "${node_mem_raw}" =~ "Ki" ]] ; then
				node_mem_allocatable=$((${node_mem_allocatable}/1024))
			fi
			if [[ "${node_mem_raw}" =~ "Gi" ]] ; then
				node_mem_allocatable=$((${node_mem_allocatable}*1024))
			fi
			
			node_cpu_request=`kubectl describe node ${node} | grep 'cpu ' | tail -1 | awk '{ print $2 }' `
			if [[ "${node_cpu_request}" =~ "m" ]] ; then
				node_cpu_request=`echo ${node_cpu_request} | sed 's/[^0-9]*//g'`
			else
				node_cpu_request=$((${node_cpu_request}*1000))
			fi
			
			node_mem_request_raw=`kubectl describe node ${node} | grep 'memory ' | tail -1 | awk '{ print $2 }'`
			node_mem_request=`echo ${node_mem_request_raw} | sed 's/[^0-9]*//g'`
			if [[ "${node_mem_request_raw}" =~ "Ki" ]] ; then
				node_mem_request=$((${node_mem_request}/1024))
			fi
			if [[ "${node_mem_request_raw}" =~ "Gi" ]] ; then
				node_mem_request=$((${node_mem_request}*1024))
			fi
			
			node_cpu_free=$((${node_cpu_allocatable}-${node_cpu_request}))
			node_mem_free=$((${node_mem_allocatable}-${node_mem_request}))
			
			total_mem=$((${total_mem}+${node_mem_allocatable}))
			total_mem_request=$((${total_mem_request}+${node_mem_request}))
			total_mem_free=$((${total_mem_free}+${node_mem_free}))
			total_cpu=$((${total_cpu}+${node_cpu_allocatable}))
			total_cpu_request=$((${total_cpu_request}+${node_cpu_request}))
			total_cpu_free=$((${total_cpu_free}+${node_cpu_free}))
			string=`printf "%-30s %15s %15s %15s %15s %15s %15s" "${node}" "${node_cpu_free}m" "${node_cpu_request}m" "${node_cpu_allocatable}m" "${node_mem_free}Mi" "${node_mem_request}Mi" "${node_mem_allocatable}Mi"`
			PRINT_MESSAGE "${string}\n"
			worker_node_list="${worker_node_list}${node} "
		fi
	done
	PRINT_MESSAGE "\n"
	string=`printf "%-30s %15s %15s %15s %15s %15s %15s" "Environment Totals" "${total_cpu_free}m" "${total_cpu_request}m" "${total_cpu}m" "${total_mem_free}Mi" "${total_mem_request}Mi" "${total_mem}Mi"`
	PRINT_MESSAGE "${string}\n\n"
fi
}

GET_WORKER_NODE_LIST
