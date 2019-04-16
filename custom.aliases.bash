alias cdd='cd /Users/Frantisek/Downloads'
alias ll='ls -AFGhl'

alias gf='git flow'
alias gff='git checkout develop && git pull && git-flow feature start'
alias gp='git push origin HEAD'
alias gl='git log --graph --pretty="format:%C(yellow)%h%Cblue%d%Creset %s %C(white)"'
# delete all banches except master 
alias gd='git branch | grep -v "master" | xargs git branch -D'


# better history https://github.com/hanslub42/rlwrap
alias lein="rlwrap lein"

# simple python server, default port is 8000
alias pserver="python -m SimpleHTTPServer"

# returns my default IP addressss
alias myIp="ifconfig en0 inet | awk '/inet/{print \$2}'"

# docker psql
alias psql='docker run -it --rm --network="host" matteofigus/docker-sqitch psql "$@"'

# haskell
alias runhaskell='stack runhaskell'
alias ghc='stack exec ghc --'
alias ghci='stack exec ghci --'
