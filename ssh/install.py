import os
from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence, copy_block
from installman import SingleFileChange, confirm, confirm_dir, confirm_file, dependency, installer

HERE = Path(__file__).parent
HOME = Path.home()

SSH_MULTIPLEXING_FENCE = CodeFence(
    start="### SSH MULTIPLEXING ###",
    end="### SSH MULTIPLEXING ###",
)


@installer("ssh", help="add ssh configuration snippets")
def install_ssh(args: Namespace):
    """Configure SSH multiplexing in ~/.ssh/config."""
    if not args.no_install:
        brew = dependency("brew")
        os.system(f"{brew} install autossh")

    ssh_dir = HOME / ".ssh"
    ssh_config = ssh_dir / "config"
    sockets_dir = ssh_dir / "sockets"

    _ = confirm_dir(ssh_dir, yes=args.yes)
    _ = confirm_dir(sockets_dir, yes=args.yes)

    if not confirm_file(ssh_config):
        print("OK, aborting then :p")
        return

    existing_config = ssh_config.read_text()

    before, after, changed = copy_block(
        fence=SSH_MULTIPLEXING_FENCE,
        source=HERE / "multiplexing",
        existing_content=existing_config,
        replace=True,
    )

    SingleFileChange(before, after, ssh_config).confirm(
        yes=args.yes,
    )


@install_ssh.parser
def setup_ssh_args(parser: ArgumentParser):
    _ = parser.add_argument(
        "--yes",
        help="automatically approve changes without prompting",
        action="store_true",
    )
    _ = parser.add_argument(
        "--no-install",
        help="skip brew install of autossh",
        action="store_true",
    )
