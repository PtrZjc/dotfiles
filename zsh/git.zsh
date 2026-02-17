# Dynamic path detection - works regardless of where dotfiles are cloned
if [[ -z "$DOTFILES" ]]; then
    export DOTFILES=${0:A:h:h}  # Absolute path to parent of parent of this file
fi

source "$DOTFILES/zsh/utils.zsh"

alias grst='git reset HEAD~1 && ga .'
alias gmm='git merge master || git merge main'
alias grm='git rebase master || git rebase main'
alias gst='git stash'
alias gcm='git checkout main'
alias gl='git pull --rebase'
alias gsl='git stash list'
alias gsp='git stash pop'
alias gp='git push'
alias gpf='git push --force-with-lease --force-if-includes'
alias gst='git stash'
alias gsp='git stash pop'
alias gs='git status'
alias root='cd $(git rev-parse --show-toplevel)'
alias gb='git branch --sort=committerdate'
alias gbl='git for-each-ref --sort=-committerdate --format "%(refname:short) %(committerdate:relative)" refs/heads/ | tail -r'
alias gblr='git for-each-ref --sort=-committerdate --format "%(authorname): %(refname:short) %(committerdate:relative)" refs/heads/ refs/remotes/ | tail -r'
alias gd='git diff && git diff --staged'
alias glog='git log --all --oneline --decorate --graph'
alias gcaa='ga; gca'
alias gck='git checkout'
alias gt='git for-each-ref --sort=creatordate --format "%(creatordate:iso) %(refname:short)" refs/tags/ | tail -r | head' # shows most recent tags

function bckp() {
    if [[ "$(git branch -l backup)" != "" ]]; then
        git branch -D backup
    fi
    git checkout -b backup
    git switch -
}

glg() {
    if [[ "$IS_MACOS" == "true" ]]; then
        git log --oneline | head | cut -d " " -f 2- | nl | tail -r
    else
        git log --oneline | head | cut -d " " -f 2- | nl | tac
    fi
}

function gcr() { #checkout to remote based on input
    git branch -r --sort=-committerdate | rg "$1" | sd 'origin/' '' | head -1 | xargs git checkout
}

alias gbl='git for-each-ref --sort=-committerdate --format "%(refname:short) %(committerdate:relative)" refs/heads/ | tail -r'

gcl() {
    if [[ -n $1 ]]; then
        git branch --sort=-committerdate --format='%(refname:short)' | head -$1 | fzf | xargs git checkout
    else
        git branch --sort=-committerdate | rg --invert-match "$(git rev-parse --abbrev-ref HEAD)" | head -1 | xargs git checkout
    fi
}

og () {
        origin=$(git remote -v | rg origin | head -1)
        if [[ $origin == "fatal" ]]
        then
                echo "No origin found"
                return
        fi
        
        host=$(echo $origin | sd '.*@(.*):.*' '$1')
        repository=$(echo $origin | sd '.*:(.*)\.git.*' '$1')
        
        # Get the path relative to the git root (e.g., "folder/subfolder/")
        relative_path=$(git rev-parse --show-prefix)
        
        # Check if we are in the root folder (empty relative path)
        if [[ -z "$relative_path" ]]
        then
                # --- Root Folder Logic ---
                if [[ $host == *"gitlab"* ]]
                then
                        url_suffix="/-/merge_requests"
                else
                        url_suffix=""
                fi
        else
                # --- Deep Folder Logic ---
                # Remove the trailing slash provided by rev-parse
                clean_path=$(echo $relative_path | sd '/$' '')
                
                if [[ $host == *"gitlab"* ]]
                then
                        # GitLab structure: /-/tree/branch/folder
                        url_suffix="/-/tree/main/${clean_path}"
                else
                        # GitHub/Generic structure: /tree/branch/folder
                        url_suffix="/tree/main/${clean_path}"
                fi
        fi

        open_url "https://$host/${repository}${url_suffix}"
}

alias ogh=og

function gcb() {
    if [[ $1 =~ ^[0-9] ]]; then
        git checkout -b LDSI-"$1"
    else
        git checkout -b "$1"
    fi
}

gc() {
    jira_number=$(git branch --show-current | cut -d - -f 2)
    if [[ ! $jira_number =~ ^[0-9]+$ ]]; then
        git commit -m "$*"
    else
        git commit -m "LDSI-$jira_number $*"
    fi
}

function gca() {
    git commit --amend --no-edit
}

function ga() {
    if [ "$#" -eq 0 ]; then
        git add .
    else
        # Find untracked/modified files matching pattern (case-insensitive, fixed string)
        local files=$(git ls-files --others --modified --exclude-standard | grep -F -i "$1")
        if [[ -z "$files" ]]; then
            echo "No files matching '$1'"
            return 1
        fi
        echo "$files" | xargs -I{} git add "{}"
        echo "Added:"
        echo "$files"
    fi
}

function gr() {
    if [ "$#" -eq 0 ]; then
        git reset .
    else
        # Find staged files matching pattern (case-insensitive, fixed string)
        local files=$(git diff --cached --name-only | grep -F -i "$1")
        if [[ -z "$files" ]]; then
            echo "No staged files matching '$1'"
            return 1
        fi
        echo "$files" | xargs -I{} git reset "{}"
        echo "Reset:"
        echo "$files"
    fi
}

function delete_branches() {
    gcm && git branch | xargs git branch -D
}

function opr() {
    current_branch=$(git branch --show-current)
    if [[ $current_branch == "master" ]]; then
        current_branch=$(git branch --remote --sort=-committerdate | rg --invert-match master | head -1 | sd "^\s+origin/" "")
    fi
    gh pr view -w $current_branch
}
