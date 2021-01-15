#!/bin/bash
#
# Copyright 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

##### Constants

# Namespace where workload will be created (operator and operand)
INSTALL_NAMESPACE=${INSTALL_NAMESPACE:-ibm-common-services}

##### Functions

usage()
{
   # Display usage
  echo "description: A script to install IBM License Service via Operator."
  echo "usage: $0 [--verbose | -v] [--help | -h] [(--olm_version | -o) <version_number>] [--skip_olm_installation | -s] [(--olm_global_catalog_namespace | -c) <OLM global catalog namespace> ] [(--operator_marketplace_rollout_timeout | -t) <how many seconds>]"
  echo "options:"
  echo "[--verbose | -v] - verbose logs from installation"
  echo "[--olm_version | -o] <version_number> - what version of OLM should be installed if it doesn't exist,"
  echo "by default olm_version=0.13.0"
  echo "[--skip_olm_installation | -s] - skips installation of OLM, but olm global catalog namespace still needs to be found."
  echo "[--olm_global_catalog_namespace | -c] <OLM global catalog namespace> - script will not try to find olm global catalog namespace when set."
  echo "You can read more about OLM global catalog namespace here: https://github.com/operator-framework/operator-lifecycle-manager/blob/master/doc/install/install.md"
  echo "[--operator_marketplace_rollout_timeout | -t] <how many seconds> - how long script should wait for operator marketplace pod to succeed"
  echo "by default operator_marketplace_rollout_timeout=120s"
  echo "[--help | -h] - shows usage"
  echo "prerequisite commands: kubectl, git, curl"
}

if [ "$(uname)" == "Darwin" ]; then
  inline_sed(){
    sed -i "" "$@"
  }
else
  inline_sed(){
    sed -i "$@"
  }
fi

verify_command_line_processing(){
  # Test code to verify command line processing
  verbose_output_command echo "olm version is ${olm_version}"
}

verify_kubectl(){
  if ! verbose_output_command kubectl version; then
    echo "Error: kubectl command does not seems to work"
    echo "try to install it and setup config for your cluster where you want to install IBM License Service"
    exit 2
  fi
}

create_namespace(){
  if ! verbose_output_command kubectl get namespace "${INSTALL_NAMESPACE}"; then
    echo "Creating namespace ${INSTALL_NAMESPACE}"
    if ! kubectl create namespace "${INSTALL_NAMESPACE}"; then
      echo "Error: kubectl command cannot create needed namespace"
      echo "make sure you are connected to your cluster where you want to install IBM License Service and have admin permissions"
      exit 3
    fi
  else
    echo "Needed namespace: \"${INSTALL_NAMESPACE}\", already exists"
  fi
}

install_olm(){
  if [ "${skip_olm_installation}" != "1" ]; then
    echo "Check if OLM is installed"
    verbose_output_command echo "Checking if CSV CRD exists"
    if ! verbose_output_command kubectl get crd clusterserviceversions.operators.coreos.com -o name; then
      echo "CSV CRD does not exists, installing OLM with version ${olm_version}"
      if ! curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/"${olm_version}"/install.sh | bash -s "${olm_version}"; then
        echo "Error: Failed to install OLM"
        echo "You can try to install OLM from here https://github.com/operator-framework/operator-lifecycle-manager/releases and continue installation while skipping OLM part"
        exit 5
      fi
    else
      verbose_output_command echo "OLM's needed CRD: CSV exists"
    fi
  else
    verbose_output_command echo "Skipping OLM installation"
  fi
  if [ "${olm_global_catalog_namespace}" == "" ]; then
    verbose_output_command echo "Trying to get namespace where OLM's packageserver is installed"
    if ! olm_namespace=$(kubectl get csv --all-namespaces -l olm.version -o jsonpath="{.items[?(@.metadata.name=='packageserver')].metadata.namespace}") || [ "${olm_namespace}" == "" ]; then
      echo "Error: Failed to get namespace where OLM's packageserver is installed, which is needed for finding OLM's global catalog namespace, make sure you have OLM installed"
      echo "You can try to install OLM from here https://github.com/operator-framework/operator-lifecycle-manager/releases"
      echo "If you can find OLM's global catalog namespace yourself try setting parameter --olm_global_catalog_namespace parameter of this script"
      echo "On OpenShift Container Platform this probably is 'openshift-marketplace', but for older versions and for custom OLM installation it might be 'olm', but you might verify it by looking for OLM's packageserver deployment configuration"
      exit 6
    else
      verbose_output_command echo "Namespace where OLM's packageserver is installed is: ${olm_namespace}"
    fi
    verbose_output_command echo "Trying to get OLM's global catalog namespace so that catalog needed by IBM Licensing can be accessed in any watched namespace."
    if ! olm_global_catalog_namespace=$(kubectl get deployment --namespace="${olm_namespace}" packageserver -o yaml | grep -A 1 -i global-namespace | tail -1 | cut -d "-" -f 2- | sed -e 's/^[ \t]*//') || [ "${olm_global_catalog_namespace}" == "" ]; then
      echo "Error: Failed to find OLM's global catalog namespace where catalog for IBM Licensign needs to be installed"
      echo "If you can find it yourself try setting parameter --olm_global_catalog_namespace parameter of this script"
      echo "On OpenShift Container Platform this probably is 'openshift-marketplace', but for older versions and for custom OLM installation it might be 'olm', but you might verify it by looking for OLM's packageserver deployment configuration"
      exit 7
    else
      verbose_output_command echo "OLM's global catalog namespace is: ${olm_global_catalog_namespace}"
    fi
  else
    verbose_output_command echo "OLM global catalog namespace set by user, skipping finding it inside script"
  fi
  echo "OLM should be working"
}

install_marketplace(){
  echo "Check if Operator Marketplace is installed"
  verbose_output_command echo "Checking if Operator Source CRD exists"
  if ! verbose_output_command kubectl get crd operatorsources.operators.coreos.com -o name; then
    echo "Operator Source CRD does not exists, installing Operator Marketplace from release tag ${operator_marketplace_release_tag}"
    if ! [[ -d operator-marketplace ]]; then
      if ! verbose_output_command git clone --single-branch --branch "${operator_marketplace_release_tag}" https://github.com/operator-framework/operator-marketplace.git; then
        echo "Error: Failed to git clone operator marketplace repository into current directory, you can try to fix it and run again or install operator marketplace yourself from https://github.com/operator-framework/operator-marketplace"
        exit 8
      fi
    fi
    verbose_output_command echo "changing Operator Marketplace yaml files namespace to OLM global catalog namespace: ${olm_global_catalog_namespace}"
    verbose_output_command echo "Doing it and creating Operator Source in this namespace will allow Subscriptions to use created Catalog Source in whole cluster"
    if ! inline_sed 's/namespace: .*/namespace: '"${olm_global_catalog_namespace}"'/g' operator-marketplace/deploy/upstream/*; then
      echo "Error: Problem during changing Operator Marketplace yamls namespace with sed"
      echo "Remember to delete operator-marketplace directory if you want cleanup"
      exit 9
    fi
    # delete not needed namespace yaml
    rm -f operator-marketplace/deploy/upstream/01_namespace.yaml
    # try kubectl apply twice for operator crd to appear
    if ! kubectl apply -f operator-marketplace/deploy/upstream; then
      echo "kubectl apply on operator-marketplace yaml files failed, will try again in 5 seconds"
      sleep 5
    fi
    if ! kubectl apply -f operator-marketplace/deploy/upstream; then
      echo "Kubectl apply on Operator Marketplace yaml files failed, will try to install with possible fix"
      inline_sed '/.*preserveUnknownFields.*/d' operator-marketplace/deploy/upstream/*
      kubectl apply -f operator-marketplace/deploy/upstream
      if ! kubectl apply -f operator-marketplace/deploy/upstream; then
        echo "kubectl apply on operator-marketplace yaml files failed, will try again in 5 seconds"
        sleep 5
      fi
      if ! kubectl apply -f operator-marketplace/deploy/upstream; then
        echo "Error: Problem during applying Operator Marketplace yamls, you can try to fix it and run again or install operator marketplace yourself from https://github.com/operator-framework/operator-marketplace"
        echo "Remember to delete operator-marketplace directory if you want cleanup"
        exit 10
      else
        echo "Applied Operator Marketplace yamls after fixing problem with preserveUnknownFields"
      fi
    fi
    echo "Operator Marketplace installed in ${olm_global_catalog_namespace} namespace"
  else
    echo "Operator Marketplace seems to be installed"
  fi
  # verify operator marketplace works
  echo "Waiting ${operator_marketplace_rollout_timeout} for Marketplace Operator deployment to succeed"
  if ! kubectl rollout status --timeout="${operator_marketplace_rollout_timeout}" -w deployment/marketplace-operator --namespace="${olm_global_catalog_namespace}"; then
    echo "Problem during marketplace-operator deployment rollout, will try to fix possible error"
    # check if this error exists:
    if kubectl get pod -l name=marketplace-operator -n "${olm_global_catalog_namespace}" -o json | grep "cannot verify user is non-root"; then
      FIX_NON_ROOT_USER_BODY="        - securityContext:\n            runAsUser: 65534"
      inline_sed 's/^        - name:/'"$FIX_NON_ROOT_USER_BODY"'\n          name:/g' operator-marketplace/deploy/upstream/08_operator.yaml
      if ! kubectl delete deployment/marketplace-operator --namespace="${olm_global_catalog_namespace}"; then
        echo "Could not delete marketplace operator deployment for fixing possible issue"
        exit 24
      fi
      if ! kubectl apply -f operator-marketplace/deploy/upstream/08_operator.yaml; then
        echo "Error: Problem during applying Operator Marketplace yamls after non-root user issue, you can try to fix it and run again or install operator marketplace yourself from https://github.com/operator-framework/operator-marketplace"
        echo "Remember to delete operator-marketplace directory if you want cleanup"
        exit 23
      fi
      echo "Waiting ${operator_marketplace_rollout_timeout} for Marketplace Operator deployment to succeed"
      if ! kubectl rollout status --timeout="${operator_marketplace_rollout_timeout}" -w deployment/marketplace-operator --namespace="${olm_global_catalog_namespace}"; then
        echo "Error: Problem during marketplace-operator deployment rollout still exists after trying potential fix, check its status for possible errors, try running script again when fixed, check README for manual installation and troubleshooting"
        echo "Remember to delete operator-marketplace directory if you want cleanup"
        exit 25
      fi
    else
      echo "Error: Problem during marketplace-operator deployment rollout, check its status for possible errors, try running script again when fixed, check README for manual installation and troubleshooting"
      echo "Remember to delete operator-marketplace directory if you want cleanup"
      exit 22
    fi
    verbose_output_command echo "Operator Marketplace deployment seems to be working good"
    rm -rf operator-marketplace
  fi
}

handle_operator_source(){
  if ! verbose_output_command kubectl get OperatorSource opencloud-operators -n "${olm_global_catalog_namespace}"; then
    verbose_output_command echo "Applying opencloud Operator Source"
    if ! cat <<EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorSource
metadata:
  name: opencloud-operators
  namespace: $olm_global_catalog_namespace
spec:
  authorizationToken: {}
  displayName: IBMCS Operators
  endpoint: https://quay.io/cnr
  publisher: IBM
  registryNamespace: opencloudio
  type: appregistry
EOF
    then
      echo "Error: Failed to apply Operator Source"
      exit 11
    fi
  else
    verbose_output_command echo "opencloud-operators Operator Source already exists"
  fi
  echo "Waiting for opencloud Operator Source deployment to be ready"
  retries=50
  until [[ $retries == 0 || $new_os_phase == "Succeeded" ]]; do
    new_os_phase=$(kubectl get operatorsource -n "${olm_global_catalog_namespace}" opencloud-operators -o jsonpath='{.status.currentPhase.phase.name}' 2>/dev/null || echo "Waiting for Operator Source to appear")
    if [[ $new_os_phase != "$os_phase" ]]; then
      os_phase=$new_os_phase
      echo "opencloud Operator Source phase: $os_phase"
      if [ "$os_phase" == "Failed" ]; then
        echo "Error: Problem during installation of Operator Source, check README for manual installation and troubleshooting"
        exit 12
      fi
    fi
    sleep 1
    retries=$((retries - 1))
  done
  if [ $retries == 0 ]; then
      echo "Error: OperatorSource \"opencloud-operators\" failed to reach phase Succeeded in 50 retries"
      exit 13
  fi
  echo "Waiting 300s for Marketplace Operator deployment to succeed"
  if ! kubectl rollout status --timeout=300s -w deployment/opencloud-operators --namespace="${olm_global_catalog_namespace}"; then
    echo "Error: Problem during opencloud-operators deployment rollout, check its status for possible errors, try running script again when fixed, check README for manual installation and troubleshooting"
    exit 14
  fi
  echo "opencloud Operator Source initialized"
}

handle_operator_group(){
  if ! verbose_output_command kubectl get OperatorGroup operatorgroup -n "${INSTALL_NAMESPACE}"; then
    verbose_output_command echo "Applying operatorgroup at namespace $INSTALL_NAMESPACE"
    if ! cat <<EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: operatorgroup
  namespace: $INSTALL_NAMESPACE
spec:
  targetNamespaces:
  - $INSTALL_NAMESPACE
EOF
    then
      echo "Error: Failed to apply OperatorGroup at namespace $INSTALL_NAMESPACE"
      exit 15
    fi
  else
    echo "OperatorGroup already exists"
  fi
}

create_subscription(){
  if ! cat <<EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-licensing-operator-app
  namespace: $INSTALL_NAMESPACE
spec:
  channel: stable-v1
  name: ibm-licensing-operator-app
  source: opencloud-operators
  sourceNamespace: $olm_global_catalog_namespace
EOF
  then
    echo "Error: Failed to apply Subscription at namespace $INSTALL_NAMESPACE"
    exit 16
  fi
}

handle_subscription(){
  if ! verbose_output_command kubectl get sub ibm-licensing-operator-app -n "${INSTALL_NAMESPACE}"; then
    create_subscription
  else
    verbose_output_command echo "Subscription already exists"
  fi
  echo "Checking Subscription and CSV status"
  retries=55
  no_csv_name_in_sub_count=0
  until [[ $retries == 0 || $new_csv_phase == "Succeeded" ]]; do
    csv_name=$(kubectl get sub -n "${INSTALL_NAMESPACE}" ibm-licensing-operator-app -o jsonpath='{.status.currentCSV}')
    if [[ "$csv_name" == "" ]]; then
      no_csv_name_in_sub_count=$((no_csv_name_in_sub_count + 1))
      if [ $no_csv_name_in_sub_count -gt 9 ]; then
        no_csv_name_in_sub_count=0
        verbose_output_command "No CSV name in Subscription, deleting Subscription and creating it again"
        kubectl delete sub ibm-licensing-operator-app -n "${INSTALL_NAMESPACE}"
        sleep 5
        create_subscription
      fi
    else
      new_csv_phase=$(kubectl get csv -n "${INSTALL_NAMESPACE}" "${csv_name}" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Waiting for CSV to appear")
      if [[ $new_csv_phase != "$csv_phase" ]]; then
        csv_phase=$new_csv_phase
        echo "$csv_name phase: $csv_phase"
        if [ "$csv_phase" == "Failed" ]; then
          echo "Error: Problem during installation of Subscription, try deleting Subscription and run script again."
          echo "If that won't help, check README for manual installation and troubleshooting"
          exit 17
        fi
      fi
    fi
    sleep 2
    retries=$((retries - 1))
  done
  if [ $retries == 0 ]; then
    echo "Error: CSV \"$csv_name\" failed to reach phase succeeded, try deleting Subscription and run script again."
    echo "If that won't help, check README for manual installation and troubleshooting"
    exit 18
  fi
  echo "Subscription and CSV should work"
}

handle_instance(){
  if ! verbose_output_command kubectl get IBMLicensing instance; then
    if ! cat <<EOF | kubectl apply -f -
apiVersion: operator.ibm.com/v1alpha1
kind: IBMLicensing
metadata:
  name: instance
spec:
  apiSecretToken: ibm-licensing-token
  datasource: datacollector
  httpsEnable: true
  instanceNamespace: $INSTALL_NAMESPACE
EOF
    then
      echo "Error: Failed to apply IBMLicensing instance at namespace $INSTALL_NAMESPACE"
      exit 19
    fi
  else
    verbose_output_command echo "IBMLicensing instance already exists"
  fi
  echo "Checking IBMLicensing instance status"
  retries=50
  until [[ $retries == 0 || $new_ibmlicensing_phase == "Running" ]]; do
    new_ibmlicensing_phase=$(kubectl get IBMLicensing instance -o jsonpath='{.status..phase}' 2>/dev/null || echo "Waiting for IBMLicensing pod to appear")
    if [[ $new_ibmlicensing_phase != "$ibmlicensing_phase" ]]; then
      ibmlicensing_phase=$new_ibmlicensing_phase
      echo "IBMLicensing Pod phase: $ibmlicensing_phase"
      if [ "$ibmlicensing_phase" == "Failed" ] ; then
        echo "Error: Problem during installation of IBMLicensing, try running script again when fixed, check README for post installation section and troubleshooting"
        exit 20
      fi
    fi
    sleep 3
    retries=$((retries - 1))
  done
  if [ $retries == 0 ]; then
    echo "Error: IBMLicensing instance pod failed to reach phase Running"
    exit 21
  fi
  echo "IBM License Service should be running, you can check post installation section in README to see possible configurations of IBM Licensing instance, and how to configure ingress/route if needed"
}

verbose_output_command(){
  if [ "$verbose" = "1" ]; then
    "$@"
  else
    "$@" 1> /dev/null 2>&1
  fi
}

##### Parse arguments

verbose=
olm_version=0.13.0
operator_marketplace_release_tag=release-4.6
operator_marketplace_rollout_timeout=120s
skip_olm_installation=
olm_global_catalog_namespace=


while [ "$1" != "" ]; do
  OPT=$1
  case $OPT in
    -h | --help )                                       usage
                                                        exit
                                                        ;;
    -v | --verbose )                                    verbose=1
                                                        ;;
    -o | --olm_version )                                shift
                                                        olm_version=$1
                                                        ;;
    -c | --olm_global_catalog_namespace )               shift
                                                        olm_global_catalog_namespace=$1
                                                        ;;
    -m | --operator_marketplace_release_tag )           shift
                                                        operator_marketplace_release_tag=$1
                                                        ;;
    -t | --operator_marketplace_rollout_timeout )       shift
                                                        operator_marketplace_rollout_timeout=$1
                                                        ;;
    -s | --skip_olm_installation )                      skip_olm_installation=1
                                                        ;;
    * )                                                 echo "Error: wrong option: $OPT"
                                                        usage
                                                        exit 1
  esac
  if ! shift; then
    echo "Error: did not add needed arguments after option: $OPT"
    usage
    exit 4
  fi
done

##### Main

verify_command_line_processing
verify_kubectl
create_namespace
install_olm
install_marketplace
handle_operator_source
handle_operator_group
handle_subscription
handle_instance
