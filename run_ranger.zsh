#/bin/zsh

run_ranger () {
  echo
  ranger --choosedir=$HOME/.rangerdir < $TTY
  LASTDIR=$(< $HOME/.rangerdir)
  cd "$LASTDIR"
  zle accept-line 
}
zle -N run_ranger
  bindkey '^f' run_ranger
