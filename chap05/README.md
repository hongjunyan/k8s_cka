# Pod Management
All commands are running on master node

## Create Pod
- Create pod with command
    ```bash
    $> kubectl run <pod_name> --image=<image_name>
    # for example
    $> kubectl run mynginx --image=nginx
    ```
- Create pod with yaml
    ```bash
    # Get yaml template with `--dry-run=client`
    $> mkdir pods && cd pods
    $> kubectl run mynginx --image=nginx --dry-run=client -o yaml > mynginx.yaml 
    $> kubectl create ns demo
    # create pod with yaml
    $> kubectl apply -f mynginx.yaml
    ```
    - mynginx.yaml
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
            creationTimestamp: null
            labels:
                run: mynginx
            name: mynginx
            namespace: demo  # <- add demo namespace
        spec:
            containers:
            - image: nginx
              name: mynginx
              resources: {}
              imagePullPolicy: IfNotPresent  # <- add pull policy
            dnsPolicy: ClusterFirst
            restartPolicy: Always
        status: {}
        ```
- Create Pod with 2 containers
    - pod_with_2_containers.yaml
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
            creationTimestamp: null
            labels:
                run: pod2c
            name: pod2c
            namespace: demo
        spec:
            containers:
            - image: nginx
              name: mynginx
              resources: {}
              imagePullPolicy: IfNotPresent
            - image: redis  # <- add second container here
              name: myredis
            dnsPolicy: ClusterFirst
            restartPolicy: Always
        status: {}
        ```
- Pod with init Container
    ```bash
    # show vm.swappiness on slave1
    slave1 $> sysctl -n vm.swappiness  # show 60
    master $> kubectl apply -f initpod.yaml
    slave1 $> sysctl -n vm.swappiness  # show 10
    ```
    - initpod.yaml
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
            creationTimestamp: null
            labels:
                run: initpod
            name: initpod
            namespace: demo
        spec:
            containers:
            - image: nginx
              name: nginxafterinit
              resources: {}
              imagePullPolicy: IfNotPresent
            
            initContainers:
            - image: alpine
              name: initnginx
              command: ["/bin/sh", "-c", "/sbin/sysctl -w vm.swappiness=10"]  # set swappiness in physical host
              securityContext:
                privileged: true  # because we modified the system variable on physical host, we need to give the privilege for the pod

            dnsPolicy: ClusterFirst
            restartPolicy: Always
        status: {}
        ```

- Create Pod with init Container, both of them shared the same data
    ```bash
    master $> kubectl apply -f initpod2.yaml
    master $> kubectl exec initpod2 -c nginxafterinit2 -- ls /xx  # show aa.txt
    ```
    - initpod2.yaml
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
            creationTimestamp: null
            labels:
                run: initpod2
            name: initpod2
            namespace: demo
        spec:
            volumes:  # <- define a volume
            - name: workdir
              emptyDir: {}

            containers:
            - image: nginx
              name: nginxafterinit2
              resources: {}
              imagePullPolicy: IfNotPresent
              volumeMounts:
              - name: workdir
                mountPath: "/xx"  # define workdir to /xx in nginx container

            initContainers:
            - image: busybox
              name: bb
              command: ["sh", "-c", "touch /work-dir/aa.txt"]
              volumeMounts:
              - name: workdir
                mountPath: "/work-dir"

            dnsPolicy: ClusterFirst
            restartPolicy: Always
        status: {}
        ```


## Check Pod status
- Check pod with namespace
    ```bash
    # Check pod with namespace
    $> kubectl get pod -n demo
    ```
- Switch Namespace to `demo`
    - ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/

    ```bash
    # Switch Namespace to demo (https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
    $> kubectl config set-context --current --namespace=demo
    # Validate namespace
    $> kubectl config view | grep namespace
    # Check pod
    $> kubectl get pod
    ```
- Check pod with node info
    ```bash
    # check which node ran this pod
    $> kubectl get pods -o wide
    ```
- Check pod with label
    ```bash
    $> kubectl get pods --show-labels
    ```
- Check pod with specific label name
    ```
    $> kubectl get pod -l run=mynginx
    ```

## Delete Pod
- Delay deletion
    ```bash
    # Waiting for terminationGracePeriodSeconds(30s by defaulted)
    $> kubectl delete pod <pod_name>
    ```
- Forcely delete (without delay)
    ```bash
    $> kubectl delete pod <pod_name> --force
    ```

- Set `terminationGracePeriodSeconds` in yaml

    Create `busybox.yaml` as below. It will wait 15s after executing the command to delete busybox.
    ```bash
    $> kubectl apply -f busybox.yaml
    $> kubectl delete pod busybox  # wait for 15s
    ```
    - busybox.yaml
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
            creationTimestamp: null
            labels:
                run: busybox
            name: busybox
            namespace: demo
        spec:
            terminationGracePeriodSeconds: 15  # <- set delay deletion in seconds
            containers:
            - image: busybox
              command: ["sh", "-c", sleep 1000]
              imagePullPolicy: IfNotPresent
            dnsPolicy: ClusterFirst
            restartPolicy: Always
        status: {}
        ```
- Special Case

    However, nginx control the quit signal by itself, so nginx is not waiting for `terminationGracePeriodSeconds`. That is, the pod will be delete when nginx was quit itself.
    ```bash
    $> kubectl apply -f mynginx2.yaml
    $> kubectl delete pod mynginx2  # The pod will be delete when nginx was quit. It will not wait for 600s
    ```
    - mynginx2.py
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
            creationTimestamp: null
            labels:
                run: mynginx2
            name: mynginx2
            namespace: demo
        spec:
            terminationGracePeriodSeconds: 600
            containers:
            - image: nginx
              name: mynginx2
              resources: {}
              imagePullPolicy: IfNotPresent
            dnsPolicy: ClusterFirst
            restartPolicy: Always
        status: {}
        ```