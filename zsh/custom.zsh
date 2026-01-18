# Dynamic path detection - works regardless of where dotfiles are cloned
if [[ -z "$DOTFILES" ]]; then
    export DOTFILES=${0:A:h:h}  # Absolute path to parent of parent of this file
fi

# Cross-platform clipboard abstraction (macOS + Linux)
function clip_copy() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pbcopy
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard
    elif command -v wl-copy &>/dev/null; then
        wl-copy
    else
        cat >/dev/null
    fi
}

function clip_paste() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pbpaste
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard -o
    elif command -v wl-paste &>/dev/null; then
        wl-paste
    fi
}

export REPO="${DOTFILES:h:h}"   # Two levels up from DOTFILES
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
alias k="kubectl"
alias less="moor"
alias p="clip_paste"
alias qr='qrencode -t ansiutf8 '
alias ij="nohup /Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea . > /dev/null 2>&1 &"
alias -g H='| head'
alias -g T='>$TMP && cat $TMP'
alias -g T2='>$TMP2 && cat $TMP2'
alias -g F=' $(fd --type=file | fzf)'
alias -g J='| jless'
alias -g C='| clip_copy'
alias -g L='| moor'

alias ls='eza -l'
alias la='eza -a'
alias lla='eza -la'
alias tree='eza --tree --icons=always'
alias wake-time='pmset -g log | grep -E "Wake.*lid|lid.*Wake"'
alias sleep-time='pmset -g log | rg "(Clamshell|Software) Sleep"'

# open files based on extension
alias -s sh='sh'
alias -s properties='$EDITOR'

unalias l
function l() {
    if [ $# -eq 0 ]; then
        eza --tree --level=1
    else
        eza --tree --level=$1
    fi
}

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
    tesseract -l "$lang" /tmp/ocr.jpg stdout | clip_copy
    clip_paste
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
    local extensions=()
    local max_depth_args=()
    local hidden_args=()
    local pattern="."
    local exclude_args=()

    # Parse options
    while getopts "d:p:e:h" opt; do
        case $opt in
        d) max_depth_args=(--max-depth "$OPTARG") ;;
        p) pattern="$OPTARG" ;;
        e) exclude_args+=(-E "*$OPTARG*") ;;
        h) hidden_args=(--no-ignore-vcs --hidden) ;;
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

    # Build extensions array
    for ext in "$@"; do
        extensions+=(-e "$ext")
    done

    # Build and execute the find command
    echo "Found files:"
    fd "${exclude_args[@]}" "${hidden_args[@]}" "${extensions[@]}" "${max_depth_args[@]}" "$pattern"

    # Execute with file processing and copy to clipboard
    fd "${exclude_args[@]}" "${hidden_args[@]}" "${extensions[@]}" "${max_depth_args[@]}" "$pattern" \
        -x sh -c 'echo "<!-- FILE: $1 -->\n\`\`\`"; cat "$1"; echo "\`\`\`\n"' _ {} | clip_copy
}

pyv() {
    local venv_dir=".venv"

    if [[ ! -d "$venv_dir" ]]; then
        echo "[*] Brak $venv_dir. Tworzenie nowego środowiska..."
        python3 -m venv "$venv_dir"
    fi

    if [[ -f "$venv_dir/bin/activate" ]]; then
        source "$venv_dir/bin/activate"
        echo "[+] Środowisko aktywowane."
    else
        echo "[!] Błąd: Nie udało się zlokalizować skryptu aktywacyjnego."
        return 1
    fi
}

yt-get-channel-id() {
    YT_CHANNEL_URL=$1
    CHANNEL_ID=$(curl -sL "$YT_CHANNEL_URL" -H "Cookie: SOCS=CAISAiAD" | rg -F 'youtube.com/channel' | head -1 | sd '.*channel/([1-9A-Za-z_-]+).*' '$1')
    # The SOCS=CAISAiAD cookie tells YouTube you've accepted the consent prompt and redirects accordingly from 302.
    echo "$CHANNEL_ID"
}

#from awesome-fzf
function feval() {
    echo | fzf -q "$*" --preview-window=up:99% --no-mouse --preview="eval {q}"
}
