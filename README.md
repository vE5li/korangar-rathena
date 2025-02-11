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

### Using the packets directly

#### TODO

### Using the NixOS module

```nix
imports = [
  rathena.nixosModules."x86_64-linux".default
];
```
