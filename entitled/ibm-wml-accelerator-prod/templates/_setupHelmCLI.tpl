{{- define "ibm-wml-accelerator-prod.setupHelmCLI" }}
echo "setup helm cli."
{{- if eq (include "ibm-wml-accelerator-prod.securedHelm" .) "false" }}
cp /tmp/helmdir/helm /usr/bin/helm
{{- else }}
{{- if eq (include "ibm-wml-accelerator-prod.securedHelm" .) "true" }}
os_arch=`arch`
bin_arch=linux-amd64
if [ "$os_arch" != "x86_64" ]; then
    bin_arch=linux-ppc64le
fi
master_ip=$(curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default/api/v1/nodes?labelSelector=master%3Dtrue | jq -r '[.items[].status.addresses[] | select(.type=="InternalIP").address][0]')
dockerRegistry={{- .Values.global.dockerRegistryPrefix -}}
export icp_cluster=`echo ${dockerRegistry}|cut -d .  -f 1`
if [ ! -f /usr/bin/helm ]; then
  {{- if eq (include "global.icpVersion" .) "2.x" }}
    if [ -f /tmp/helmdir/cli/$bin_arch/helm ]; then
        cp /tmp/helmdir/cli/$bin_arch/helm /usr/bin/helm
    else
        cp /tmp/helmdir/helm /usr/bin/helm
    fi
  {{- else }}
    curl -kLo /tmp/helm-${bin_arch}.tar.gz https://${master_ip}:8443/api/cli/helm-${bin_arch}.tar.gz
    tar -xvf /tmp/helm-${bin_arch}.tar.gz -C /tmp/
    mv /tmp/${bin_arch}/helm /usr/bin/helm
  {{- end }}
fi

if [ -z "$ADMIN_USERNAME" -a -f /root/.helm/.credential ]; then
    decodedCred=`cat /root/.helm/.credential |base64 -d`
    export ADMIN_USERNAME=`echo $decodedCred|awk -F':' '{ print $1 }'`
    export ADMIN_PASSWORD=`echo $decodedCred|awk -F':' '{ print $2 }'`
fi
{{- if and (eq (.Capabilities.KubeVersion.Major|int) 1) (lt (.Capabilities.KubeVersion.Minor|int) 11)}}
plugin_installed=`bx plugin list|grep icp`
if [ "x$plugin_installed" = "x" ]; then
    icp_cli=icp-${bin_arch}
    wget -q https://${master_ip}:8443/api/cli/${icp_cli} --no-check-certificate -P /tmp/
    bx plugin install /tmp/${icp_cli} -f
fi
bx pr login -a https://${master_ip}:8443 --skip-ssl-validation -u $ADMIN_USERNAME -p $ADMIN_PASSWORD -c id-${icp_cluster}-account
{{- else }}
cloud_ctl=cloudctl-${bin_arch}
if [ ! -f "/usr/local/bin/cloudctl" ]; then
    curl -kLo /tmp/$cloud_ctl https://${master_ip}:8443/api/cli/$cloud_ctl
    chmod a+x /tmp/$cloud_ctl
    mv /tmp/$cloud_ctl /usr/local/bin/cloudctl
fi
export HELM_HOME=/root/.helm
cloudctl login -a https://${master_ip}:8443 --skip-ssl-validation -u $ADMIN_USERNAME -p $ADMIN_PASSWORD -c id-${icp_cluster}-account -n default
{{- end }}
if [ $? -ne 0 ]; then
    echo "helm cli setup failed. you may not be able to create any Spark Instance Groups."
fi
{{- else }}
{{- if eq .Values.cluster.type "iks" }}
if [ ! -f /usr/bin/helm ]; then
  curl -o /tmp/helm-v2.11.0-linux-386.tar.gz -f -X GET https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-386.tar.gz
  tar -xvf /tmp/helm-v2.11.0-linux-386.tar.gz -C /tmp/
  mv /tmp/linux-386/helm /usr/bin/helm
fi
export HELM_HOME=/root/.helm
if [ -z "$APIKEY" -a -f /root/.helm/.credential ]; then
    decodedCred=`cat /root/.helm/.credential |base64 -d`
    export APIKEY=`echo $decodedCred|awk -F':' '{ print $1 }'`
fi

# Make sure our ibmcloud command is up to date
ibmcloud update -f
# Make sure our container plugin is up to date
ibmcloud plugin update container-service
# Login to ibmcloud - Use API key
ibmcloud login --apikey $APIKEY -a api.ng.bluemix.net
ibmcloud cs region-set {{.Values.iks.region}}
ibmcloud cs cluster-config {{.Values.iks.clustername}}
export KUBECONFIG={{.Values.iks.configfile}}
ibmcloud target -g {{.Values.iks.target}}
if [ $? -ne 0 ]; then
    echo "helm cli setup failed. you may not be able to create any Spark Instance Groups."
fi
{{- end }}
{{- end }}
{{- end }}
{{- end }}
