# Install K8S Cluster with Kubeadm

## Prerequest
Please read this article first: https://medium.com/p/f3528b8154aa

## Install VMs
```commandline
$> ./create_k8s.ps1 3  # create 3 nodes, the first one is master node, the others are slave nodes 
```

## Add slave node into cluster
show the join token by running the following command
```commandline
$> ./create_k8s.ps1  # Please do not assign any number
```  
then please use the join token to add slave into cluster