# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]]; then
  # Disable instant prompt for JetBrains IDE terminal to avoid issues with agent mode
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  ZSH_THEME="powerlevel10k/powerlevel10k"
fi

###################################
### common config for agent mode and normal mode
###################################

export ZSH="$HOME/.oh-my-zsh"

# pressing del does not close shell with empty prompt
setopt IGNORE_EOF

# other configuration
export PATH="$HOME/.local/bin:$PATH"

# Lazy-load Sdkman (call 'sdk-init' when needed)
sdk-init() {
  if [ -s "$(brew --prefix sdkman-cli)/libexec/bin/sdkman-init.sh" ]; then
      export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"
      [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  fi

}
# Auto-initialize sdkman on first use of 'sdk' command
sdk() {
  unfunction sdk &>/dev/null
  sdk-init
  sdk "$@"
}

###################################
### Intellij Agent Mode config (sterile, no colors, no prompts, low latency)
###################################

if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]]; then
  plugins=(
    git
  )

  source $ZSH/oh-my-zsh.sh
  # 1. Minimalist Prompt for easy parsing
  PROMPT='[%~] $ '
  RPROMPT=''
  
  # 2. Terminal Capabilities (Disable colors and rich formatting)
  export TERM=xterm
  export CLICOLOR=0
  unset LS_COLORS

  # 3. Disable ZSH Interactive Features (prevent blocking/asking)
  unsetopt CORRECT
  unsetopt CORRECT_ALL 
  unsetopt SHARE_HISTORY 
  unsetopt PROMPT_SP 
  unsetopt FLOW_CONTROL 
  unsetopt BEEP

  # 4. Safe Alias Overrides (Force coreutils, disable lsd/icons)
  alias ls='ls --color=never'
  alias ll='ls -l --color=never'
  alias la='ls -a --color=never'
  alias grep='grep --color=never'

  sdk-init
  return
fi

###################################
### normal mode config
###################################

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(
	git
	zsh-fzf-history-search
	zsh-autosuggestions
  fzf
  fzf-tab
  F-Sy-H
  # docker  # Lazy-loaded below
  # kubectl # Lazy-loaded below
  # aws     # Lazy-loaded below
  github
)

source $ZSH/oh-my-zsh.sh

zstyle ':completion:*' menu select

# autoload -Uz bracketed-paste-magic
# zle -N bracketed-paste bracketed-paste-magic

# autoload -Uz url-quote-magic
# zle -N self-insert url-quote-magic

# to make psql work with libpq
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

#bash completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# below keybinding originally pastes "ls\n"
bindkey "^[l" down-case-word

# Lazy-load NVM (call 'nvm-init' when needed, or use node/npm/npx directly)
nvm-init() {
    if [[ -z "$NVM_DIR" ]]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
        [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
    fi
}
# Auto-initialize nvm commands as functions that load nvm on first use
for cmd in nvm node npm npx; do
    eval "$cmd() { unfunction $cmd &>/dev/null; nvm-init; $cmd \"\$@\"; }"
done

# Lazy-load kubectl, docker, aws completions
kubectl() {
    unfunction kubectl
    source $ZSH/plugins/kubectl/kubectl.plugin.zsh
    kubectl "$@"
}
docker() {
    unfunction docker
    source $ZSH/plugins/docker/docker.plugin.zsh
    docker "$@"
}
aws() {
    unfunction aws
    source $ZSH/plugins/aws/aws.plugin.zsh
    aws "$@"
}

# Make man pages search case insensitive
export LESS="-i -R"

# Configure podman - required podman-mac-helper installed to work
export DOCKER_HOST='unix:///var/run/docker.sock'

# Load AWS profile from saved file if it exists
if [[ -f "$HOME/.aws/aws_profile" ]]; then
    export AWS_PROFILE=$(cat "$HOME/.aws/aws_profile")
fi

# Swap right command and option keys (source: https://rakhesh.com/mac/using-hidutil-to-map-macos-keyboard-keys/)
launchctl start local.hidutilKeyMapping

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"

# enable zoxide
eval "$(zoxide init zsh)"