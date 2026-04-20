# Mina Address CLI

`mina` is lightweight IPv6 to IPv4 `ssh` CLI tool - created by MinaVPS (https://minavps.com) <br/>
It is the official client tool for **Mina Address**, designed to simplify ssh to IPv6 server.

This repo provides a shell-based installer and a prebuilt binary to simplify setup.

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/minavps-com/mina/main/install.sh | bash
```

Installs the latest binary to `~/.local/bin` (or `/usr/local/bin`).

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

## License

- **Installer Script (`install.sh`):** Licensed under [Apache License 2.0](LICENSE).
- **Software Binary:** Licensed under our [Proprietary EULA](LICENSE-BINARY).
