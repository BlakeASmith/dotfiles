# wrapper functions for dotfiles/bin scripts
# depends on scripts being on the PATH

### BIN WRAPPERS ###
function proj {
    cd "$(list-git-repos)"
}
function projn {
    nvim "$(list-git-repos)"
}
function projc {
    cursor "$(list-git-repos)"
}
function projdo {
    cd "$(list-git-repos)"
    $@
}
function projt {
    projdo tree -L 2
}
function projgo {
    projt
}
function projtree {
    projt
}
function ptree {
    projt
}
# Technically not a bin wrapper -- but who cares
function dotinstall {
    python3 install.py $@
    source ~/.zshrc
}
function di {
    dotinstall $@
}
function die {
    dotinstall zsh --edit-rc --replace all
}
### BIN WRAPPERS ###
