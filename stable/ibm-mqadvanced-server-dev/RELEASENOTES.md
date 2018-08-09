# Breaking changes

- Kubernetes resource names have changed, to prevent problems with long names in some systems.  This will require you to manually upgrade from a previous release.
- If you used DNS SRV records to locate the correct MQ port, then you need to use the name `qmgr` instead of `qmgr-server`.
- The chart value `service.name` has been removed, as it wasn't used correctly.

# What’s new in the MQ Advanced Chart, Version 2.0.2

- Bug Fixes

# Fixes

- Fixed error in service selector for helm tests.

# Prerequisites

Note: if you have already attempted to upgrade to Version 2.0.0, 2.0.1 or 2.0.2 (without following these instructions), then you will need to perform additional steps to complete a successful upgrade.

- If your attempted upgrade failed, then you can follow the upgrade instructions to upgrade your release.

- If your attempted upgrade succeeded, then a new PersistentVolumeClaim (PVC) and PersistentVolume (PV) will have been created that does not contain your existing queue manager data. To reuse your existing queue manager data, follow the upgrade instructions and perform the additional step (below) after completing step 6 and before step 7.

    ```sh
    export NEW_PVC_NAME=$(kubectl get pvc -l release=$RELEASE --namespace=$NAMESPACE | tail -n1 | awk '{print $1}')
    kubectl delete pvc $NEW_PVC_NAME
    ```

# Documentation

## Upgrading to Version 2.0.2

To perform these instructions you will need to have permissions to modify the PersistentVolume (PV) for your release. This is required to update the “Reclaim Policy” and "Claim Reference" in steps 2, 7 and 12.

Note: You may experience upgrade issues if you have a long release name (25+ characters). In this case you should choose a new shorter release name for your upgrade and use this new release name in steps 7, 8 and 10.

1. Run the following commands to set the required environment values for your release

  ```sh
  export RELEASE=[RELEASE]
  export NAMESPACE=[NAMESPACE]
  export REVISION=$(helm history $RELEASE | grep DEPLOYED | tail -n1 | awk '{print $1}')
  export APP_LABEL=$(helm get $RELEASE --revision $REVISION | grep app: | head -n1 | awk '{print $2}' | tr -d '"')
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
  helm get values $RELEASE > user-supplied-values.yaml
  ```

5. Delete your release

  ```sh
  helm delete --purge $RELEASE
  ```

  > This command will remove all the Kubernetes components associated with the chart, except the PersistentVolumeClaim (PVC) and the PersistentVolume (PV) that contains the queue manager data.

6. Delete the PersistentVolumeClaim (PVC)

  ```sh
  kubectl delete pvc $PVC_NAME
  ```

7. Update the "Claim Reference" of the PersistentVolume (PV)

  ```sh
  kubectl patch pv $PV_NAME -p '{"spec":{"claimRef":{"uid":"","name":"data-'$RELEASE'-ibm-mq-0"}}}'
  ```

8. Update details of the PersistentVolumeClaim (PVC)

  Create a new file called `pvc-new.yaml` that contains the following:

  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    labels:
      app: ibm-mq
      chart: ibm-mqadvanced-server-dev
      heritage: Tiller
      release: [RELEASE]
    name: data-[RELEASE]-ibm-mq-0
    namespace: [NAMESPACE]
  spec:
    accessModes:
    - [USE-OLD-VALUE]
    resources:
      requests:
        storage: [USE-OLD-VALUE]
    storageClassName: [USE-OLD-VALUE]
    volumeName: [USE-OLD-VALUE]
  ```

> Where:
> - [RELEASE] is your release name.
> - [NAMESPACE] is the namespace where your release is deployed.
> - `accessModes`, `storage`, `storageClassName` & `volumeName` values should be copied from the file `pvc-details.yaml` that was created in step 3. *Note:* If a value does not exist in `pvc-details.yaml` then it is not required.

9. Create the updated PersistentVolumeClaim (PVC) using the file created in step 8

  ```sh
  kubectl create -f pvc-new.yaml
  ```

10. Install the Version 2.0.2 Chart

  ```sh
  helm install --name $RELEASE -f user-supplied-values.yaml [CHART]
  ```

  > Where [CHART] is the Version 2.0.2 chart in your Helm repository.

11. Validate upgrade

  Check that your queue manager is running and persistent data is available.

12. Reset the “Reclaim Policy” of the PersistentVolume (PV) back to original value

  ```sh
  kubectl patch pv $PV_NAME -p '{"spec":{"persistentVolumeReclaimPolicy":"'$PV_POLICY'"}}'
  ```

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 2.0.2 | August 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Fixed error in service selector for helm tests |
| 2.0.1 | July 2018 | >= 1.9 | = MQ 9.1.0.0  | None | Reverted statefulset to apps/v1beta2 to prevent deletion failures |
| 2.0.0 | July 2018    | >= 1.9 | = MQ 9.1.0.0  | New Kubernetes resource names and labels | Added metrics service |
| 1.3.0 | May 2018     | >= 1.6 | = MQ 9.0.5.0  | None | Added POWER and z/Linux support |
| 1.2.1 | Apr 30, 2018 | >= 1.6 | >= MQ 9.0.4.0 | None | README fixes |
| 1.2.0 | Apr 3, 2018  | >= 1.6 | >= MQ 9.0.4.0 | None | Added liveness and readiness probes; Optional JSON logging; New README format |
| 1.0.2 | Nov 6, 2017  | >= 1.6 | >= MQ 9.0.3.0 | None | Updates for MQ 9.0.4.0 |
| 1.0.1 | Oct 25, 2017 | >= 1.6 | MQ 9.0.3.0    | None | Initial version |