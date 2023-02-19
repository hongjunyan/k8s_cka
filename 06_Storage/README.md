# Storage

key concept: 一個pv只能和一個pvc綁定

## EmptyDir
An emptyDir volume is first created when a Pod is assigned to a node, and exists as long as that Pod is running on that node. As the name says, the emptyDir volume is initially empty. All containers in the Pod can read and write the same files in the emptyDir volume, though that volume can be mounted at the same or different paths in each container. <b>When a Pod is removed from a node for any reason, the data in the emptyDir is deleted permanently</b>.

```bash
$> vim podempdir.yaml
```

- podempdir.yaml
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: demo
    labels:
        run: demo
    spec:
        volumes:
        - name: volume1
          emptyDir: {}
        - name: volume2
          emptyDir: {}

        containers:
        - image: busybox
          name: demo1
          command: ["sh", "-c", "sleep 5000"]
          volumeMounts:  # <- add volume1 to demo1
          - name: volume1
            mountPath: /xx

        - image: busybox
          name: demo2
          command: ["sh", "-c", "sleep 5000"]
          volumeMounts:  # <- add volume1 to demo2
          - name: volume1
            mountPath: /oo
    ```

# NFS Storage Class

## Install NFS Provisioner
- ref: https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner
- HOST: `master`
- NFS_PATH: `/nfs_demo`
- StorageClass: `nfs-client`
- Setup NFS provisioner
  ```bash
  UbuntuVM $> git clone https://github.com/hongjunyan/k8s_cka.git
  UbuntuVM $> cd k8s_cka/06_Storage
  UbuntuVM $> bash ./scripts/install_nfs_provisioner.sh
  ```

## Create PVC
- demo-pvc.yaml
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc1
spec:
  storageClassName: nfs-client  # create with `kubectl apply -f class.yaml` in install_nfs_provisioner.sh
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi
```
then run `kubectl apply -f demo-pvc.yaml`.
You can check with `kubectl get pv,pvc`

## Create Pod with PVC
- test-pod.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx1
spec:
  volumes:
  - name: my-nfs
    persistentVolumeClaim:
      claimName: pvc1  # created above
  containers:
  - image: nginx
    name: nginx-container
    volumeMounts:
      - mountPath: "/demo_mnt"  # you can customize mountPath
        name: my-nfs  # define in volumes
```
then execute `kubectl apply -f test-pod.yaml`

## Demo
- Pass hosts into the pod created above
  ```bash
  UbuntuVM $> kubectl cp /etc/hosts nginx1:/demo_mnt/hosts.txt
  UbuntuVM $> kubectl exec -it nginx1 -- bash
  nginx1 $> cat /demo_mnt/hosts.txt
  ```

- Check nfs folder in NFS Master Node
  ```bash
  master $> cd /nfs_demo/<namespace>-<pvc-name><pv-name>/
  master $> cat hosts.txt  # the content is the same as above
  ```