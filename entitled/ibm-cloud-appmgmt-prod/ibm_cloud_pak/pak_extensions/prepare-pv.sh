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

pwd=$(pwd)/ibm_cloud_pak/pak_extensions
DIR=$(dirname $0)
source ${DIR}/lib/cloud-vars.sh
source ${DIR}/lib/utils.sh
test -e ${DIR}/../yaml || mkdir ${DIR}/../yaml



USAGE() {
    echo "This script will compose persistent storage definitions for Cassandra, Kafka, Zookeeper, CouchDB
and Datastore. After running this script, you will find these definitions in ${DIR}/../yaml directory.
You will apply these persistent storage definitions onto ICP via kubectl create -f ${DIR}/../yaml"
    echo ""
    echo "Usage: $0"
    echo "    --releaseName <name>                Release name (default is ${release_name})"
    echo "    --size0                                   Install as size0 (minimum resource requirements)  - if omitted, specify each size in parameters"
    echo "    --size0_amd64                             Install as size0 on amd64 (minimum resource requirements)  - if omitted, specify each size in parameters"
    echo "    --size0_ppc64le                           Install as size0 on ppc64le (minimum resource requirements, reduced CPU values)  - if omitted, specify each size in parameters"
    echo "    --size1                                   Install as size1 (standard resource requirements)  - if omitted, specify each size in parameters"
    echo "    --size1_amd64                             Install as size1 on amd64 (standard resource requirements) - if omitted, specify each size in parameters"
    echo "    --size1_ppc64le                           Install as size1 on ppc64le (standard resource requirements, reduced CPU values) - if omitted, specify each size in parameters"
    echo
    echo "  *Required flags for local storage: "
    echo "    --local                                  Use local persistent volume storage"
    echo "    --CassandraNodes     <ICP_worker_node>   Worker node(s) for Cassandra. For multiple Cassandra use a quoted, space separated list."
    echo "    --KafkaNodes         <ICP_worker_node>   Worker node(s) for Kafka. For multiple Kafka use a quoted, space separated list."
    echo "    --ZookeeperNodes     <ICP_worker_node>   Worker node(s) for Zookeeper. For multiple Zookeeper use a quoted, space separated list."
    echo "    --CouchDBNodes       <ICP_worker_node>   Worker node(s) for CouchDB. For multiple CouchDB use a quoted, space separated list."
    echo "    --DatalayerNodes     <ICP_worker_node>   Worker node(s) for Datalayer. For multiple Datalayer use a quoted, space separated list."
    echo "    --ElasticsearchNodes <ICP_worker_node>   Worker node(s) for Elasticsearch. For multiple Elasticsearch use a quoted, space separated list."
    echo
    echo "  *Optional storage directory paths for local storage: "
    echo "    --CassandraDir        <directory>     Local system directory for Cassandra (default is ${cassandra_dir})"
    echo "    --CassandraBackupDir  <directory>     Local system directory for Cassandra backups (default is ${cassandra_backup_dir})"
    echo "    --KafkaDir            <directory>     Local system directory for Kafka (default is ${kafka_dir})"
    echo "    --ZookeeperDir        <directory>     Local system directory for Zookeeper (default is ${zookeeper_dir})"
    echo "    --CouchDBDir          <directory>     Local system directory for CouchDB (default is ${couchdb_dir})"
    echo "    --DatalayerDir        <directory>     Local system directory for Datalayer (default is ${datalayer_dir})"
    echo "    --ElasticsearchDir    <directory>     Local system directory for Elasticsearch (default is ${elasticsearch_dir})"
    echo
    echo "  *Optional storage class name flags for local storage: "
    echo "    --CassandraClass        <className>         Storage class name for Cassandra (default is <release_name>-${cassandra_class})"
    echo "    --CassandraBackupClass  <className>         Storage class name for Cassandra backups (default is <release_name>-${cassandra_backup_class})"
    echo "    --KafkaClass            <className>         Storage class name for Kafka (default is <release_name>-${kafka_class})"
    echo "    --ZookeeperClass        <className>         Storage class name for Zookeeper (default is <release_name>-${zookeeper_class})"
    echo "    --CouchDBClass          <className>         Storage class name for CouchDB (default is <release_name>-${couchdb_class})"
    echo "    --DatalayerClass        <className>         Storage class name for Datalayer (default is <release_name>-${datalayer_class})"
    echo "    --ElasticsearchClass    <className>         Storage class name for Elasticsearch (default is <release_name>-${elasticsearch_class})"
    echo
    echo "  *Required flags for vSphere storage: "
    echo "    --vSphere                           Use vSphere provisioned storage (requires existing vSphere storage class)"
    echo
    echo "  *Optional storage size flags for local and vSphere storage: "
    echo "    --CassandraSize         <size>              Size of persistent volume for Cassandra (default size0_amd64 and size0_ppc64le is ${cassandra_size})"
    echo "    --CassandraBackupSize   <size>              Size of persistent volume for Cassandra backups (default size0_amd64 and size0_ppc64le is ${cassandra_backup_size})"
    echo "    --KafkaSize             <size>              Size of persistent volume for Kafka (default size0_amd64 and size0_ppc64le is ${kafka_size})"
    echo "    --ZookeeperSize         <size>              Size of persistent volume for Zookeeper (default size0_amd64 and size0_ppc64le is ${zookeeper_size})"
    echo "    --CouchDBSize           <size>              Size of persistent volume for CouchDB (default size0_amd64 and size0_ppc64le is ${couchdb_size})"
    echo "    --DatalayerSize         <size>              Size of persistent volume for Datalayer (default size0_amd64 and size0_ppc64le is ${datalayer_size})"
    echo "    --ElasticsearchSize     <size>              Size of persistent volume for Elasticsearch (default size0_amd64 and size0_ppc64le is ${elasticsearch_size})"
    echo
}

PARSE_ARGS() {
    ARGC=$#
    if [ $ARGC == 0 ] ; then
        USAGE
        exit
    fi
    while [ $ARGC != 0 ] ; do
        if [ "$1" == "-n" ] || [ "$1" == "-N" ] ; then
            ARG="-N"
        else
            PRE_FORMAT_ARG=$1
            ARG=`echo $1 | tr .[a-z]. .[A-Z].`
        fi
        case $ARG in
            "--RELEASENAME")  #
              release_name=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--SIZE0_AMD64")  #
              global_environmentSize="size0_amd64"; shift 1; ARGC=$(($ARGC-1)) ;;
            "--SIZE0_PPC64LE")  #
              global_environmentSize="size0_ppc64le"; shift 1; ARGC=$(($ARGC-1)) ;;
            "--SIZE1_AMD64")  #
              global_environmentSize="size1_amd64"; shift 1; ARGC=$(($ARGC-1)) ;;
            "--SIZE1_PPC64LE")  #
              global_environmentSize="size1_ppc64le"; shift 1; ARGC=$(($ARGC-1)) ;;
            "--SIZE0")  #
              global_environmentSize="size0"; shift 1; ARGC=$(($ARGC-1)) ;;
            "--SIZE1")  #
              global_environmentSize="size1"; shift 1; ARGC=$(($ARGC-1)) ;;
            "--VSPHERE")    #
              use_vsphere_storage="true"; shift 1; ARGC=$(($ARGC-1)) ;;
            "--LOCAL")    #
              use_vsphere_storage="false"; shift 1; ARGC=$(($ARGC-1)) ;;
            "--BACKUPCASSANDRA")    #
              backup_cassandra="true"; shift 1; ARGC=$(($ARGC-1)) ;;

            "--CASSANDRANODES")  #
              cassandra_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ZOOKEEPERNODES")  #
              zookeeper_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--KAFKANODES")  #
              kafka_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--COUCHDBNODES")  #
              couchdb_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--DATALAYERNODES")  #
              datalayer_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ELASTICSEARCHNODES")  #
              elasticsearch_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;

            "--CASSANDRANODE")  #
              cassandra_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ZOOKEEPERNODE")  #
              zookeeper_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--KAFKANODE")  #
              kafka_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--COUCHDBNODE")  #
              couchdb_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--DATALAYERNODE")  #
              datalayer_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ELASTICSEARCHNODE")  #
              elasticsearch_nodes=$2; shift 2; ARGC=$(($ARGC-2)) ;;

            "--CASSANDRACLASS")  #
              cassandra_class=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--CASSANDRABACKUPCLASS")  #
              cassandra_backup_class=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ZOOKEEPERCLASS")  #
              zookeeper_class=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--KAFKACLASS")  #
              kafka_class=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--COUCHDBCLASS")  #
              couchdb_class=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--DATALAYERCLASS")  #
              datalayer_class=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ELASTICSEARCHCLASS")  #
              elasticsearch_class=$2; shift 2; ARGC=$(($ARGC-2)) ;;

            "--CASSANDRADIR")  #
              cassandra_dir=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--CASSANDRABACKUPDIR")  #
              cassandra_backup_dir=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ZOOKEEPERDIR")  #
              zookeeper_dir=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--KAFKADIR")  #
              kafka_dir=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--COUCHDBDIR")  #
              couchdb_dir=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--DATALAYERDIR")  #
              datalayer_dir=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ELASTICSEARCHDIR")  #
              elasticsearch_dir=$2; shift 2; ARGC=$(($ARGC-2)) ;;

            "--CASSANDRASIZE")      #
                cassandra_size=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--CASSANDRABACKUPSIZE")      #
                cassandra_backup_size=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--KAFKASIZE")  #
                kafka_size=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ZOOKEEPERSIZE")      #
                zookeeper_size=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--DATALAYERSIZE")      #
                datalayer_size=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--COUCHDBSIZE")        #
                couchdb_size=$2; shift 2; ARGC=$(($ARGC-2)) ;;
            "--ELASTICSEARCHSIZE")        #
                elasticsearch_size=$2; shift 2; ARGC=$(($ARGC-2)) ;;

            "--HELP")  #
                USAGE
                exit 1 ;;

            *)
                PRINT_MESSAGE "Argument \"${PRE_FORMAT_ARG}\" not known. Exiting.\n"
                USAGE
                exit 1 ;;
        esac
    done
}


VSPHERE_STORAGE() {
    ## VSphere storage class name is hard coded according to VMWare
    vsphere_class=`kubectl get sc | grep -i vsphere-volume | tail -1 | awk '{ print $1 }'`
  if [ -z "${vsphere_class}" ] ; then
    PRINT_MESSAGE "Could not find any vsphere-volume storage classes. Exiting.\n"
    exit 1
    fi

  global_persistence_storageClassName="${vsphere_class}"
  if [ -z "${cassandra_class}" ] ; then
    cassandra_class="default"
  fi
  if [ -z "${cassandra_backup_class}" ] ; then
    if [ "${backup_cassandra}" == "true" ] ; then
      cassandra_backup_class="default"
    else
      cassandra_backup_class="none"
    fi
  fi
  if [ -z "${kafka_class}" ] ; then
    kafka_class="default"
  fi
  if [ -z "${zookeeper_class}" ] ; then
    zookeeper_class="default"
  fi
  if [ -z "${couchdb_class}" ] ; then
    couchdb_class="default"
  fi
  if [ -z "${datalayer_class}" ] ; then
    datalayer_class="default"
  fi
  if [ -z "${elasticsearch_class}" ] ; then
    elasticsearch_class="default"
  fi
  create_PVs=""
}

LOCAL_STORAGE() {

  if [ -z "${cassandra_class}" ] ; then
    cassandra_class="${release_name}-${local_storage_class_prefix}-cassandra"
  fi
  if [ -z "${cassandra_backup_class}" ] ; then
    if [ "${backup_cassandra}" == "true" ] ; then
      cassandra_backup_class="${release_name}-${local_storage_class_prefix}-cassandra-backup"
    else
      cassandra_backup_class="none"
    fi
  fi
  if [ -z "${kafka_class}" ] ; then
    kafka_class="${release_name}-${local_storage_class_prefix}-kafka"
  fi
  if [ -z "${zookeeper_class}" ] ; then
    zookeeper_class="${release_name}-${local_storage_class_prefix}-zookeeper"
  fi
  if [ -z "${couchdb_class}" ] ; then
    couchdb_class="${release_name}-${local_storage_class_prefix}-couchdb"
  fi
  if [ -z "${datalayer_class}" ] ; then
    datalayer_class="${release_name}-${local_storage_class_prefix}-datalayer"
  fi
  if [ -z "${elasticsearch_class}" ] ; then
    elasticsearch_class="${release_name}-${local_storage_class_prefix}-elasticsearch"
  fi
}

IDENTIFY_STORAGE_SIZE() {
  if [[ $global_environmentSize == *"size1"* ]]; then
    if [ -z "${cassandra_size}" ] ; then
      cassandra_size=$cassandra_size_1
    fi
    if [ -z "${cassandra_backup_size}" ] ; then
      cassandra_backup_size=$cassandra_backup_size_1
    fi
    if [ -z "${kafka_size}" ] ; then
      kafka_size=$kafka_size_1
    fi
    if [ -z "${zookeeper_size}" ] ; then
      zookeeper_size=$zookeeper_size_1
    fi
    if [ -z "${couchdb_size}" ] ; then
      couchdb_size=$couchdb_size_1
    fi
    if [ -z "${datalayer_size}" ] ; then
      datalayer_size=$datalayer_size_1
    fi
    if [ -z "${elasticsearch_size}" ] ; then
      elasticsearch_size=$elasticsearch_size_1
    fi
  else
    if [ -z "${cassandra_size}" ] ; then
      cassandra_size=$cassandra_size_0
    fi
    if [ -z "${cassandra_backup_size}" ] ; then
      cassandra_backup_size=$cassandra_backup_size_0
    fi
    if [ -z "${kafka_size}" ] ; then
      kafka_size=$kafka_size_0
    fi
    if [ -z "${zookeeper_size}" ] ; then
      zookeeper_size=$zookeeper_size_0
    fi
    if [ -z "${couchdb_size}" ] ; then
      couchdb_size=$couchdb_size_0
    fi
    if [ -z "${datalayer_size}" ] ; then
      datalayer_size=$datalayer_size_0
    fi
    if [ -z "${elasticsearch_size}" ] ; then
      elasticsearch_size=$elasticsearch_size_0
    fi
  fi
}

CALL_CLOUD_PV() {
    x=0
    for cassandra_node in ${cassandra_nodes} ; do
    ${DIR}/lib/cloud-pv.sh --release ${release_name} \
          --name ${release_name}-cassandra${x} \
          --size $cassandra_size \
          --node $cassandra_node \
          --class $cassandra_class \
          --dir $cassandra_dir
    x=$(($x+1))
    done

  if [ "${backup_cassandra}" == "true" ] ; then
    x=0
    for cassandra_node in ${cassandra_nodes} ; do
      ${DIR}/lib/cloud-pv.sh --release ${release_name} \
        --name ${release_name}-cassandra-backup${x} \
        --size $cassandra_backup_size \
        --node $cassandra_node \
        --class $cassandra_backup_class \
        --dir $cassandra_backup_dir
      x=$(($x+1))
    done
  fi

    x=0
    for zookeeper_node in ${zookeeper_nodes} ; do
    ${DIR}/lib/cloud-pv.sh --release ${release_name} \
          --name ${release_name}-zookeeper${x} \
          --size $zookeeper_size \
          --node $zookeeper_node \
          --class $zookeeper_class \
          --dir $zookeeper_dir
    x=$(($x+1))
    done

    x=0
    for kafka_node in ${kafka_nodes} ; do
    ${DIR}/lib/cloud-pv.sh --release ${release_name} \
          --name ${release_name}-kafka${x} \
          --size $kafka_size \
          --node $kafka_node \
          --class $kafka_class \
          --dir $kafka_dir
    x=$(($x+1))
    done

    x=0
    for couchdb_node in ${couchdb_nodes} ; do
    ${DIR}/lib/cloud-pv.sh --release ${release_name} \
          --name ${release_name}-couchdb${x} \
          --size $couchdb_size \
          --node $couchdb_node \
          --class $couchdb_class \
          --dir $couchdb_dir
    x=$(($x+1))
    done

    x=0
    for datalayer_node in ${datalayer_nodes} ; do
    ${DIR}/lib/cloud-pv.sh --release ${release_name} \
          --name ${release_name}-datalayer${x} \
          --size $datalayer_size \
          --node $datalayer_node \
          --class $datalayer_class \
          --dir $datalayer_dir
    x=$(($x+1))
    done

    x=0
    for elasticsearch_node in ${elasticsearch_nodes} ; do
    ${DIR}/lib/cloud-pv.sh --release ${release_name} \
          --name ${release_name}-elasticsearch${x} \
          --size $elasticsearch_size \
          --node $elasticsearch_node \
          --class $elasticsearch_class \
          --dir $elasticsearch_dir
    x=$(($x+1))
    done

}

CONFIG_YAML() {
    cat >${DIR}/../yaml/${storage_size_file}  <<EOF
  environmentSize: "${global_environmentSize}"
  persistence:
    enabled: true
    storageClassName: "${global_persistence_storageClassName}"
    storageClassOption:
      cassandradata: "${cassandra_class}"
      cassandrabak: "${cassandra_backup_class}"
      zookeeperdata: "${zookeeper_class}"
      kafkadata: "${kafka_class}"
      couchdbdata: "${couchdb_class}"
      datalayerjobs: "${datalayer_class}"
      elasticdata: "${elasticsearch_class}"
    storageSize:
      cassandradata: "${cassandra_size}"
      cassandrabak: "${cassandra_backup_size}"
      zookeeperdata: "${zookeeper_size}"
      kafkadata: "${kafka_size}"
      couchdbdata: "${couchdb_size}"
      datalayerjobs: "${datalayer_size}"
      elasticdata: "${elasticsearch_size}"
EOF

    if [ -n "$DEBUG" ]; then
        cat ${DIR}/../yaml/${storage_size_file}
    fi
}

INITIALIZE
PARSE_ARGS "$@"

IDENTIFY_STORAGE_SIZE

if [ "$use_vsphere_storage" == "true" ]; then
   PRINT_MESSAGE "Using vSphere storage.\n\n"
   VSPHERE_STORAGE
else
    global_persistence_storageClassName=""
    PRINT_MESSAGE "Using Local storage.\n\n"
    LOCAL_STORAGE
    CALL_CLOUD_PV
fi

CONFIG_YAML
cat <<EOF
    Persistent volumes and storage classes definitions are prepared in "${DIR}/../yaml" directory. You can modify volume sizes by editing persitent volumes YAML file if necessary.
    Then please execute "kubectl create -f ${DIR}/../yaml/" command to create persistent volumes and storage classes in to ICP.

EOF
