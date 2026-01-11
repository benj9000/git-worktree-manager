{
  description = "git worktree manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      homeManagerModules.default = import ./nix/hm-module.nix self;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        applicationName = "git-worktree-manager";
        dependencies = with pkgs; [ git fzf gawk gnugrep ];
        package = pkgs.writeShellApplication {
          name = applicationName;
          runtimeInputs = dependencies;
          text = builtins.readFile ./src/git-worktree-manager;
        };
      in
      {
        packages = rec {
          default = git-worktree-manager;
          git-worktree-manager = package;
        };

        apps = rec {
          default = git-worktree-manager;
          git-worktree-manager = flake-utils.lib.mkApp {
            drv = package;
            exePath = "/bin/${applicationName}";
          };
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = dependencies;
          shellHook = /*sh*/ ''
            export PATH="$PWD/src:$PATH";
          '';
        };
      }
    );
}
