# Migration Steps: NixOS → Ansible (Debian)

## Prerequisites

1. Install Ansible on your workstation:
   ```bash
   pip install ansible
   ansible-galaxy collection install -r requirements.yml
   ```

2. Set up Ansible Vault password:
   ```bash
   echo "your-vault-password" > ~/.ansible-vault-pw
   chmod 600 ~/.ansible-vault-pw
   ```

## Step 1: Populate Secrets

Decrypt your SOPS secrets and populate the Ansible Vault:

```bash
cd ansible

# Create hashed admin password
mkpasswd --method=SHA-512
# Copy the output

# Edit vault with real values (then encrypt)
ansible-vault edit group_vars/all/vault.yml
# Add: vault_tailscale_authkey, vault_k3s_token,
#       vault_cloudflare_api_token, vault_admin_password,
#       vault_tuliprox_url, vault_tuliprox_username, vault_tuliprox_password
```

Or encrypt individual strings:
```bash
ansible-vault encrypt_string "tskey-xxxxx" --name vault_tailscale_authkey >> group_vars/all/vault.yml
```

## Step 2: Install Debian on Servers

- **ds10u**: Debian netinstall (x86_64), single disk `/dev/sda`
- **pi**: Debian ARM image for Raspberry Pi 4, SD card `/dev/mmcblk1`

During install:
- Hostname: `ds10u` / `pi`
- User: create `admin` user (temporary password)
- SSH server: enabled
- Partition: single ext4 root + swap (or match the disko layout)

## Step 3: Add SSH Key for Ansible

```bash
ssh-copy-id admin@ds10u.krugten.org
ssh-copy-id admin@pi.krugten.org
```

## Step 4: Run Bootstrap Playbook

```bash
cd ansible
ansible-playbook playbooks/bootstrap.yml -i inventory/production/hosts.ini --ask-vault-pass
```

This will:
- Set hostname, timezone, locale
- Create admin user with SSH keys
- Harden SSH (password auth off)
- Set up firewall (iptables)
- Install monitoring packages
- Disable bluetooth/audio services

## Step 5: Install K3s Cluster

```bash
ansible-playbook playbooks/k3s.yml -i inventory/production/hosts.ini --ask-vault-pass
```

This will:
- Install and configure Tailscale on master
- Install K3s server on ds10u
- Install K3s agent on pi
- Open required firewall ports

## Step 6: Copy Existing Data (if keeping volumes)

If you're not wiping `/var/lib/` directories (hostPath volumes), skip this.
If you are migrating data from NixOS installation:

```bash
# On the old NixOS, backup data:
tar czf /tmp/pihole-backup.tar.gz /var/lib/pihole/
tar czf /tmp/ha-backup.tar.gz /var/lib/home-assistant/
tar czf /tmp/vaultwarden-backup.tar.gz /var/lib/vaultwarden/

# Copy to new Debian install, then extract
```

## Step 7: Deploy Kubernetes Manifests

```bash
ansible-playbook playbooks/k3s-manifests.yml -i inventory/production/hosts.ini --ask-vault-pass
```

This will:
- Create data directories for hostPath volumes
- Deploy Home Assistant config
- Deploy Homepage and TuliProx configs
- Create Cloudflare API token secrets
- Apply all Kubernetes manifests in order:
  1. Namespaces
  2. cert-manager (from upstream URL)
  3. ClusterIssuer (Let's Encrypt)
  4. nginx-ingress (from upstream URL)
  5. external-dns
  6. All application manifests (pihole, HA, vaultwarden, mealie, kuma, homepage, tuliprox, factorio)

## Step 8: Verify

```bash
# Check cluster
ssh admin@ds10u "kubectl get nodes"
ssh admin@ds10u "kubectl get pods -A"

# Check Tailscale
ssh admin@ds10u "tailscale status"

# Check DNS resolution
ssh admin@ds10u "dig @10.43.0.10 krugten.org"

# Check ingresses
ssh admin@ds10u "kubectl get ingress -A"
```

## Step 9: Fix cert-manager + nginx-ingress (if upstream URLs fail)

If the upstream kubectl apply fails during the playbook, apply manually:

```bash
ssh admin@ds10u
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml
```

## Step 10: Clean up NixOS

Once everything is verified:
- Remove old NixOS boot entries (or just fully reinstall with Debian)
- The NixOS config in this repo can be kept for workstation/laptop references

## Notes

- **k3s agent on pi**: Currently the k3s worker is a work in progress (agent is commented out in Nix config). The Ansible setup will install it — if you don't want it, remove `pi` from `[k3s_worker]` in the inventory.
- **DNS during migration**: Pi-hole runs in k3s. During migration, DNS will be down until k3s is back up. Use `1.1.1.1` as fallback.
- **Tailscale subnet routes**: After `tailscale up`, accept the routes in the Tailscale admin console.
- **SSH host keys**: After reinstall, you'll get host key warnings. Remove old keys: `ssh-keygen -R ds10u.krugten.org`
