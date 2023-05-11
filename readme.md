# Welcome!

This server is an instance of [Soft Serve](https://github.com/charmbracelet/soft-serve) developed by [Charm](https://charm.sh) deployed on [Fly.io](https://fly.io) manged by [StepBroBD](https://github.com/stepbrobd).

## Access

Access are only given to people I know IRL, they probably already know how to contact me.

If you really want to try it out, take a look at this instance, or `ssh git.charm.sh`.

## Deployment

- You'll need an [Fly.io](https://fly.io) account.
- If you want to automate the update process, you'll need a GitHub account for GitHub Action (or other CI services).
- Have some experience with Git/TOML/TAML.
- Soda/Coffee/Tea,

1. Fork this repo (or clone then remove `.git` folder, then `git init`).
2. `fly launch`.
3. Change `fly.toml`, make sure app name and all the environment variables are properly setup, documentation available [here](https://github.com/charmbracelet/soft-serve).
4. Create a volume: `fly volumes create <volume name> -s <volume size> -r <volume region>`.
5. Create IP address(es): `fly ips allocate-[v4|v6]`.
6. Add created IP address(es) to your DNS provider.
7. Add certificate: `fly certs add <FQDN>`.
8. Deploy your first version: `fly deploy`.

If you are lazy, stop right here, have a good day.

[Fly.io](https://fly.io) is deprecating NoMad platform, the following steps will tell you how to switch from Fly.io App Platform v1 to v2.

1. Save your `fly.toml`, run: `fly migrate-to-v2`.
2. Above step should switch v1 to v2, but it will also create an additional volume.
3. List volumes with `fly volumes list`, remove all volumes.
4. List all machines with `fly machines list`, destroy all machines.
5. Recreate a volume, then re-deploy the app.

## License

This repository content excluding all submodules is licensed under the [MIT License](license.md), third-party code are subject to their original license.
