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
    # Pinned to nixos-25.05 to match home-manager release-25.05. Newer
    # nixpkgs (nixos-unstable, 26.11) removed the `fold` builtin that
    # home-manager 25.05 still depends on.
    nixpkgs.url = "https://channels.nixos.org/nixos-25.05/nixexprs.tar.xz";
    home-manager = {
      url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
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
        # User identity goes in modules, not as direct arguments to
        # homeManagerConfiguration (the function does not accept them).
        modules = [
          ./niri
          {
            home.username = "dev";
            home.homeDirectory = "/home/dev";
            # State version is mandatory. Pin to the release we are running
            # against; do not bump on existing installs without reading the
            # release notes first.
            home.stateVersion = "25.05";
          }
        ];
      };
    };
}
