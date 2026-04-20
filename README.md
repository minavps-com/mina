# Mina Address CLI

`mina` is lightweight IPv6 to IPv4 `ssh` CLI tool - created by MinaVPS (https://minavps.com) <br/>
It is the official client tool for **Mina Address**, designed to simplify ssh to IPv6 server.

This repo provides a shell-based installer and prebuilt binaries for all major platforms.

## Installation

### One-line installer (recommended)

```bash
curl -sSL https://raw.githubusercontent.com/minavps-com/mina/main/install.sh | bash
```

Installs the latest binary to `~/.local/bin` (adds to your PATH automatically).

## Quick Start

Add your IPv6 server:
```bash
mina add 2001:db8:85a3:0000:0000:8a2e:0370:7334

# ✅ Mina Address generated!
# IPv6 address:  2001:4860:85a3:0000:0000:8a2e:0370:7334
# Mina Address:  12.10.192.5 (🔹 Free)
```

SSH using Mina Address:
```bash
mina user@12.10.192.5

# 12.10.192.5 --> 2001:4860:85a3:0000:0000:8a2e:0370:7334
# ssh user@2001:4860:85a3:0000:0000:8a2e:0370:7334
# connected to server
```

## Usage

```
mina command [command options] [arguments...]
```

### Commands

- `mina login` - Authenticate with Minavps service (interactive or `--auth-code`)
- `mina logout` - Remove authentication token
- `mina add <ipv6> [--pro]` - Add an IPv6 address (optional `--pro`)
- `mina delete <mina-address>` - Delete an IP address
- `mina subscribe [plan]` - Subscribe to service plans
- `mina list` - List IPv6 entries
- `mina status` - Show authentication status and configuration
- `mina version` - Show CLI version

### Examples

```bash
# Login (will open browser)
mina login

# Login with code (non‑interactive)
mina login --auth-code ABC-D12

# Add IPv6 address
mina add 2001:db8::1

# Add IPv6 address as pro
mina add 2001:db8::2 --pro

# List entries
mina list

# Delete entry
mina delete 12.10.192.5

# Check status
mina status
```

## License

- **Installer Script (`install.sh`):** Licensed under [Apache License 2.0](LICENSE).
- **Software Binary:** Licensed under our [Proprietary EULA](LICENSE-BINARY).

## Advanced

### Installation Options

```bash
# Install specific version
curl -sSL https://raw.githubusercontent.com/minavps-com/mina/main/install.sh | bash -s -- --version=0.1.0

# Install to custom directory
curl -sSL https://raw.githubusercontent.com/minavps-com/mina/main/install.sh | bash -s -- --dir=/usr/local/bin

# See all options
curl -sSL https://raw.githubusercontent.com/minavps-com/mina/main/install.sh | bash -s -- --help
```

### Manual Installation

Download the appropriate binary for your platform from the [bin/](bin/) directory and make it executable:

```bash
# Example for Linux x86_64
curl -LO https://raw.githubusercontent.com/minavps-com/mina/main/bin/0.1.0/mina-0.1.0-linux-amd64
chmod +x mina-0.1.0-linux-amd64
sudo mv mina-0.1.0-linux-amd64 /usr/local/bin/mina
```

### Supported Platforms

The Mina CLI is available for:

| Platform | Architecture | Binary Name |
|----------|--------------|-------------|
| Linux | x86_64 (64-bit) | `mina-{version}-linux-amd64` |
| Linux | ARM64 | `mina-{version}-linux-arm64` |
| macOS | Intel | `mina-{version}-darwin-amd64` |
| macOS | Apple Silicon | `mina-{version}-darwin-arm64` |
| Windows | x86_64 (64-bit) | `mina-{version}-windows-amd64.exe` |
| Windows | ARM64 | `mina-{version}-windows-arm64.exe` |

All binaries are statically linked and require no external dependencies.

### Directory Structure

```
mina/
├── bin/
│   ├── 0.1.0/                    # Versioned releases
│   │   ├── mina-0.1.0-linux-amd64
│   │   ├── mina-0.1.0-linux-arm64
│   │   ├── mina-0.1.0-darwin-amd64
│   │   ├── mina-0.1.0-darwin-arm64
│   │   ├── mina-0.1.0-windows-amd64.exe
│   │   └── mina-0.1.0-windows-arm64.exe
│   └── (future versions)
├── install.sh                    # Smart installer script
└── README.md                     # This file
```

### Security

All binaries are accompanied by SHA256 checksums for verification. The installer automatically verifies checksums during installation.

For security-conscious users, you can verify the checksum manually:
```bash
# Download binary and checksum
curl -LO https://raw.githubusercontent.com/minavps-com/mina/main/bin/0.1.0/mina-0.1.0-linux-amd64
curl -LO https://raw.githubusercontent.com/minavps-com/mina/main/bin/0.1.0/mina-0.1.0-linux-amd64.sha256

# Verify checksum
sha256sum -c mina-0.1.0-linux-amd64.sha256
