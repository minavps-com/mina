# Changelog

## [0.1.0] - 2026-05-30

### Added
- Released initial version 0.1.0

`mina help`
```
NAME:
   mina - Mina CLI - ssh to IPv6 server, with IPv4-style address

USAGE:
   mina [global options] [command [command options]]

VERSION:
   0.1.0

COMMANDS:
  login       Authenticate with Minavps service
  logout      Remove authentication token
  add         Add an IPv6 address and get a IPv4-style Mina Address
  delete      Delete an IP address
  subscribe   Subscribe to Minavps service plans
  list        List mina addresses and mapped IPv6 entries
  status      Show authentication status and configuration
  version     Show CLI version
  ssh         SSH to an IPv6 server using
                a Mina IPv4-style virtual IP address
  fetch       Lookup IPv6 mapping and add to routing table
  forget      Forget a single address from routing table
  forget-all  Forget all addresses from routing table
  help, h     Shows a list of commands or help for one command
```
