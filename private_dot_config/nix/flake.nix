{
  description = "My system configuration";
  # Command to reload:

  # darwin-rebuild switch --flake ~/.config/nix

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = {pkgs, ... }: {
        # Use touch ID when running darwin-rebuild command above:
        security.pam.enableSudoTouchIdAuth = true;

        services.nix-daemon.enable = true;
        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes repl-flake";

        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility. please read the changelog
        # before changing: `darwin-rebuild changelog`.
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        # If you're on an Intel system, replace with "x86_64-darwin"
        nixpkgs.hostPlatform = "aarch64-darwin";

        # Declare the user that will be running `nix-darwin`.
        users.users.diomedes = {
            name = "diomedes";
            home = "/Users/diomedes";
        };

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;

        environment.systemPackages = with pkgs; [
        ];
        homebrew = {
          enable = true;
          # onActivation.cleanup = "uninstall";
          taps = [];
          brews = [ "cowsay" ];
          casks = [];
        };
    };
  in
  {
    darwinConfigurations."Argos" = nix-darwin.lib.darwinSystem {
      modules = [
         configuration
      ];
    };
  };
}
