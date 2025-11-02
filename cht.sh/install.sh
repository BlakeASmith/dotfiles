PATH_DIR="$HOME/.local/bin"  # or another directory on your $PATH
mkdir -p "$PATH_DIR"
curl https://cht.sh/:cht.sh > "$PATH_DIR/cht.sh"
chmod +x "$PATH_DIR/cht.sh"
curl https://cheat.sh/:zsh > ~/.zsh.d/_cht
echo 'fpath=(~/.zsh.d/ $fpath)' >> ~/.zshrc
