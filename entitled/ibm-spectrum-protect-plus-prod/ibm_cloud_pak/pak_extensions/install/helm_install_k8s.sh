# ===================================================================================================
# IBM Confidential
# OCO Source Materials
# 5725-W99
# (c) Copyright IBM Corp. 1998, 2020
# The source code for this program is not published or otherwise divested of its
# trade secrets, irrespective of what has been deposited with the U.S. Copyright Office.
# ===================================================================================================
# Install and configure Helm on K8s
# Run as root with K8s admin login 
# 2019-05-06 G.Schmidt
# ===================================================================================================

echo "### ---------------------------"
echo "### Deploying Helm on Kubernetes"
echo "### ---------------------------"

PID=$$
echo "Checking if we are connected to a Kubernetes cluster..."
if ! kubectl get nodes 
then
  echo "ERROR: Please check if you are logged in to a Kubernetes cluster as cluster admin and rerun the script!"
  exit 1
fi

echo "Downloading and installing Helm binary package locally..."
sudo curl -s https://storage.googleapis.com/kubernetes-helm/helm-v2.16.1-linux-amd64.tar.gz | tar xz
sudo cp linux-amd64/helm /usr/local/bin/

echo "Creating RBAC role for server component of Helm (Tiller)"
cat <<\EOF >> /tmp/${PID}_helm_install
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tiller-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
EOF
kubectl create -f /tmp/${PID}_helm_install
rm -f /tmp/${PID}_helm_install

echo "Setting Helm home directory to ~/.helm and adding it as export to .bashrc..."
export HELM_HOME=~/.helm
grep 'HELM_HOME' ~/.bashrc || echo 'export HELM_HOME=~/.helm' >> ~/.bashrc
export TILLER_NAMESPACE=kube-system
grep 'TILLER_NAMESPACE' ~/.bashrc || echo 'export TILLER_NAMESPACE=kube-system' >> ~/.bashrc

# Initialize Helm client and server (Tiller)
echo "Initializing Helm (client & server)..."
helm init --service-account tiller
echo "Waiting 30 seconds for Helm server component Tiller to start..."
sleep 30 
helm version || echo "ERROR: Something went wrong... Please check if you are logged in to a Kubernetes cluster as cluster admin and rerun the script!" && exit 1

