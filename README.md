# git worktree manager

A small CLI tool for handling Git wortrees, with **interactive selection** and **customizable hooks**.

Originally inspired by <https://oppi.li/posts/curing_a_case_of_git-UX/>.

## Requirements

- A POSIX-compliant shell,
- [Git](https://git-scm.com/), of course, and
- [fzf](https://junegunn.github.io/fzf/).

## Installation

### Nix

The project contains a Nix flake, which provides packages, apps and a [Home Manager](https://github.com/nix-community/home-manager) module.


### Else

The actual application is just a shell script, such that it can be
  - downloaded,
  - made executable, and
  - put into the `PATH`.

For example,
```sh
curl -o git-worktree-manager https://raw.githubusercontent.com/benj9000/git-worktree-manager/refs/heads/main/src/git-worktree-manager
chmod +x git-worktree-manager
mv git-worktree-manager ~/.local/bin/ # For example.
```

## Configuration

The application requires the following environment variables to be set:

- `GWM_PROJECTS_DIR` - The directory containing the original Git repositories.
- `GWM_WORKTREES_DIR` - The directory where worktrees will be created.

For long-term use, you will probably want to set them in your shell configuration (`.bashrc`, `.zshrc`, etc.):

```sh
export GWM_PROJECTS_DIR="$HOME/projects"
export GWM_WORKTREES_DIR="$HOME/projects/worktrees"
```

## Usage

### Commands


| Command | Description |
|---------|-------------|
| `init <branch>` | Initialize a new worktree for the specified branch and trigger the "init" hook. |
| `open <worktree>` | Open the specified worktree (triggers the "open" hook). |
| `activate <worktree>` | Activate the specified worktree (triggers the "activate" hook). |
| `remove <worktree>` | Remove the specified worktree. |
| `find <query>` | Find a worktree and return its path. |
| `prune` | Prune stale worktree information. |
| `list` | List all worktrees. |

The command's arguments are optional and are used as initial queries for and selection.

### Hooks

Hooks allow to automate actions when certain events occur.
Some commands exist soley to run a hook.
They are assumed to be executable shell scripts placed in the repository-specific worktrees directory (`$GWM_WORKTREES_DIR/<repository>/`).

#### Available Hooks

| Hook | Filename | Description |
|------|----------|-------------|
| **init** | `init.sh` | Runs when initializing a new worktree. Usually sets up the worktree for further usage. |
| **open** | `open.sh` | Runs when opening a worktree. Usually opens the editor/IDE with the specified worktree. |
| **activate** | `activate.sh` | Runs when activating a worktree. Usually performs actions like spinning up containers. |


### Shell Integration

The Nix Home Manager module, `hm-module.nix`, includes an option for shell integration, that provides functions and aliases.
If you do not use Home Manager, you can be inspired and convert them for your shell configuration (`.bashrc`, `.zshrc`, etc.).

## How It Works

git worktree manager maintains a clean separation between your main projects and their worktrees:

```
~/projects/               # Your main repositories ($GWM_PROJECTS_DIR).
  └── myrepo/
      └── main branch files

~/worktrees/              # Managed worktrees ($GWM_WORKTREES_DIR).
  └── myrepo/             # Repository-specific directory.
      ├── init.sh         # Hooks (optional).
      ├── open.sh
      ├── activate.sh
      ├── feature-a/      # Worktree for feature-a branch.
      ├── feature-b/      # Worktree for feature-b branch.
      └── bugfix-123/     # Worktree for bugfix-123 branch.
```
