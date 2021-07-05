alias cdd='cd /Users/Frantisek/Downloads'
alias ll='ls -AFGhl'

alias gf='git flow'
alias gff='git checkout develop && git pull && git-flow feature start'
alias gp='git push origin HEAD'
alias gl='git log --graph --pretty="format:%C(yellow)%h%Cblue%d%Creset %s %C(white)"'
# delete all banches except master 
alias gdd='git branch | grep -v "master" | xargs git branch -D'
# set the date of the last commit to the current date
alias gd='git commit --amend --no-edit --date "$(date)"'


# better history https://github.com/hanslub42/rlwrap
alias lein="rlwrap lein"

# simple python server, default port is 8000
alias pserver="python -m SimpleHTTPServer"

# returns my default IP addressss
alias myIp="ifconfig en0 inet | awk '/inet/{print \$2}'"

# docker psql
alias psql='docker run -it --rm --network="host" postgres:alpine psql "$@"'

# haskell
alias runhaskell='stack runhaskell'
alias ghc='stack exec ghc --'
alias ghci='stack exec ghci --'

# kafka client
alias kafka-client='docker run -it --rm --network="host" -w /opt/kafka_2.11-0.10.1.0/bin spotify/kafka /bin/bash'

# browser-sync - body tag must be present!!!
alias browser-sync='docker run --rm -dt --name browser-sync -p 3000:3000 -v $(PWD):/source -w /source ustwo/browser-sync start --server --files "./**" --"." && open http://localhost:3000'

# copy / paste to clipboard from shell
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"

alias k=kubectl
