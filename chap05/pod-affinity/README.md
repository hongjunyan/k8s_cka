# Create Environment
- slave1 label:
    - device=ssd
- slave2 label:
    - device=gpu
- slave3 label:
    - device=ssd, zone=taiwan

## Case1

Only can be deployed on slave2. Node must have `device=gpu` and 
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-affinity-case1
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: device
            operator: In
            values:
            - gpu
  containers:
  - name: pod-affinity-case1
    image: nginx
```

## Case2

Can be all of slaves, i.e., slave1, slave2, slave3.
Node must have either `device=gpu` or `device=ssd`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-affinity-case2
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: device
            operator: In
            values:
            - gpu
            - ssd
  containers:
  - name: pod-affinity-case2
    image: nginx
```

## Case3

Can only be deployed on slave3. Node must have `device=ssd` and `zone=tawian`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-affinity-case3
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: device
            operator: In
            values:
            - ssd
          - key: zone
            operator: In
            values:
            - taiwan
  containers:
  - name: pod-affinity-case3
    image: nginx
```

## Case4

Can be deployed on slave1 or slave3. Node must have either `device=ssd` or `zone=taiwan`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-affinity-case4
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: device
            operator: In
            values:
            - ssd
        - matchExpressions:
          - key: zone
            operator: In
            values:
            - taiwan
  containers:
  - name: pod-affinity-case4
    image: nginx
```