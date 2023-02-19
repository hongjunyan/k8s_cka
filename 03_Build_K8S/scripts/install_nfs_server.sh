# https://ubuntu.com/server/docs/service-nfs

sudo apt install -y nfs-kernel-server
sudo systemctl start nfs-kernel-server.service
sudo mkdir /nfs_demo
sudo sed -i "1 a /nfs_demo  *(rw,sync,no_root_squash)" /etc/exports
sudo exportfs -a

# exec `showmount -e master`` in client to check the nfs server is working