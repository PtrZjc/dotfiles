export REPO="${HOME}/workspace"
export DOTFILES="${REPO}/private/dotfiles"
export CUSTOM="${DOTFILES}/zsh/custom.zsh"
export ZSHRC="${DOTFILES}/zsh/.zshrc"
export GIT="${DOTFILES}/zsh/git.zsh"
export VIMRC="${DOTFILES}/vim/.vimrc"
export BREWFILE="${DOTFILES}/brew/Brewfile"
export PYTHON_SRC="${REPO}/priv/python-scripts"
export EDITOR="nvim"
export TEMP_FILE="/tmp/x"

alias rst="exec zsh"
alias co=tldr
alias cat=bat
alias a='alias'
alias cof='declare -f'
alias icat='wezterm imgcat'
alias ipaste='pngpaste'
alias todo='todo.sh'
alias cls='clear && printf "\e[3J"'
alias vi='nvim'
alias vim='nvim'
alias code='code .'
alias python='python3'
alias argbash='${HOME}/.local/argbash-2.10.0/bin/argbash'
alias argbash-init='${HOME}/.local/argbash-2.10.0/bin/argbash-init'
alias pip='pip3'
alias cop='gh copilot suggest'
alias cope='gh copilot explain'

alias -g H='| head'
alias -g T='>/tmp/x && cat /tmp/x'
alias -g F=' $(fd --type=file | fzf)'

alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias tree='lt'

alias qr='qrencode -t ansiutf8 '
alias ij="nohup /Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea . > /dev/null 2>&1 &"

function initialize_zsh_symlinks() {
    fd . -I "$DOTFILES/zsh" -x sh -c '[ ! -L "$ZSH/custom/{/.}.zsh" ] && ln -s {} "$ZSH/custom/{/.}.zsh"'
}

function wat() {
    which $1 | pygmentize -P style=one-dark
}

function color() {
    lang=$1
    stdin=$(cat)
    # check if stdin is empty
    if [[ -z "$lang" ]]; then
        echo $stdin | pygmentize -P style=one-dark;
    else
        echo $stdin | pygmentize -P style=one-dark -l $lang
    fi
}

function goto() {
    DESTINATION=$(fd -t d | fzf)
    if [ "$DESTINATION" = "" ]; then
        echo "Empty destination" && return 1
    else
        cd "./$DESTINATION"
    fi
}

function ocr() {
    local lang=${1:-eng}
    ipaste - >/tmp/ocr.jpg || return 1
    tesseract -l "$lang" /tmp/ocr.jpg stdout | pbcopy
    pbpaste
}

function killport() {
    if [[ ! ("$1" =~ ^[0-9]+$) ]]; then
        echo "impoproper port" && return 2
    fi
    lsof -i tcp:"$1" | gawk 'NR>1 {print $2}' | xargs kill -9
}

#from awesome-fzf
function feval() {
    echo | fzf -q "$*" --preview-window=up:99% --no-mouse --preview="eval {q}"
}
