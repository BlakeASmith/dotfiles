from argparse import ArgumentParser, Namespace
from pathlib import Path

from installman import confirm_symlink, installer

HERE = Path(__file__).parent
HOME = Path.home()


@installer("karabiner", help="Link karabiner.json file")
def install_karabiner(args: Namespace):
    confirm_symlink(
        HERE / "karabiner.json",
        HOME / ".config/karabiner/karabiner.json",
        yes=args.yes,
    )


@install_karabiner.parser
def karabiner_parser(_parser: ArgumentParser):
    _parser.add_argument("--yes")
