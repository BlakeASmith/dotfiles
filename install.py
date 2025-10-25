from argparse import ArgumentParser, Namespace
from pathlib import Path

HERE = Path(__file__).parent
HOME = Path.home()

def config_zsh(args: Namespace):
    keybinds_path = HERE/'zsh/keybinds.sh'
    keybinds_sh = keybinds_path.read_text()

    if args.edit_rc:
        rc_path = HOME/".zshrc"
        rc_sh = rc_path.read_text()
        if keybinds_sh in rc_sh:
            print("you already have this config installed")
            return
        updated= "\n".join([rc_sh, keybinds_sh])
        _ = rc_path.write_text(updated)
        print("added to the end of your .zshrc:")
        print("".join("  " + line for line in (rc_sh.splitlines())))
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

