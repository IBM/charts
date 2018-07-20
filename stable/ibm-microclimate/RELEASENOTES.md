# Breaking Changes
No breaking changes are present in this release

# What’s new in Chart Version 1.4.0

## Microclimate
* Warning added for if the Microclimate backend disconnects
* Enhanced remote workspace connection with notifications
* Updated UI to match latest accessibility compliance spec
* Newly created projects are now set up to dynamically pull in the latest available JDK service release to pick up patches and security fixes.
* Shutdown of projects is more efficient when you close or log off Microclimate.
* A new validation step on project import generates any missing files which means a better experience getting your imported projects working in Microclimate.


## Pipeline
* *No new changes*

## Chart
* *No new changes*

# Fixes
* Helm chart names no longer need to match the project name
* Various minor bug and stability fixes


# Prerequisites
1. IBM Cloud Private version 2.1.0.3. Installing into 2.1.0.2 may work but is not completely tested


## Upgrading Microclimate to v1.4.0

### ...from version v1.3.0

You can upgrade to the v1.4.0 version of the chart from v1.3.0 using Helm upgrade. You should pass the same values into the Helm upgrade command that you initially installed the chart with to ensure configuration remains the same. It is recommended that you retrieve these values and store them for later use by using the following command with your Microclimate release name:

`helm get values <release-name> > values.yaml`

You can then perform the upgrade with the following command:

`helm upgrade <release-name> <path-to-microclimate-chart> -f values.yaml`


### ...from version v1.2.x
**WARNINGS**:
- These instructions have been tested using v1.2.x versions of the chart, upgrading to v1.3.0. These instructions may work for previous versions but have not been tested.
- These instructions have only been tested using GlusterFS. If a different type of PersistentVolume is being used, it is recommended that you back up the contents of the volumes manually.

To carry existing projects over to Microclimate v1.3.0, your existing Microclimate PersistentVolumes (PVs) will need to be reused in the new Microclimate installation by binding new PersistentVolumeClaims (PVCs) that you will need to create manually. This can be achieved by following the steps below (note: this requires you to have `kubectl` configured to your cluster):

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


### Set the Microclimate PersistentVolume Access Mode to ReadWriteMany

As of version 1.3.0, Microclimate now requires a PersistentVolume with a ReadWriteMany access mode and so you will need to edit your PersistentVolume. This can be achieved using the following command:

`kubectl patch pv <microclimate-pv-name> -p '{"spec":{"accessModes":["ReadWriteMany"]}}'`


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

### Install Microclimate

Finally, install Microclimate setting the `persistence.size` value to the value of the Microclimate PVC you recorded in the earlier step along with the required Microclimate values and any other values you want to set.

For example, you `helm install` command may look like this:

`helm install --name microclimate --set persistence.size=<pvcCapacity> --set hostName=<MICROCLIMATE_INGRESS> --set jenkins.Master.HostName=<JENKINS_INGRESS> --set <any-other-values> ibm-charts/ibm-microclimate`

For more information on setting installation values, read the 'Configuring Microclimate' section of the README.

### Run the project migration node application

Because of the new multi-user support in this version of Microclimate, projects from previous Microclimate installations won't be compatible when re-installing. To solve this, you can use our project migration script to make old projects compatible with a Microclimate v1.3.0 installation. **NOTE** This has only been tested with Microclimate v1.2.x projects and may not work with projects from previous Microclimate installations


1. Ensure you Microclimate installation is running using the release you used to install Microclimate with: `kubectl get pods -l release=<releaseName>`. You should see all pods ready.

2. Identify the main Microclimate pod. Using the command in the previous step, you should see 3 pods running with the names `<releaseName>-ibm-microclimate-...`, `<releaseName>-ibm-microclimate-devops...` and `<releaseName>-jenkins-...`. The main Microclimate pod is the one named `<releaseName>-ibm-microclimate-...`.

3. Open bash in the Microclimate pod using the following command: `kubectl exec -it <microclimate-pod-name> bash`.

**NOTE**: Before continuing, it is recommended to make a backup of your `microclimate-workspace` directory.

4. In the pod bash terminal, download the project migration program from the Microclimate landing page: `curl -o migrateProjects.js -L https://microclimate-dev2ops.github.io/utils/migrateProjects.js`

5. Run the project migration program using: `node migrateProjects.js`

6. Restart the Microclimate pod using `kubectl delete pod <microclimate-pod-name>`. This will kill the pod and will create a fresh instance.

6. Open your Microclimate instance and navigate to the projects window. You should see your old projects here. If these projects have no build status, open each project individually and press the `Build` button. You projects should now be usable as normal.



# Documentation
For detailed installation instructions go to https://microclimate-dev2ops.github.io/installicp

# Version History

| Chart | Date | Kubernetes Version Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- |
| 1.4.0 | July 20, 2018 | 1.10.0, 1.9.1 | 1807 | None | Logout implemented, various small fixes and improvements |
| 1.3.0 | June 29, 2018 | 1.10.0, 1.9.1 | 1806 | Multi-user support caused changes to the Microclimate PVCs - upgrade will not work  | Various changes and new features |
| 1.2.1 | June 11, 2018 | 1.10.0, 1.9.1 | 1805 | Upgrading from versions v1.1.x requires additional steps for project migration | ICP 2.1.0.2 fixes |
| 1.2.0 | May 25, 2018 | 1.10.0 | 1805 | Upgrading from versions v1.1.x requires additional steps for project migration, An additional secret must be created to use the Helm tiller in kube-system |  |
| 1.1.1 | May 1, 2018 | 1.9.1 | 1804 | None |  |
| 1.1.0 | Apr 27, 2018 | 1.9.1 |  | The docker-registry secret required by microclimate has been changed from microclimate-icp-secret to microclimate-registry-secret |  UI updates, Users can authenticate with Jenkins using their IBM Cloud Private credentials |
| 1.0.0 | Mar 30, 2018|  1.9.1 |  | None  | New product release. See https://microclimate-dev2ops.github.io/ |
