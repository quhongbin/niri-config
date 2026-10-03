# Home Manager module for quhongbin's niri window manager configuration.
#
# Installs the niri compositor and the helper tools the config binds assume.
# It does NOT touch ~/.config/niri/ — that's owned by the repo, linked in
# via install.sh (which creates symlinks so repo and live config are the
# same files on disk).
#
# Note: we deliberately do NOT use `wayland.windowManager.niri` from
# home-manager. That module manages ~/.config/niri/config.kdl itself, which
# would clobber the symlink install.sh creates. If you want to migrate to
# home-manager's declarative settings, remove this comment, switch to
# `wayland.windowManager.niri.enable = true` + `settings = { ... }`, and
# delete install.sh.

{ pkgs, lib, ... }:

{
  # Install niri and the helper packages the binds assume.
  home.packages = [
    pkgs.niri
  ] ++ (with pkgs; [
    kitty
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
  ]);

  # Wayland session entry so login managers (gdm, greetd, tuigreet, ...)
  # can start a niri session. Harmless on setups that launch niri another
  # way (TTY, dwl-style, etc.).
  xdg.desktopEntries.niri = {
    name = "niri";
    genericName = "Wayland Session";
    comment = "Scrollable-tiling Wayland compositor";
    exec = "niri-session";
    type = "Application";
  };

  # XDG Desktop Portal — required for screen sharing, file pickers, etc.
  # niri's portal config prefers gnome + gtk portals.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  # niri ships systemd user units (used by `niri-session`). On NixOS this
  # would go under `systemd.user.packages`; on a foreign distro (Arch)
  # niri-session already invokes the relevant units without help.
}
