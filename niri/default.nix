# Home Manager module for quhongbin's niri window manager configuration.
#
# Installs the niri compositor and the helper tools the config binds assume.
# It does NOT touch ~/.config/niri/ — that's owned by the repo, linked in
# via install.sh (which creates symlinks so repo and live config are the
# same files on disk).
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
  };
}
