from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence, InstallResultType, install_block
from installman import installer

HERE = Path(__file__).parent
HOME = Path.home()

SSH_MULTIPLEXING_FENCE = CodeFence(
    start="### SSH MULTIPLEXING ###",
    end="### SSH MULTIPLEXING ###",
)


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
        print(f"run with {result.edit_flag_name} to do this automatically")
        print(result.block_text)
        if result.existing_block_text:
            print(f"\n# This would replace the existing block:")
            print(result.existing_block_text)
    elif result.type == InstallResultType.INSTALLED:
        print(f"added to the end of your {result.target_path}:")
        print(result.block_text)


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

    result = install_block(
        fence=SSH_MULTIPLEXING_FENCE,
        source=HERE / "multiplexing",
        target_path=ssh_config,
        existing_content=existing_config,
        edit=args.edit_config,
        replace=args.replace,
        config_name="SSH config",
        edit_flag_name="--edit-config",
    )
    print_install_result(result)


@install_ssh.parser
def setup_ssh_args(parser: ArgumentParser):
    _ = parser.add_argument(
        "--edit-config",
        help="whether to modify the SSH config file",
        action="store_true",
    )
    _ = parser.add_argument(
        "--replace",
        help="whether to replace existing SSH multiplexing config",
        action="store_true",
    )
