# Breaking Changes
* **IMPORTANT** Upgrading to chart version 1.2.0 from previous versions is not supported. See [Prerequisites](#migrating-projects-to-microclimate-v1.2.0) for steps on migrating your projects to a new installation
* An additional secret must be created to use the Helm tiller in kube-system (see Prerequisites).


# What’s new in Chart Version 1.2.0
* Security update for GDPR compliance.
* Microclimate now uses HTTPS over an ingress
* Theia update to version 0.3.10, which includes a more recent version of the Java language server.
* Pick up and build changes on package.json and Dockerfile for Node.js applications.
* Support of using the Helm Tiller in kube-system - Microclimate no longer deploys its own tiller
* More detailed log on build and run container failures.
* Performance improvements.

# Fixes
* Theia pulled in a number of OS level security fixes.

# Prerequisites
1. IBM Cloud Private version 2.1.0.3.
2. An additional secret must be created to use the tiller in kube-system. This can be by created by following the "Create secret to use Tiller over TLS" step in the README.

## Migrating projects to Microclimate v1.2.0

To carry existing projects over to Microclimate v1.2.0, your existing Microclimate PersistentVolumes (PVs) will need to be reused in the new Microclimate installation by binding new PersistentVolumeClaims (PVCs) that you will need to create manually. This can be achieved by following the steps below (note: this requires you to have `kubectl` configured to your cluster):

### Identify which PersistentVolumes the existing Microclimate deployment is currently using
Microclimate will be using two PersistentVolumes: one for the main Microclimate deployment and one for the  Jenkins deployment. These can be found by using `kubectl describe deploy <deploymentName> | grep "ClaimName"` on each of the Microclimate deployments to find the name of the PersistentVolumeClaim being used; followed by using `kubectl describe pvc <pvcName> | grep "Volume"` to find the name of the PersistentVolume that the claim is bound to. Repeat this step for both the Microclimate and Jenkins deployments.

Keep note of these PV names for the following steps.

### Ensure the reclaim policy is set to 'Retain' on both PersistentVolumes
To check this, use `kubectl get <pvName> -o yaml` and find the field called `persistentVolumeReclaimPolicy`. If the policy is set to anything other than 'Retain', you can modify the PV by copying the output of the `get` command into a text editor; setting the value to `Retain`; saving the file (e.g. pv.yaml) and using `kubectl apply -f pv.yaml`. This will ensure the PV does not get deleted after Microclimate is uninstalled.

Repeat this step for both PersistentVolumes.

### Take note of capacities used by existing PersistentVolumeClaims

When you create your PVCs in the later step, you will want to recreate them with the same capacity as your existing Microclimate PVCs. To find this value, use the following command:

`kubectl describe pvc <pvcName> | grep "Capacity"`

Use this to find the capacity of both the Microclimate and Jenkins PVCs

### Uninstall Microclimate

**IMPORTANT** Ensure the previous step has been completed - otherwise you will risk losing your Microclimate data

Uninstall Microclimate using Helm using the release name you installed Microclimate with: `helm delete --purge <releaseName>`. This will leave behind the Persistent Volumes but delete the PersistentVolumeClaims.

### Add metadata labels to and remove claimRefs from the PersistentVolumes

You will be creating two new PersistentVolumeClaims to be assigned to your existing PersistentVolumes in the next step. To allow the new PVC to find the PV, you need to set a label in the PersistentVolume metadata. To modify the PV, print out the PV yaml using `kubectl describe pv <pvName> -o yaml` and save it to a file (e.g. `pv.yaml`). In the file, add a new subsection name `labels` within the `metadata` section. Then within the `labels` section add a `name` field with a meaningful value (e.g. `microclimate-pv`). The name field and it's value are arbitrary and can be a key-value pair of anything as long as it matches with what you add to PVC in the following step.

Once this is complete, the first section of the PV may look like this:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    name: microclimate-pv
  annotations:
    ...
    ...
    ...
  creationTimestamp: ...
  name: <pv-name>
  resourceVersion: ...
  selfLink: ...
  uid: ...
spec:
  ...
```


Your PV might contain a reference to the old PVC that was bound to it previously. This is stored in a section of the `spec` called `claimRef` and will look similar to this:

```
claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: ...
    namespace: ...
    resourceVersion: ...
    uid: ...
```

You will need to delete this section to allow a new PVC to bind to the Microclimate PV.

Once you have added the `name` label and deleted the `claimRef`, save the file and update the PersistentVolume using `kubectl apply -f pv.yaml`.

To confirm that your PV is ready to be bound again, check it's status using `kubectl get pv -o yaml` and you should see the following fields in the `spec` section:
```
status:
  phase: Available
```

If the `phase` value is set to anything other than `Available`, ensure you have correctly completed the other steps before continuing.

Repeat this step with the Jenkins PV, using a different label value (e.g. `name: jenkins-pv`)

### Create the PersistentVolumeClaims

With the PersistentVolume prepared, you will need to create a PersistentVolumeClaim which will find the PV using the label defined in the previous step. To do this copy the following to a new file named `pvc.yaml`:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: microclimate-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
     requests:
       storage: 2Gi
  selector:
    matchLabels:
      <label>: <value>
```

In this file, replace the `name` value with a meaningful name for your PVC (e.g. `microclimate-pvc`) and replace the `storage` value with the `capacity` value from the earlier step. Finally, set the `<label>` and `<value>` to the label and value that you added to the Microclimate PV in previous step (e.g. `name: microclimate-pv`).

Note: you must ensure the `accessModes` match the `accessModes` field in the PV. You can check the value in the PV using `kubectl get pv <pvName> -o yaml`.

Save this file and create the PVC using `kubectl create -f pvc.yaml`. The PVC and PV should automatically find each other using the selector label you provided. You can confirm this has worked by printing out the contents of the PV using `kubectl get pv <pvName> -o yaml` and finding the `claimRef` field. Here you should see a reference to your newly created PVC with the `name` field matching the `name` set in the PVC.

Repeat this step to create the Jenkins PVC, using a different name value (e.g. jenkins-pvc) and the label you set in the Jenkins PV metadata.

Keep note of the names of these new PVCs for the following step.

### Install Microclimate

Finally, install Microclimate using your newly created PVCs by setting the `persistence.existingClaimName` and `jenkins.Persistence.ExistingClaim` to the names given to the Microclimate and Jenkins PVCs you created in the previous step, on top of the installation steps defined in the 'Installing the Chart' section of the README.

For more information on setting installation values, read the 'Configuring Microclimate' section of the README.


# Documentation
For detailed upgrade instructions go to https://microclimate-dev2ops.github.io/installicp

# Version History

| Chart | Date | Kubernetes Version Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.2.0 | Apr 27, 2018 | 1.10.0 | 1805 | Upgrading from previous versions requires additional steps, An additional secret must be created to use the Helm tiller in kube-system |  |
| 1.1.1 | Apr 27, 2018 | 1.9.1 | 1804 | None |  |
| 1.1.0 | Apr 27, 2018 | 1.9.1 |  | The docker-registry secret required by microclimate has been changed from microclimate-icp-secret to microclimate-registry-secret |  UI updates, Users can authenticate with Jenkins using their IBM Cloud Private credentials |
| 1.0.0 | Mar 30, 2018|  1.9.1 |  | None  | New product release. See https://microclimate-dev2ops.github.io/ |
