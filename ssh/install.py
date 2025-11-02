from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence
from installman import installer

HERE = Path(__file__).parent
HOME = Path.home()

SSH_MULTIPLEXING_FENCE = CodeFence(
    start="### SSH MULTIPLEXING ###",
    end="### SSH MULTIPLEXING ###",
)


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

    install_block(
        fence=SSH_MULTIPLEXING_FENCE,
        source=HERE / "multiplexing",
        target_path=ssh_config,
        existing_content=existing_config,
        edit=args.edit_config,
        replace=args.replace,
        config_name="SSH config",
        edit_flag_name="--edit-config",
    )


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
