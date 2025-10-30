# Blake's Dotfiles

Hi! Welcome to my dotfiles repo


These are my personal configurations --- feel free to copy/clone but please do not depend on this repo directly!


## Setup

Many people use a git bare repo, mise, or other dotflies management tool. For me, I don't strictly want to install all dotfiles in their exact format on
every computer that I use. For any specific file, such as `.zshrc`, I always have some specific config lines for the computer that I am using which I 
don't always want to have everywhere. On my work machine, I have work-specific config lines. On my persional machine I have config lines which I don't want
to use on my work matchine. On a random linux box in the cloud I really don't need everything. So, instead of copying every dotfile in full, this repo
has a `install.py` python script which has custom installation logic for each program, or a single "feature" accross multiple programs.

For example, to install my preferred keybindings for `.zsh` on a new machine I would run

```sh
python3 install.py zsh keybindings --edit-rc --replace
```
```
added to the end of your .zshrc:
### KEYBINDINGS ###
# ctrl-n/ctrl-p for next/previous command
bindkey "^p" up-line-or-search
bindkey "^n" down-line-or-search
### KEYBINDINGS ###
``

Or, If I want to be more cautious, I can skip the `--edit-rc` flag and the script will print the config out. The 
`--replace` will overwrite the content of the block with the latest version in the case the block is already
present in the `.zshrc` file. Without that flag, the script will not modify the existing block and will just exit.


To enable this, I wrote a small library `fencing` which handles adding, removing, or updating **sections** of a file delimited by start/end patterns. Each different section of configuration which I want to be independantly install-able is surrounded in some
kind of block delimiter, usually a comment like `### SECTION ###`. 


## Configs

```sh
# all nvim configuration files
python3 install.py nvim all

# all nvim configuration, but installing by symlink at the root directory level
python3 install.py nvim all --symlink-dir

# specific plugin only ([tfling.nvim](https://github.com/BlakeASmith/tfling.nvim)) as an example
python3 install.py nvim selective --plugin tfling
```


I am still in the process of slowly migrating everything over to this format, so feel free to check back in a month or 2 and there will probably be more here.

if you like this alterative approach to dotfiles management, please let me know by filing an issue on this repo or
reaching out directly (to blakeinvictoria@gmail.com). If there is enough intrest I will consider creating a pip 
installable package to enable this workflow for other people! 
