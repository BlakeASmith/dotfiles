import subprocess
import sys
from argparse import ArgumentParser, Namespace
from pathlib import Path

fencing_path = Path(__file__).parent / "python/fencing"
sys.path.append(str(fencing_path))
from fencing import CodeFence, FencedBlock

HERE = Path(__file__).parent
HOME = Path.home()

KEYBINDINGS_FENCE = CodeFence(
    start="### KEYBINDINGS ###",
    end="### KEYBINDINGS ###",
)


def symlink_rec(source: Path, destination: Path, quiet: bool = False):
    """Recursively symlink all leaf files from source to destination.

    Creates directory structure in destination as needed, but only symlinks
    individual files, not directories.
    """
    if not destination.exists():
        destination.mkdir()

    if not source.is_dir() or not destination.is_dir():
        raise ValueError(f"{source} or {destination} is not a directory")

    for item in source.rglob("*"):
        if item.is_file():
            rel = item.relative_to(source)
            dest = destination / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            try:
                dest.symlink_to(item)
            except:
                if not quiet:
                    print(
                        f"- failed to symlink {item} to {dest} (probably already exists)"
                    )

            if not quiet:
                print(f"- symlinked {item} to {dest}")


def config_zsh(args: Namespace):
    rc_path = HOME / ".zshrc"
    rc_sh = rc_path.read_text()

    def install_block(
        fence: CodeFence, source: Path, replace: bool = False, edit: bool = True
    ):
        block = fence.find_blocks(source.read_text())[0]
        existing_blocks = fence.find_blocks(rc_sh)
        # expect zero or one existing_blocks
        if len(existing_blocks) > 1:
            print("\n...".join((block.text for block in existing_blocks)))
            raise ValueError(
                f"You .zshrc has two or more existing blocks matching the {fence}, I don't know what to do here"
            )

        if existing_blocks:
            if replace:
                _ = existing_blocks[0].replace(block.content, rc_path)
                print("replaced content with latest")
                print(block.content)
                return
            print(
                "you already have this config installed! Use --replace if you want to overwrite it"
            )
            print(existing_blocks[0].text)
            return

        if not edit:
            print("# add to your .zshrc")
            print("run with --edit-rc to do this automatically")
            print(block.text)
            return

        block.append_to(rc_path)
        print("added to the end of your .zshrc:")
        print(block.text)

    configs = {
        "keybindings": {"fence": KEYBINDINGS_FENCE, "source": HERE / "zsh/keybinds.sh"},
        "aliases": {
            "fence": CodeFence(start="### ALIAS ###", end="### ALIAS ###"),
            "source": HERE / "zsh/aliases.sh",
        },
    }

    if args.config == "all":
        for conf in configs.values():
            install_block(
                fence=conf["fence"],
                source=conf["source"],
                edit=args.edit_rc,
                replace=args.replace,
            )
        return

    conf = configs[args.config]
    install_block(
        fence=conf["fence"],
        source=conf["source"],
        edit=args.edit_rc,
        replace=args.replace,
    )


def config_nvim(args: Namespace):
    if args.mode == "all":
        nvim_path = HOME / ".config/nvim"
        all_path = HERE / "nvim"
        if args.symlink_dir:
            nvim_path.symlink_to(all_path)
            print(f"symlinked entire nvim config to {nvim_path}")
            return

        symlink_rec(all_path, nvim_path, quiet=False)
        return

    if not args.plugin:
        print("set --plugin option. Nothing else here yet")

    if args.plugin:
        plugins_path = HOME / ".config/nvim/lua/plugins"
        plugin_install_path = plugins_path / f"{args.plugin}.lua"
        plugin_impl_path = HERE / f"nvim/lua/plugins/{args.plugin}.lua"

        plugin_install_path.symlink_to(plugin_impl_path)
        print(f"created symlink from {plugin_impl_path} to {plugin_install_path}")


def config_lazygit(args: Namespace):
    # lazygit config direcotry will be in a differnet place depending on how it was installed
    # there is a -ucf option which allows changing it, but we can also just get the current one
    output = subprocess.check_output(["lazygit", "--print-config-dir"])
    target = Path(output.decode().strip()) / "config.yml"
    source = HERE / "lazygit/config.yml"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source)
    print(f"created symlink from {source} to {target}")


dispatch = {
    "zsh": config_zsh,
    "nvim": config_nvim,
    "lazygit": config_lazygit,
    "lg": config_lazygit,
}

if __name__ == "__main__":
    parser = ArgumentParser("dotfiles-installer")
    subparsers = parser.add_subparsers(dest="_program")

    zsh = subparsers.add_parser("zsh")
    _ = zsh.add_argument(
        "config", default="all", choices=["all", "keybindings", "aliases"]
    )
    _ = zsh.add_argument(
        "--edit-rc", help="whether to modify the zshrc file", action="store_true"
    )
    _ = zsh.add_argument(
        "--replace", help="whether to modify the zshrc file", action="store_true"
    )

    nvim = subparsers.add_parser("nvim")
    _ = nvim.add_argument("--plugin", choices=["tfling"], default=None)
    _ = nvim.add_argument(
        "--symlink-dir", default=None, action="store_true", help="don't use this"
    )
    _ = nvim.add_argument("mode", default="selective", choices=["selective", "all"])

    lazygit = subparsers.add_parser("lazygit", aliases=["lg"])

    args = parser.parse_args()

    if args._program not in dispatch:
        parser.print_help()
        exit(1)

    dispatch[args._program](args)
