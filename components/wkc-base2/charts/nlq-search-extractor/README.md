# Introduction
This chart is used to install the IGC Indexing service.

# Chart Details
Version: 0.11.4

## Installing the Chart
### Instructions to deploy helm charts on K8s
Copy the contents of this folder to a K8s cluster on which you have command-line access (to kubectl and helm commands).
Perform the following steps on the cluster.

#### Change deployed image on the cluster.
- Create a K8s secert on the cluster using instructions [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)
- Edit deployment.yaml on the cluster and add imagePullSecrets
- If the requirement is to deploy containers with a tag other than latest, replace global.tag with the appropriate tag.


## Some basic k8s commands to help with debugging

#### Check logs for a container
Run helm status to and look at the v1/Pod section to locate the NAME of the pod in question. Then run
```
oc logs -n zen <Pod Name>
```
Note that it's important to add `-n zen` with every k8s command since k8s needs the namespace information to locate the k8s asset.

#### Login to a container
Run helm status to and look at the v1/Pod section to locate the NAME of the pod in question. Then run
```
oc exec -it -n zen <Pod Name> bash
```

#### Get Pod details
If a pod does not come up, then it will not have any logs to inspect. In that case, run the command below to describe the pod and get more information.
```
kubectl describe pod -n zen <Pod Name>
```

# Configuration
Add imagePullSecrets to change the image running on a cluster.

# Prerequisites
None

# Resources Required

# Limitations

# PodSecurityPolicy Requirements
Custom PodSecurityPolicy definition:
    ```
    apiVersion: policy/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
    spec:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      allowedCapabilities:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      volumes:
      - configMap
      - secret
    ```

# Red Hat OpenShift SecurityContextConstraints Requirements
[`ibm-priveleged-scc`](https://ibm.biz/cpkspec-scc)
Custom SecurityContextConstraints definition:
```
```