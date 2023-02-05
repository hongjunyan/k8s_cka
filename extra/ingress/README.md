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

### Example
- git clone https://github.com/nigelpoulton/TheK8sBook.git
- cd ingress
- (optional) replace image in app.yml with hongjunyan/fastapi_backend:v1 which built with fastapi-docker/Dockerfile
- kubectl apply app.yml
- kubectl apply ig-all.yml
- try `curl shield.mcu.com/images/image.png` and `curl mcu.com/shield/images/image.png`, the both results will be different due to incorrect path-base rule
- fix path-base rule by set another ingress
  - ig-all.yml
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: mcu-all-host-base
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /  
  spec:
    ingressClassName: nginx
    rules:
    - host: shield.mcu.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: svc-shield
              port:
                number: 8080
    - host: hydra.mcu.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: svc-hydra
              port:
                number: 8080

  ---
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: mcu-all-path-base
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2
  spec:
    ingressClassName: nginx
    rules:
    - host: mcu.com
      http:
        paths:
        - path: /shield(/|$)(.*)
          pathType: Prefix
          backend:
            service:
              name: svc-shield
              port:
                number: 8080
        - path: /hydra(/|$)(.*)
          pathType: Prefix
          backend:
            service:
              name: svc-hydra
              port:
                number: 8080

  ```
- now, `curl shield.mcu.com/images/image.png` and `curl mcu.com/shield/images/image.png` will get the same results.