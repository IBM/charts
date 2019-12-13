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

test -n "$DEBUG" && set -x

INITIALIZE() {
#yaml_name="/tmp/pv_create.yaml"
YAML_NAME="/tmp/pv_create"

print_yaml="true"
silent=""
reclaim="Retain"
release="ibmcloudappmgmt"
DIR=$(dirname $0)/../..
}
USAGE() {
	echo "Use this script to create Kubernetes Persistent Volumes, either Local or NFS."
	echo "Flags: $0 "
	echo "   --name <name>         Name for the PV"
	echo "   [--node <name>]       Hostname of worker node to be assigned the local storage using affinity "
	echo "   [--ip <ip>]           IP for NFS server, or IP of worker node to be assigned the local storage using affinity "
	echo "                           In IBM Cloud Private, the worker nodes are named based on their hostname if they can be resolved. "
	echo "                           In the case that they cannot be, the IP addresses will be be used. "
	echo "                           For local storage, check which is used for your nodes, example \`kubectl get nodes\`"
	echo "   --class <name>        Type of PV, either nfs or local.  Add extra qualifiers to local to further define the usage. "
	echo "                           Example: local-storage-kafka  local-storage-zookeeper  local-storage-cassandra"
	echo "   --dir <dir>           Directory for the local or NFS storage "
	echo "   --size <size>         Size of PV in Mi or Gi "
	echo "   [--reclaim <policy>]  PV reclaim policy, default of $reclaim "
	echo "   [--release <name>]    Release name, default of $release "
	echo "   [--silent]            Minimizes printed output"
	echo "   [--print]             Displays the yaml file used to create the PV"
	echo
	echo "example:"
	echo "$0 --release ibmcloudappmgmt --name cassandra0 --node 0.0.0.0 --class local-storage-cassandra --dir /k8s/data/cassandra --size 100Gi"
	echo "$0 --release ibmcloudappmgmt --name cassandra1 --node 0.0.0.1 --class local-storage-cassandra --dir /k8s/data/cassandra --size 100Gi"
	echo "$0 --release ibmcloudappmgmt --name storage0 --ip 1.1.1.1 --class nfs --dir /nfs/storage0 --size 50Gi"
	echo "$0 --release ibmcloudappmgmt --name storage1 --ip 1.1.1.1 --class nfs --dir /nfs/storage0 --size 20Gi"
	echo
	exit 0
}
VERIFY_VARIABLE() {
variable_name="${1}"
variable_description="${2}"
variable_flag="${3}"
variable_contents="${4}"
if [ -z "${variable_contents}" ] ; then
	echo "Warning! Could not find ${variable_description}. Please provide the value using the \"-${variable_flag}\" flag. Exiting."
	exit 1
fi
}

PARSE_ARGS() {
ARGC=$#
if [ $ARGC == 0 ] ; then
	USAGE
fi
while [ $ARGC != 0 ] ; do
	if [ "$1" == "-n" ] || [ "$1" == "-N" ] ; then
		ARG="-N"
	else
		ARG=`echo $1 | tr .[a-z]. .[A-Z].`
	fi
	case $ARG in
		"--PRINT")	#
			print_yaml="true"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--NAME")	#
			name=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--IP")	#
			ip=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--NODE")	#
			node=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--CLASS")	#
			storageclass=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--DIR")	#
			directory=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--SIZE")	#
			size=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--RECLAIM")	#
			reclaim=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--RELEASE")	#
			release=$2; shift 2; ARGC=$(($ARGC-2)) ;;
		"--SILENT")	#
			silent="true"; shift 1; ARGC=$(($ARGC-1)) ;;
		"--HELP")	#
			USAGE
            exit 1 ;;
		*)
			echo "Argument \"$ARG\" not known, exiting..."
			USAGE
            exit 1 ;;
    esac
done

}

PRINT_YAML() {
if [ -n "${print_yaml}" ] ; then
	echo "Printing YAML:"
	echo "-----"
	cat ${yaml_name}
	echo "-----"
	echo
fi
}
PRINT() {
if [ -z "${silent}" ] ; then
	echo "$@"
fi
}

CREATE_NFS_PV() {
VERIFY_VARIABLE name "the name of the PV" "name" ${name}
VERIFY_VARIABLE size "the size of the PV" "size" ${size}
VERIFY_VARIABLE release "the release of the PV" "release" ${release}
VERIFY_VARIABLE storageclass "the storageclass of the PV" "class" ${storageclass}
VERIFY_VARIABLE directory "the directory of the PV" "dir" ${directory}
VERIFY_VARIABLE ip "the ip of the PV" "ip" ${ip}
VERIFY_VARIABLE reclaim "the reclaim policy of the PV" "reclaim" ${reclaim}

yaml_name=${DIR}/yaml/PersistentVolume_${name}_${release}.yaml

cat > ${yaml_name} <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${name}
  labels:
    release: ${release}
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: ${size}
  persistentVolumeReclaimPolicy: ${reclaim}
  storageClassName: ${storageclass}
  nfs:
    path: ${directory}
    server: ${ip}
EOF
PRINT_YAML
 #PRINT "Creating PV ${name}"
 # kubectl create -f ${yaml_name}
 #PRINT
 #echo "*** Please create dir $directory on NFS server $ip ***"
}

CREATE_STORAGECLASS() {
 #exists=`kubectl get storageclass | grep ${storageclass}`
 #if [ -z "${exists}" ] ; then
 #VERIFY_VARIABLE release "the release of the PV" "release" ${release}

yaml_name=${DIR}/yaml/StorageClass_${storageclass}_${release}.yaml

cat > ${yaml_name} <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${storageclass}
  labels:
    release: ${release}
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
	PRINT_YAML
 #	PRINT "Creating STORAGECLASS ${storageclass}"
 # 	kubectl create -f ${yaml_name}
 #else
 #	PRINT "STORAGECLASS ${storageclass} already exists"
 #fi
PRINT
}

CREATE_LOCAL_PV() {
VERIFY_VARIABLE name "the name of the PV" "name" ${name}
VERIFY_VARIABLE size "the size of the PV" "size" ${size}
VERIFY_VARIABLE release "the release of the PV" "release" ${release}
VERIFY_VARIABLE directory "the directory of the PV" "dir" ${directory}
VERIFY_VARIABLE reclaim "the reclaim policy of the PV" "reclaim" ${reclaim}

if [ -n "${node}" ] ; then
	affinityNode=${node}
elif [ -n "${ip}" ] ; then
	affinityNode=${ip}
fi
if [ -z "${affinityNode}" ] ; then
	echo "Please enter either the \"--node <name>\" or the \"--ip <ip>\" for the system to lock the local PV to with affinity."
	exit 1
fi

yaml_name=${DIR}/yaml/PersistentVolume_${name}_${release}.yaml

cat > ${yaml_name} <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${name}
  labels:
    release: ${release}
spec:
  capacity:
    storage: ${size}
  storageClassName: ${storageclass}
  local:
    path: ${directory}
  nodeAffinity:
      required:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values: ["${affinityNode}"]
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: ${reclaim}
EOF

PRINT_YAML
 #PRINT "Creating PV ${name}"
 # kubectl create -f ${yaml_name}
 #echo "*** Please ensure dir $directory is created on IBM Cloud Private Worker Node $node ***"
}

MAIN() {
VERIFY_VARIABLE storageclass "the storageclass of the PV" "class" ${storageclass}
is_nfs=`echo $storageclass | grep -i nfs | wc -l`
if [ ${is_nfs} -gt '0' ] ; then
	CREATE_NFS_PV
else
	CREATE_STORAGECLASS
	CREATE_LOCAL_PV
fi
PRINT
#if [ -z "${silent}" ] ; then
#	kubectl get pv | egrep "${name}|STORAGECLASS"
#fi
#rm -rf ${yaml_name}
#PRINT
}

INITIALIZE
PARSE_ARGS "$@"
MAIN
