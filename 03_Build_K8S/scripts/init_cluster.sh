# Step1: Set control Plane host as apiserver-advertise-address
master_host = ifconfig eth0 | grep 'inet ' | sed 's/^.*inet //g' | sed 's/ *netmask.*$//g'
sudo kubeadm init --control-plane-endpoint=$master_host --pod-network-cidr=10.244.0.0/16 --cri-socket=/run/cri-dockerd.sock  # Flannel
# sudo kubeadm init --control-plane-endpoint=$master_host --pod-network-cidr=192.168.0.0/16 --cri-socket=/run/cri-dockerd.sock  # Calico

# Step2: let user can use kubectl without root privileges
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step3: Installing a Pod network add-on
# https://kubernetes.io/docs/concepts/cluster-administration/addons/
# https://github.com/justmeandopensource/kubernetes/blob/master/docs/install-cluster-ubuntu-20.md

# Use Calico
# https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises
# sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
# curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml -O
# kubectl apply -f calico.yaml

# Use Flannel
# https://github.com/flannel-io/flannel
curl https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml -O
kubectl apply -f kube-flannel.yml
