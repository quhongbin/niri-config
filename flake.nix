# quhongbin's niri window manager configuration.
#
# Apply with:
#   home-manager switch --flake .#quhongbin
#
# Or, from a fresh checkout on a non-NixOS host:
#   nix run home-manager -- switch --flake .#quhongbin
#
# See README.md for the full setup including how to enable flakes.

{
  description = "quhongbin's niri Wayland compositor configuration, packaged with home-manager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      homeConfigurations.quhongbin = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Username on the target system. Used to compute home-manager's home
        # directory. Change if your $USER is not quhongbin on that machine.
        username = "dev";
        homeDirectory = "/home/dev";
        # Modules are imported from ./niri (its default.nix is the entry point).
        modules = [ ./niri ];
      };
    };
}
