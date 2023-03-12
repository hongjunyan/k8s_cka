# Authorization

- ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#core-component-roles

## Create Role and RoleBinding for jason

- Create a role which has RUD privilege for POD in `default` namespace
    ```bash
    master $> kubectl apply -f role_crud_pod.yaml
    master $> kubectl get role
    ```

    - role_crud_pod.yaml
    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      namespace: default
      name: crud-pod
    rules:
    - apiGroups: [""]
      resources: ["pods"]
      verbs: ["get", "list", "update", "delete"]
    ```

- Grant the crud-pod role to Jason
    ```bash
    master $> kubectl apply -f rolebind_crud_pod.yaml
    master $> kubectl describe rolebinding crud-pod
    ```

    - rolebind_crud_pod.yaml
    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      namespace: default
      name: crud-pod
    subjects:
    - kind: User
      name: jason  # <- the authenticated user
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: Role
      name: crud-pod  # <- create above
      apiGroup: rbac.authorization.k8s.io
    ```

## Login client VM and RUD pod with user jason
- Login client VM
    ```bash
    host $> multipass exec client bash
    ```
- RUD pod
    ```bash
    client $> kubectl run client-nginx --image=nginx  # get fail, because we don't grant `create` privilege to jason
    client $> kubectl get pod -n kube-system  # get fail, we only grant accessing in default namespace to jason.
    client $> kubectl get pod  # get successs
    ```