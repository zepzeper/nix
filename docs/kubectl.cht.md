# kubectl Debugging Cheatsheet

## Pod Management

| Command | Description |
|---|---|
| `kubectl get pods -n <ns>` | List all pods in a namespace |
| `kubectl get pods -n <ns> -w` | Watch pods in real-time |
| `kubectl describe pod -n <ns>` | Show detailed info including events and errors |
| `kubectl logs -n <ns> deployment/<name>` | Show logs from a deployment |
| `kubectl logs -n <ns> deployment/<name> -f` | Follow logs in real-time |
| `kubectl delete pod -n <ns> -l app=<name>` | Delete pod by label — auto-recreated |
| `kubectl rollout restart deployment/<name> -n <ns>` | Restart all pods in a deployment |
| `kubectl exec -n <ns> deployment/<name> -- <cmd>` | Run a command inside a pod |

## Deployments & Services

| Command | Description |
|---|---|
| `kubectl get deployments -n <ns>` | List all deployments |
| `kubectl describe deployment <name> -n <ns>` | Show deployment details and events |
| `kubectl get services -n <ns>` | List all services and their ports |
| `kubectl get ingress -n <ns>` | List all ingress rules |
| `kubectl get all -n <ns>` | List everything in a namespace at once |

## TLS & Certificates (cert-manager)

| Command | Description |
|---|---|
| `kubectl get certificate -n <ns>` | List certificates and READY status |
| `kubectl describe certificate <name> -n <ns>` | Show certificate details and events |
| `kubectl get certificaterequest -n <ns>` | List certificate signing requests |
| `kubectl describe certificaterequest <name> -n <ns>` | Show why a cert request is pending/failed |
| `kubectl get challenge -n <ns>` | List ACME challenges and their state |
| `kubectl describe challenge -n <ns>` | Show challenge details — useful for DNS-01 errors |
| `kubectl delete certificate <name> -n <ns>` | Force cert-manager to reissue a certificate |
| `kubectl get clusterissuer` | List ClusterIssuers and READY status |

## Secrets & Config

| Command | Description |
|---|---|
| `kubectl get secret <name> -n <ns>` | Check if a secret exists |
| `kubectl get secret <name> -n <ns> -o yaml` | Show secret contents (base64 encoded) |
| `kubectl get configmap -n <ns>` | List all configmaps |
| `kubectl get addon -n kube-system` | List k3s addons and applied manifests |

## Namespaces & Cluster

| Command | Description |
|---|---|
| `kubectl get nodes` | List all nodes and their status |
| `kubectl get namespaces` | List all namespaces |
| `kubectl get pods --all-namespaces` | List all pods across every namespace |
| `kubectl top nodes` | CPU and memory usage per node |
| `kubectl top pods -n <ns>` | CPU and memory usage per pod |

## Debugging Flow

1. `kubectl get pods -n <ns>` — check pod status
2. `kubectl describe pod -n <ns>` — if Pending/Error, check events at the bottom
3. `kubectl logs -n <ns> deployment/<name>` — if CrashLoopBackOff, check app logs
4. `kubectl get certificate -n <ns>` — if site has no HTTPS, check cert status
5. `kubectl describe challenge -n <ns>` — if cert not ready, check ACME challenge
6. `kubectl get secret <name> -n <ns>` — if challenge errors, check if secret exists
7. `sudo systemctl restart k3s` — restart the whole cluster
