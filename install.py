import sys
sys.path.append("../python")
from argparse import ArgumentParser, Namespace
from pathlib import Path
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

    rc_path = HOME/".zshrc"
    rc_sh = rc_path.read_text()

    blocks = KEYBINDINGS_FENCE.find_blocks(rc_sh)

    # expect zero or one blocks
    if len(blocks) > 1:
        print(blocks)
        raise ValueError("You .zshrc has two KEYBINDINGS blocks, I don't know what to do here")

    if blocks:
        print("you already have this config installed")
        print(blocks[0])
        return

    if args.edit_rc:
        updated= "\n".join([rc_sh, keybinds_sh])
        _ = rc_path.write_text(updated)
        print("added to the end of your .zshrc:")
        print("\n".join("  " + line for line in (keybinds_sh.splitlines())))
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

