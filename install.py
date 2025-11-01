import glob
import subprocess
import sys
from argparse import ArgumentParser, Namespace
from fileinput import hook_compressed
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

SSH_MULTIPLEXING_FENCE = CodeFence(
    start="### SSH MULTIPLEXING ###",
    end="### SSH MULTIPLEXING ###",
)

COMPLETIONS_FENCE = CodeFence(
    start="### COMPLETIONS ###",
    end="### COMPLETIONS ###",
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


def install_block(
    fence: CodeFence,
    source: Path,
    target_path: Path,
    existing_content: str,
    replace: bool = False,
    edit: bool = True,
    config_name: str = "config",
    edit_flag_name: str = "--edit",
):
    """Install a fenced block into a configuration file.

    Args:
        fence: CodeFence to identify the block
        source: Path to source file containing the block
        target_path: Path to target configuration file
        existing_content: Current content of the target file
        replace: Whether to replace existing block
        edit: Whether to actually edit the file (False = preview only)
        config_name: Name of config file for error messages
        edit_flag_name: Name of edit flag for prompt messages
    """
    block = fence.find_blocks(source.read_text())[0]
    existing_blocks = fence.find_blocks(existing_content)
    # expect zero or one existing_blocks
    if len(existing_blocks) > 1:
        print("\n...".join((block.text for block in existing_blocks)))
        raise ValueError(
            f"Your {config_name} has two or more existing blocks matching the {fence}, I don't know what to do here"
        )

    if existing_blocks:
        if replace:
            _ = existing_blocks[0].replace(block.content, target_path)
            print("replaced content with latest")
            print(block.content)
            return
        print(
            "you already have this config installed! Use --replace if you want to overwrite it"
        )
        print(existing_blocks[0].text)
        return

    if not edit:
        print(f"# add to your {target_path}")
        print(f"run with {edit_flag_name} to do this automatically")
        print(block.text)
        return

    block.append_to(target_path)
    print(f"added to the end of your {target_path}:")
    print(block.text)


def config_zsh(args: Namespace):
    rc_path = HOME / ".zshrc"
    # Read existing config if it exists
    rc_sh = ""
    if rc_path.exists():
        rc_sh = rc_path.read_text()

    configs = {
        "keybindings": {"fence": KEYBINDINGS_FENCE, "source": HERE / "zsh/keybinds.sh"},
        "aliases": {
            "fence": CodeFence(start="### ALIAS ###", end="### ALIAS ###"),
            "source": HERE / "zsh/aliases.sh",
        },
        "completions": {
            "fence": COMPLETIONS_FENCE,
            "source": HERE / "zsh/completions.sh",
        },
    }

    if args.config == "all":
        for conf in configs.values():
            install_block(
                fence=conf["fence"],
                source=conf["source"],
                target_path=rc_path,
                existing_content=rc_sh,
                edit=args.edit_rc,
                replace=args.replace,
                config_name=".zshrc",
                edit_flag_name="--edit-rc",
            )
        return

    conf = configs[args.config]
    install_block(
        fence=conf["fence"],
        source=conf["source"],
        target_path=rc_path,
        existing_content=rc_sh,
        edit=args.edit_rc,
        replace=args.replace,
        config_name=".zshrc",
        edit_flag_name="--edit-rc",
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


def config_ssh(args: Namespace):
    """Configure SSH multiplexing in ~/.ssh/config."""
    ssh_dir = HOME / ".ssh"
    ssh_config = ssh_dir / "config"
    sockets_dir = ssh_dir / "sockets"

    # Create .ssh directory if it doesn't exist
    ssh_dir.mkdir(mode=0o700, exist_ok=True)

    # Create sockets directory if it doesn't exist
    sockets_dir.mkdir(mode=0o700, exist_ok=True)
    print(f"created sockets directory: {sockets_dir}")

    # Read existing config if it exists
    existing_config = ""
    if ssh_config.exists():
        existing_config = ssh_config.read_text()

    install_block(
        fence=SSH_MULTIPLEXING_FENCE,
        source=HERE / "ssh/multiplexing",
        target_path=ssh_config,
        existing_content=existing_config,
        edit=args.edit_config,
        replace=args.replace,
        config_name="SSH config",
        edit_flag_name="--edit-config",
    )


def config_bin(args):
    target_bin = Path("~/.local/bin").expanduser()
    source_bin = HERE / "bin"

    if args.config[0] == "all":
        scripts = source_bin.glob("*")
    else:
        scripts = [source_bin / script for script in args.config]

    for source in scripts:
        (target_bin / source.name).symlink_to(source)


dispatch = {
    "zsh": config_zsh,
    "nvim": config_nvim,
    "lazygit": config_lazygit,
    "lg": config_lazygit,
    "ssh": config_ssh,
    "bin": config_bin,
}

if __name__ == "__main__":
    parser = ArgumentParser("dotfiles-installer")
    subparsers = parser.add_subparsers(dest="_program")

    zsh = subparsers.add_parser("zsh", help="install zsh config snippets")
    _ = zsh.add_argument(
        "config",
        default="all",
        choices=["all", "keybindings", "aliases", "completions"],
    )
    _ = zsh.add_argument(
        "--edit-rc", help="whether to modify the zshrc file", action="store_true"
    )
    _ = zsh.add_argument(
        "--replace", help="whether to modify the zshrc file", action="store_true"
    )

    nvim = subparsers.add_parser("nvim", help="install neovim config, or parts of it")
    _ = nvim.add_argument("--plugin", choices=["tfling"], default=None)
    _ = nvim.add_argument(
        "--symlink-dir", default=None, action="store_true", help="don't use this"
    )
    _ = nvim.add_argument("mode", default="selective", choices=["selective", "all"])

    lazygit = subparsers.add_parser(
        "lazygit", aliases=["lg"], help="link the lazygit config file"
    )

    ssh = subparsers.add_parser("ssh", help="add ssh configuration snippets")
    _ = ssh.add_argument(
        "--edit-config",
        help="whether to modify the SSH config file",
        action="store_true",
    )
    _ = ssh.add_argument(
        "--replace",
        help="whether to replace existing SSH multiplexing config",
        action="store_true",
    )

    bin = subparsers.add_parser(
        "bin", help="pick scripts from the bin to install. use 'all' to grab everything"
    )
    bin.add_argument(
        "config",
        nargs="+",
        choices=["all"] + list(p.name for p in (HERE / "bin").glob("*")),
    )
    args = parser.parse_args()

    if args._program not in dispatch:
        parser.print_help()
        exit(1)

    dispatch[args._program](args)
