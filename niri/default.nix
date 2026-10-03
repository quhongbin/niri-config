# Home Manager module for quhongbin's niri window manager configuration.
#
# Installs the niri compositor, the helper tools the config binds assume,
# and syncs this repo's KDL files into ~/.config/niri via xdg.configFile.
#
# Toggle everything in this module by enabling programs.niri in the host
# configuration, e.g.:
#
#   { programs.niri.enable = true; }

{ config, pkgs, lib, ... }:

let
  cfg = config.programs.niri;
in
{
  # Reuse home-manager's existing programs.niri option rather than shadowing
  # it — it already carries `enable` and `package` of the right shape.
  config = lib.mkIf cfg.enable {
    programs.niri = {
      # Use niri from nixpkgs. Override by setting `programs.niri.package`
      # in your host config.
      package = lib.mkDefault pkgs.niri;
    };

    # Wayland session entry so login managers (gdm, greetd, tuigreet, ...)
    # can start a niri session. Harmless on setups that launch niri another
    # way (TTY, dwl-style, etc.).
    xdg.sessionFile."niri".desktopEntry = {
      exec = "niri-session";
      desktopName = "niri";
      comment = "Scrollable-tiling Wayland compositor";
      genericName = "Wayland Session";
    };

    # Packages the niri binds / spawn-at-startup assume exist. Add more here
    # if you bind to them in config.kdl.
    home.packages = with pkgs; [
      alacritty
      fuzzel
      waybar
      swaylock
      swayidle
      brightnessctl
      playerctl
      wireplumber
      pipewire
      grim
      slurp
      wl-clipboard
    ];

    # Only config.kdl is managed here. The dms/ fragments in this repo are
    # reference snapshots — DankMaterialShell writes its own copies to
    # ~/.config/niri/dms/ at runtime, so we deliberately don't own them via
    # home-manager (otherwise home-manager and DMS would clobber each other
    # on every switch).
    xdg.configFile."niri/config.kdl".source = ./config.kdl;
  };
}
