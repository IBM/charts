#!/bin/bash
#
# You need to run this script for each namespace.
#

if [ "$#" -lt 1 ]; then
	echo "Usage: setupNamespace.sh NAMESPACE"
  exit 1
fi

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' serviceaccount.yaml > $namespace-serviceaccount.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' role.yaml > $namespace-role.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' rolebinding.yaml > $namespace-rolebinding.yaml

# Create the role binding for all service accounts in the current namespace
kubectl apply -f $namespace-serviceaccount.yaml -n $namespace
kubectl apply -f $namespace-role.yaml -n $namespace
kubectl apply -f $namespace-rolebinding.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-serviceaccount.yaml
rm $namespace-role.yaml
rm $namespace-rolebinding.yaml
