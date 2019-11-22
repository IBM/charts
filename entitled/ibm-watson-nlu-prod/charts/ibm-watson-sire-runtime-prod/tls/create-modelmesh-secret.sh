#!/bin/bash
echo '{' > modelmesh_connection_string.json
echo '  "root_prefix":"sire",' >> modelmesh_connection_string.json
echo '  "userid":"root",' >> modelmesh_connection_string.json
echo '  "password":"ibmwatson",' >> modelmesh_connection_string.json
echo '  "compose_deployment":"*.*.svc.cluster.local",' >> modelmesh_connection_string.json
echo '  "endpoints":"https://cluster-local-etcd-etcd-headless:2379",' >> modelmesh_connection_string.json
echo '  "certificate_file":"/etc/ssl/etcd/ca.crt"' >> modelmesh_connection_string.json
echo '}' >> modelmesh_connection_string.json

#kubectl create secret generic cluster-local-model-mesh --from-file=modelMeshConnectionString=modelmesh_connection_string.json
