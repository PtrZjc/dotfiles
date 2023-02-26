alias grst='git reset HEAD~1 && ga .'
alias gmm='git merge master'
alias gst='git stash'
alias gsl='git stash list'
alias gsp='git stash pop'
alias gcl='git branch --sort=-committerdate | rg --invert-match "$(git rev-parse --abbrev-ref HEAD)" | head -1 | xargs git checkout'
alias glg='git log --oneline | head | cut -d " " -f 2- | nl | tail -r'
alias gst='git stash'
alias gsp='git stash pop'
  alias gs='git status'

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

function ogh() {
  git remote -v | head -1 | sd '.*:(.*)\.git.*' '$1' | xargs -I {} open "https://github.com/{}/pulls"
}

## Extensions related with allegro repos

unalias gcb
function gcb() {
  git checkout -b HUBZ-"$1"
}

unalias gc
function gc() {
  ./gradlew lintKotlin \
  && git branch --show-current | cut -d - -f 2 | xargs -I {} git commit -m "HUBZ-{} | $1" \
  || ./gradlew formatKotlin
}

unalias gca
function gca() {
  ./gradlew formatKotlin \
  && git commit -a --amend --no-edit
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
