## Install ingress controller 
- https://kubernetes.github.io/ingress-nginx/deploy/

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
```

## Install Metallb
- https://metallb.universe.tf/installation/

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
```


## Specific IPAddressPool 
- https://metallb.universe.tf/configuration/

```
echo "apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.9.1-192.168.9.5" > IPAddressPool.yaml
```
After building cluater, please execute `kubectl apply -f IPAddressPool.yaml`

## Check IPAddressPool

```
kubectl get ipaddresspool -n metallb-system
```

## Ingress more deeper
- Ingress Rewrite Rule: https://kubernetes.github.io/ingress-nginx/examples/rewrite/
- Ingress Path Matching: https://kubernetes.github.io/ingress-nginx/user-guide/ingress-path-matching/
- Nginx location Matching: https://segmentfault.com/a/1190000013267839
