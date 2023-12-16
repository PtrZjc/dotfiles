export REPO="${HOME}/workspace"
export OBSIDIAN="${REPO}/private/obsidian"
export DOTFILES="${REPO}/private/dotfiles"
export CUSTOM="${DOTFILES}/zsh/custom.zsh"
export ZSHRC="${DOTFILES}/zsh/.zshrc"
export GIT="${DOTFILES}/zsh/git.zsh"
export VIMRC="${DOTFILES}/vim/.vimrc"
export BREWFILE="${DOTFILES}/brew/Brewfile"
export PYTHON_SRC="${REPO}/priv/python-scripts"
export EDITOR="nvim"

alias rst="exec zsh"
alias co=tldr
alias a='alias'
alias cof='declare -f'
alias icat='imgcat'
alias ipaste='pngpaste'
alias todo='todo.sh'
alias t='tree -C -L'
alias cls='clear && printf "\e[3J"'
alias vi='nvim'
alias vim='nvim'
alias code='code .'
alias wat='which'
alias python='python3'
alias argbash='${HOME}/.local/argbash-2.10.0/bin/argbash'
alias argbash-init='${HOME}/.local/argbash-2.10.0/bin/argbash-init'
alias pip='pip3'
alias obs_sync='cd ${OBSIDIAN}; git add .; git pull && git commit -m "Sync obsidian from $(hostname)"; git push && cd -'

alias -g H='| head'
alias -g L='| less'
alias -g JL='| jq -C | less'
alias -g T='| tail'
alias -g C='| cat'
alias -g O='| xargs -I _ open _'
alias -g DF='-u | diff-so-fancy' # use as: diff file1 file2 DF
alias ls='ls -lahgG'
alias l='tree -C -L 1'
alias qr='qrencode -t ansiutf8 '
alias ij="nohup /Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea . > /dev/null 2>&1 &"

function initialize_zsh_symlinks() {
    fd . -I "$DOTFILES/zsh" -x sh -c '[ ! -L "$ZSH/custom/{/.}.zsh" ] && ln -s {} "$ZSH/custom/{/.}.zsh"'
}

function ke-l() {
    DB_NAME="KeePass"
    DIR="${HOME}/keepass"
    LOCAL_FILE="${HOME}/keepass/$DB_NAME.kdbx"
    REMOTE_FILE="Aplikacje/KeePass/$DB_NAME.kdbx"
    mkdir -p $BACKUP_DIR_REMOTE $BACKUP_DIR_LOCAL
    LOCAL_FILE_DATE=$(stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$LOCAL_FILE")

    LOCAL_BACKUP="$DIR/$DB_NAME"_local_"$LOCAL_FILE_DATE.kdbx"
    cp "$LOCAL_FILE" "$LOCAL_BACKUP"

    echo "Downloading and overriding local database"
    dbxcli get "$REMOTE_FILE" "$LOCAL_FILE"

    if cmp -s "$LOCAL_FILE" "$LOCAL_BACKUP"; then
        rm "$LOCAL_BACKUP"
    else
        echo "Difference with remote - Local backup kept in $LOCAL_BACKUP"
    fi
}

function ke-p() {
    DB_NAME="KeePass"
    DIR="${HOME}/keepass"
    LOCAL_FILE="${HOME}/keepass/$DB_NAME.kdbx"
    REMOTE_FILE="Aplikacje/KeePass/$DB_NAME.kdbx"

    # Step 1: Make backup of remote database before override
    echo "Making backup of remote database before override"
    dbxcli get "$REMOTE_FILE" "$TEMP_FILE"
    REMOTE_FILE_DATE=$(stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$TEMP_FILE")
    REMOTE_BACKUP="$DIR/$DB_NAME"_remote_"$REMOTE_FILE_DATE.kdbx"
    mv "$TEMP_FILE" "$REMOTE_BACKUP"

    if cmp -s "$LOCAL_FILE" "$REMOTE_BACKUP"; then
        rm "$REMOTE_BACKUP"
    else
        echo "Difference with remote - Remote backup kept in $REMOTE_BACKUP"
    fi
    echo "Uploading local database"
    # Step 2: Upload the local file, overriding the remote database
    dbxcli put "$LOCAL_FILE" $REMOTE_FILE
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
    echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}
