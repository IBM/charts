#!/bin/bash
#
# You need to run this script for each namespace.
#

if [ "$#" -lt 1 ]; then
	echo "Usage: setupNamespace.sh NAMESPACE"
  exit 1
fi

namespace=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' $DIR/serviceaccount.yaml > $DIR/$namespace-serviceaccount.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' $DIR/role.yaml > $DIR/$namespace-role.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' $DIR/rolebinding.yaml > $DIR/$namespace-rolebinding.yaml

# Create the role binding for all service accounts in the current namespace
kubectl apply -f $DIR/$namespace-serviceaccount.yaml -n $namespace
kubectl apply -f $DIR/$namespace-role.yaml -n $namespace
kubectl apply -f $DIR/$namespace-rolebinding.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $DIR/$namespace-serviceaccount.yaml
rm $DIR/$namespace-role.yaml
rm $DIR/$namespace-rolebinding.yaml
