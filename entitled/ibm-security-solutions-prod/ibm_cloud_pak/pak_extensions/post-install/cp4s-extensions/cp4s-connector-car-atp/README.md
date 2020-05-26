# Configuring CP4S ATP Connector

"ATP" is referring to Microsoft&trade; Defender Advanced Threat Protection technology.

## Configuring the connector
The ATP connector service requires following fields: 

| Fields          | Description                        | Example                                                  |
|-----------------|------------------------------------|----------------------------------------------------------|
| SUBSCRIPTION_ID | ATP subscription id.               | 083de1fb-c52d-4b7c-895a-2b5ad7fg91e8                     |
| TENANT_ID       | ATP tenant id.                     | b73d5h78-34d5-495a-9901-06bd6h4ff13e                     |
| CLIENT_ID       | ATP client id.                     | 45g56k24-56f3-485c-9e42-c52ed9h3b3de                     |
| CLIENT_SECRET   | ATP client secret.                 | gdujS%6sd/-w                                             |
| CAR_SERVICE_URL | The API URI for IBM's CAR API.     | https://\<CP4S URL\>/api/car/v2                            |
| API_KEY         | The access key for IBMs CAR API.   |                                                          |
| PASSWORD        | The api password for IBMs CAR API  |                                                          |
| SOURCE          | The source id for the data source. | microsoft-atp                                            |

## Deploy the Connector

An overview of the required configuration is as follows:
1. Create the **ibm-car-atp-secret** secret
2. Update the CronJob template
3. Deploy the CronJob to the cluster
4. Check the CronJob
5. Cleanup

Each of these tasks are described in the following sections.

1. Create the **ibm-car-atp-secret** secret

Create a secret for the API keys used to make connection between the car service and the Connectors:
```
kubectl create secret generic ibm-car-atp-secret  
    --from-literal=SUBSCRIPTION_ID='<SUBSCRIPTION_ID>' 
    --from-literal=TENANT_ID='<TENANT_ID>'
    --from-literal=CLIENT_ID='<CLIENT_ID>' 
    --from-literal=CLIENT_SECRET='<CLIENT_SECRET>'
    --from-literal=API_KEY='<IBM_API_KEY>' 
    --from-literal=PASSWORD='<IBM_PASSWORD_KEY>' -n <NAMESPACE>
```
Verify the secret is created successfully:
```
    kubectl get secret ibm-car-atp-secret -n <NAMESPACE>
```
2. Update the CronJob template

Create a cronjob yaml template called `cp4s-connector-car-atp.yaml`.
The cronjob is configured to execute every 15 minutes by default. Also the environment variable value of **IBM_CAR_API_URI** needs to be updated to the CP4S URL. 

PLEASE NOTE
The registry URL for the image is the default entitled registry for Cloud Pak for Security
If you are using a different or local registry, update this link.
Update the tag to your current release version or fixpack
(For example, for IBM Cloud Pak for Security Version 1.3.0.0, it is: 1.3.0.0-amd64)
`image: cp.icr.io/cp/cp4s/solutions/:isc-car-connector-atp:1.3.0.0-amd64`

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cp4s-car-connector-atp
  labels:
    name: atp-connector
    type: carconnector
spec:
  schedule: "*/15 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            name: atp-connector
        spec:
          restartPolicy: Never
          imagePullSecrets:
          - name: ibmcp4s-image-pull-secret
          initContainers:
          - name: concat-ca
            image: registry.access.redhat.com/ubi8/ubi-minimal
            command: 
            - sh
            - -c
            - 'cat /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt /etc/config/ca.crt > /etc/cache_ca/ca_roots.crt'
            volumeMounts:
              - mountPath: /etc/config
                name: secrets
                readOnly: true
              - mountPath: /etc/cache_ca
                name: cache-ca
          containers:
          - name: atp-connector
            securityContext:
              privileged: false
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: false
              runAsNonRoot: true
              capabilities:
                drop:
                - ALL
            image: cp.icr.io/cp/cp4s/solutions/isc-car-connector-atp:1.3.0.0-amd64
            imagePullPolicy: Always
            env:
              - name: SUBSCRIPTION_ID
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-atp-secret
                    key: SUBSCRIPTION_ID
              - name: TENANT_ID
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-atp-secret
                    key: TENANT_ID
              - name: CLIENT_ID
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-atp-secret
                    key: CLIENT_ID
              - name: CLIENT_SECRET
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-atp-secret
                    key: CLIENT_SECRET
              - name: CAR_SERVICE_URL
                value: '<CLUSTER_URL>/api/car/v2'
              - name: API_KEY
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-atp-secret
                    key: API_KEY
              - name: PASSWORD
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-atp-secret
                    key: PASSWORD
              - name: SOURCE
                value: <source-id>
              - name: REQUESTS_CA_BUNDLE
                value: '/etc/cache_ca/ca_roots.crt'
            volumeMounts:
              - mountPath: /etc/config
                name: secrets
                readOnly: true
              - mountPath: /etc/cache_ca
                name: cache-ca
          volumes:
          - name: secrets
            secret:
              defaultMode: 420
              secretName: car
          - name: cache-ca
            emptyDir: {}
```
3. Deploy the CronJob <cp4s-connector-car-atp.yaml>
```
    kubectl create -f cp4s-connector-car-atp.yaml -n <NAMESPACE>
```
4. Validate CronJob and Pod created  successfully

Check CronJob
```
    kubectl get cronjob -lname=atp-connector -n <NAMESPACE>
```
Check Pod
```
    kubectl get pod -lname=atp-connector -n <NAMESPACE>
```

## Uninstall the CAR ATP connector

Delete CronJob
```
    kubectl delete cronjob cp4s-car-connector-atp -n <NAMESPACE>
```
Delete secret
```
kubectl delete secret ibm-car-atp-secret
```
Delete pods
```
kubectl delete pod -lname=atp-connector -n <NAMESPACE> --force
```

