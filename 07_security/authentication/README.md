# Authentication

## Environment
all node are VMs created by multipass
- K8S Cluster nodes
    - master
    - slave1
    - slave2
- Client nodes
    - client

In this tutorial, we will create a user call jason on client node and is available to access the K8S cluster resource. Here are the steps:
1. [client] - create private `jason.key` and create use it to generate `jason.csr`(certificate signing request)
2. [master] - receive `jason.csr`, and then create CSR object with `client.csr`
3. [master] - approve CSR object and issure `jason.crt`
4. [client] - download `jason.crt` and create kubeconfig.yaml to access K8S cluster.

## Step 0: Create VMs
- Create k8s cluster
    ```bash
    host$> cd 03_Build_K8S/
    host$> setup_k8s_cluster.ps1 3  # create cluster with 3 nodes   
    ```

- Create client VM
    ```bash
    host$> multipass launch --name client -m 2G -c 1 -d 15G
    ```

Now, that's talk about the more details for above steps:
## Step 1: Create Private Key and CSR
- ref: https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user

- Create private key
    ```bash
    client $> openssl genrsa -out jason.key 4096
    ```
- Create csr
    ```bash
    client $> openssl req -sha512 -new -subj "/C=TW/ST=Taipei/L=Taipei/O=sysjust/OU=personal/CN=jason" -key jason.key -out jason.csr
    ```
- Sent csr to master node
    ```bash
    host $> multipass transfer client:jason.csr .
    host $> multipass transfer jason.csr master:
    ```

## Step 2: Create CSR object
- ref - create CSR object: https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user

- ref - signer: https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#kubernetes-signers

- Create CSR object
    ```bash
    master $> bash create_csr_manifest.sh 
    master $> kubectl apply -f csr_manifest.yaml
    master $> kubectl get csr  # the status is pending
    ```

    - create_csr_manifest.sh
        ```bash
        # encode csr with base64
        csr_base64=`cat jason.csr | base64 | tr -d "\n"`

        # create csr manifest
        cat > csr_manifest.yaml <<-EOF
        apiVersion: certificates.k8s.io/v1
        kind: CertificateSigningRequest
        metadata:
          name: jason  # <- replace your user name
        spec:
          request: ${csr_base64}
          signerName: kubernetes.io/kube-apiserver-client  # <- need manually approve
          usages:
          - client auth
        EOF
        ```

## Step 3: Approve CSR object and issue CRT
- ref: https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#approval-rejection
    ```bash
    master $> kubectl certificate approve jason  # manually approve
    master $> kubectl get csr jason -o jsonpath='{.status.certificate}'| base64 -d > jason.crt
    ```

## Step4: Download issued CRT and Create kubeconfig.yaml
- Download jason.crt and ca.crt(/etc/kubernetes/pki)
    ```bash
    host $> multipass transfer master:jason.crt .
    host $> multipass transfer jason.crt client:
    host $> multipass transfer master:/etc/kubernetes/pki/ca.crt .
    host $> multipass transfer ca.crt client:
    ```
- Access K8S cluster
    ```bash
    client $> sudo apt-get update
    client $> sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    client $> echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    client $> sudo apt-get update
    client $> sudo apt-get install -y kubectl
    client $> bash create_and_apply_kubeconfig.sh
    client $> source <(kubectl completion bash)  # for auto-complete
    client $> kubectl get pod
    ```

    The last command, you will get `Error from server (Forbidden): pods is forbidden: User "jason" cannot list resource "pods" in API group "" in the namespace "default"`, because we haven't grant any privilege for jason.


    - create_and_apply_kubeconfig.sh
    ```bash
    # Create template
    cat > kubeconfig.yaml <<-EOF
    apiVersion: v1
    kind: Config
    perferences: {}
    clusters:
    - cluster:
      name: cluster1
    users:
    - name: jason
    contexts:
    - context:
      name: context1
      namespace: default
    current-context: "context1"
    EOF

    # setup cluster info, `--server` must assign your master host
    master_host=`ping -c1 master | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p'`
    kubectl config --kubeconfig=kubeconfig.yaml set-cluster cluster1 --server=https://${master_host}:6443 --certificate-authority=ca.crt --embed-certs=true

    # setup user info
    kubectl config --kubeconfig=kubeconfig.yaml set-credentials jason --client-certificate=jason.crt --client-key=jason.key --embed-certs=true

    # setup context
    kubectl config --kubeconfig=kubeconfig.yaml set-context context1 --cluster=cluster1 --namespace=default --user=jason

    # copy kubeconfig.yaml to .kube/config
    mkdir -p $HOME/.kube
    cp kubeconfig.yaml $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config

    # use context1
    kubectl config use-context context1
    ```