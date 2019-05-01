#!/bin/bash

# Example test script that'll clean up, install the sample, then run the tests

helm delete --purge sample 2> /dev/null
kubectl delete pod sample-main-endpoint-test 2> /dev/null
kubectl delete pod sample-metrics-endpoint-test 2> /dev/null
kubectl delete pod sample-dash-endpoint-test 2> /dev/null
kubectl delete pod sample-version-8-test 2> /dev/null
kubectl delete pod sample-version-10-test 2> /dev/null

#sleep 15

helm install --name sample .

#sleep 45

helm test --timeout 45 sample
