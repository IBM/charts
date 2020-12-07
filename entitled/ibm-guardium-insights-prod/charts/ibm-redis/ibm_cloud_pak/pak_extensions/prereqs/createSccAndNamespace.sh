#!/bin/bash -e
################################################################################
#
# Create Security Context Constraint
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
        --namespace        [namespace]           - The name of the namespace for the deployment.
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

cp ibm-restricted-scc.yaml ibm-restricted-scc.yaml.bak
cp namespace.yaml namespace.yaml.bak
sed -i -e "s/%NAMESPACE%/${NAMESPACE}/g" ibm-restricted-scc.yaml
sed -i -e "s/%NAMESPACE%/${NAMESPACE}/g" namespace.yaml

if [ `kubectl get namespace | grep $NAMESPACE | wc -l` -gt 0 ]; then
   echo "Namespace $NAMESPACE already exists "
else
   echo "Creating namespace $NAMESPACE"
   kubectl create -f namespace.yaml
fi

echo "Creating Security Context Constraints"
oc apply -f ibm-restricted-scc.yaml

mv ibm-restricted-scc.yaml.bak ibm-restricted-scc.yaml
mv namespace.yaml.bak namespace.yaml
