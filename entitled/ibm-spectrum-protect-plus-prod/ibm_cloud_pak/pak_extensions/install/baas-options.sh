# The value for DOCKER_REGISTRY_ADDRESS must match the value for imageRegistry in baas-values.yaml
# The value for DOCKER_REGISTRY_NAMESPACE must match the value for imageRegistryNamespace: in baas-values.yaml
#
# To obtain values for PVC_NAMESPACES_TO_PROTECT
#   Determine the namespaces of any PVCs that you want to protect.
#   kubectl get pvc --all-namespaces
#   The namespaces are what's important here. Identify the PVCs that you want to protect.
#   Specify the unique set of namespaces associated with PVCs.

export DOCKER_REGISTRY_ADDRESS='your_docker_registry'
export DOCKER_REGISTRY_USERNAME='your_docker_username'
export DOCKER_REGISTRY_PASSWORD='your_docker_password'
export DOCKER_REGISTRY_NAMESPACE='your_docker_namespace'
export SPP_ADMIN_USERNAME='your_isppadmin_username'
export SPP_ADMIN_PASSWORD='your_isppadmin-password'
export DATAMOVER_USERNAME='make_up_a_datamover_username'
export DATAMOVER_PASSWORD='make_up_a_datamover_password'
export MINIO_USERNAME='make_up_a_minio_username'
export MINIO_PASSWORD='make_up_a_minio_password'
export PVC_NAMESPACES_TO_PROTECT='ns1 ns2'
export BAAS_VERSION='10.1.7'
