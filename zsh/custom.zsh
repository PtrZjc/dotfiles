export REPO="${HOME}/workspace"
export DOTFILES="${REPO}/private/dotfiles"
export CUSTOM="${DOTFILES}/zsh/custom.zsh"
export ZSHRC="${DOTFILES}/zsh/.zshrc"
export GIT="${DOTFILES}/zsh/git.zsh"
export VIMRC="${DOTFILES}/vim/.vimrc"
export BREWFILE="${DOTFILES}/brew/Brewfile"
export SCRIPTS="${REPO}/private/my-scripts"
export EDITOR="nvim"
export TMP="/tmp/tmp"
export TMP2="/tmp/tmp2"

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
alias -g T='>$TMP && cat $TMP'
alias -g T2='>$TMP2 && cat $TMP2'
alias -g F=' $(fd --type=file | fzf)'
alias -g Trim='| cut -c 1-$COLUMNS' # $COLUMNS -> screen width
alias -g J='| bat -l json'

alias ls='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias tree='lsd --tree'
alias wake-time='pmset -g log | grep -E "Wake.*lid|lid.*Wake"'
alias sleep-time='pmset -g log | rg "(Clamshell|Software) Sleep"'

unalias l
function l() {
    if [ $# -eq 0 ]; then
        lsd --tree --depth=1
    else
        lsd --tree --depth=$1
    fi
}

alias qr='qrencode -t ansiutf8 '
alias ij="nohup /Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea . > /dev/null 2>&1 &"

function en() {
    trans :en "$*"
}

function pol() {
    trans :pl "$*"
}

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
        echo $stdin | pygmentize -P style=one-dark
    else
        echo $stdin | pygmentize -P style=one-dark -l $lang
    fi
}

function goto() {
    DEPTH=$1
    if [[ -z "$DEPTH" ]]; then
        DEPTH=99
    fi
    DESTINATION=$(fd -t d --max-depth "$DEPTH" | fzf)
    if [ "$DESTINATION" = g"" ]; then
        echo "Empty destination" && return 1
    else
        cd "./$DESTINATION"
    fi
}

function ocr() {
    cd /tmp/
    local lang=${1:-eng}
    ipaste - >/tmp/ocr.jpg || return 1
    tesseract -l "$lang" /tmp/ocr.jpg stdout | pbcopy
    pbpaste
    cd - >/dev/null
}

function killport() {
    if [[ ! ("$1" =~ ^[0-9]+$) ]]; then
        echo "impoproper port" && return 2
    fi
    lsof -i tcp:"$1" | gawk 'NR>1 {print $2}' | xargs kill -9
}

function rob() {
    local count=$1
    local command=${@:2}

    for i in $(seq 1 $count); do
        eval $command
    done
}

function fdf() {
    local extensions=""
    local max_depth=""
    local hidden=""
    local pattern="."
    local excludes="" # allow multiple

    # Parse options
    while getopts "d:p:e:h" opt; do
        case $opt in
        d) max_depth="--max-depth $OPTARG" ;;
        p) pattern="$OPTARG" ;;
        e) excludes="$excludes -E '*$OPTARG*'" ;;
        h) hidden="--no-ignore-vcs --hidden" ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check for extensions
    if [ $# -eq 0 ]; then
        echo "Error: Please provide at least one file extension"
        return 1
    fi

    # Build extensions part
    for ext in "$@"; do
        extensions+=" -e $ext"
    done

    # Build command
    local find_part="fd $excludes $hidden $extensions $max_depth $pattern"

    local exec_part="-x sh -c 'echo \"<!-- FILE: {} -->\n\\\`\\\`\\\`\"; cat {}; echo \"\\\`\\\`\\\`\n\"'"

    # Execute
    echo "Found files:"
    eval "$find_part"
    eval "$find_part $exec_part | pbcopy"
}

#from awesome-fzf
function feval() {
    echo | fzf -q "$*" --preview-window=up:99% --no-mouse --preview="eval {q}"
}
