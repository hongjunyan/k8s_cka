$num_vms=$args[0]

# multipass delete --purge --all  # delete all vms

function replaceFileLineBreak($filePath) {
    ((Get-Content $filePath) -join "`n") + "`n" | Set-Content -NoNewline $filePath
}

for ($x = 0; $x -lt $num_vms; $x = $x + 1) {
    if ($x -eq 0) {
        $vm_name="master"
        $memory="2G"
        $cpus="2"
        $disk="15G"
    }
    else {
        $vm_name="slave" + $x
        $memory="2G"
        $cpus="1"
        $disk="15G"
    }

    if ((multipass info $vm_name)) {
        echo $vm_name "already existed"
    }
    else {
        # Create VMs and copy some scripts into VMs
        multipass launch --name $vm_name -m $memory -c $cpus -d $disk
        $scripts = Get-ChildItem -Path ./scripts -File -Recurse | Select-Object -ExpandProperty FullName
        foreach ($script in $scripts) {
            replaceFileLineBreak $script
            multipass transfer $script $vm_name":"
        }

        # Install kubeadm and docker
        multipass exec $vm_name -- bash install_kubeadm.sh
        multipass exec $vm_name -- bash install_docker.sh
        multipass exec $vm_name -- bash install_nfs_client.sh
        if ($vm_name -eq "master") {
            multipass exec $vm_name -- bash init_cluster.sh
            multipass exec $vm_name -- bash install_nfs_server.sh
        }
    }
}

$join_cmd = multipass exec master -- kubeadm token create --print-join-command
$join_cmd = "sudo " + $join_cmd + "--cri-socket=/run/cri-dockerd.sock"
echo "Run this command on slave to join the cluster:"
echo $join_cmd