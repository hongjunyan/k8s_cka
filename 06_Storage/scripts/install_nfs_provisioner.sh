sudo apt install -y python3-pip
sudo apt-get install -y jq
pip install yq


git clone https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner.git
cd nfs-subdir-external-provisioner/deploy

# Setup current used namespace to rbac.yaml and deployment.yaml
NS=$(kubectl config get-contexts|grep -e "^\*" |awk '{print $5}')
NAMESPACE=${NS:-default}
sed -i "s/namespace:.*/namespace: $NAMESPACE/g" rbac.yaml deployment.yaml

# Setup NFS info in deployment.yaml
yq -i -y '.spec.template.spec.containers[0].env |= map(select(.name == "NFS_SERVER").value="master")' deployment.yaml
yq -i -y '.spec.template.spec.containers[0].env |= map(select(.name == "NFS_PATH").value="/nfs_demo")' deployment.yaml
yq -i -y '.spec.template.spec.volumes |= map(select(.name == "nfs-client-root").nfs.server="master")' deployment.yaml
yq -i -y '.spec.template.spec.volumes |= map(select(.name == "nfs-client-root").nfs.path="/nfs_demo")' deployment.yaml

# customize provisioner name to thejun.io/nfs-storage
yq -i -y '.spec.template.spec.containers[0].env |= map(select(.name == "PROVISIONER_NAME").value="thejun.io/nfs-storage")' deployment.yaml
yq -i -y '.provisioner="thejun.io/nfs-storage"' class.yaml


# deploy NFS provisioner
kubectl apply -f rbac.yaml
kubectl apply -f deployment.yaml
kubectl apply -f class.yaml
