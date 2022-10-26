# Usage:
```commandline
# Create a cluster with 3 node, all of them are used containerd as CRI
$> setup_k8s_cluster.ps1 3 
```
[link](../../chap03/README.md)


# Ref:
- K8S with containerd:
  - pre-request: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
  - https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
  - https://github.com/containerd/containerd/blob/main/docs/getting-started.md

- Change container runtime on a Node from Docker engine to Containerd 
  - https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/change-runtime-containerd/
