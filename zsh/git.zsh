alias grst='git reset HEAD~1 && ga .'
alias gmm='git merge master || git merge main'
alias grm='git rebase master || git rebase main'
alias gst='git stash'
alias gl='git pull --rebase'
alias gsl='git stash list'
alias gsp='git stash pop'
alias gcl='git branch --sort=-committerdate | rg --invert-match "$(git rev-parse --abbrev-ref HEAD)" | head -1 | xargs git checkout'
alias glg='git log --oneline | head | cut -d " " -f 2- | nl | tail -r'
alias gst='git stash'
alias gsp='git stash pop'
alias gs='git status'
alias root='cd $(git rev-parse --show-toplevel)'
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

function gcr() { #checkout to remote based on input
    git branch -r --sort=-committerdate | rg "$1" | sd 'origin/' '' | head -1 | xargs git checkout
}

function og() {
    origin=$(git remote -v | rg origin | head -1)
    if [[ $origin == "fatal" ]]; then
        echo "No origin found"
        return
    fi
    host=$(echo $origin | sd '.*@(.*):.*' '$1')
    repository=$(echo $origin | sd '.*:(.*)\.git.*' '$1')

    if [[ $host == *"gitlab"* ]]; then
        starting_page="/-/merge_requests"
    else
        starting_page=""
    fi

    open "https://$host/${repository}${starting_page}"
}

alias ogh=og

unalias gcb
function gcb() {
    if [[ $1 =~ ^[0-9] ]]; then
        git checkout -b LDSI-"$1"
    else
        git checkout -b "$1"
    fi
}

unalias gc
gc() {
    jira_number=$(git branch --show-current | cut -d - -f 2)
    if [[ ! $jira_number =~ ^[0-9]+$ ]]; then
        git commit -m "$*"
    else
        git commit -m "LDSI-$jira_number $*"
    fi
}

unalias gca
function gca() {
    git commit --amend --no-edit
}

unalias ga
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
        echo "Added:"; echo "$files"
    fi
}

unalias gr
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
        echo "Reset:"; echo "$files"
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
