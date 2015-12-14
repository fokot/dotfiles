. ~/.profile
alias cdd='cd /Users/Frantisek/Downloads'
alias gf='git flow'
alias gff='git flow feature'
alias ll='ls -AFGhl'

# readline variables and bindings
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set visible-stats on'
bind 'set skip-completed-text on'

alias gl='git log --graph --pretty="format:%C(yellow)%h%Cblue%d%Creset %s %C(white)"'

# doesnt work on Mac
#bind 'set completion-prefix-display-length 2'
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"

# set java version here
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

# better history https://github.com/hanslub42/rlwrap
alias lein="rlwrap lein"

# the fuck?? (https://github.com/nvbn/thefuck)
eval "$(thefuck --alias)"
