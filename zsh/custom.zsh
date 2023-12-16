# todo
# kubectl completion zsh > ~/.oh-my-zsh/custom/kubectl_autocompletion.zsh

export REPO="${HOME}/workspace"
export DOTFILES="${REPO}/priv/dotfiles"
export CUSTOM="${DOTFILES}/zsh/custom.zsh"
export ZSHRC="${DOTFILES}/zsh/.zshrc"
export GIT="${DOTFILES}/zsh/git.zsh"
export VIMRC="${DOTFILES}/vim/.vimrc"
export BREWFILE="${DOTFILES}/brew/Brewfile"
export TEMP_FILE="/tmp/temp_file"
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

function ke-l(){
    DB_NAME="KeePass"
    DIR="${HOME}/keepass"
    LOCAL_FILE="${HOME}/keepass/$DB_NAME.kdbx"
    REMOTE_FILE="Aplikacje/KeePass/$DB_NAME.kdbx"
    mkdir -p $BACKUP_DIR_REMOTE $BACKUP_DIR_LOCAL
    LOCAL_FILE_DATE=`stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$LOCAL_FILE"`

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

function ke-p(){
    DB_NAME="KeePass"
    DIR="${HOME}/keepass"
    LOCAL_FILE="${HOME}/keepass/$DB_NAME.kdbx"
    REMOTE_FILE="Aplikacje/KeePass/$DB_NAME.kdbx"

    # Step 1: Make backup of remote database before override
    echo "Making backup of remote database before override"
    dbxcli get "$REMOTE_FILE" "$TEMP_FILE"
    REMOTE_FILE_DATE=`stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$TEMP_FILE"`
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

function line() {
    head -$1 | tail -1
}

function goto() {
    DESTINATION=$(fd -t d | fzf)
    if [ "$DESTINATION" = "" ]; then
        echo "Empty destination" && exit 1
    else
        cd "./$DESTINATION"
    fi
}

function ocr() {
    ipaste - >~/ocr_temp.jpg
    tesseract -l pol ~/ocr_temp.jpg stdout | pbcopy
    rm ~/ocr_temp.jpg
    pbpaste
}

function unescape() {
    pbpaste | sd '\\n' '' | sd '\\"' '"' | jq
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

## TEXT PROCESSING

# below functions are meant to be used with stdin input 
function ucase() {
  while read -r line; do
    print -r -- ${(U)line}
  done
}

# Function used to divide stdin into multiple files. Takes 1 argument as number of files to split into.
function split() {
  # Read stdin into a variable
  input_string=$(cat)

  # Calculate the length of the string
  length=${#input_string}

  # Number of files to split into
  num_files=$1

  # Calculate the length of each segment
  segment_length=$((length / num_files))

  # Initialize variables
  start=0
  end=$segment_length

  # Loop to create files
  for (( i=1; i<=num_files; i++ )); do
    # Extract the substring
    segment=${input_string:start:end}

    # Write to a file
    echo -n "$segment" > "split_$i.txt"

    # Update start and end for the next iteration
    start=$((start + segment_length))
    end=$((end + segment_length))
  done
}

alias extract-ids='pbpaste | rg id | sd ".*(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w+{12}).*" "\$1," | pbcopy && pbpaste'
alias wrap-with-uuid='pbpaste | sd ".*?(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}).*" "UUID(\"\$1\"), " | pbcopy && pbpaste'
1