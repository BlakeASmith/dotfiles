from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence, InstallResultType, install_block
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


def print_install_result(result) -> None:
    """Print the result of an install_block operation."""
    if result.type == InstallResultType.REPLACED:
        print("replaced content with latest")
        print(result.block_content)
    elif result.type == InstallResultType.ALREADY_EXISTS:
        print(
            "you already have this config installed! Use --replace if you want to overwrite it"
        )
        print(result.existing_block_text)
    elif result.type == InstallResultType.PREVIEW:
        print(f"# add to your {result.target_path}")
        print("run with --edit-rc to do this automatically")
        print(result.block_text)
        if result.existing_block_text:
            print(f"\n# This would replace the existing block:")
            print(result.existing_block_text)
    elif result.type == InstallResultType.INSTALLED:
        print(f"added to the end of your {result.target_path}:")
        print(result.block_text)


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
            result = install_block(
                fence=conf["fence"],
                source=conf["source"],
                target_path=rc_path,
                existing_content=rc_sh,
                edit=args.edit_rc,
                replace=args.replace,
                config_name=".zshrc",
            )
            print_install_result(result)
        return

    conf = configs[args.config]
    result = install_block(
        fence=conf["fence"],
        source=conf["source"],
        target_path=rc_path,
        existing_content=rc_sh,
        edit=args.edit_rc,
        replace=args.replace,
        config_name=".zshrc",
    )
    print_install_result(result)


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
