#!/bin/bash
kubectl create secret generic cluster-local-s3-access --from-literal=accesskey=admin --from-literal=secretkey=ibmwatson
kubectl create secret generic cluster-local-s3-tls --from-file=private.key --from-file=public.crt --from-file=ca.crt=public.crt
