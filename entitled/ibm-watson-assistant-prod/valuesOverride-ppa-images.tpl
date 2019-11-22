# To get rendered file run with image overrides for your cluster please run
#   cat valuesOverride-ppa-images.tpl | ICP_CLUSTER=NAME_OF_YOUR_CLUSTER NAMESPACE=NAMESPACE_NAME envsubst | tee valuesOverride-ppa-images.yaml
# E.g.:  cat valuesOverride-ppa-images.tpl | ICP_CLUSTER=mycluster.icp NAMESPACE=conversation envsubst | tee valuesOverride-ppa-images.yaml 

# Consider adding/uncommenting even these entries
global:
  image:
    repository: "${ICP_CLUSTER}:8500/${NAMESPACE}"
#
#  icp:
#    masterHostname: "${ICP_CLUSTER}"
