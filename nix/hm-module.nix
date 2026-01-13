flake: { config, lib, pkgs, ... }:

let
  cfg = config.programs.git-worktree-manager;
in
{
  options.programs.git-worktree-manager = {
    enable = lib.mkEnableOption "git worktree manager";
    settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          projectsDirectory = lib.mkOption {
            type = lib.types.str;
            example = "/home/alice/projects/";
            description = "The path to the projects directory.";
          };
          worktreesDirectory = lib.mkOption {
            type = lib.types.str;
            example = "/home/alice/projects/worktrees/";
            description = "The path to the worktrees directory.";
          };
        };
      };
      default = { };
      description = "Settings of the git worktree manager application.";
    };
    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };
    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        wrapped = pkgs.writeShellApplication {
          name = "git-worktree-manager";
          runtimeInputs = [ flake.packages.${pkgs.system}.default ];
          runtimeEnv = {
            GWM_PROJECTS_DIR = cfg.settings.projectsDirectory;
            GWM_WORKTREES_DIR = cfg.settings.worktreesDirectory;
          };
          text = ''exec git-worktree-manager "$@"'';
        };
      in
      [ wrapped ];

    programs =
      let
        shellFunctions = /*sh*/ ''
          gwj() {
            local dir
            dir="$(git-worktree-manager find "$@")" || return
            [ -n "$dir" ] && cd "$dir"
          }
        '';
        shellAliases = {
          gwi = ''git-worktree-manager init "$@"'';
          gwo = ''git-worktree-manager open "$@"'';
          gwa = ''git-worktree-manager activate "$@"'';
          gwrm = ''git-worktree-manager remove "$@"'';
          gwls = "git-worktree-manager list";
        };
      in
      {
        bash = lib.mkIf cfg.enableBashIntegration {
          initExtra = shellFunctions;
          shellAliases = shellAliases;
        };

        zsh = lib.mkIf cfg.enableZshIntegration {
          initContent = shellFunctions;
          shellAliases = shellAliases;
        };
      };
  };
}
