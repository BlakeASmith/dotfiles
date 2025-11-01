### ALIAS ###
alias lg="lazygit --sm half"
alias lazygi="lazygit --sm half"
alias lazygt="lazygit --sm half"
alias lazgit="lazygit --sm half"
alias laygit="lazygit --sm half"
alias lh="lazygit --sm half"
alias dot="cd ~/dotfiles/"
function zsh_refresh {
  cd ~/dotfiles
  python3 install.py zsh all --edit-rc --replace
  source ~/.zshrc
}
### ALIAS ###
