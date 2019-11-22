# IBM Operations Analytics - Predictive Insights Mediation Pack for Prometheus 
This helm package contains the Docker image for the IBM Operations Analytics - Predictive Insights Mediation Pack for Prometheus. Use it to convert Prometheus metric data received from nodes in a Kubernetes environment, and to send that data to IBM Operations Analytics - Predictive Insights for monitoring and anomaly prediction.

## Introduction

IBM Operations Analytics - Predictive Insights provides early warning and problem detection for anomalous events in your Kubernetes environment. Use it to leverage machine-learning to reduce downtime. 
For more information, see [IBM Knowledge Center for IBM Operations Analytics - Predictive Insights](https://www.ibm.com/support/knowledgecenter/SSJQQ3_1.3.6/com.ibm.scapi.doc/kc_welcome-scapi.html)

This agent allows you to harness Predictive Insights to monitor usage statistics for CPU usage per server and memory usage per Kubernetes node. This helps you to identify issues before they result in significant downtime.

## Chart Details

Deploys single Predictive Insights Mediation Pack for Prometheus onto Kubernetes, to receive metrics from a Prometheus probe.


## Resources Required
The following versions of operating system and IBM Operations Analytics - Predictive Insights are supported:
- Red Hat Enterprise for Linux version 7.x

- IBM Operations Analytics - Predictive Insights version 1.3.6

## Prerequisites
- The On-premise install of IBM Operations Analytics - Predictive Insights must be complete before installing this agent. For more information, see [Installing](https://www.ibm.com/support/knowledgecenter/SSJQQ3_1.3.6/com.ibm.scapi.doc/install_guide/c_tsaa_install_guide.html).

- Install the Kubernetes command line interface (CLI). For more information, see [Accessing your cluster by using the kubectl CLI](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.2/manage_cluster/cfc_cli.html).

- Ensure that Prometheus is connected with Single Socket Layer (SSL) in your Kubernetes environment and gather the information that is required for configuring the Helm chart, by completing the following steps.
1. Log in to your the master node in your Kubernetes environment.

2. Apply the service.yaml file that creates the monitoring-prometheusexternalservice service. The default namespace is set to kube-system. If you intend to deploy to a different namespace change the namespace defined in svc/service.yaml. Enter the following command:

```
kubectl apply -f svc/service.yaml
```
For the PPA deliverable, extract the package and then extract the chart within it. The service.yaml will be in charts/ibm-netcool-piagent-prometheus-prod/svc .  

3. To retrieve the nodePort for the service, enter the following command:

```
kubectl get --namespace kube-system -o jsonpath="{.spec.ports[0].nodePort}" services monitoring-prometheus-externalservice
```
You will need to note this nodePort for the install when specifying the Prometheus Endpoint IP and the NodePort from monitoring-prometheus-externalservice.


4. To retrieve the CA certificates that Prometheus uses, enter the following command:

```
kubectl get secrets/monitoring-ca-cert -n kube-system -o yaml
```
Note: The default secret name is monitoring-ca-cert but this may be customized on each system. To check for secrets, run ```kubectl get secrets --namespace kube-system ```

This command retrieves the CA Certificate or ca.pem if one exists. Copy the content of the file and save it as you need it when you configure the Helm chart. If the ca.pem does not exist, use the tls.crt

5. To retrieve the client certificates, enter the following command:

```
kubectl get secrets/monitoring-client-certs -n kube-system -o yaml
```
This command retrieves 2 files, tls.crt and tls.key. Copy the content of these files and save it as you need it when you configure the Helm chart.


## Installing the Chart

You can install the chart from the user interface or form the command line.

### From the user interface

To read this documentation on Knowledge Center, see [Configuring integration](https://www-01.ibm.com/support/knowledgecenter/SSJQQ3_1.3.6/com.ibm.scapi.doc/admin_guide/c_icp_cnf_ovw.html).

1. To select the helm chart from the Catalog, click the menu icon and click Catalog and Helm Chart. Enter PI agent in the Search field.

2. To configure the connections, complete the following fields:
- Container labels: Enter a label to help you identify the container that the chart belongs to. This field is optional.
- Prometheus endpoint: Enter the IP address of the master node in your Kubernetes cluster and the port that is used by Prometheus that you noted in step 3 in the Prerequisites section.
- Group label: Enter a label to help you identify the group that the chart belongs to. This field is optional.
- PI Endpoint: Enter the IP address and port that you want to use to connect to your Predictive Insights installation.
- Tenant ID: Enter the Tenant ID that Predictive Insights uses to identify the data. Note the ID as you need when you create a topic in Predictive Insights.

3. To configure the security certificates, complete the following fields:
- Prometheus TLS Certificate: Copy the content of the TLS certificate that Prometheus uses from your Kubernetes environment. This file is the tls.crt file that you noted in step 4 in the Prerequisites section.
- Prometheus TLS Key: Copy the content of the TLS key that Prometheus uses from your Kubernetes environment. This file is the tls.key file that you noted in step 4 in the Prerequisites section.
- Prometheus CA Certificate: Copy the content of the CA certificate that Prometheus uses from your Kubernetes environment. This file is the CA Certificate file that you noted in step 5 in the Prerequisites section.
4. When you are finished, click Install.

5. To validate the install you can verify from the UI or from the command line.
   In the UI , go to Helm releases . Search for the agent the you installed. Click on the agent name. In the Deployment section, click on the deployment name. Click on Logs. 
   You should see log entries for Executing command service_memory_metrics & Executing command prometheus_cpu. If there is no error message associated with this, your install was successful
   INFO   [14:54:11.359] [pool-5-thread-1] c.i.c.w.r.c.d.ChainedCommand -  Executing command service_memory_metrics
   INFO   [14:54:11.364] [pool-4-thread-1] c.i.c.w.r.c.d.ChainedCommand -  Executing command prometheus_cpu
   
   To validate from the command line,  run ```kubectl get pods --namespace kube-system``` if agent deployed on namespace kube-system. Using the name of your agent pod, run ```kubectl logs piagent-ibm-netcool-piagent-prometheus-dev-54b45d984cpglm --namespace kube-system``` . 


6. Create a topic and begin to work with the data in Predictive Insights. For more information about how to analyze the data, see [Analyzing IBM Cloud data](https://www-01.ibm.com/support/knowledgecenter/SSJQQ3_1.3.6/com.ibm.scapi.doc/admin_guide/c_icp_anlyz_dt.html)


### From the user command line

1. Configure the installation by editing the values.yaml file. See the configuration parameters in the Configuration section for more information.

2. Run the following command to install the chart:

```bash
$ helm install --name my-pack stable/ibm-netcool-piagent-prometheus-dev
```
The command deploys on the Kubernetes cluster in the default configuration.



## Configuration

The following tables list the configuration parameters of the chart and their default values.


### Parameters that you must set


| Parameter                                          | Description                                                                                                                                                                                                        | Default                           |
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| `icpProm.attributeArgumentsVals.piEndpoint`                                 | Predictive Insights host endpoint and port.                                                                                                                                                                                           | No default |
| `icpProm.attributeArgumentsVals.prometheusEndpoint`                                 | Prometheus probe endpoint.                                                                                                                                                                                                  | No default                    |
| `tlsCrt`                                 | TLS certificate from your Kubernetes environment, used by Prometheus. This file is the tls.crt file that you noted in step 5 in the Prerequisites section.                                                                                                                                                                                             | No default |
| `tlsKey`                                 | TLS key from your Kubernetes environment, used by Prometheus. This file is the tls.key file that you noted in step 5 in the Prerequisites section.                                                                                                                                                                                                 | No default                    |
| `caCrt`                                 | CA certificate from your Kubernetes environment, used by Prometheus. This file is the CA Certificate file that you noted in step 6 in the Prerequisites section.                                                                                                                                                                                             | No default |
| `license`                                 | The license state of the image being deployed. Enter accept to install and use the image.                                                                                                                                                                                           | No default                    |


### Parameters that you can optionally set


| Parameter                                          | Description                                                                                                                                                                                                        | Default                           |
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| `icpProm.attributeArgumentsVals.containerLabels`                                 | Container labels as used by prometheus e.g container_name='ibmliberty'. For multiple labels, use comma to seperate.                                                                                                                                                                  | No default |


### Parameters with default values. You can optionally change these values.


| Parameter                                          | Description                                                                                                                                                                                                        | Default                           |
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| `icpProm.attributeArgumentsVals.polingInterval`                             | Interval in seconds that Prometheus should be polled for metrics                                                                                                                                                  | `30`  |
| `icpProm.attributeArgumentsVals.stepTime`                                   | Step time in seconds.                                                                                                                                                                                             | `30s` |
| `icpProm.attributeArgumentsVals.tenantId`                                  | Tenabt identifier                                                                                                                                                                                                  | `tenant_id`                    |
| `icpProm.attributeArgumentsVals.groupLabel`                                 | Group label.                                                                                                                                                                                             | `KubeCluster` |
| `image.repository`                                 | Location of the Docker repository                                                                                                                                                                                                  | `netcool-piagent-prometheus`                    |
| `image.tag`                                 | Tag for this image.                                                                                                                                                                                             | `1.0` |
| `image.pullPolicy`                                 | Image pull policy.                                                                                                                                                                                                  | `IfNotPresent`                    |
| `resources.requests.cpu`                                 | CPU resource.                                                                                                                                                                                             | `2000m` |
| `resources.requests.memory`                                 | Memory resource.                                                                                                                                                                                                  | `1512Mi`                    |




## Limitations
- Only the AMD64 / x86_64 architecture is supported for the IBM Netcool PI Prometheus Agent.
- Validated to Run on IBM Cloud Private 2.1.0.1 or newer.
- It is recommended that the polling interval is set to a value of 30s or greater for performance reasons.

