Now I'm using zsh and [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh).

* Install via
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
* Install font [Source Code Pro + Font Awesome](https://github.com/Falkor/dotfiles/blob/master/fonts/SourceCodePro%2BPowerline%2BAwesome%2BRegular.ttf)
* Choose corrent font in Terminal > Preferences > Profiles
* Install powerlevel10k
```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
* Then edit your `~/.zshrc` and set `ZSH_THEME="powerlevel10k/powerlevel10k"`.
* To configure run `p10k configure` or `vim ~/.p10k.zsh`

* Copy and add run_ranger to `.zshrc`. To change ranger color run `ranger --copy-config=all` go to `~/.config/ranger/rc.conf` and change colorscheme to snow. 

* fzf
```
brew install fzf
# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install
```

* gpg
```
brew install gpg2
```
To test gpg
```
echo "test" | gpg --clearsign
```
If needed install and configure `pinentry-mac` too.

When I was using [bash-it](https://github.com/Bash-it/bash-it).

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

[k9s](https://k9scli.io/) is great tool for K8s
