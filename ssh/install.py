from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence, copy_block
from installman import installer

HERE = Path(__file__).parent
HOME = Path.home()

SSH_MULTIPLEXING_FENCE = CodeFence(
    start="### SSH MULTIPLEXING ###",
    end="### SSH MULTIPLEXING ###",
)


@installer("ssh", help="add ssh configuration snippets")
def install_ssh(args: Namespace):
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

    change = copy_block(
        fence=SSH_MULTIPLEXING_FENCE,
        source=HERE / "multiplexing",
        target_path=ssh_config,
        existing_content=existing_config,
        replace=args.replace,
        config_name="SSH config",
    )
    if change is None:
        print("you already have this config installed! Use --replace if you want to overwrite it")
        return
    
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


@install_ssh.parser
def setup_ssh_args(parser: ArgumentParser):
    _ = parser.add_argument(
        "--yes",
        help="automatically approve changes without prompting",
        action="store_true",
    )
    _ = parser.add_argument(
        "--replace",
        help="whether to replace existing SSH multiplexing config",
        action="store_true",
    )
