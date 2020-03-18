#!/bin/bash

INITIALIZE() {
prompts="true"
run="true"
prereq=""
values_file="/tmp/ibmcloudappmgmt.values.yaml"
timestamp=`date +"20%y%m%d%H%M"`
log_file="/tmp/install.ibmcloudappmgmt.${timestamp}.log"

size0_cpu="8000"
size0_mem="20000"
size1_cpu="24000"
size1_mem="40000"

set_flag=""
license_agreement_accepted=""
instance_name="ibmcloudappmgmt"
https="false"
advanced="false"

global_environmentSize=""

use_local_storage=""
use_vsphere_storage=""
global_persistence_storageClassName=""
local_storage_class_prefix="local-storage"
directory_prefix="/k8s/data"

backup_cassandra="false"

cassandra_dir="${directory_prefix}/cassandra"
cassandra_backup_dir="${directory_prefix}/cassandra_backup"
kafka_dir="${directory_prefix}/kafka"
zookeeper_dir="${directory_prefix}/zookeeper"
couchdb_dir="${directory_prefix}/couchdb"
datalayer_dir="${directory_prefix}/datalayer"
elasticsearch_dir="${directory_prefix}/elasticsearch"

#Empty, gets set in prepare-pv.sh if not passed as flag
cassandra_class=""
cassandra_backup_class=""
kafka_class=""
zookeeper_class=""
couchdb_class=""
datalayer_class=""
elasticsearch_class=""

ppa_name="app_mgmt_server_2019.2.1.tar.gz"
helm_chart_name="ibm-cloud-appmgmt-prod-1.4.0.tgz"
chart_name="ibm-cloud-appmgmt-prod"
cassandra_resources="${chart_name}/charts/cassandra/templates/_resources.tpl"
kafka_resources="${chart_name}/charts/kafka/templates/_resources.tpl"
zookeeper_resources="${chart_name}/charts/zookeeper/templates/_resources.tpl"
couchdb_resources="${chart_name}/charts/ibm-cem/charts/depCouchdb/templates/_resources.tpl"
datalayer_resources="${chart_name}/charts/ibm-cem/templates/_resources.tpl"
#kubernetes_version="v1.8.3"
icp_version="2.1.0.3"
icp_helm_api_version="1.0.0"
localStorageDir="/k8s"
global_masterIP=""
global_proxyIP=""
global_ingress_domain=""

ppa_file=""
skip_ppa=""
helm_chart_file=""
skip_helm_install=""
run_ICP_post_install_config="true"

namespace="default"
repo_username="admin"
repo_password="admin"
bx_already_logged_in=""
bx_username="admin"
bx_password="admin"
skip_ssl_validation="--skip-ssl-validation"
cluster_CA_domain_default="mycluster.icp"
cluster_name=`echo ${cluster_CA_domain_default} | cut -d '.' -f 1`
bx_account="id-${cluster_name}-account"

cluster_name_default="mycluster"
cluster_CA_domain_default="${cluster_name_default}.icp"
bx_account_default="id-${cluster_name_default}-account"

release_name="ibmcloudappmgmt"
repository_port="8500"
global_masterPort="8443"
global_ingressPort="443"
email="email"

global_environmentSize="size0"

use_local_storage=""
use_vsphere_storage=""
global_persistence_storageClassName=""
local_storage_class_prefix="local-storage"
directory_prefix="/k8s/data"

#Empty, gets set in prepare-pv.sh if not passed as flag
cassandra_size=""
cassandra_backup_size=""
kafka_size=""
zookeeper_size=""
couchdb_size=""
datalayer_size=""
elasticsearch_size=""

cassandra_size_0="50Gi"
cassandra_backup_size_0="50Gi"
kafka_size_0="5Gi"
zookeeper_size_0="1Gi"
couchdb_size_0="5Gi"
datalayer_size_0="5Gi"
elasticsearch_size_0="5Gi"

cassandra_size_1="1000Gi"
cassandra_backup_size_1="1000Gi"
kafka_size_1="100Gi"
zookeeper_size_1="1Gi"
couchdb_size_1="25Gi"
datalayer_size_1="25Gi"
elasticsearch_size_1="25Gi"

create_PVs="true"

storage_size_file=config.storage.txt

server_secret=""
client_secret=""
certificate_archive=""

ibmcemprod_email_type=""
ibmcemprod_email_smtphost=""
ibmcemprod_email_smtpport=""
ibmcemprod_email_smtpuser=""
ibmcemprod_email_smtppassword=""
ibmcemprod_email_smtpauth="true"
ibmcemprod_email_smtprejectunauthorized="true"
ibmcemprod_email_mail=""

ibmcemprod_email_apikey=""
}

#POST_READ() {
#	printf "user input \"$@\"\n" >> ${log_file}
#}
