from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence, copy_block
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
            change = copy_block(
                fence=conf["fence"],
                source=conf["source"],
                target_path=rc_path,
                existing_content=rc_sh,
                replace=args.replace,
                config_name=".zshrc",
            )
            if change is None:
                print("you already have this config installed! Use --replace if you want to overwrite it")
                continue
            
            print(f"# {change.describe()}")
            print(change.pretty_diff())
            
            if args.yes:
                change.apply()
                print(f"Applied: {change.describe()}")
            else:
                response = input("Apply this change? [y/N]: ").strip().lower()
                if response == "y":
                    change.apply()
                    print(f"Applied: {change.describe()}")
                else:
                    print("Skipped.")
        return

    conf = configs[args.config]
    change = copy_block(
        fence=conf["fence"],
        source=conf["source"],
        target_path=rc_path,
        existing_content=rc_sh,
        replace=args.replace,
        config_name=".zshrc",
    )
    if change is None:
        print("you already have this config installed! Use --replace if you want to overwrite it")
        return
    
    # Always show the diff
    print(f"# {change.describe()}")
    print(change.pretty_diff())
    print()  # Blank line for readability
    
    if args.yes:
        change.apply()
        print(f"Applied: {change.describe()}")
    else:
        response = input("Apply this change? [y/N]: ").strip().lower()
        if response == "y":
            change.apply()
            print(f"Applied: {change.describe()}")
        else:
            print("Skipped.")


@install_zsh.parser
def setup_zsh_args(parser: ArgumentParser):
    _ = parser.add_argument(
        "--yes", help="automatically approve changes without prompting", action="store_true"
    )
    _ = parser.add_argument(
        "--replace", help="whether to replace existing blocks", action="store_true"
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
