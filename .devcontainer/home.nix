{ pkgs, lib, config, ... }:
{
  # Allow unfree packages (needed for claude-code)
  nixpkgs.config.allowUnfree = true;

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Core tools available everywhere
  home.packages = with pkgs; [
    helix
    ripgrep
    jujutsu
    gh
    claude-code
  ];

  # preserve claude authentication and history (possibly redundant with devcontainer volume mount)
  home.activation.preserveClaude = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.claude
  '';

  # direnv with nix-direnv for fast flake loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable bash so home-manager can add direnv hook
  programs.bash = {
    enable = true;

    # initExtra is added to .bashrc for interactive shells
    initExtra = ''
      # Source session vars for non-login shells
      if [[ ! -v __HM_SESS_VARS_SOURCED ]]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi
    '';
  };

  # don't use, unsets the USER from poststart.sh
  # programs.jujutsu = {
  #   enable = true;
  #   settings = {
  #     ui.editor = "hx";
  #   };
  # };

  # Set globally
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "code";
    CHEAT_CONFIG_PATH = toString ./cheat/conf.yml;
  };

  home.stateVersion = "24.05";
  home.username = "root";  # Since you're running as root in the container
  home.homeDirectory = "/root";
}