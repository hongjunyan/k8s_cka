# Storage

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