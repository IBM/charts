#!/bin/bash
kubectl create secret generic cluster-local-etcd --from-literal=etcd-root-password=ibmwatson --from-file=key.pem=private.key --from-file=cert.pem=public.crt --from-file=ca.crt=public.crt
