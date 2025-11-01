# wrapper functions for dotfiles/bin scripts
# depends on scripts being on the PATH

### SCRIPT WRAPPERS ###
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
### SCRIPT WRAPPERS ###
