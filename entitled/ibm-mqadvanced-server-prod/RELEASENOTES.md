# Breaking Changes

- None

## Upgrading to Version 4.1.x from ibm-mqadvanced-server-rhel-prod Version 2.3.X

When upgrading from ibm-mqadvanced-server-rhel-prod v2.3.X, you need to follow these manual instructions.  This will create an outage.  Client applications will be able to reconnect after the manual upgrade is complete.

To perform these instructions you will need to have permissions to modify the PersistentVolume (PV) for your release. This is required to update the “Reclaim Policy” and "Claim Reference" in steps 2, 7 and 12.

1. Run the following commands to set the required environment values for your release

  ```sh
  export RELEASE=[RELEASE]
  export NAMESPACE=[NAMESPACE]
  export REVISION=$(helm history $RELEASE --tls | grep DEPLOYED | tail -n1 | awk '{print $1}')
  export APP_LABEL=$(helm get $RELEASE --revision $REVISION --tls | grep app: | head -n1 | awk '{print $2}' | tr -d '"')
  export PVC_NAME=$(kubectl get pvc -l app=$APP_LABEL --namespace=$NAMESPACE | tail -n1 | awk '{print $1}')
  export PV_NAME=$(kubectl get pvc -l app=$APP_LABEL --namespace=$NAMESPACE | tail -n1 | awk '{print $3}')
  export PV_POLICY=$(kubectl get pv $PV_NAME | tail -n1 | awk '{print $4}')
  ```

  > Where [RELEASE] is your release name and [NAMESPACE] is the namespace where your release is deployed.

2. Update the “Reclaim Policy” of the PersistentVolume (PV) to “Retain”

  ```sh
  kubectl patch pv $PV_NAME -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
  ```

3. Get details of the PersistentVolumeClaim (PVC)

  ```sh
  kubectl get pvc $PVC_NAME -o yaml > pvc-details.yaml
  ```

4. Get user-supplied values for the release

  ```sh
  helm get values $RELEASE --tls > user-supplied-values.yaml
  ```

5. Delete your release

  ```sh
  helm delete --purge $RELEASE --tls
  ```

  > This command will remove all the Kubernetes components associated with the chart, except the PersistentVolumeClaim (PVC) and the PersistentVolume (PV) that contains the queue manager data.

6. Delete the PersistentVolumeClaim (PVC)

  ```sh
  kubectl delete pvc $PVC_NAME
  ```

7. Update the "Claim Reference" of the PersistentVolume (PV)

  ```sh
  kubectl patch pv $PV_NAME -p '{"spec":{"claimRef":{"uid":""}}}'
  ```

8. Update details of the PersistentVolumeClaim (PVC)

  Create a new file called `pvc-new.yaml` that contains the following:

  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    labels:
      app: ibm-mq
      chart: ibm-mqadvanced-server-prod
      heritage: Tiller
      release: [RELEASE]
    name: data-[RELEASE]-ibm-mq-0
    namespace: [NAMESPACE]
  spec:
    accessModes:
    - [USE-OLD-VALUE]
    dataSource: null
    resources:
      requests:
        storage: [USE-OLD-VALUE]
    storageClassName: [USE-OLD-VALUE]
    volumeMode: [USE-OLD-VALUE]
    volumeName: [USE-OLD-VALUE]
  ```

> Where:
> - [RELEASE] is your release name.
> - [NAMESPACE] is the namespace where your release is deployed.
> - `accessModes`, `storage`, `storageClassName`, `volumeMode` & `volumeName` values should be copied from the file `pvc-details.yaml` that was created in step 3. *Note:* If a value does not exist in `pvc-details.yaml` then it is not required.

9. Create the updated PersistentVolumeClaim (PVC) using the file created in step 8

  ```sh
  kubectl create -f pvc-new.yaml
  ```

10. Install the Version 4.0.0 Chart

  ```sh
  helm install --name $RELEASE -f user-supplied-values.yaml [CHART] --set security.initVolumeAsRoot=true --tls
  ```

  > Where [CHART] is the Version 4.0.0 chart in your Helm repository.

11. Validate upgrade

  Check that your queue manager is running and persistent data is available.

12. Reset the “Reclaim Policy” of the PersistentVolume (PV) back to original value

  ```sh
  kubectl patch pv $PV_NAME -p '{"spec":{"persistentVolumeReclaimPolicy":"'$PV_POLICY'"}}'
  ```

# What’s new in the MQ Advanced Chart, Version 4.1.x

- Updated to IBM MQ 9.1.3

# Fixes

- Updated go-toolset to version 1.11.13

# Prerequisites

- The following IBM Platform Core Service is required: `tiller`

# Documentation

- [What's new and changed in IBM MQ Version 9.1.x](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.1.0/com.ibm.mq.pro.doc/q113110_.htm)
- When upgrading from a previous version of this chart, you will experience a short outage, while the old Queue Manager container is replaced.  Client applications which are set to automatically reconnect should recover within seconds or minutes.

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 4.1.2 | September 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | Updated go-toolset to version 1.11.13 |
| 4.1.1 | August 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | Updated UBI 7 base image |
| 4.1.0 | July 2019 | >= 1.11.0 | = MQ 9.1.3.0 | None | Updated to IBM MQ 9.1.3 |
| 4.0.0 | June 2019 | >= 1.11.0 | = MQ 9.1.2.0 | Now runs as user ID 888; Verification of MQSC files | Added support for multi-instance queue managers; Custom labels; Image based on UBI; Added TLS certificates mechanism |
| 3.0.2 | April 2019 | >= 1.9 | = MQ 9.1.2.0 | None | Security fixes, Dashboard fixes, large MQSC fixes |
| 3.0.1 | March 2019 | >= 1.9 | = MQ 9.1.2.0 | None | Fix capabilities when running init volume as root |
| 3.0.0 | March 2019 | >= 1.9 | = MQ 9.1.2.0 | Set initVolumeAsRoot on IKS | Updated to IBM MQ 9.1.2; Improved security (including running as non-root); Additional IBM Cloud Pak content; Added ILMT annotations; README updates; Kibana dashboard fix |
| 2.2.2 | January 2019 | >= 1.9 | = MQ 9.1.1.0  | None | Security fixes |
| 2.2.1 | December 2018 | >= 1.9 | = MQ 9.1.1.0  | None | Security fixes |
| 2.2.0 | November 2018 | >= 1.9 | = MQ 9.1.1.0  | None | Updated to IBM MQ version 9.1.1 |
| 2.1.0 | September 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Declaration of securityContext; Configurable service account name; New IBM Cloud Pak content |
| 2.0.2 | August 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Fixed error in service selector for helm tests |
| 2.0.1 | July 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Reverted statefulset to apps/v1beta2 to prevent deletion failures |
| 2.0.0 | July 2018 | >= 1.9 | = MQ 9.1.0.0  | New Kubernetes resource names and labels | Added metrics service |
| 1.3.0 | May 2018  | >= 1.6 | = MQ 9.0.5.0  | None | Added POWER and z/Linux support |
| 1.2.2 | Apr 2018  | >= 1.6 | >= MQ 9.0.4.0 | None | README fixes |
| 1.2.1 | Apr 2018  | >= 1.6 | >= MQ 9.0.4.0 | None | README fixes |
| 1.2.0 | Mar 2018  | >= 1.6 | >= MQ 9.0.4.0 | None | Added JSON logging; New README format |
| 1.1.0 | Nov 2017  | >= 1.6 | >= MQ 9.0.3.0 | None | Updates for MQ 9.0.4.0 |
| 1.0.1 | Oct 2017  | >= 1.6 | MQ 9.0.3.0    | None | Initial version |
