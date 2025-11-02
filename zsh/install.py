from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence
from installman import installer

HERE = Path(__file__).parent
HOME = Path.home()

KEYBINDINGS_FENCE = CodeFence(
    start="### KEYBINDINGS ###",
    end="### KEYBINDINGS ###",
)

COMPLETIONS_FENCE = CodeFence(
    start="### COMPLETIONS ###",
    end="### COMPLETIONS ###",
)

BIN_WRAPPERS_FENCE = CodeFence(
    start="### BIN WRAPPERS ###",
    end="### BIN WRAPPERS ###",
)

configs = {
    "keybindings": {
        "fence": KEYBINDINGS_FENCE,
        "source": HERE / "keybinds.sh",
        "help": "zsh shell keybinds (for command line)",
    },
    "aliases": {
        "fence": CodeFence(start="### ALIAS ###", end="### ALIAS ###"),
        "source": HERE / "aliases.sh",
        "help": "shell aliases",
    },
    "completions": {
        "fence": COMPLETIONS_FENCE,
        "source": HERE / "completions.sh",
        "help": "zsh completion configuration",
    },
    "wrappers": {
        "fence": BIN_WRAPPERS_FENCE,
        "source": HERE / "bin_wrappers.sh",
        "help": "wrappers for scripts; use `python3 install.py bin all` first",
    },
}


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


@installer("zsh", help="install zsh config snippets")
def install_zsh(args: Namespace):
    rc_path = HOME / ".zshrc"
    # Read existing config if it exists
    if rc_path.exists():
        rc_sh = rc_path.read_text()
    else:
        rc_sh = ""

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


@install_zsh.parser
def setup_zsh_args(parser: ArgumentParser):
    _ = parser.add_argument(
        "--edit-rc", help="whether to modify the zshrc file", action="store_true"
    )
    _ = parser.add_argument(
        "--replace", help="whether to modify the zshrc file", action="store_true"
    )

    parser_configs = parser.add_subparsers(
        dest="config",
        title="Select what to install, use 'all' for everything 🚀",
        required=True,
    )
    for k, v in configs.items():
        _help: str = v.get("help") or ""  # pyright: ignore[reportAssignmentType]
        parser_configs.add_parser(k, help=_help)
    parser_configs.add_parser("all", help="The Kitchen Sink")
