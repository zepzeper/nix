# SOPS Secret Management

This module uses sops-nix to manage and decrypt your SSH keys.

## How It Works

1. **secrets.yaml** - Contains your encrypted SSH keys
2. **.sops.yaml** - Defines who can encrypt/decrypt (age keys)
3. **sops-nix** - Automatically decrypts keys on NixOS to `~/.ssh/`

## Setup Steps

### 1. On Arch: Encrypt Your SSH Keys

```bash
# Run the helper script
encrypt-ssh-keys
# or
~/personal/nix/scripts/encrypt-ssh-keys
```

This will:
- Check that sops is installed
- Encrypt your current SSH keys from `~/.ssh/`
- Create `secrets.yaml` with encrypted keys
- Tell you where to copy the file

### 2. Copy Encrypted File to Nix Repo

```bash
cp /path/to/encrypted/secrets.yaml ~/personal/nix/
cd ~/personal/nix
git add secrets.yaml .sops.yaml
git commit -m "Add encrypted SSH keys"
git push
```

### 3. After NixOS Install: Copy Your Age Key

Once you've installed NixOS and run `home-manager switch`:

```bash
# From your Arch system, copy the age private key
scp ~/.config/sops/age/keys.txt nixos:~/.config/sops/age/

# On NixOS, set correct permissions
chmod 600 ~/.config/sops/age/keys.txt
```

### 4. Decrypt Keys

Run:
```bash
home-manager switch --flake ~/.dotfiles/nix#zepzeper@nixix
```

Your SSH keys will automatically appear in `~/.ssh/` with correct permissions!

## Structure

```
secrets.yaml (encrypted)
  └── ssh_keys/
      ├── id_ed25519
      ├── id_ed25519_pub
      ├── id_ed25519_chartbuddy
      ├── id_ed25519_chartbuddy_pub
      └── known_hosts

→ Decrypted by sops-nix to:
~/.ssh/
  ├── id_ed25519 (0600)
  ├── id_ed25519.pub (0644)
  ├── id_ed25519.chartbuddy (0600)
  ├── id_ed25519.chartbuddy.pub (0644)
  └── known_hosts (0644)
```

## Important Notes

- **Never commit your age private key!** (it's in ~/.config/sops/age/)
- **secrets.yaml is safe to commit** - it's encrypted
- If you lose your age key, you lose access to the encrypted secrets
- Keep a backup of your age key somewhere safe (password manager, etc.)

## Troubleshooting

### "Failed to decrypt" error
Check that your age key exists:
```bash
ls -la ~/.config/sops/age/keys.txt
```

### Keys not appearing
Run home-manager switch again:
```bash
home-manager switch --flake ~/.dotfiles/nix#zepzeper@nixix
```

### Wrong permissions
Check the sops module configuration if permissions aren't correct.

## Updating Keys

To add new keys or update existing ones:

1. On Arch: Edit `~/.ssh/` files
2. Run `encrypt-ssh-keys` again
3. Copy new `secrets.yaml` to nix repo
4. Commit and push
5. On NixOS: Run `home-manager switch`
