which rustup || (brew install rustup && rustup default stable)
rustup-init -y
../bin/install-fence --start "### RUST ###" --end "### RUST ###" ./rust-config.zsh ~/.zshrc
echo "^ ^ ^ Ignore the PATH related instructions"
echo "^ ^ ^ We are adding those for you :)"
./crates.sh
