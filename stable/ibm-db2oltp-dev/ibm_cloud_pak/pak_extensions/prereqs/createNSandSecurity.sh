#!/bin/bash -e
################################################################################
# 
# You only need to run this script one time per cluster. This will create the namespace
# and also create the respective psp, clusterrole and clusterrolebinding for Db2 OLTP Developer-C.
#
# Copyright 2018, IBM Corporation
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

function usage()
{

cat <<-USAGE #| fmt
        Usage: $0 [OPTIONS] [arg]
        OPTIONS:
        =======
        --namespace        [namespace]           - The name of the namespace for the Db2 OLTP Developer-C deployment.
USAGE
}

if [ "$#" -lt 1 ]; then
   usage >&2
   exit 1
fi

while [ -n "$1" ]
do
   case $1 in
      --namespace)
        NAMESPACE=$2
        shift 2
        ;;
      --help|-h)
        usage >&2
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        usage >&2
        exit 1
        ;;
   esac
done

cp clusterrolebinding.yaml clusterrolebinding.yaml.bak
cp namespace.yaml namespace.yaml.bak
sed -i -e "s/%NAMESPACE%/${NAMESPACE}/g" clusterrolebinding.yaml
sed -i -e "s/%NAMESPACE%/${NAMESPACE}/g" namespace.yaml

if [ `kubectl get namespace | grep $NAMESPACE | wc -l` -gt 0 ]; then
   echo "Namespace $NAMESPACE already exists "
else
   echo "Creating namespace $NAMESPACE for Db2 OLTP Developer-C"
   kubectl create -f namespace.yaml
fi

echo "Creating Pod Security Policies and Cluster Role for Db2 OLTP Developer-C"
kubectl apply -f psp-cr.yaml

echo "Creating Cluster Role Binding for Db2 OLTP Developer-C"
kubectl apply -f clusterrolebinding.yaml

mv clusterrolebinding.yaml.bak clusterrolebinding.yaml
mv namespace.yaml.bak namespace.yaml
