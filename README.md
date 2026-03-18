# Korangar rAthena

This repository packages rAthena for Nix. This includes all the settings and patches required to connect to this server with [Korangar](https://github.com/vE5li/korangar). See [`rathena.nix`](./rathena.nix) for a list of all the patches.

# Usage in `flake.nix`

Import the flake:

```nix
inputs = {
  # ...

  rathena.url = "github:ve5li/korangar-rathena";
};
```

and add the system overlay:

```nix
overlays = [ rathena.overlays.default ];

```

The flake exposes two the following packages
- `rathena`: compiled rAthena (with the patches applied) including config files and the SQL files for setting up the database
- `rathena-scripts`: `rathena-start-database` and `rathena-setup-database` scripts for automating the setup process
- `rathena-test-{PACKETVER}`: script to set up a local test insance of rAthena (including the database) with a specific packet version

### Using the packages directly

#### Test packages

The test packages are scripts to set up a temporary rAthena instance from a single command.
To create a local test rAthena server with `PACKETVER = 20220406`, you can run

```nix
nix run .#rathena-test-20220406
```

### Using the NixOS module

```nix
imports = [
  rathena.nixosModules."x86_64-linux".default
];
```
