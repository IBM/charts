# Breaking Changes
No breaking changes.

# What’s new in Chart Version 1.8.0


## Microclimate

* Added support for debugging Spring applications using the Microclimate Developer Tools for Eclipse.
* Improved build status for Spring applications.
* When installing, Microclimate now checks the details of its install and gives the user a message and a link to the documentation if it's unable to start.
* Liberty delivered default non-root user support. Microclimate now supports builds with non-root user and our liberty java template generates non-root image sample.
* Added support for IBM Cloud Private Version 3.1.1


## Pipeline
* No significant updates.


## Chart
* Added support for IBM Cloud Private Version 3.1.1


# Fixes
* Various minor bug and stability fixes.


# Prerequisites
- IBM Cloud Private Version 3.1.0 or later. Older versions of IBM Cloud Private are supported only by chart versions v1.5.0 and earlier. Version support information can be found in the release notes of each chart release.
- Ensure [socat](http://www.dest-unreach.org/socat/doc/README) is available on all worker nodes in your cluster. Microclimate uses Helm internally, and both the Helm Tiller and client require socat for port forwarding.
- Download the IBM Cloud Private CLI, `cloudctl`, from your cluster at the `https://<your-cluster-ip>:8443/console/tools/cli` URL.


## Upgrading Microclimate to v1.8.0

To upgrade to Microclimate v1.8.0:
1. Obtain information about current persistent volumes so that they can be retained in the new installation.
1. Uninstall Microclimate.
1. Upgrade IBM Cloud Private to Version 3.1.0 or 3.1.1.
1. Install Micrcolimate with the persitent volumes.

More details are provided in the following sections:

### Identify which PersistentVolumes the existing Microclimate deployment is currently using
Microclimate will be using two PersistentVolumes: one for the main Microclimate deployment and one for the  Jenkins deployment. These can be found by using `kubectl describe deploy <deploymentName> | grep "ClaimName"` on each of the  deployments to find the name of the PersistentVolumeClaim being used; followed by using `kubectl describe pvc <pvcName> | grep "Volume"` to find the name of the PersistentVolume that the claim is bound to. Repeat this step for both the Microclimate and Jenkins deployments.

Keep note of these PV names for the following steps.

### Ensure the Reclaim Policy is set to 'Retain' on both PersistentVolumes
To ensure your Microclimate data is retained during the migration, you need to ensure the PersistentVolume doesn't get deleted or recycled by setting their Reclaim Policies to `Retain`. To check the policy of a Persistent Volume, use `kubectl get pv <pvName> -o yaml | grep persistentVolumeReclaimPolicy`. If the policy is set to anything other than 'Retain', you can set this value using the following command:

`kubectl patch pv <pvName> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'`

Repeat this step for both the Microclimate and Jenkins PersistentVolumes.

### Take note of capacity used by the existing Microclimate PersistentVolumeClaim

Because the default PVC size of Microclimate has changed, you will need to ensure you set the PVC size when re-installing Microclimate to ensure the Microclimate PVC binds to the PV correctly. To find this value, use the following command:

`kubectl describe pvc <pvcName> | grep "Capacity"`

Use this to find the capacity of both the Microclimate and Jenkins PVCs

### Uninstall Microclimate

**IMPORTANT** Ensure the previous steps have been completed - otherwise you may risk losing your Microclimate data

Uninstall Microclimate using Helm using the release name you installed Microclimate with: `helm delete --purge <releaseName>`. This will remove all of the Microclimate components including the PersistentVolumeClaims and should leave behind the PersistentVolumes in a `Released` state. To confirm this, do `kubectl get pv` and you should see both of the Microclimate PersistentVolumes left behind with their status set to `Released` and still have a `Claim` associated to them.

### Removing existing claim references from the PersistentVolumes

Your PVs may still contain references to the old PVCs that were bound to them previously which are stored in a section of each PV spec called `claimRef`. You will need to delete this from each PV to allow the new Microclimate PVCs to bind to them.

For both the Microclimate and Jenkins PersistentVolumes, carry out the following steps:

1. Use `kubectl edit pv <pv-name>` to begin editing the PV. By default, this will open ‘vi’ for Linux or ‘notepad’ for Windows. To learn how to use a different editor, view the documentation for `kubectl edit` [here](https://kubernetes-v1-4.github.io/docs/user-guide/kubectl/kubectl_edit/)

2. Identify the `claimRef` in the PV spec. It should look similar to the following:

```
claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: ...
    namespace: ...
    resourceVersion: ...
    uid: ...
```

3. Delete this section from the PV, save the changes and exit the editor. If this was successful, you should see the message `persistentvolume "<pv-name>" edited` and using `kubectl get pv <pv-name> -o yaml`.

4. Verify that the PV is now available. Using `kubectl get pv <pv-name>` should show the PV with an `Available` status and with an empty claim field.

### Reinstall Microclimate after upgrading to IBM Cloud Private Verion 3.1.0

After you upgrade your cluster, you follow the installation steps in the README file. These steps have been updated specifically for Version 3.1.0. In addition to these installation steps, you need to set the persistence.size value to the value of the Microclimate PVC you recorded in the earlier steps to ensure a new PVC gets created, which binds to your previous Microclimate PV." 

For example, you `helm install` command may look like this:

`helm install --name microclimate --set persistence.size=<pvcCapacity> --set hostName=<MICROCLIMATE_INGRESS> --set jenkins.Master.HostName=<JENKINS_INGRESS> --set <any-other-values> ibm-charts/ibm-microclimate`

If Microclimate doesn't bind to the correct PV, you might need to manually create a PVC to bind to the PV and reinstall Microclimate and provide the PVC name in the `persistence.existingClaimName` value.

For more information on setting installation values, read the **Configuring Microclimate** section of the README.



# Documentation
For detailed installation instructions go to https://microclimate-dev2ops.github.io/installicp

# Version History

| Chart | Date | Kubernetes Version Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.8.0 | November 16, 2018 | 1.11.0  | 1811 | None | Added support for ICP 3.1.1. Various fixes and improvements |
| 1.7.0 | October 12, 2018 | 1.11.0  | 1810 | None | Various fixes and improvements |
| 1.6.0 | September 14, 2018 | 1.11.0  | 1809 | Support only for ICP 3.1.0 | Various fixes and improvements |
| 1.5.0 | Aug 20, 2018 | 1.10.0, 1.9.1 | 1808 | None | Various fixes and improvements |
| 1.4.0 | July 20, 2018 | 1.10.0, 1.9.1 | 1807 | None | Logout implemented, various small fixes and improvements |
| 1.3.0 | June 29, 2018 | 1.10.0, 1.9.1 | 1806 | Multi-user support caused changes to the Microclimate PVCs - upgrade will not work  | Various changes and new features |
| 1.2.1 | June 11, 2018 | 1.10.0, 1.9.1 | 1805 | Upgrading from versions v1.1.x requires additional steps for project migration | ICP 2.1.0.2 fixes |
| 1.2.0 | May 25, 2018 | 1.10.0 | 1805 | Upgrading from versions v1.1.x requires additional steps for project migration, An additional secret must be created to use the Helm tiller in kube-system |  |
| 1.1.1 | May 1, 2018 | 1.9.1 | 1804 | None |  |
| 1.1.0 | Apr 27, 2018 | 1.9.1 |  | The docker-registry secret required by microclimate has been changed from microclimate-icp-secret to microclimate-registry-secret |  UI updates, Users can authenticate with Jenkins using their IBM Cloud Private credentials |
| 1.0.0 | Mar 30, 2018|  1.9.1 |  | None  | New product release. See https://microclimate-dev2ops.github.io/ |
