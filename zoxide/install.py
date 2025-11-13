from argparse import ArgumentParser, Namespace
from pathlib import Path

from fencing import CodeFence, copy_block
from installman import SingleFileChange, confirm_brewed, installer

HERE = Path(__file__).parent
HOME = Path.home()

ZOXIDE_FENCE = CodeFence(
    start="### ZOXIDE ###",
    end="### ZOXIDE ###",
)


@installer("zoxide", help="install zoxide and configure shell integration")
def install_zoxide(args: Namespace):
    """Install zoxide and add initialization to .zshrc."""
    # Install zoxide if not already installed
    zoxide_path = confirm_brewed("zoxide", yes=args.yes)
    if not zoxide_path:
        print(
            "zoxide not available. Install zoxide first or use --yes to install automatically."
        )
        return

    # Read existing .zshrc if it exists
    rc_path = HOME / ".zshrc"
    if rc_path.exists():
        rc_sh = rc_path.read_text()
    else:
        rc_sh = ""

    # Add zoxide initialization to .zshrc
    before, after, changed = copy_block(
        fence=ZOXIDE_FENCE,
        source=HERE / "init.sh",
        existing_content=rc_sh,
        replace=args.replace,
    )
    
    if not changed:
        print(
            "zoxide config already installed! Use --replace if you want to overwrite it"
        )
        return
    
    change = SingleFileChange(before, after, rc_path)
    change.confirm(yes=args.yes)


@install_zoxide.parser
def setup_zoxide_args(parser: ArgumentParser):
    parser.add_argument(
        "--yes",
        help="automatically approve changes without prompting",
        action="store_true",
    )
    parser.add_argument(
        "--replace", help="whether to replace existing blocks", action="store_true"
    )
