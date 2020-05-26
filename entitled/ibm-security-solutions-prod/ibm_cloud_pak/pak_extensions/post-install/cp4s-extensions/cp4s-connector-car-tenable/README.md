# Configuring CP4S Tenable Connector
"Tenable" is referring to Tenable&trade;.

## Configuring the connector
The tenable connector service requires some mandatory fields and other optional. 

| Fields            | Description                              | Required | Example                                                    |
|-------------------|------------------------------------------|----------|------------------------------------------------------------|
| TIO_ACCESS_KEY    | Tenable.io Access Key.                   | Y        |                                                            |
| TIO_SECRET_KEY    | Tenable.io Secret Key.                   | Y        |                                                            |
| IBM_CAR_API_URI   | The API URI for IBM's CAR API.           | Y        | https://\<CP4S URL\>/api/car/v2   |
| IBM_ACCESS_KEY    | The access key for IBMs CAR API.         | Y        |                                                            |
| IBM_PASSWORD_KEY  | The password key for IBMs CAR API.       | Y        |                                                            |
| BATCH_SIZE        | Export/Import Batch Sizing.              | N        | 100                                                        |
| VERBOSITY         | Logging Verbosity.                       | N        | 1                                                          |
| SINCE             | The unix timestamp of the age threshold. | N        | 0                                                          |

## Procedure to Deploy the Connector

An overview of the required configuration is as follows:
1. Create the **ibm-car-tenable-secret** secret
2. Update the CronJob template
3. Deploy the CronJob to the cluster
4. Check the CronJob
5. Cleanup

Each of these tasks are described in the following sections.

1. Create the **ibm-car-tenable-secret** secret
Create a secret for the API keys used to make connection between the car service and the Connectors:

```
kubectl create secret generic ibm-car-tenable-secret 
  --from-literal=TIO_ACCESS_KEY='<TIO_ACCESS_KEY>'
  --from-literal=TIO_SECRET_KEY='<TIO_SECRET_KEY>'
  --from-literal=IBM_ACCESS_KEY='<IBM_ACCESS_KEY>'
  --from-literal=IBM_PASSWORD_KEY='<IBM_PASSWORD_KEY>'
```
Verify the secret is created successfully:
```
    kubectl get secret ibm-car-tenable-secret -n <NAMESPACE>
```


2. Update the CronJob template

Create a cronjob yaml template called `cp4s-connector-car-tenable.yaml`.
The cronjob is configured to execute every 15 minutes by default. Also the environment variable value of **IBM_CAR_API_URI** needs to be updated to the CP4S URL. 

PLEASE NOTE
The registry URL for the image is the default entitled registry for Cloud Pak for Security
If you are using a different or local registry, update this link.
Update the tag to your current release version or fixpack
(For example, for IBM Cloud Pak for Security Version 1.3.0.0, it is: 1.3.0.0-amd64)
`image: cp.icr.io/cp/cp4s/solutions/:isc-car-connector-tenable:1.3.0.0-amd64`

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: cp4s-car-connector-tenable
  labels:
    name: tioc
    type: carconnector
spec:
  schedule: "*/15 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            name: tioc
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
            - 'cat /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt /etc/config/ca.crt > /etc/cache_ca/ca_roots.pem'
            volumeMounts:
              - mountPath: /etc/config
                name: secrets
                readOnly: true
              - mountPath: /etc/cache_ca
                name: cache-ca
          containers:
          - name: tioc
            securityContext:
              privileged: false
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: false
              runAsNonRoot: true
              capabilities:
                drop:
                - ALL
            image: "cp.icr.io/cp/cp4s/solutions/isc-car-connector-tenable:1.3.0.0-amd64"
            imagePullPolicy: Always
            env:
            - name: REQUESTS_CA_BUNDLE
              value: "/etc/cache_ca/ca_roots.pem"
            - name: TIO_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: ibm-car-tenable-secret
                  key: TIO_ACCESS_KEY
            - name: TIO_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: ibm-car-tenable-secret
                  key: TIO_SECRET_KEY
            - name: BATCH_SIZE
              value: "100"
            - name: VERBOSITY
              value: "1"
            - name: SINCE
              value: "0"
            - name: IBM_CAR_API_URI
              value: "<CLUSTER_URL>/api/car/v2"
            - name: IBM_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: ibm-car-tenable-secret
                  key: IBM_ACCESS_KEY
            - name: IBM_PASSWORD_KEY
              valueFrom:
                secretKeyRef:
                  name: ibm-car-tenable-secret
                  key: IBM_PASSWORD_KEY
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
3. Deploy the CronJob <cp4s-connector-car-tenable.yaml>
```
    kubectl create -f cp4s-connector-car-tenable.yaml -n <NAMESPACE>
```
4. Validate CronJob and Pod created  successfully

Check CronJob
```
    kubectl get cronjob -lname=tioc -n <NAMESPACE>
```
Check Pod
```
    kubectl get pod -lname=tioc -n <NAMESPACE>
```
## Uninstall the CAR Tenable connector
Delete CronJob
```
    kubectl delete cronjob cp4s-car-connector-tenable -n <NAMESPACE>
```
Delete secret
```
kubectl delete secret ibm-car-tenable-secret
```

Delete Pod
```
kubectl delete pod -lname=tioc -n <NAMESPACE> --force
```



