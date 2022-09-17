# Configurations

Welcome to `Git.StepBroBD.com`!

## Server name

In `config.yaml`, use `name` to specify server display name.

```yaml
name: Git.StepBroBD.com
```

## Domain name and port

In `config.yaml`, use `host` and `port` to specify server domain name and port.

Remember to setup A record and AAAA record!

```yaml
host: Git.StepBroBD.com
port: 22
```

## Access control

In `config.yaml`, use `anon-access` to specify user access control for users didn't use a SSH Key to login to this server.

```yaml
# Options: admin-access, read-write, read-only, and no-access.
anon-access: no-access
```

In `config.yaml`, use `allow-keyless` to specify user access control for users use a SSH Key pair without password protection.

```yaml
# Options: true, false
allow-keyless: false
```

In `config.yaml`, use `users` to specify user names, roles and SSH Keys.

```yaml
users:
  - name: Beatrice
    admin: true
    public-keys:
      - ssh-rsa AAAAB3Nz... # redacted
      - ssh-ed25519 AAAA... # redacted

  - name: Frankie
    collab-repos:
      - my-public-repo
      - my-private-repo
    public-keys:
      - ssh-rsa AAAAB3Nz... # redacted
      - ssh-ed25519 AAAA... # redacted
```

## Repository

In `config.yaml`, use `repos` to specify repos names, folder name, description and access control.

```yaml
repos:
  - name: Home
    repo: config
    private: true
    note: "Configuration and content repo for this server"

  - name: Example Public Repo
    repo: my-public-repo
    private: false
    note: "A publicly-accessible repo"
    readme: docs/README.md

  - name: Example Private Repo
    repo: my-private-repo
    private: true
    note: "A private repo"
```
