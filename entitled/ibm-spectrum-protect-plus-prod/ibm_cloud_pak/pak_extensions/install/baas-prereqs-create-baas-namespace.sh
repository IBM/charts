#==================================================================================================
echo "INFO - Create the baas namespace"
#==================================================================================================

echo "kubectl create namespace baas"
echo "kubectl label --overwrite namespace baas namespace=baas"
kubectl create namespace baas
kubectl label --overwrite namespace baas namespace=baas