
### RUST ###
# Add rustup completions to fpath
if [ -d "/opt/homebrew/opt/rustup/share/zsh/site-functions" ]; then
  fpath=("$fpath[@]" "/opt/homebrew/opt/rustup/share/zsh/site-functions")
fi

. "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:$PATH"
### RUST ###

