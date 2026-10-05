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

let
  # On non-NixOS hosts, nix GUI apps cannot load GL: nix's libglvnd dlopens
  # mesa's vendor libs (libEGL_mesa/libGLX_mesa) by soname, but they are
  # neither in kitty's closure nor reachable through the host's /usr/lib
  # (the nix loader never searches it). On NixOS /run/opengl-driver covers
  # this; here we inject the nixpkgs mesa into LD_LIBRARY_PATH instead.
  # Mesa MUST come from the same nixpkgs revision as kitty, otherwise its
  # libgallium requires a newer glibc than kitty ships and crashes.
  kitty-fixed = pkgs.symlinkJoin {
    name = "kitty";
    paths = [ pkgs.kitty ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/kitty \
        --prefix LD_LIBRARY_PATH : ${pkgs.mesa}/lib
      wrapProgram $out/bin/kitten \
        --prefix LD_LIBRARY_PATH : ${pkgs.mesa}/lib
    '';
  };
in

{
  # Install niri and the helper packages the binds assume.
  # home-manager itself must be here: `home-manager switch` replaces
  # ~/.nix-profile wholesale, so without it the CLI disappears after
  # the first switch on a non-NixOS host.
  home.packages = [
    pkgs.home-manager
    pkgs.niri
  ] ++ (with pkgs; [
    kitty-fixed
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
