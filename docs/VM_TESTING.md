# Testing NixOS Configuration in VM

Before installing NixOS on your main system, you can test the configuration in a virtual machine.

## Prerequisites

Make sure you have QEMU/KVM installed:

```bash
# On Arch Linux (your current system)
sudo pacman -S qemu-full qemu-img
```

## Quick Start

```bash
# Build and run the VM
nix-vm

# Or explicitly
nix-vm run
```

## Available Commands

| Command | Description |
|---------|-------------|
| `nix-vm build` | Build the VM image only |
| `nix-vm run` | Build (if needed) and run the VM |
| `nix-vm rebuild` | Rebuild config and restart VM |
| `nix-vm ssh` | SSH into running VM |
| `nix-vm clean` | Remove VM files |
| `nix-vm help` | Show help |

## How It Works

The VM script uses NixOS's built-in VM building capability:

1. **Build**: `nixos-rebuild build-vm --flake .#nixix` creates a bootable VM
2. **Run**: QEMU launches the VM with:
   - 4GB RAM (configurable)
   - 2 CPU cores (configurable)
   - 20GB disk image
   - SSH port forwarding (host:2222 → VM:22)

## Testing Workflow

### 1. First Test

```bash
# Build and run VM
nix-vm

# Login with your username: zepzeper
# Test your configuration:
# - Check if hyprland starts
# - Test neovim
# - Verify dotfiles are linked
# - Check if apps work
```

### 2. Make Changes

```bash
# Edit your config in another terminal
nvim ~/personal/nix/flake.nix

# Rebuild and test
nix-vm rebuild
```

### 3. SSH Into VM

```bash
# From another terminal
nix-vm ssh

# Or manually
ssh -p 2222 zepzeper@localhost
```

## VM Controls

- **Ctrl+A then X** - Quit QEMU
- **Ctrl+A then C** - QEMU monitor (type `quit` to exit)
- **Ctrl+Alt+G** - Release mouse grab
- **Ctrl+Alt+F** - Toggle full screen

## Customization

Edit `~/personal/nix/scripts/nix-vm` to change:

```bash
VM_MEMORY="8192"    # 8GB RAM
VM_CORES="4"        # 4 CPU cores
```

## Troubleshooting

### VM Won't Start

```bash
# Check if KVM is enabled
lsmod | grep kvm

# Enable KVM (if available)
sudo modprobe kvm-intel  # or kvm-amd

# Check QEMU version
qemu-system-x86_64 --version
```

### Slow Performance

- Make sure KVM is enabled (should be automatic)
- Increase VM memory/cores in the script
- Close unnecessary host applications

### Disk Full

```bash
# Clean up old generations in VM
sudo nix-collect-garbage -d

# Or remove and recreate disk
nix-vm clean
```

## Installing on Real Hardware

Once you're satisfied with the VM test:

1. **Create NixOS USB**:
   ```bash
   # Download NixOS ISO
   wget https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
   
   # Flash to USB
   sudo dd if=nixos-minimal.iso of=/dev/sdX bs=4M status=progress
   ```

2. **Boot from USB** and follow standard NixOS install

3. **Clone your config**:
   ```bash
   git clone --recurse-submodules https://github.com/zepzeper/nix.git ~/.dotfiles/nix
   ```

4. **Install**:
   ```bash
   sudo nixos-install --flake ~/.dotfiles/nix#nixix
   ```

5. **Reboot and enjoy!**

## Tips

- Test all your critical workflows in the VM
- Verify hardware-specific configs work (NVIDIA, etc.)
- Check that secrets (SOPS) work correctly
- Make sure dotfiles submodule initializes properly
