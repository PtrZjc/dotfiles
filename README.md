# Dotfiles Repository

This repository is my collection of configuration files for various tools. 
I also include here my set of aliases and Bash scripts which enhance my productivity.

## What Are Dotfiles?

Dotfiles are plain text configuration files on Unix-based systems for setting up a user's environment. These files traditionally begin with a dot (`.`), hence the name. They control the behavior of various programs, including but not limited to, the shell, text editors like Vim, and Git version control.

### Why Keep Dotfiles in a Repository?

1. **Version Control**: Storing dotfiles in a Git repository allows for version control, making it easier to track changes, revert to previous states, and synchronize among different systems.
   
2. **Portability**: With a dotfiles repository, setting up a new machine becomes less cumbersome. The repository can be cloned to the new system, and the configurations can be deployed easily.
   
3. **Backup**: In case of system failure or data loss, the dotfiles repository serves as a backup for important configuration settings.

4. **Sharing**: A dotfiles repository can be shared publicly, providing a way for others to learn and adopt useful configurations and scripts.

### Video introduction

For quick but detailed overview of dotfiles ideology, watch [~/.dotfiles in 100 Seconds](https://www.youtube.com/watch?v=r_MpUP6aKiQ) of amazing [Fireship](https://www.youtube.com/@Fireship) (and leave him a sub btw) 

### Further Reading

For more tutorials and large link collection, visit [dotfiles.github.io](https://dotfiles.github.io/).

## Initialization (Mac-specific)

This section is specific to macOS and may be ported to be Linux-compatible in the future. The initialization process is divided into two parts, and they need to be run separately.

### 1. Zsh Framework Installation

Run the `1-oh-my-zsh.sh` script to download and install the Zsh framework.

```bash
./1-oh-my-zsh.sh
```

### 2. Configuration and Symlinks

Run the `2-configure-rest.sh` script to set up the rest of the environment.

```bash
./2-configure-rest.sh
```

**Note**: Symlinks will be made to the dotfiles repository, allowing you to keep your configurations in sync with any updates made to this repository.
