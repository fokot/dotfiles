Now I'm using [bash-it](https://github.com/Bash-it/bash-it).

I enabled there competions ```bash-it show completion | grep '\[x\]'```
```
bash-it               [x]     
dirs                  [x]     
docker                [x]     
git                   [x]     
git_flow              [x]     
ssh                   [x]     
system                [x]
```

So
* .bash_profile is not needed anymore
* .bash-it/aliases/custom.aliases.bash is used for my own aliases instead
* .profile is still needed for variables


And these are the configuration files to it. I have also enabled [thefuck](https://github.com/nvbn/thefuck) bash alias, git, git-flow and dirs completitions which are parts of bash-it.

Put the files in correct bash-it folders.

[rlwrap](https://github.com/hanslub42/rlwrap) is amazing extension what fixes problem with pressing arrows in some shells. It can be added to a shell like this
```alias lein="rlwrap lein"```
