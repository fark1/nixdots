{ config, pkgs, lib, ... }:

{
  imports = [
    ./browser.nix
  ];

  home.username = "fark";
  home.homeDirectory = "/home/fark";
  home.stateVersion = "26.05";

  # Cursor theme for every app - labwc's own environment file (common/labwc)
  # already sets XCURSOR_THEME/XCURSOR_SIZE for Wayland/XWayland clients;
  # this covers GTK apps' internal cursor-theme setting plus the
  # ~/.icons/default symlink some non-Wayland-aware tools still look for.
  home.pointerCursor = {
    package = pkgs.phinger-cursors;
    name = "phinger-cursors-dark";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    quickshell
    mpv
    thunar
    stow
    swaybg
    foot
    fuzzel
    grim
    slurp
    wl-clipboard
    pulseaudio
    pavucontrol
    wlr-randr
    vscode
  ];

  # Applies dots-common/ from the dotfiles repo via stow on every activation.
  # Assumes the repo is cloned to ~/.config/dots (same path on every machine).
  # zsh targets $HOME directly since that's where .zshrc/.zshenv are read from;
  # everything else targets $HOME/.config to match how each app already expects
  # its config to be laid out.
  #
  # flock-guarded: home-manager's NixOS module integration can invoke this
  # activation script through more than one path during a single switch
  # (systemd unit + direct switch-to-configuration call - see
  # nix-community/home-manager#2191), and two concurrent `stow --restow`
  # runs racing on the same symlinks produces spurious "not owned by stow"
  # conflicts even when the end state would've been correct. home-manager's
  # own docs require activation entries to be idempotent under repeat runs;
  # flock serializes the two invocations instead of letting them race.
  home.activation.stowDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DOTS="$HOME/.config/dots/dots-common"
    if [ -d "$DOTS" ]; then
      (
        ${pkgs.util-linux}/bin/flock -w 30 9
        ${pkgs.stow}/bin/stow -d "$DOTS" -t "$HOME/.config" --restow \
          foot alacritty Thunar labwc mpv quickshell
        ${pkgs.stow}/bin/stow -d "$DOTS" -t "$HOME" --restow zsh
        mkdir -p "$HOME/.local/share/themes"
        ${pkgs.stow}/bin/stow -d "$DOTS" -t "$HOME/.local/share/themes" --restow themes
      ) 9>"''${XDG_RUNTIME_DIR:-/tmp}/dots-stow.lock"
    fi
  '';

  programs.home-manager.enable = true;
}
