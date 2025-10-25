import sys
from argparse import ArgumentParser, Namespace
from pathlib import Path
fencing_path =Path(__file__).parent/"python/fencing"
sys.path.append(str(fencing_path))
from fencing import CodeFence

HERE = Path(__file__).parent
HOME = Path.home()

KEYBINDINGS_FENCE = CodeFence(
    start="### KEYBINDINGS ###",
    end="### KEYBINDINGS ###",
)

def config_zsh(args: Namespace):
    keybinds_path = HERE/'zsh/keybinds.sh'
    keybinds_sh = keybinds_path.read_text()
    keybinds_block = KEYBINDINGS_FENCE.find_blocks(keybinds_sh)[0]

    rc_path = HOME/".zshrc"
    rc_sh = rc_path.read_text()

    existing_blocks = KEYBINDINGS_FENCE.find_blocks(rc_sh)

    # expect zero or one existing_blocks
    if len(existing_blocks) > 1:
        print("\n...".join((block.text for block in existing_blocks)))
        raise ValueError("You .zshrc has two KEYBINDINGS existing_blocks, I don't know what to do here")

    if existing_blocks:
        print("you already have this config installed")
        print(existing_blocks[0].text)
        return

    if args.edit_rc:
        keybinds_block.append_to(rc_path)
        print("added to the end of your .zshrc:")
        print(keybinds_block.text)
        return

    print("# add to your .zshrc")
    print("run with --edit-rc to do this automatically")
    print(keybinds_sh)


dispatch = {
    "zsh": config_zsh
}

if __name__ == '__main__':
    parser = ArgumentParser("dotfiles-installer")
    subparsers = parser.add_subparsers(dest="_program")
    zsh = subparsers.add_parser("zsh")
    _ = zsh.add_argument("--edit-rc", help="whether to modify the zshrc file", action="store_true")

    args= parser.parse_args()

    if args._program not in dispatch:
        parser.print_help()
        exit(1)

    dispatch[args._program](args)

