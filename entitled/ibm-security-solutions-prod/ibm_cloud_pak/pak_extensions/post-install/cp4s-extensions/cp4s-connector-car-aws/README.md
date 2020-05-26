# Configuring Amazon&trade; AWS  Connector
"AWS" is referring to Amazon&trade; AWS.

## Configuring the connector
The aws connector service requires following fields: 

| Fields          | Description                          | Example                                    |
|-----------------|--------------------------------------|--------------------------------------------|
| ACCOUNT_ID      | AWS account id.                      | 974738500502                               |
| CLIENT_ID       | AWS client id.                       | 45g56k24-56f3-485c-9e42-c52ed9h3b3de       |
| CLIENT_SECRET   | AWS client secret.                   | gdujS%6sd/-w                               |
| REGION          | AWS region.                          | us-east-1                                  |
| CAR_SERVICE_URL | The API URI for IBM's CAR API.       | https://\<CP4S URL\>/api/car/v2            |
| API_KEY         | The access key for IBMs CAR API.     |                                            |
| PASSWORD        | The api password for IBMs CAR API    |                                            |
| SOURCE          | The source id for the data source.   | aws                                        |

## Procedure to Deploy the Connector

An overview of the required configuration is as follows:
1. Create the **ibm-car-aws-secret** secret
2. Update the CronJob template
3. Deploy the CronJob to the cluster
4. Check the CronJob
5. Cleanup

Each of these tasks are described in the following sections.

1. Create the **ibm-car-aws-secret** secret

Create a secret for the API keys used to make connection between the car service and the Connectors:
```
kubectl create secret generic ibm-car-aws-secret  
    --from-literal=ACCOUNT_ID='<ACCOUNT_ID>' 
    --from-literal=CLIENT_ID='<CLIENT_ID>' 
    --from-literal=CLIENT_SECRET='<CLIENT_SECRET>'
    --from-literal=API_KEY='<IBM_API_KEY>' 
    --from-literal=PASSWORD='<IBM_PASSWORD_KEY>' -n <NAMESPACE>
```
Verify the secret is created successfully:
```
    kubectl get secret ibm-car-aws-secret -n <NAMESPACE>
```
2. Update the CronJob template

Create a cronjob yaml template called `cp4s-connector-car-aws.yaml`.
The cronjob is configured to execute every 15 minutes by default. Also the environment variable value of **IBM_CAR_API_URI** needs to be updated to the CP4S URL. 

PLEASE NOTE
The registry URL for the image is the default entitled registry for Cloud Pak for Security
If you are using a different or local registry, update this link.
Update the tag to your current release version or fixpack
(For example, for IBM Cloud Pak for Security Version 1.3.0.0, it is: 1.3.0.0-amd64)
`image: cp.icr.io/cp/cp4s/solutions/:isc-car-connector-aws:1.3.0.0-amd64`

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cp4s-car-connector-aws
  labels:
    name: awsc
    type: carconnector
spec:
  schedule: "*/15 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            name: awsc
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
          - name: awsc
            securityContext:
              privileged: false
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: false
              runAsNonRoot: true
              capabilities:
                drop:
                - ALL
            image: cp.icr.io/cp/cp4s/solutions/isc-car-connector-aws:1.3.0.0-amd64
            imagePullPolicy: Always
            env:
              - name: ACCOUNT_ID
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-aws-secret
                    key: ACCOUNT_ID
              - name: CLIENT_ID
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-aws-secret
                    key: CLIENT_ID
              - name: CLIENT_SECRET
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-aws-secret
                    key: CLIENT_SECRET
              - name: CAR_SERVICE_URL
                value: '<CLUSTER_URL>/api/car/v2'
              - name: API_KEY
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-aws-secret
                    key: API_KEY
              - name: PASSWORD
                valueFrom:
                  secretKeyRef:
                    name: ibm-car-aws-secret
                    key: PASSWORD
              - name: SOURCE
                value: <source-id>
              - name: REGION
                value: 'us-east-1'
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
3. Deploy the CronJob <cp4s-connector-car-aws.yaml>
```
    kubectl create -f cp4s-connector-car-aws.yaml -n <NAMESPACE>
```
4. Validate CronJob and Pod created  successfully

Check CronJob
```
    kubectl get cronjob -lname=awsc -n <NAMESPACE>
```
Check Pod
```
    kubectl get pod -lname=awsc -n <NAMESPACE>
```
## Uninstall the CAR AWS connector
Delete CronJob
```
    kubectl delete cronjob cp4s-car-connector-aws -n <NAMESPACE>
```
Delete secret
```
kubectl delete secret ibm-car-aws-secret
```
Delete pods
```
kubectl delete pod -lname=awsc -n <NAMESPACE> --force
```
