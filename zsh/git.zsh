
alias grst='git reset HEAD~1 && ga .'
alias gmm='git merge master'
alias gst='git stash'
alias gsl='git stash list'
alias gsp='git stash pop'
alias gcl='git branch --sort=-committerdate | head -1 | xargs git checkout'
alias glg'=git log --oneline | head | nl | tac'
alias gca='git commit -a  --amend --no-edit'
alias gst='git stash'
alias gsp='git stash pop'
alias gs='git status'

function bckp(){
    git branch -D backup | git checkout -b backup && git switch -
}

function gcr(){ #checkout to remote based on input
   git branch -r | cat | grep "$1" | sed 's/origin\///' | xargs git checkout
}

## Extensions related with allegro repos

function gcb(){
    git checkout -b HUBZ-"$1"
}

function gc(){
    git branch --show-current | awk -F- '{print "HUBZ-"$2" | "}' | xargs -I{}  git commit -m '{} '$1''
}

function delete_branches(){
    gcm && git branch | xargs git branch -D
}

function wiremock(){
    cd /Users/piotr.zajac/workspace/hub-mocks && sh launch-wiremock.sh
}


## Below functions are copied from https://tighten.com/blog/open-github-pull-request-from-terminal/#:~:text=First%2C%20you%20have%20to%20push,your%20PR%20and%20share%20it.

# Open the Pull Request URL for your current directory's branch (base branch defaults to main)
function opr() {
  github_url=`git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#https://#' -e 's@com:@com/@' -e 's%\.git$%%' | awk '/github/'`;
  branch_name=`git symbolic-ref HEAD | cut -d"/" -f 3,4`;
  pr_url=$github_url"/compare/master..."$branch_name
  open $pr_url;
}
 
# Run git push and then immediately open the Pull Request URL
function gpr() {
  git push origin HEAD
 
  if [ $? -eq 0 ]; then
    opr
  else
    echo 'failed to push commits and open a pull request.';
  fi
}